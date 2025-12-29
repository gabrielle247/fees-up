import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/providers/dashboard_provider.dart';
import '../../../../data/services/database_service.dart'; // Import DatabaseService

class InvoicesHeader extends ConsumerWidget {
  const InvoicesHeader({super.key});

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
    
    // Check connectivity status directly for UI feedback
    final bool isConnected = DatabaseService().db.currentStatus.connected;

    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      color: AppColors.backgroundBlack,
      child: Row(
        children: [
          // --- Page Title ---
          const Icon(Icons.description, color: AppColors.primaryBlue, size: 28),
          const SizedBox(width: 12),
          const Text(
            "Invoices",
            style: TextStyle(
              color: AppColors.textWhite,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          
          const Spacer(),

          // --- Global Search Bar (Fixed) ---
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
                hintText: "Search payments, invoices...",
                hintStyle: const TextStyle(color: AppColors.textWhite38),
                prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.textWhite54),
                
                // Content Padding zero to center text vertically
                contentPadding: EdgeInsets.zero, 

                // Default Border
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.divider),
                ),
                
                // Focused Border
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.primaryBlue),
                ),
                
                // Fallback Border
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.divider),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 24),

          // --- Notification Bell ---
          Stack(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_none, color: AppColors.textWhite70),
                tooltip: "Notifications",
              ),
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  width: 8, height: 8,
                  decoration: const BoxDecoration(color: AppColors.errorRed, shape: BoxShape.circle),
                ),
              )
            ],
          ),
          
          const SizedBox(width: 16),

          // --- Profile with Connectivity Logic ---
          dashboardAsync.when(
            loading: () => _buildProfileLoading(),
            error: (err, _) => _buildProfileError(isConnected),
            data: (data) {
              final initials = _getInitials(data.userName);
              
              // Determine subtitle based on data state AND connectivity
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