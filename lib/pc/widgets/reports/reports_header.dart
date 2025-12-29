import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/providers/dashboard_provider.dart';
import '../../../../data/services/database_service.dart';

class ReportsHeader extends ConsumerWidget {
  const ReportsHeader({super.key});

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
    final bool isConnected = DatabaseService().db.currentStatus.connected;

    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      color: AppColors.backgroundBlack,
      child: Row(
        children: [
          const Icon(Icons.analytics, color: AppColors.primaryBlue, size: 28),
          const SizedBox(width: 12),
          const Text(
            "Reports Center",
            style: TextStyle(
              color: AppColors.textWhite,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          
          const Spacer(),

          // Search Bar
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
                hintText: "Search saved reports...",
                hintStyle: const TextStyle(color: AppColors.textWhite38),
                prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.textWhite54),
                contentPadding: EdgeInsets.zero, 
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
          
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none, color: AppColors.textWhite70),
          ),
          const SizedBox(width: 16),
          
          // Profile & Connectivity
          dashboardAsync.when(
            loading: () => const CircleAvatar(backgroundColor: AppColors.surfaceGrey, radius: 16),
            error: (_, __) => Icon(isConnected ? Icons.error_outline : Icons.wifi_off, color: AppColors.errorRed),
            data: (data) {
              final initials = _getInitials(data.userName);
              String subtitle = data.schoolName;
              if (data.schoolName == 'Loading...') {
                subtitle = isConnected ? "Syncing Data..." : "Offline Mode";
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
                          color: (subtitle == "Offline Mode") ? AppColors.warningOrange : AppColors.textWhite38, 
                          fontSize: 11
                        )
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  CircleAvatar(
                    backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.2),
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
}