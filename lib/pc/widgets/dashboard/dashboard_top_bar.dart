import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Top Bar Fragment - Displays user info, school status, and connectivity
/// Complies with Law of Fragments: Reusable, self-contained widget
class DashboardTopBar extends StatelessWidget {
  final String userName;
  final String schoolName;
  final bool hasSchool;
  final bool isConnected;
  final VoidCallback onAvatarTap;

  const DashboardTopBar({
    super.key,
    required this.userName,
    required this.schoolName,
    required this.hasSchool,
    required this.isConnected,
    required this.onAvatarTap,
  });

  String _getInitials(String name) {
    if (name.isEmpty) return "U";
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return "${parts[0][0]}${parts[1][0]}".toUpperCase();
    }
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    // Determine subtitle status (Offline / Syncing / School Name)
    String subtitle = schoolName;
    Color subtitleColor = AppColors.textWhite54;

    if (!hasSchool) {
      subtitle = isConnected ? "Tap avatar to setup" : "Waiting for Sync...";
      subtitleColor = AppColors.warningOrange;
    } else if (!isConnected) {
      subtitle = "Offline Mode";
      subtitleColor = AppColors.errorRed;
    } else if (schoolName == 'Loading...') {
      subtitle = "Syncing Data...";
      subtitleColor = AppColors.primaryBlueLight;
    }

    final initials = _getInitials(userName);

    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          const Text(
            "Financial Dashboard",
            style: TextStyle(
              color: AppColors.textWhite,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),

          // User Info Column
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                userName.isEmpty ? "User" : userName,
                style: const TextStyle(
                  color: AppColors.textWhite,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Row(
                children: [
                  if (!isConnected) ...[
                    const Icon(
                      Icons.wifi_off,
                      size: 10,
                      color: AppColors.errorRed,
                    ),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    subtitle,
                    style: TextStyle(color: subtitleColor, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(width: 12),

          // Profile Avatar
          InkWell(
            onTap: onAvatarTap,
            borderRadius: BorderRadius.circular(50),
            child: CircleAvatar(
              backgroundColor: hasSchool
                  ? AppColors.primaryBlue.withValues(alpha: 0.2)
                  : AppColors.warningOrange.withValues(alpha: 0.2),
              child: hasSchool
                  ? Text(
                      initials,
                      style: const TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    )
                  : const Icon(
                      Icons.priority_high,
                      color: AppColors.warningOrange,
                      size: 18,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
