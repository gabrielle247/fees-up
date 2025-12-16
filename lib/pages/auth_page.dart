import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For SystemNavigator
import '../services/auth_service.dart';

enum AuthView { signIn, signUp }

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});
  static const String routeName = '/auth';

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _schoolNameController = TextEditingController();

  // State
  AuthView _currentView = AuthView.signIn;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    _schoolNameController.dispose();
    super.dispose();
  }

  void _toggleView() {
    setState(() {
      _currentView = _currentView == AuthView.signIn
          ? AuthView.signUp
          : AuthView.signIn;
      _formKey.currentState?.reset();
    });
  }

  // --- ACTIONS ---

  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      if (_currentView == AuthView.signIn) {
        await _authService.signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        // Main listener in main.dart handles navigation
      } else {
        await _authService.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          fullName: _fullNameController.text.trim(),
          schoolName: _schoolNameController.text.trim().isEmpty
              ? 'My School'
              : _schoolNameController.text.trim(),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Account created! Please verify your email."),
              backgroundColor: Colors.green,
            ),
          );
          _toggleView(); // Switch to login
        }
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _showError("Please enter your email address first.");
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authService.resetPassword(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Password reset link sent to $email"),
            backgroundColor: Colors.blueAccent,
          ),
        );
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<bool> _onWillPop() async {
    // Show Quit Dialog
    final shouldQuit = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xff1c2a35),
        title: const Text("Exit App?", style: TextStyle(color: Colors.white)),
        content: const Text(
          "Are you sure you want to close Fees Up?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text("Exit", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (shouldQuit == true) {
      SystemNavigator.pop();
      return true;
    }
    return false;
  }

  void _showError(String message) {
    if (!mounted) return;
    // Strip "Exception: " prefix for cleaner UI
    final cleanMsg = message.replaceFirst("Exception: ", "");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(cleanMsg),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // --- UI ---

  @override
  Widget build(BuildContext context) {
    final isSignIn = _currentView == AuthView.signIn;
    final colorScheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldExit = await _onWillPop();
        if (shouldExit) SystemNavigator.pop();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              final shouldExit = await _onWillPop();
              if (shouldExit) SystemNavigator.pop();
            },
          ),
          title: const Text('Admin Portal'),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.school, size: 80, color: Colors.blue),
                    const SizedBox(height: 16),
                    Text(
                      isSignIn ? 'Welcome Back' : 'Setup School',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isSignIn
                          ? 'Sign in to manage your students.'
                          : 'Register as a school administrator.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 32),

                    // FULL NAME (SignUp Only)
                    if (!isSignIn) ...[
                      _buildTextField(
                        controller: _fullNameController,
                        label: 'Full Name',
                        icon: Icons.person,
                        validator: (v) =>
                            v!.isEmpty ? 'Enter your full name' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _schoolNameController,
                        label: 'School Name',
                        icon: Icons.business,
                        validator: (v) =>
                            v!.isEmpty ? 'Enter school name' : null,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // EMAIL
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email Address',
                      icon: Icons.email,
                      inputType: TextInputType.emailAddress,
                      validator: (v) =>
                          v == null || !v.contains('@') ? 'Invalid email' : null,
                    ),
                    const SizedBox(height: 16),

                    // PASSWORD
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest.withAlpha(50),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() => _obscurePassword = !_obscurePassword);
                          },
                        ),
                      ),
                      validator: (v) => v!.length < 6
                          ? 'Min 6 characters'
                          : null,
                    ),

                    // CONFIRM PASSWORD (SignUp Only)
                    if (!isSignIn) ...[
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _confirmPasswordController,
                        label: 'Confirm Password',
                        icon: Icons.lock_reset,
                        isPassword: true, // Use basic obscure here
                        validator: (v) {
                          if (v != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                    ],

                    // FORGOT PASSWORD (SignIn Only)
                    if (isSignIn)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _isLoading ? null : _handleForgotPassword,
                          child: const Text('Forgot Password?'),
                        ),
                      ),

                    const SizedBox(height: 24),

                    // ACTION BUTTON
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleAuth,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                isSignIn ? 'Log In' : 'Create Account',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // TOGGLE VIEW
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isSignIn
                              ? "New here? "
                              : "Already have an account? ",
                          style: const TextStyle(color: Colors.grey),
                        ),
                        TextButton(
                          onPressed: _toggleView,
                          child: Text(isSignIn ? 'Sign Up' : 'Log In'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType inputType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: inputType,
      style: const TextStyle(color: Colors.white),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(50),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
