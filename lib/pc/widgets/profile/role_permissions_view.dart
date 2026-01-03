import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

class RolePermissionsView extends StatelessWidget {
  const RolePermissionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // --- ROLE HIGHLIGHT CARD ---
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            // Special gradient for Admin Highlight
            gradient: LinearGradient(
              colors: [
                AppColors.primaryBlue.withValues(alpha: 0.15), 
                AppColors.surfaceGrey
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: AppColors.primaryBlue.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4))
                      ]
                    ),
                    child: const Icon(Icons.verified_user, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Current Role Assignment", style: TextStyle(color: AppColors.textWhite54, fontSize: 12, letterSpacing: 1)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Text("School Administrator", style: TextStyle(color: AppColors.textWhite, fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text("SUPER USER", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                "You have full access to all modules within this school organization. You can manage users, billing configurations, and academic records.",
                style: TextStyle(color: AppColors.textWhite70, fontSize: 14, height: 1.6),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),

        // --- PERMISSIONS LIST ---
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surfaceGrey,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Active Permissions", style: TextStyle(color: AppColors.textWhite, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              
              _buildPermItem(
                Icons.account_balance_wallet, 
                "Financial Access", 
                "Full read/write access to invoices, payments, and ledgers."
              ),
              const Divider(color: AppColors.divider, height: 32),
              
              _buildPermItem(
                Icons.people_alt, 
                "User Management", 
                "Can invite teachers, students, and modify roles."
              ),
              const Divider(color: AppColors.divider, height: 32),
              
              _buildPermItem(
                Icons.settings, 
                "System Configuration", 
                "Can modify school year, billing cycles, and global settings."
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPermItem(IconData icon, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.textWhite54, size: 22),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: AppColors.textWhite, fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(desc, style: const TextStyle(color: AppColors.textWhite54, fontSize: 13)),
            ],
          ),
        ),
        const Icon(Icons.check_circle, color: AppColors.successGreen, size: 20),
      ],
    );
  }
}