import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart'; // Added for debugPrint
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl =
      'https://nonconcluding-vanesa-noncredulously.ngrok-free.dev';

  // ───────── 1. TOKEN MANAGEMENT ─────────

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
    debugPrint("Token Saved: $token");
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  static Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
  }

  static Future<Map<String, String>> _getAuthHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Token $token',
      'ngrok-skip-browser-warning': 'true',
    };
  }

  // ───────── 2. AUTHENTICATION ─────────

  static Future<Map<String, dynamic>> signUp({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String password,
    required int age,
  }) async {
    final body = jsonEncode({
      'first_name': firstName,
      'last_name': lastName,
      'username': username,
      'email': email,
      'password': password,
      're_password': password,
      'age': age,
    });
    return _postWithoutToken('$baseUrl/auth/users/', body);
  }

  static Future<Map<String, dynamic>> signUpOrganizer({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String password,
    required String organizationName,
    required String phoneNumber,
  }) async {
    final body = jsonEncode({
      'first_name': firstName,
      'last_name': lastName,
      'username': username,
      'email': email,
      'password': password,
      're_password': password,
      'role': 'admin',
      'organization_name': organizationName,
      'phone_number': phoneNumber,
    });
    return _postWithoutToken('$baseUrl/auth/users/', body);
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/token/login/'),
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true'
        },
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['auth_token'] != null) {
          await saveToken(data['auth_token']);
        }
        return {'success': true};
      }
      return {'success': false, 'message': 'Invalid email or password.'};
    } catch (e) {
      return {'success': false, 'message': 'Connection error.'};
    }
  }

  static Future<void> logout() async {
    try {
      final headers = await _getAuthHeaders();
      await http.post(
        Uri.parse('$baseUrl/auth/token/logout/'),
        headers: headers,
      );
    } catch (e) {
      debugPrint('Logout error: $e');
    } finally {
      await deleteToken();
    }
  }

  // ───────── 3. PROFILE ─────────

  static Future<Map<String, dynamic>?> getProfile() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/auth/users/me/'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>> deleteAccount() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/delete_account/'),
        headers: headers,
      );
      if (response.statusCode == 204 || response.statusCode == 200) {
        await deleteToken();
        return {'success': true};
      }
      return {'success': false, 'message': 'Failed to delete account.'};
    } catch (e) {
      return {'success': false, 'message': 'Connection error.'};
    }
  }

  // ───────── 4. EVENTS (ORGANIZER & USER) ─────────

  static Future<List<Map<String, dynamic>>> getEvents() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/deaf-hub/events/'),
        headers: {'ngrok-skip-browser-warning': 'true'},
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.map((e) => e as Map<String, dynamic>).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> createEvent({
    required String title,
    required String description,
    required String date,
    required String location,
    String? imagePath,
  }) async {
    try {
      final token = await getToken();
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/deaf-hub/events/'),
      );
      request.headers.addAll({
        'Authorization': 'Token $token',
        'ngrok-skip-browser-warning': 'true',
      });
      request.fields.addAll({
        'title': title,
        'description': description,
        'date': date,
        'location': location,
      });
      if (imagePath != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', imagePath),
        );
      }
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true};
      }
      return {
        'success': false,
        'message': 'Error: ${response.body}'
      };
    } catch (e) {
      return {'success': false, 'message': 'Request failed.'};
    }
  }

  // ✅ ADDED: Update Event Method
  static Future<Map<String, dynamic>> updateEvent({
    required String id,
    required String title,
    required String description,
    required String date,
    required String location,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final body = jsonEncode({
        'title': title,
        'description': description,
        'date': date,
        'location': location,
      });

      final response = await http.put(
        Uri.parse('$baseUrl/api/deaf-hub/events/$id/'),
        headers: headers,
        body: body,
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        return {'success': true};
      }
      return {'success': false, 'message': response.body};
    } catch (e) {
      return {'success': false, 'message': 'Connection error.'};
    }
  }

  // ✅ ADDED: Delete Event Method
  static Future<Map<String, dynamic>> deleteEvent(String id) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/api/deaf-hub/events/$id/'),
        headers: headers,
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 204 || response.statusCode == 200) {
        return {'success': true};
      }
      return {'success': false, 'message': 'Failed to delete.'};
    } catch (e) {
      return {'success': false, 'message': 'Connection error.'};
    }
  }

  // ───────── 5. LEARNING & DICTIONARY ─────────

  static Future<List<Map<String, dynamic>>> getLetters() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/accounts/asl-letters/'),
        headers: headers,
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.map((e) => e as Map<String, dynamic>).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<String>> getCategories() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/accounts/categories/'),
        headers: headers,
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data.map((e) {
            if (e is String) return e;
            return (e['name'] ?? e['category'] ?? '').toString();
          }).where((s) => s.isNotEmpty).toList();
        }
      }
      return await _getCategoriesFromWords();
    } catch (e) {
      return await _getCategoriesFromWords();
    }
  }

  static Future<List<String>> _getCategoriesFromWords() async {
    try {
      final words = await getWords();
      final Set<String> unique = {};
      for (var item in words) {
        if (item['category'] != null && item['category'].toString().isNotEmpty) {
          unique.add(item['category'].toString());
        }
      }
      return unique.toList();
    } catch (e) {
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getWords({String? category}) async {
    try {
      final headers = await _getAuthHeaders();
      String url = '$baseUrl/accounts/sign_dictionary/';
      if (category != null) {
        url += '?category=${Uri.encodeComponent(category)}';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.map((e) => e as Map<String, dynamic>).toList();
      }
      return [];
    } catch (e) {
      debugPrint("Error fetching words: $e");
      return [];
    }
  }

  // ───────── 6. RESET & VERIFICATION ─────────

  static Future<Map<String, dynamic>> sendResetCode({required String email}) async {
    final body = jsonEncode({'email': email});
    return _postWithoutToken('$baseUrl/api/custom-reset/send-code/', body);
  }

  static Future<Map<String, dynamic>> verifyResetCode({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    final body = jsonEncode({
      'email': email,
      'code': code,
      'new_password': newPassword
    });
    return _postWithoutToken('$baseUrl/api/custom-reset/verify-code/', body);
  }

  static Future<Map<String, dynamic>> sendVerificationCode({required String email}) async {
    final body = jsonEncode({'email': email});
    return _postWithoutToken('$baseUrl/accounts/custom-verify/send-code/', body);
  }

  static Future<Map<String, dynamic>> verifyEmailCode({
    required String email,
    required String code,
  }) async {
    final body = jsonEncode({'email': email, 'code': code});
    return _postWithoutToken('$baseUrl/accounts/custom-verify/verify-email/', body);
  }

  // ───────── HELPER ─────────

  static Future<Map<String, dynamic>> _postWithoutToken(String url, String body) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true'
        },
        body: body,
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true};
      }
      return {'success': false, 'message': response.body};
    } catch (e) {
      return {'success': false, 'message': 'Connection error.'};
    }
  }
}