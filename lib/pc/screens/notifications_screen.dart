import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/sidebar.dart';
import '../widgets/notifications/notifications_kpi_cards.dart'; // Renamed & Moved
import '../widgets/notifications/notifications_list.dart'; // Renamed & Moved

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      body: Row(
        children: [
          DashboardSidebar(),
          Expanded(
            child: Column(
              children: [
                _NotificationsHeader(),
                Divider(height: 1, color: AppColors.divider),
                
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(32),
                    child: Column(
                      children: [
                        // 1. Personal Stats (Unread / Urgent)
                        NotificationsKpiCards(),
                        SizedBox(height: 24),
                        
                        // 2. The Personal Inbox List
                        NotificationsList(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationsHeader extends StatelessWidget {
  const _NotificationsHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      color: AppColors.backgroundBlack,
      child: Row(
        children: [
          const Icon(Icons.notifications_active_outlined, color: AppColors.primaryBlue, size: 28),
          const SizedBox(width: 12),
          const Text("My Notifications", style: TextStyle(color: AppColors.textWhite, fontSize: 20, fontWeight: FontWeight.bold)),
          const Spacer(),
          // Standard Search or Actions
          IconButton(
            onPressed: () {}, 
            icon: const Icon(Icons.filter_list, color: AppColors.textWhite54),
            tooltip: "Filter",
          ),
        ],
      ),
    );
  }
}