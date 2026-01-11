import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // State
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    // Simulate Network Request
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2)); // Placebo delay

    if (mounted) {
      setState(() => _isLoading = false);
      // Navigate to Dashboard (Happy Path)
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      // Background comes automatically from AppTheme
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- Back Button (Visual Only for Root) ---
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () {
                           // Logic to exit app or go back if coming from somewhere else
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 20),

                    // --- Logo Section ---
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withAlpha(100),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.account_balance,
                          color: colorScheme.onPrimary,
                          size: 48,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Fees Up",
                      textAlign: TextAlign.center,
                      style: textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 40),

                    // --- Welcome Text ---
                    Text(
                      "Welcome Back",
                      textAlign: TextAlign.center,
                      style: textTheme.displayMedium?.copyWith(
                        fontSize: 28, 
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Manage your school fees with ease",
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium,
                    ),

                    const SizedBox(height: 32),

                    // --- Email Input ---
                    Text("Email Address", style: textTheme.labelLarge),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: textTheme.bodyLarge,
                      // Decoration is handled by AppTheme.inputDecorationTheme
                      decoration: const InputDecoration(
                        hintText: "admin@schoolname.edu",
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Please enter email';
                        if (!value.contains('@')) return 'Invalid email address';
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // --- Password Input ---
                    Text("Password", style: textTheme.labelLarge),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      style: textTheme.bodyLarge,
                      decoration: InputDecoration(
                        hintText: "Enter your password",
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Please enter password';
                        if (value.length < 6) return 'Password too short';
                        return null;
                      },
                    ),

                    // --- Forgot Password ---
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // Placeholder
                        },
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // --- Sign In Button ---
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        child: _isLoading
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: colorScheme.onPrimary,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text("Sign In"),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // --- Footer ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: textTheme.bodyMedium,
                        ),
                        GestureDetector(
                          onTap: () => context.go('/signup'),
                          child: Text(
                            "Create an Account",
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}