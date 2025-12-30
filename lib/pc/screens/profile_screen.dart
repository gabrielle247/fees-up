import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/sidebar.dart';
import '../widgets/profile/profile_header_card.dart';
import '../widgets/profile/personal_info_form.dart';
import '../widgets/profile/account_security_card.dart';
import '../widgets/profile/security_password_view.dart';
import '../widgets/profile/role_permissions_view.dart';
import '../widgets/profile/activity_log_view.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _navItems = [
    {'icon': Icons.person_outline, 'label': 'Personal Information'},
    {'icon': Icons.lock_outline, 'label': 'Security & Password'},
    {'icon': Icons.shield_outlined, 'label': 'Role & Permissions'},
    {'icon': Icons.history, 'label': 'Activity Log'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      body: Row(
        // FIX: Pin Sidebar and Content to the top to prevent vertical jumping
        // when content height changes during navigation.
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DashboardSidebar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Profile Settings",
                      style: TextStyle(
                          color: AppColors.textWhite,
                          fontSize: 24,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),

                  // 1. Top Hero Card
                  const ProfileHeaderCard(),
                  const SizedBox(height: 24),

                  // 2. Main Content Area
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // LEFT COLUMN: Nav & Widget
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            _buildInnerNav(),
                            // Only show the security summary on Personal & Security tabs
                            if (_selectedIndex == 0 || _selectedIndex == 1) ...[
                              const SizedBox(height: 24),
                              const AccountSecurityCard(),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(width: 24),

                      // RIGHT COLUMN: Dynamic Content
                      Expanded(
                        flex: 2,
                        child: _buildActiveContent(),
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

  Widget _buildActiveContent() {
    switch (_selectedIndex) {
      case 0:
        return const PersonalInfoForm();
      case 1:
        return const SecurityPasswordView();
      case 2:
        return const RolePermissionsView();
      case 3:
        return const ActivityLogView();
      default:
        return const PersonalInfoForm();
    }
  }

  Widget _buildInnerNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: List.generate(_navItems.length, (index) {
            final item = _navItems[index];
            final isSelected = _selectedIndex == index;
            return Column(
              children: [
                if (index > 0)
                  const Divider(height: 1, color: AppColors.divider),
                InkWell(
                  onTap: () => setState(() => _selectedIndex = index),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    decoration: isSelected
                        ? BoxDecoration(
                            border: const Border(
                                left: BorderSide(
                                    color: AppColors.primaryBlue, width: 3)),
                            color:
                                AppColors.primaryBlue.withValues(alpha: 0.05),
                          )
                        : null,
                    child: Row(
                      children: [
                        Icon(item['icon'],
                            size: 20,
                            color: isSelected
                                ? AppColors.primaryBlue
                                : AppColors.textWhite54),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item['label'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: isSelected
                                    ? AppColors.primaryBlue
                                    : AppColors.textWhite70,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
