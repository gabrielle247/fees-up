import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  // State
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("You must agree to the Terms and Conditions"),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    // Simulate Network
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isLoading = false);
      // Navigate to Create School
      context.go('/create-school');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // --- Custom Header ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.go('/login'),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.cardTheme.color,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: theme.dividerTheme.color ?? Colors.grey),
                      ),
                      child: Icon(Icons.arrow_back_ios_new, size: 20, color: textTheme.bodyLarge?.color),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "Create Admin Account",
                      textAlign: TextAlign.center,
                      style: textTheme.headlineSmall,
                    ),
                  ),
                  const SizedBox(width: 40), // Spacer to balance back button
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // --- Icon Header ---
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withAlpha(25),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              Icons.school,
                              color: colorScheme.primary,
                              size: 40,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Fees Up",
                          textAlign: TextAlign.center,
                          style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
                          child: Text(
                            "Start managing your school fees efficiently.",
                            textAlign: TextAlign.center,
                            style: textTheme.bodyMedium,
                          ),
                        ),

                        const SizedBox(height: 32),

                        // --- Full Name ---
                        Text("Full Name", style: textTheme.labelLarge),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _nameController,
                          style: textTheme.bodyLarge,
                          decoration: const InputDecoration(
                            hintText: "Enter your full name",
                          ),
                          validator: (value) => value!.isEmpty ? 'Name required' : null,
                        ),

                        const SizedBox(height: 16),

                        // --- Email ---
                        Text("Email Address", style: textTheme.labelLarge),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: textTheme.bodyLarge,
                          decoration: const InputDecoration(
                            hintText: "name@school.com",
                          ),
                          validator: (value) => !value!.contains('@') ? 'Invalid email' : null,
                        ),

                        const SizedBox(height: 16),

                        // --- Password ---
                        Text("Password", style: textTheme.labelLarge),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          style: textTheme.bodyLarge,
                          decoration: InputDecoration(
                            hintText: "Create a strong password",
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                              ),
                              onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                            ),
                          ),
                          validator: (value) => value!.length < 6 ? 'Min 6 chars' : null,
                        ),

                        const SizedBox(height: 16),

                        // --- Confirm Password ---
                        Text("Confirm Password", style: textTheme.labelLarge),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _confirmPassController,
                          obscureText: !_isConfirmPasswordVisible,
                          style: textTheme.bodyLarge,
                          decoration: InputDecoration(
                            hintText: "Re-enter your password",
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
                              ),
                              onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                            ),
                          ),
                          validator: (value) {
                            if (value != _passwordController.text) return 'Passwords do not match';
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        // --- Terms Checkbox ---
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 24,
                              width: 24,
                              child: Checkbox(
                                value: _agreedToTerms,
                                activeColor: colorScheme.primary,
                                onChanged: (val) => setState(() => _agreedToTerms = val ?? false),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Wrap(
                                children: [
                                  Text("I agree to the ", style: textTheme.bodyMedium),
                                  GestureDetector(
                                    onTap: () {}, 
                                    child: Text(
                                      "Terms", 
                                      style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Text(" and ", style: textTheme.bodyMedium),
                                  GestureDetector(
                                    onTap: () {}, 
                                    child: Text(
                                      "Privacy Policy", 
                                      style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Text(".", style: textTheme.bodyMedium),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // --- Create Account Button ---
                        SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleSignup,
                            child: _isLoading
                                ? SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(color: colorScheme.onPrimary),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text("Create Account"),
                                      SizedBox(width: 8),
                                      Icon(Icons.person_add_outlined),
                                    ],
                                  ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // --- Footer ---
                        Padding(
                          padding: const EdgeInsets.only(bottom: 24.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Already have an account? ", style: textTheme.bodyMedium),
                              GestureDetector(
                                onTap: () => context.go('/login'),
                                child: Text(
                                  "Sign In",
                                  style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}