import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/announcement_model.dart';
import '../../../../data/providers/notifications_provider.dart';

class NotificationsKpiCards extends ConsumerWidget {
  const NotificationsKpiCards({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return notificationsAsync.when(
      data: (notifications) {
        // Safe Calculation
        final urgentUnread = notifications
            .where((n) => n.category == AnnouncementCategory.urgent && !n.isRead)
            .length;
        
        final totalUnread = notifications
            .where((n) => !n.isRead)
            .length;

        final total = notifications.length;

        return Row(
          children: [
            _buildCard(
              "Urgent Alerts", 
              urgentUnread.toString(), 
              Icons.warning_amber_rounded, 
              AppColors.errorRed,
              AppColors.errorRed.withValues(alpha: 0.1)
            ),
            const SizedBox(width: 24),
            _buildCard(
              "New Messages", 
              totalUnread.toString(), 
              Icons.mark_email_unread_outlined, 
              AppColors.primaryBlue,
              AppColors.primaryBlue.withValues(alpha: 0.1)
            ),
            const SizedBox(width: 24),
            _buildCard(
              "Total History", 
              total.toString(), 
              Icons.history, 
              AppColors.successGreen,
              AppColors.successGreen.withValues(alpha: 0.1)
            ),
          ],
        );
      },
      // Shimmer / Skeleton Loading State
      loading: () => Row(
        children: List.generate(3, (index) => Expanded(
          child: Container(
            height: 100,
            margin: EdgeInsets.only(left: index == 0 ? 0 : 24),
            decoration: BoxDecoration(
              color: AppColors.surfaceGrey,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
        )),
      ),
      // Graceful Error State
      error: (e, s) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.errorRed.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text("System Alerts unavailable at the moment.", style: TextStyle(color: AppColors.errorRed)),
      ),
    );
  }

  Widget _buildCard(String title, String count, IconData icon, Color color, Color bg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceGrey,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppColors.textWhite70, fontSize: 13)),
                Text(count, style: const TextStyle(color: AppColors.textWhite, fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}