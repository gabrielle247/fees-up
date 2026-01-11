import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fees_up/data/constants/app_colors.dart';
import 'package:fees_up/data/constants/app_strings.dart';

// =============================================================================
// 1. LOCAL STRINGS (Strictly No UI String Literals)
// =============================================================================
class _ForgotStrings {
  static const String pageTitle = "Reset Password";
  static const String backToLogin = "Back to Login";
  
  // Step 1: Request
  static const String headRequest = "Forgot Password?";
  static const String subRequest = "Enter your email address to receive a 6-digit verification code.";
  static const String btnSend = "Send Reset Code";
  
  // Step 2: Verify & Reset
  static const String headReset = "Create New Password";
  static const String subReset = "Enter the code sent to your email and set your new password.";
  static const String lblCode = "6-Digit Code";
  static const String hintCode = "123456";
  static const String lblNewPass = "New Password";
  static const String lblConfirmPass = "Confirm Password";
  static const String btnReset = "Reset Password";
  static const String resendLink = "Didn't receive code? Resend";
  
  // Messages
  static const String msgSent = "Code sent to your email";
  static const String msgSuccess = "Password reset successfully. Please login.";
  static const String errMatch = "Passwords do not match";
  static const String errCode = "Invalid code format";
}

// =============================================================================
// 2. SCREEN IMPLEMENTATION
// =============================================================================
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // State
  int _currentStep = 0; // 0 = Request, 1 = Reset
  bool _isLoading = false;
  bool _isObscure1 = true;
  bool _isObscure2 = true;

  // Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  // --- Logic: Step 1 (Send Code) ---
  Future<void> _handleSendCode() async {
    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.enterValidEmail),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    // Simulate API Call
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isLoading = false;
        _currentStep = 1; // Move to next step
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(_ForgotStrings.msgSent),
          backgroundColor: AppColors.successGreen,
        ),
      );
    }
  }

  // --- Logic: Step 2 (Reset) ---
  Future<void> _handleReset() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Simulate API Call
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isLoading = false);
      
      // Success -> Go back to Login
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(_ForgotStrings.msgSuccess),
          backgroundColor: AppColors.successGreen,
        ),
      );
      context.pop(); 
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(_ForgotStrings.pageTitle),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- Dynamic Header Icon ---
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withAlpha(25),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _currentStep == 0 ? Icons.mark_email_unread_outlined : Icons.lock_reset,
                        size: 40,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // --- Dynamic Texts ---
                  Text(
                    _currentStep == 0 ? _ForgotStrings.headRequest : _ForgotStrings.headReset,
                    textAlign: TextAlign.center,
                    style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _currentStep == 0 ? _ForgotStrings.subRequest : _ForgotStrings.subReset,
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium,
                  ),
                  
                  const SizedBox(height: 40),

                  // ================= STEP 0: EMAIL INPUT =================
                  if (_currentStep == 0) ...[
                    _buildLabel(context, AppStrings.emailLabel),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: AppStrings.emailAddressHint,
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSendCode,
                        child: _isLoading 
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(_ForgotStrings.btnSend),
                      ),
                    ),
                  ],

                  // ================= STEP 1: VERIFY & RESET =================
                  if (_currentStep == 1) ...[
                    // Code Input
                    _buildLabel(context, _ForgotStrings.lblCode),
                    TextFormField(
                      controller: _codeController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 6,
                      style: const TextStyle(
                        fontSize: 24, 
                        fontWeight: FontWeight.bold,
                        letterSpacing: 8.0, // Space out the digits
                      ),
                      decoration: const InputDecoration(
                        hintText: _ForgotStrings.hintCode,
                        counterText: "", // Hide character count
                        contentPadding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      validator: (v) => (v == null || v.length != 6) ? _ForgotStrings.errCode : null,
                    ),
                    const SizedBox(height: 24),

                    // New Password
                    _buildLabel(context, _ForgotStrings.lblNewPass),
                    TextFormField(
                      controller: _passController,
                      obscureText: _isObscure1,
                      decoration: InputDecoration(
                        hintText: AppStrings.passwordHint,
                        suffixIcon: IconButton(
                          icon: Icon(_isObscure1 ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _isObscure1 = !_isObscure1),
                        ),
                      ),
                      validator: (v) => (v == null || v.length < 6) ? AppStrings.passwordTooShort : null,
                    ),
                    const SizedBox(height: 16),

                    // Confirm Password
                    _buildLabel(context, _ForgotStrings.lblConfirmPass),
                    TextFormField(
                      controller: _confirmController,
                      obscureText: _isObscure2,
                      decoration: InputDecoration(
                        hintText: AppStrings.passwordHint,
                        suffixIcon: IconButton(
                          icon: Icon(_isObscure2 ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _isObscure2 = !_isObscure2),
                        ),
                      ),
                      validator: (v) {
                        if (v != _passController.text) return _ForgotStrings.errMatch;
                        return null;
                      },
                    ),

                    const SizedBox(height: 32),

                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleReset,
                        child: _isLoading 
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(_ForgotStrings.btnReset),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: () {
                           // Resend Logic
                           ScaffoldMessenger.of(context).showSnackBar(
                             const SnackBar(content: Text(_ForgotStrings.msgSent))
                           );
                        },
                        child: const Text(_ForgotStrings.resendLink),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),
                  
                  // Back to Login Link
                  Center(
                    child: GestureDetector(
                      onTap: () => context.pop(),
                      child: Text(
                        _ForgotStrings.backToLogin,
                        style: TextStyle(
                          color: theme.textTheme.bodyMedium?.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}