// lib/views/login_page.dart (Final Clean Structure)

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/sized_box_normal.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _schoolController = TextEditingController();

  bool _isLogin = true; 
  bool _isLoading = false;
  bool _signUpSuccess = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _schoolController.dispose();
    super.dispose();
  }

  // -----------------------------------------------------
  // 🧠 CORE SUBMIT LOGIC (FIXED CATCH STRUCTURE)
  // -----------------------------------------------------

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _signUpSuccess = false;
    });

    try {
      if (_isLogin) {
        await _authService.signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        
      } else {
        await _authService.signUp( 
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          fullName: _nameController.text.trim(),
          schoolName: _schoolController.text.trim(),
        );
        
        // If signUp completes without throwing an error, it was successful.
        setState(() {
          _signUpSuccess = true;
          _isLogin = true; // Switch to Login mode
        });
        _clearFields();
      }
    } on Exception catch (e) {
      // 🛑 FIX: Catch all standard exceptions (which includes the mapped ones from AuthService)
      if (mounted) _showFriendlyError(e);
      
    } catch (e) {
      // Catch all non-standard or platform errors (e.g. OutOfMemoryError)
      if (mounted) _showError("An unexpected error occurred: $e");
      
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  
  void _clearFields() {
    _emailController.clear();
    _passwordController.clear();
    _nameController.clear();
    _schoolController.clear();
  }
  
  // -----------------------------------------------------
  // 💬 FRIENDLY FEEDBACK METHODS
  // -----------------------------------------------------
  
  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showFriendlyError(Exception e) {
    // Safely extract message from the Exception object thrown by AuthService
    String message = e.toString().contains("Exception:") 
      ? e.toString().substring(e.toString().indexOf(":") + 1).trim()
      : e.toString();
      
    _showError(message);
  }

  // NOTE: Postgrest specific error handlers are now obsolete/removed because 
  // they were unreachable and AuthService maps the errors before throwing.

  // -----------------------------------------------------
  // 🧱 BUILD METHOD
  // -----------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- LOGO & HEADER ---
                Icon(Icons.school_rounded, size: 80, color: colorScheme.primary),
                const SizedBox(height: 16),
                Text(
                  "Fees Up",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isLogin ? "Welcome back, Admin" : "Setup your School Account",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                ),
                const SizedBox(height: 48),

                // 🛑 SUCCESS MESSAGE BANNER 🛑
                if (_signUpSuccess) ...[
                  _buildSuccessBanner(context),
                  const SizedBox(height: 32),
                ],
                
                // --- SIGN UP FIELDS ---
                if (!_isLogin) ...[
                  _buildTextField(_nameController, "Your Full Name", Icons.person_outline),
                  const SizedBoxNormal(16, 0),
                  _buildTextField(_schoolController, "School Name", Icons.business_rounded),
                  const SizedBoxNormal(16, 0),
                ],

                // --- LOGIN FIELDS ---
                _buildTextField(_emailController, "Email Address", Icons.email_outlined),
                const SizedBoxNormal(16, 0),
                _buildTextField(_passwordController, "Password", Icons.lock_outline, isPassword: true),

                const SizedBox(height: 32),

                // --- SUBMIT BUTTON ---
                ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : Text(
                          _isLogin ? "Login" : "Create Account",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),

                const SizedBox(height: 24),

                // --- TOGGLE BUTTON ---
                TextButton(
                  onPressed: () {
                    _formKey.currentState?.reset();
                    setState(() {
                      _isLogin = !_isLogin;
                      _signUpSuccess = false; // Hide success message on toggle
                    });
                  },
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.grey.shade400),
                      children: [
                        TextSpan(text: _isLogin ? "New here? " : "Already have an account? "),
                        TextSpan(
                          text: _isLogin ? "Create Account" : "Login",
                          style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // -----------------------------------------------------
  // 🎨 HELPER WIDGETS
  // -----------------------------------------------------

  Widget _buildSuccessBanner(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.secondary.withAlpha(40), 
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.secondary), 
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.mark_email_read_rounded, color: colorScheme.secondary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Verification Required",
                  style: TextStyle(
                    color: colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Success! Please check your email inbox to verify your account and complete the sign-up process. We automatically switched you to the Login tab.",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                TextButton(
                  onPressed: () => setState(() => _signUpSuccess = false),
                  child: Text(
                    "OK, I've verified it.", 
                    style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isPassword = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      validator: (val) {
        if (val == null || val.isEmpty) return "$label is required";
        if (!isPassword && label.contains("Email") && !val.contains("@")) return "Invalid email";
        if (isPassword && val.length < 6) return "Password too short (min 6 chars)";
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade500),
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: colorScheme.tertiary.withAlpha(25), 
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
      ),
    );
  }
}