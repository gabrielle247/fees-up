import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import 'stat_cards.dart';

/// KPI Section Fragment - Displays key performance indicators
/// Complies with Law of Fragments: Encapsulates KPI logic and display
class KpiSection extends ConsumerWidget {
  final double outstandingBalance;
  final int studentCount;
  final AsyncValue fundraisingAsync;

  const KpiSection({
    super.key,
    required this.outstandingBalance,
    required this.studentCount,
    required this.fundraisingAsync,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: StatCard(
            title: "Outstanding Bills",
            value: NumberFormat.simpleCurrency().format(outstandingBalance),
            icon: Icons.receipt_long,
            iconColor: AppColors.errorRed,
            iconBgColor: AppColors.errorRedBg,
            isAlert: outstandingBalance > 0,
            footer: const AlertBadge(text: "Updated", subText: "Just now"),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: fundraisingAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const SizedBox(),
            data: (fundData) {
              if (fundData == null) {
                return const StatCard(
                  title: "No Active Campaign",
                  value: "-",
                  icon: Icons.volunteer_activism,
                  iconColor: AppColors.iconGrey,
                  iconBgColor: AppColors.divider,
                );
              }
              return StatCard(
                title: fundData.campaignName,
                value: "${fundData.percentage.toStringAsFixed(1)}%",
                icon: Icons.volunteer_activism,
                iconColor: AppColors.accentPurple,
                iconBgColor: AppColors.purpleBg,
                footer: Text(
                  "Raised \$${fundData.raisedAmount.toInt()} of \$${fundData.goalAmount.toInt()}",
                  style: const TextStyle(
                    color: AppColors.textWhite38,
                    fontSize: 11,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: StatCard(
            title: "Active Students",
            value: studentCount.toString(),
            icon: Icons.school,
            iconColor: AppColors.primaryBlue,
            iconBgColor: AppColors.primaryBlueBg,
            footer: const Text(
              "Enrolled",
              style: TextStyle(color: AppColors.textWhite38, fontSize: 11),
            ),
          ),
        ),
      ],
    );
  }
}
