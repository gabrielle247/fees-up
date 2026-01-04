import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/providers/invoices_provider.dart';
import '../../../../data/providers/device_authority_provider.dart';

class InvoicesStats extends ConsumerWidget {
  final String schoolId;
  final VoidCallback onCreateInvoice;

  const InvoicesStats({
    super.key,
    required this.schoolId,
    required this.onCreateInvoice,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(invoiceStatsProvider(schoolId));

    return SizedBox(
      height: 140,
      child: _buildStatsRow(stats, ref),
    );
  }

  Widget _buildStatsRow(InvoiceStats stats, WidgetRef ref) {
    final formatter = NumberFormat.simpleCurrency();

    final totalBilled = stats.totalBilled;
    final pendingAmount = stats.pendingAmount;
    final overdueAmount = stats.overdueAmount;
    final totalInvoices = stats.totalInvoices;
    final paidCount = stats.paidCount;
    final overdueCount = stats.overdueCount;
    final collectionRate = stats.collectionRate;

    return Row(
      children: [
        // 1. Total Invoiced
        Expanded(
          child: _StatCard(
            title: "Total Invoiced",
            value: formatter.format(totalBilled),
            subtext:
                "$totalInvoices invoices • ${collectionRate.toStringAsFixed(1)}% collected",
            subtextColor: AppColors.successGreen,
            icon: Icons.bar_chart,
            iconColor: AppColors.primaryBlue,
          ),
        ),
        const SizedBox(width: 16),

        // 2. Pending Payment
        Expanded(
          child: _StatCard(
            title: "Pending Payment",
            value: formatter.format(pendingAmount),
            subtext: "${totalInvoices - paidCount} active invoices",
            subtextColor: AppColors.warningOrange,
            icon: Icons.pending_actions,
            iconColor: AppColors.warningOrange,
          ),
        ),
        const SizedBox(width: 16),

        // 3. Overdue
        Expanded(
          child: _StatCard(
            title: "Overdue",
            value: formatter.format(overdueAmount),
            subtext: overdueCount > 0
                ? "Needs attention ($overdueCount students)"
                : "All payments on track",
            subtextColor:
                overdueCount > 0 ? AppColors.errorRed : AppColors.successGreen,
            icon: Icons.warning_amber_rounded,
            iconColor:
                overdueCount > 0 ? AppColors.errorRed : AppColors.successGreen,
          ),
        ),
        const SizedBox(width: 16),

        // 4. Create New Action Card
        Expanded(
          child: _CreateInvoiceCard(
            onTap: onCreateInvoice,
            schoolId: schoolId,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtext;
  final Color subtextColor;
  final IconData icon;
  final Color iconColor;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtext,
    required this.subtextColor,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style:
                      const TextStyle(color: AppColors.textGrey, fontSize: 13)),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withAlpha(38),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: const TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(subtext,
                  style: TextStyle(
                      color: subtextColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}

class _CreateInvoiceCard extends ConsumerWidget {
  final VoidCallback onTap;
  final String schoolId;

  const _CreateInvoiceCard({
    required this.onTap,
    required this.schoolId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBillingEngineAsync = ref.watch(isBillingEngineProvider(schoolId));

    return isBillingEngineAsync.when(
      data: (isBillingEngine) {
        if (!isBillingEngine) {
          // Non-billing engine: Show read-only card
          return Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceDarkGrey.withAlpha(128),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider.withAlpha(128)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: AppColors.textWhite54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock,
                      color: AppColors.textWhite38, size: 24),
                ),
                const SizedBox(height: 12),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    children: [
                      Text(
                        "Read-Only",
                        style: TextStyle(
                          color: AppColors.textWhite70,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Billing engine only",
                        style: TextStyle(
                          color: AppColors.textWhite38,
                          fontSize: 11,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        // Billing engine: Show interactive create button
        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceDarkGrey,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppColors.divider,
                  style: BorderStyle
                      .solid), // Dashed effect requires custom painter, using solid for now to stay clean
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withAlpha(26),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add,
                      color: AppColors.primaryBlue, size: 24),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Create New Invoice",
                  style: TextStyle(
                      color: AppColors.textWhite, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceGrey,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryBlue,
            strokeWidth: 2,
          ),
        ),
      ),
      error: (err, _) => Container(
        decoration: BoxDecoration(
          color: AppColors.errorRed.withAlpha(26),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.errorRed.withAlpha(77)),
        ),
        child: const Center(
          child: Icon(Icons.error_outline, color: AppColors.errorRed),
        ),
      ),
    );
  }
}
