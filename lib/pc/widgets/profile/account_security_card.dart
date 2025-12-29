import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

class AccountSecurityCard extends StatelessWidget {
  const AccountSecurityCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundBlack,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Account Security", style: TextStyle(color: AppColors.textWhite, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          // Password Status
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.successGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.successGreen.withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.shield, color: AppColors.successGreen, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Strong Password", style: TextStyle(color: AppColors.successGreen, fontWeight: FontWeight.bold, fontSize: 12)),
                      Text("Last changed 30 days ago", style: TextStyle(color: AppColors.textWhite54, fontSize: 10)),
                    ],
                  ),
                ),
                Icon(Icons.check_circle, color: AppColors.successGreen, size: 16),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 2FA Status
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.phonelink_lock, color: Colors.orange, size: 20),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("2FA Inactive", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
                      Text("Recommended for admins", style: TextStyle(color: AppColors.textWhite54, fontSize: 10)),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text("Enable", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}