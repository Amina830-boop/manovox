import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'organizer_code_confirmation_page.dart';

class OrganizerSignUpPage extends StatefulWidget {
  const OrganizerSignUpPage({super.key});

  @override
  State<OrganizerSignUpPage> createState() => _OrganizerSignUpPageState();
}

class _OrganizerSignUpPageState extends State<OrganizerSignUpPage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _orgNameController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _orgNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _usernameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _orgNameController.text.isEmpty) {
      _showSnackBar('Please fill all required fields');
      return;
    }

    if (_passwordController.text.length < 8) {
      _showSnackBar('Password must be at least 8 characters');
      return;
    }

    setState(() => _isLoading = true);

    final result = await AuthService.signUpOrganizer(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      organizationName: _orgNameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      if (mounted) {
        // ✅ Navigate to code confirmation for email verification
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OrganizerCodeConfirmationPage(
              email: _emailController.text.trim(),
              isPasswordReset: false,
            ),
          ),
        );
      }
    } else {
      _showSnackBar(result['message'] ?? 'Sign up failed');
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF424242)),
                onPressed: () => Navigator.pop(context),
              ),

              const SizedBox(height: 16),

              const Center(
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Color(0xFF355E3B),
                  child: Icon(Icons.admin_panel_settings,
                      color: Colors.white, size: 30),
                ),
              ),

              const SizedBox(height: 16),

              const Center(
                child: Text(
                  'Create Organizer Account',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A)),
                ),
              ),

              const SizedBox(height: 8),

              const Center(
                child: Text(
                  'Manage and publish sign language events',
                  style: TextStyle(fontSize: 13, color: Color(0xFF757575)),
                ),
              ),

              const SizedBox(height: 30),

              _buildField(_firstNameController, 'First Name',
                  'Enter first name', Icons.badge_outlined),
              const SizedBox(height: 16),
              _buildField(_lastNameController, 'Last Name', 'Enter last name',
                  Icons.badge_outlined),
              const SizedBox(height: 16),
              _buildField(_usernameController, 'Username', 'Choose username',
                  Icons.person_outline),
              const SizedBox(height: 16),
              _buildField(
                _emailController,
                'Email',
                'Enter email',
                Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              _buildField(
                _orgNameController,
                'Organization Name *',
                'Enter organization name',
                Icons.business_outlined,
              ),
              const SizedBox(height: 16),
              _buildField(
                _phoneController,
                'Phone Number',
                'Enter phone number',
                Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              // ── Password ──
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Password',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A)),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: 'Min 8 chars, Uppercase, Number, @!#',
                      hintStyle: const TextStyle(
                          color: Color(0xFFBDBDBD), fontSize: 13),
                      prefixIcon: const Icon(Icons.lock_outline,
                          color: Color(0xFF424242)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: const Color(0xFF424242),
                        ),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
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
                            color: Color(0xFF355E3B), width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF355E3B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5))
                      : const Text(
                          'Create Account',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    String hint,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A))),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFBDBDBD)),
            prefixIcon: Icon(icon, color: const Color(0xFF424242)),
            filled: true,
            fillColor: const Color(0xFFECF5EC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide:
                  const BorderSide(color: Color(0xFF355E3B), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}