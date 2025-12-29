import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/providers/dashboard_provider.dart';
import '../../../../data/services/database_service.dart';

class SettingsHeader extends ConsumerWidget {
  const SettingsHeader({super.key});

  String _getInitials(String name) {
    if (name.isEmpty) return "U";
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return "${parts[0][0]}${parts[1][0]}".toUpperCase();
    }
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardDataProvider);
    
    // Direct connectivity check for real-time UI feedback
    final bool isConnected = DatabaseService().db.currentStatus.connected;

    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      color: AppColors.backgroundBlack,
      child: Row(
        children: [
          // --- Page Title ---
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.settings, color: AppColors.primaryBlue, size: 20),
          ),
          const SizedBox(width: 12),
          const Text(
            "Settings",
            style: TextStyle(
              color: AppColors.textWhite,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          
          const Spacer(),

          // --- Global Search Bar (Standardized) ---
          SizedBox(
            width: 300,
            height: 40,
            child: TextField(
              textAlignVertical: TextAlignVertical.center,
              style: const TextStyle(color: AppColors.textWhite, fontSize: 13),
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: AppColors.surfaceGrey,
                hintText: "Search settings...",
                hintStyle: const TextStyle(color: AppColors.textWhite38),
                prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.textWhite54),
                
                // Content Padding zero to center text vertically
                contentPadding: EdgeInsets.zero, 

                // Borders
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.divider),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.primaryBlue),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.divider),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 24),

          // --- Actions ---
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none, color: AppColors.textWhite70),
            tooltip: "Notifications",
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.help_outline, color: AppColors.textWhite70),
            tooltip: "Help & Support",
          ),
          const SizedBox(width: 16),

          // --- Profile with Connectivity Logic ---
          dashboardAsync.when(
            loading: () => _buildProfileLoading(),
            error: (err, _) => _buildProfileError(isConnected),
            data: (data) {
              final initials = _getInitials(data.userName);
              
              // Determine subtitle status (Offline / Syncing / Role)
              String subtitle = "Administrator"; // Default role text from design
              Color subtitleColor = AppColors.textWhite38;

              if (data.schoolName == 'Loading...') {
                subtitle = isConnected ? "Syncing..." : "Offline Mode";
                subtitleColor = isConnected ? AppColors.primaryBlueLight : AppColors.errorRed;
              } else if (!isConnected) {
                subtitle = "Offline Mode";
                subtitleColor = AppColors.errorRed;
              }

              return Row(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        data.userName.isEmpty ? "User" : data.userName, 
                        style: const TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold, fontSize: 13)
                      ),
                      Text(
                        subtitle, 
                        style: TextStyle(
                          color: subtitleColor, 
                          fontSize: 11
                        )
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  CircleAvatar(
                    backgroundColor: AppColors.primaryBlue.withOpacity(0.2),
                    child: Text(
                      initials, 
                      style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 12)
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // --- Loading/Error States ---

  Widget _buildProfileLoading() {
    return Row(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(width: 80, height: 12, color: AppColors.surfaceGrey),
            const SizedBox(height: 4),
            Container(width: 50, height: 10, color: AppColors.surfaceGrey),
          ],
        ),
        const SizedBox(width: 12),
        const CircleAvatar(
          backgroundColor: AppColors.surfaceGrey,
          radius: 20,
        ),
      ],
    );
  }

  Widget _buildProfileError(bool isConnected) {
    return Row(
      children: [
        Text(
          isConnected ? "Sync Error" : "Offline", 
          style: TextStyle(color: isConnected ? AppColors.errorRed : AppColors.warningOrange, fontSize: 12)
        ),
        const SizedBox(width: 12),
        CircleAvatar(
          backgroundColor: AppColors.surfaceGrey,
          child: Icon(
            isConnected ? Icons.error_outline : Icons.wifi_off, 
            size: 16, 
            color: isConnected ? AppColors.errorRed : AppColors.warningOrange
          ),
        ),
      ],
    );
  }
}