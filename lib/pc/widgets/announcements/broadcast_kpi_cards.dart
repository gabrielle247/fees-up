import 'package:fees_up/data/providers/broadcast_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';

class BroadcastKpiCards extends ConsumerWidget {
  const BroadcastKpiCards({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // --- THE FIX: AGGREGATED CONTEXT ---
    // We watch both streams to provide a holistic view for the Super Admin
    final schoolFeedAsync = ref.watch(schoolBroadcastProvider);
    final hqFeedAsync = ref.watch(internalHQBroadcastProvider);

    return Row(
      children: [
        // 1. Critical Alerts (From School Feed)
        _buildAsyncCard(
          schoolFeedAsync,
          title: "Critical Alerts",
          icon: Icons.warning_amber_rounded,
          color: AppColors.errorRed,
          bgColor: AppColors.errorRedBg,
          countLogic: (list) => list.where((b) => b.priority == 'critical').length,
        ),
        const SizedBox(width: 24),

        // 2. System Notices (From Greyway HQ Feed)
        // Loophole Closed: This now tracks Global HQ alerts specifically [cite: 2025-12-30]
        _buildAsyncCard(
          hqFeedAsync,
          title: "HQ Internal",
          icon: Icons.security_outlined,
          color: AppColors.accentPurple,
          bgColor: AppColors.accentPurple.withAlpha(25),
          countLogic: (list) => list.length,
        ),
        const SizedBox(width: 24),

        // 3. Active Broadcasts (Total Local School messages)
        _buildAsyncCard(
          schoolFeedAsync,
          title: "Active Broadcasts",
          icon: Icons.campaign_outlined,
          color: AppColors.successGreen,
          bgColor: AppColors.successGreenBg,
          countLogic: (list) => list.length,
        ),
      ],
    );
  }

  /// Helper to build cards that handle their own loading/error states per stream [cite: 2025-12-30]
  Widget _buildAsyncCard(
    AsyncValue<List<dynamic>> asyncValue, {
    required String title,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required int Function(List<dynamic>) countLogic,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceGrey,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: asyncValue.when(
          data: (list) => Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: AppColors.textWhite70, fontSize: 13)),
                  Text(
                    countLogic(list).toString(),
                    style: const TextStyle(color: AppColors.textWhite, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          loading: () => const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
          error: (_, __) => const Icon(Icons.error_outline, color: AppColors.errorRed, size: 20),
        ),
      ),
    );
  }
}