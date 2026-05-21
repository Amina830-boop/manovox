import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'organizer_login_page.dart';

class OrganizerResetPasswordPage extends StatefulWidget {
  final String email;
  final String code;

  const OrganizerResetPasswordPage({
    super.key,
    required this.email,
    required this.code,
  });

  @override
  State<OrganizerResetPasswordPage> createState() =>
      _OrganizerResetPasswordPageState();
}

class _OrganizerResetPasswordPageState
    extends State<OrganizerResetPasswordPage> {
  final _newPasswordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;
  bool _obscure1 = true;
  bool _obscure2 = true;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _reset() async {
    if (_newPasswordController.text.isEmpty) {
      _showSnackBar('Please enter a new password');
      return;
    }

    if (_newPasswordController.text != _confirmController.text) {
      _showSnackBar('Passwords do not match');
      return;
    }   

    if (_newPasswordController.text.length < 8) {
      _showSnackBar('Password must be at least 8 characters');
      return;
    }

    setState(() => _isLoading = true);

    final result = await AuthService.verifyResetCode(
      email: widget.email,
      code: widget.code,
      newPassword: _newPasswordController.text,
    );

    setState(() => _isLoading = false);

    if (result['success'] && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset successfully!'),
          backgroundColor: Color(0xFF355E3B),
        ),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const OrganizerLoginPage()),
        (route) => false,
      );
    } else {
      if (mounted) {
        _showSnackBar(result['message'] ?? 'Reset failed');
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF355E3B)),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Organizer Portal',
          style: TextStyle(
            color: Color(0xFF355E3B),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),

            // ── Header icon ──
            Center(
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFF355E3B).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock_outline,
                    color: Color(0xFF355E3B), size: 36),
              ),
            ),

            const SizedBox(height: 24),

            const Center(
              child: Text(
                'New Password',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ),

            const SizedBox(height: 8),

            const Center(
              child: Text(
                'Enter your new password below',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF757575),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // ── New Password ──
            const Text(
              'New Password',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            _buildPasswordField(
              controller: _newPasswordController,
              hint: 'Enter new password',
              obscure: _obscure1,
              onToggle: () => setState(() => _obscure1 = !_obscure1),
            ),

            const SizedBox(height: 20),

            // ── Confirm Password ──
            const Text(
              'Confirm Password',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            _buildPasswordField(
              controller: _confirmController,
              hint: 'Repeat new password',
              obscure: _obscure2,
              onToggle: () => setState(() => _obscure2 = !_obscure2),
            ),

            const SizedBox(height: 40),

            // ── Reset Button ──
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _reset,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF355E3B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        'Reset Password',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: Color(0xFFBDBDBD),
          fontSize: 14,
        ),
        prefixIcon: const Icon(
          Icons.lock_outline,
          color: Color(0xFF424242),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscure
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: const Color(0xFF424242),
          ),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: const Color(0xFFECF5EC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(
            color: Color(0xFF355E3B),
            width: 1.5,
          ),
        ),
      ),
    );
  }
}