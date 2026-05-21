import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'organizer_login_page.dart';

class OrganizerProfilePage extends StatefulWidget {
  const OrganizerProfilePage({super.key});

  @override
  State<OrganizerProfilePage> createState() => _OrganizerProfilePageState();
}

class _OrganizerProfilePageState extends State<OrganizerProfilePage> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final data = await AuthService.getProfile();
      setState(() {
        _userData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load profile. Please try again.';
        _isLoading = false;
      });
    }
  }

  String _safeString(dynamic value, {String fallback = 'N/A'}) {
    if (value == null) return fallback;
    final s = value.toString().trim();
    return s.isEmpty ? fallback : s;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Color(0xFF355E3B),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () async {
              await AuthService.logout();
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const OrganizerLoginPage()),
                );
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF355E3B)))
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 48),
                      const SizedBox(height: 12),
                      Text(_errorMessage!,
                          style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchProfile,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF355E3B)),
                        child: const Text('Retry',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchProfile,
                  color: const Color(0xFF355E3B),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // ── Avatar ──
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: const Color(0xFF355E3B),
                          child: Text(
                            _userData?['first_name']?.toString().isNotEmpty ==
                                    true
                                ? _userData!['first_name']
                                    .toString()[0]
                                    .toUpperCase()
                                : 'O',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        Text(
                          '${_safeString(_userData?['first_name'], fallback: '')} ${_safeString(_userData?['last_name'], fallback: '')}'
                              .trim(),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),

                        const SizedBox(height: 4),

                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF355E3B).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Organizer',
                            style: TextStyle(
                              color: Color(0xFF355E3B),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ── Info Card ──
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _infoTile(
                                Icons.email_outlined,
                                'Email',
                                _safeString(_userData?['email']),
                              ),
                              const Divider(height: 1, indent: 56),
                              _infoTile(
                                Icons.alternate_email,
                                'Username',
                                '@${_safeString(_userData?['username'])}',
                              ),
                              const Divider(height: 1, indent: 56),
                              _infoTile(
                                Icons.business_outlined,
                                'Organization',
                                // ✅ FIX: try multiple possible key names
                                _safeString(
                                  _userData?['organization_name'] ??
                                      _userData?['organizationName'] ??
                                      _userData?['organization'],
                                ),
                              ),
                              const Divider(height: 1, indent: 56),
                              _infoTile(
                                Icons.phone_outlined,
                                'Phone',
                                // ✅ FIX: try multiple possible key names
                                _safeString(
                                  _userData?['phone_number'] ??
                                      _userData?['phoneNumber'] ??
                                      _userData?['phone'],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ── Debug helper (remove in production) ──
                        // Uncomment to see raw API keys if fields still appear N/A:
                        // Container(
                        //   padding: const EdgeInsets.all(12),
                        //   decoration: BoxDecoration(
                        //     color: Colors.yellow.shade100,
                        //     borderRadius: BorderRadius.circular(8),
                        //   ),
                        //   child: Text(
                        //     'Raw keys: ${_userData?.keys.toList()}',
                        //     style: const TextStyle(fontSize: 11),
                        //   ),
                        // ),

                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF355E3B)),
      title: Text(label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1A1A1A),
        ),
      ),
    );
  }
}