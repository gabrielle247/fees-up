import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

class SecurityPasswordView extends StatelessWidget {
  const SecurityPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Password Card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surfaceGrey,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Change Password",
                  style: TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text(
                  "Ensure your account is using a long, random password to stay secure.",
                  style: TextStyle(color: AppColors.textWhite54, fontSize: 13)),
              const SizedBox(height: 24),

              _buildLabel("Current Password"),
              _buildInput("••••••••", isPassword: true),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("New Password"),
                        _buildInput("••••••••", isPassword: true, isNew: true),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Confirm New Password"),
                        _buildInput("••••••••", isPassword: true),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Strength Meter
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.backgroundBlack,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Password Strength",
                            style: TextStyle(
                                color: AppColors.textWhite70, fontSize: 11)),
                        Text("Strong",
                            style: TextStyle(
                                color: AppColors.successGreen,
                                fontSize: 11,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: const LinearProgressIndicator(
                        value: 0.85,
                        minHeight: 4,
                        backgroundColor: AppColors.divider,
                        color: AppColors.successGreen,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Icon(Icons.check,
                            size: 12, color: AppColors.successGreen),
                        SizedBox(width: 6),
                        Text(
                            "Contains at least 8 characters, one number, and one symbol.",
                            style: TextStyle(
                                color: AppColors.textWhite54, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Password reset flow coming soon'),
                          backgroundColor: AppColors.primaryBlue,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: const Text("Forgot Password?",
                        style: TextStyle(color: AppColors.textWhite70)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Updating password coming soon'),
                          backgroundColor: AppColors.primaryBlue,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white),
                    child: const Text("Update Password"),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // 2FA Card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surfaceGrey,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: const Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Two-Factor Authentication",
                        style: TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text(
                        "Add an extra layer of security by requiring a code from your phone.",
                        style: TextStyle(
                            color: AppColors.textWhite54, fontSize: 13)),
                  ],
                ),
              ),
              Icon(Icons.phonelink_lock,
                  size: 32, color: AppColors.textWhite38),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: const TextStyle(color: AppColors.textWhite70, fontSize: 13)));

  Widget _buildInput(String hint,
      {bool isPassword = false, bool isNew = false}) {
    return TextFormField(
      obscureText: isPassword,
      style: const TextStyle(color: AppColors.textWhite),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.backgroundBlack,
        hintText: hint,
        hintStyle:
            const TextStyle(color: AppColors.textWhite38, letterSpacing: 2),
        prefixIcon:
            const Icon(Icons.key, color: AppColors.textWhite38, size: 18),
        suffixIcon: isNew
            ? const Icon(Icons.visibility_off,
                color: AppColors.textWhite38, size: 18)
            : null,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.divider)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.divider)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.primaryBlue)),
      ),
    );
  }
}
