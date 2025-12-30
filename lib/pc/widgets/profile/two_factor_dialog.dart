import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';

class EnableTwoFactorDialog extends StatefulWidget {
  const EnableTwoFactorDialog({super.key});

  @override
  State<EnableTwoFactorDialog> createState() => _EnableTwoFactorDialogState();
}

class _EnableTwoFactorDialogState extends State<EnableTwoFactorDialog> {
  final TextEditingController _codeController = TextEditingController();
  final String _manualCode = "J7X9 2K4M P5Q8 R3V1";

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surfaceGrey,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 480, // Fixed width for the dialog
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.shield_outlined, color: AppColors.primaryBlue, size: 20),
                    SizedBox(width: 12),
                    Text("Enable 2FA", style: TextStyle(color: AppColors.textWhite, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: AppColors.textWhite54),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 2. QR CODE SECTION
            const Text(
              "Scan this QR code with your authenticator app (like Google Authenticator or Authy) to generate your verification code.",
              style: TextStyle(color: AppColors.textWhite70, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 24),
            Center(
              child: Container(
                width: 160,
                height: 160,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                // Replace with your actual QR code image asset or generator
                child: const Center(
                  child: Icon(Icons.qr_code_2, size: 100, color: AppColors.backgroundBlack),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 3. MANUAL ENTRY SECTION
            const Row(
              children: [
                Expanded(child: Divider(color: AppColors.divider)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text("OR ENTER CODE MANUALLY", style: TextStyle(color: AppColors.textWhite38, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
                Expanded(child: Divider(color: AppColors.divider)),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.backgroundBlack,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _manualCode,
                    style: const TextStyle(color: AppColors.primaryBlue, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                  ),
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _manualCode));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Code copied to clipboard")),
                      );
                    },
                    icon: const Icon(Icons.copy, color: AppColors.textWhite54, size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 4. VERIFICATION SECTION
            const Text("Enter 6-digit verification code", style: TextStyle(color: AppColors.textWhite70, fontSize: 14)),
            const SizedBox(height: 12),
            TextFormField(
              controller: _codeController,
              style: const TextStyle(color: AppColors.textWhite, letterSpacing: 2),
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.backgroundBlack,
                hintText: "000 000",
                hintStyle: const TextStyle(color: AppColors.textWhite38),
                prefixIcon: const Icon(Icons.lock_clock_outlined, color: AppColors.textWhite38, size: 18),
                counterText: "", // Hide max length counter
                contentPadding: const EdgeInsets.all(16),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.divider)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.divider)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primaryBlue)),
              ),
            ),
            const SizedBox(height: 32),

            // 5. ACTIONS
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textWhite70,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                  child: const Text("Cancel"),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Implement verification logic
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("2FA Enabled Successfully!")),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("Verify & Enable"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}