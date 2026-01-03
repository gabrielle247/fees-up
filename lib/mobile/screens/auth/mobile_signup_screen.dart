import 'package:fees_up/data/providers/auth_provider.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_colors.dart';

class MobileAuthScreen extends ConsumerStatefulWidget {
  final bool initialIsLogin; 
  const MobileAuthScreen({super.key, this.initialIsLogin = true});

  @override
  ConsumerState<MobileAuthScreen> createState() => _MobileAuthScreenState();
}

class _MobileAuthScreenState extends ConsumerState<MobileAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _schoolNameController = TextEditingController(); 

  late bool _isLogin;
  bool _isLoading = false;
  bool _isObscure = true;

  @override
  void initState() {
    super.initState();
    _isLogin = widget.initialIsLogin;
  }

  /// Handles Email/Password Auth
  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final authRepo = ref.read(authRepositoryProvider);

      if (_isLogin) {
        await Supabase.instance.client.auth.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        await authRepo.signUpWithSchool(
          fullName: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          schoolName: _schoolNameController.text.trim(),
        );
      }
      // Success is handled by the Router listening to Auth State changes
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

  /// Handles Google OAuth
  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    try {
      // 1. Web: Redirects to URL
      // 2. Mobile: Opens Browser -> Redirects back to app via Deep Link
      // Ensure you added 'io.supabase.flutterquickstart://login-callback' (or your custom scheme) 
      // to the "Redirect URLs" in Supabase Auth Settings.
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? null : 'io.supabase.flutterquickstart://login-callback',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Google Login Failed: $e"), backgroundColor: AppColors.errorRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, 
      body: Container(
        // Fallback gradient if not covered by PC wrapper
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F172A), Color(0xFF020617)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // --- HEADER ---
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F3946),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Icon(
                        _isLogin ? Icons.lock_open : Icons.security, 
                        size: 32, 
                        color: AppColors.successGreen
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _isLogin ? "Welcome Back" : "Setup School",
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white, fontWeight: FontWeight.bold
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isLogin 
                        ? "Login to access your financial dashboard" 
                        : "Create admin account & school profile",
                      style: const TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    // --- FORM FIELDS ---
                    if (!_isLogin) ...[
                      _buildSectionLabel("ADMINISTRATOR"),
                      _buildTextField(
                        controller: _nameController,
                        icon: Icons.badge_outlined,
                        hint: "Admin Full Name",
                      ),
                      const SizedBox(height: 16),
                    ],

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
                      hint: "Password",
                      isPassword: true,
                      isObscure: _isObscure,
                      onToggleObscure: () => setState(() => _isObscure = !_isObscure),
                    ),

                    if (!_isLogin) ...[
                      const SizedBox(height: 32),
                      _buildSectionLabel("SCHOOL DETAILS"),
                      _buildTextField(
                        controller: _schoolNameController,
                        icon: Icons.school_outlined,
                        hint: "School Name",
                      ),
                    ],

                    const SizedBox(height: 32),

                    // --- SUBMIT BUTTON ---
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleAuth,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 4,
                        ),
                        child: _isLoading 
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _isLogin ? "Log In" : "Create School", 
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward, color: Colors.white),
                              ],
                            ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // --- GOOGLE LOGIN ---
                    Row(
                      children: [
                        const Expanded(child: Divider(color: Colors.white12)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            "Or continue with",
                            style: TextStyle(color: Colors.white.withAlpha(128), fontSize: 12),
                          ),
                        ),
                        const Expanded(child: Divider(color: Colors.white12)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : _handleGoogleLogin,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: Colors.white.withAlpha(26)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          backgroundColor: Colors.white.withAlpha(13),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // You can replace this Icon with an SVG asset for the colorful 'G' logo
                            Icon(Icons.g_mobiledata, color: Colors.white, size: 28),
                            SizedBox(width: 8),
                            Text("Sign in with Google", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                    
                    // --- TOGGLE MODE ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isLogin ? "Don't have an account? " : "Already have an admin account? ", 
                          style: const TextStyle(color: Colors.grey)
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isLogin = !_isLogin;
                              _formKey.currentState?.reset(); 
                            });
                          },
                          child: Text(
                            _isLogin ? "Create School" : "Log In", 
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
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
        child: Text(
          label,
          style: const TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.bold, letterSpacing: 1.0, fontSize: 12),
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
        fillColor: const Color(0xFF1E293B),
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