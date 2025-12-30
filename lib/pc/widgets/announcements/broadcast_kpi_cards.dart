import 'package:fees_up/data/providers/broadcast_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';

class BroadcastKpiCards extends ConsumerWidget {
  const BroadcastKpiCards({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(broadcastFeedProvider);

    return feedAsync.when(
      data: (broadcasts) {
        //  logic
        
        // 1. Critical: Priority is 'high' or 'critical'
        final criticalCount = broadcasts.where((b) => 
          b.priority == 'high' || b.priority == 'critical'
        ).length;

        // 2. System: Messages from HQ (isSystemMessage == true)
        final systemCount = broadcasts.where((b) => b.isSystemMessage).length;

        // 3. Active: Total messages currently in the feed (Service handles expiration)
        final activeCount = broadcasts.length;

        return Row(
          children: [
            _buildCard(
              "Critical Alerts", 
              criticalCount.toString(), 
              Icons.warning_amber_rounded, 
              AppColors.errorRed, 
              AppColors.errorRedBg
            ),
            const SizedBox(width: 24),
            _buildCard(
              "System Notices", 
              systemCount.toString(), 
              Icons.verified_user_outlined, 
              const Color(0xFF9333EA), // Purple for HQ
              const Color(0xFF9333EA).withValues(alpha: 0.1),
            ),
            const SizedBox(width: 24),
            _buildCard(
              "Active Broadcasts", 
              activeCount.toString(), 
              Icons.campaign_outlined, 
              AppColors.successGreen, 
              AppColors.successGreenBg
            ),
          ],
        );
      },
      loading: () => _buildLoadingState(),
      error: (e, s) => _buildErrorState(),
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
              decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
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

  Widget _buildLoadingState() {
    return Row(children: List.generate(3, (i) => Expanded(
      child: Container(
        height: 100,
        margin: EdgeInsets.only(left: i == 0 ? 0 : 24),
        decoration: BoxDecoration(
          color: AppColors.surfaceGrey,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
    )));
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.errorRed.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8)
      ),
      child: const Text("Unable to load statistics", style: TextStyle(color: AppColors.errorRed)),
    );
  }
}