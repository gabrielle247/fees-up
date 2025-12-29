import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/sidebar.dart';
import '../widgets/profile/profile_header_card.dart';
import '../widgets/profile/personal_info_form.dart';
import '../widgets/profile/account_security_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      body: Row(
        children: [
          const DashboardSidebar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Profile Settings", style: TextStyle(color: AppColors.textWhite, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  
                  // 1. Top Hero Card
                  const ProfileHeaderCard(),
                  const SizedBox(height: 24),

                  // 2. Main Content Area (Split View)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // LEFT: Navigation & Security Summary
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            _buildInnerNav(),
                            const SizedBox(height: 24),
                            const AccountSecurityCard(),
                          ],
                        ),
                      ),
                      
                      const SizedBox(width: 24),

                      // RIGHT: Active Form
                      const Expanded(
                        flex: 2,
                        child: PersonalInfoForm(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInnerNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          _navItem(Icons.person, "Personal Information", true),
          const Divider(height: 1, color: AppColors.divider),
          _navItem(Icons.lock, "Security & Password", false),
          const Divider(height: 1, color: AppColors.divider),
          _navItem(Icons.notifications, "Notifications", false),
          const Divider(height: 1, color: AppColors.divider),
          _navItem(Icons.shield, "Role & Permissions", false),
          const Divider(height: 1, color: AppColors.divider),
          _navItem(Icons.history, "Activity Log", false),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool isActive) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: isActive ? BoxDecoration(
        border: const Border(left: BorderSide(color: AppColors.primaryBlue, width: 3)),
        color: AppColors.primaryBlue.withValues(alpha: 0.05),
      ) : null,
      child: Row(
        children: [
          Icon(icon, size: 18, color: isActive ? AppColors.primaryBlue : AppColors.textWhite54),
          const SizedBox(width: 12),
          Text(
            label, 
            style: TextStyle(
              color: isActive ? AppColors.primaryBlue : AppColors.textWhite70,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              fontSize: 13
            )
          ),
        ],
      ),
    );
  }
}