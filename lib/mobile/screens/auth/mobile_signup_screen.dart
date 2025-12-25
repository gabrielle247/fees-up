import 'package:fees_up/data/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';

class MobileSignupScreen extends ConsumerStatefulWidget {
  const MobileSignupScreen({super.key});

  @override
  ConsumerState<MobileSignupScreen> createState() => _MobileSignupScreenState();
}

class _MobileSignupScreenState extends ConsumerState<MobileSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _schoolNameController = TextEditingController();
  bool _isLoading = false;
  bool _isObscure = true;

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      // Call the specialized "School Setup" logic
      await ref.read(authRepositoryProvider).signUpWithSchool(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        schoolName: _schoolNameController.text.trim(),
      );
      // Router will handle redirect once user is detected
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.errorRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Gradient Background as per image
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F172A), Color(0xFF020617)], // Deep Navy to Black
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  // Icon / Logo
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F3946), // Dark Teal/Green bg
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: const Icon(Icons.security, size: 32, color: AppColors.successGreen),
                  ),
                  const SizedBox(height: 24),
                  
                  // Headings
                  Text("Setup School", 
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white, fontWeight: FontWeight.bold
                    )
                  ),
                  const SizedBox(height: 8),
                  const Text("Create admin account & school profile",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 40),

                  // Section: ADMINISTRATOR
                  _buildSectionLabel("ADMINISTRATOR"),
                  _buildTextField(
                    controller: _nameController,
                    icon: Icons.badge_outlined,
                    hint: "Admin Full Name",
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _emailController,
                    icon: Icons.email_outlined,
                    hint: "admin@school.edu",
                    inputType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _passwordController,
                    icon: Icons.lock_outline,
                    hint: "Create Password",
                    isPassword: true,
                    isObscure: _isObscure,
                    onToggleObscure: () => setState(() => _isObscure = !_isObscure),
                  ),

                  const SizedBox(height: 32),

                  // Section: SCHOOL DETAILS
                  _buildSectionLabel("SCHOOL DETAILS"),
                  _buildTextField(
                    controller: _schoolNameController,
                    icon: Icons.school_outlined,
                    hint: "School Name",
                  ),

                  const SizedBox(height: 40),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSignup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6), // Bright Blue
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 4,
                      ),
                      child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Create School", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward, color: Colors.white),
                            ],
                          ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  
                  // Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an admin account? ", style: TextStyle(color: Colors.grey)),
                      GestureDetector(
                        onTap: () => context.goNamed('login'),
                        child: const Text("Log In", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 40),
                  const Text("© 2025 Greyway.Co. All rights reserved.", style: TextStyle(color: Colors.white24, fontSize: 12)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Row(
          children: [
            const Icon(Icons.security, size: 16, color: Color(0xFF3B82F6)),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.bold, letterSpacing: 1.0, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    bool isPassword = false,
    bool isObscure = false,
    VoidCallback? onToggleObscure,
    TextInputType inputType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      keyboardType: inputType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFF1E293B), // Dark Slate
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        prefixIcon: Icon(icon, color: Colors.white54),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility, color: Colors.white54),
                onPressed: onToggleObscure,
              )
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5)),
      ),
      validator: (val) {
        if (val == null || val.isEmpty) return 'Required';
        if (isPassword && val.length < 6) return 'Min 6 chars';
        return null;
      },
    );
  }
}