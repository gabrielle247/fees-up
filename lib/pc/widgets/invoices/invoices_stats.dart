import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/providers/financial_reports_provider.dart';

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
    final invoiceStatsAsync = ref.watch(invoiceStatsProvider(InvoiceStatsParams(
      schoolId: schoolId,
    )));

    return SizedBox(
      height: 140,
      child: invoiceStatsAsync.when(
        data: (stats) => _buildStatsRow(stats),
        loading: () => _buildLoadingRow(),
        error: (err, stack) => _buildErrorRow(ref, err.toString()),
      ),
    );
  }

  Widget _buildStatsRow(Map<String, dynamic> stats) {
    final formatter = NumberFormat.simpleCurrency();
    
    final totalBilled = (stats['total_billed'] as num?)?.toDouble() ?? 0.0;
    final totalCollected = (stats['total_collected'] as num?)?.toDouble() ?? 0.0;
    final pendingAmount = totalBilled - totalCollected;
    final overdueAmount = (stats['overdue_amount'] as num?)?.toDouble() ?? 0.0;
    final totalInvoices = (stats['total_invoices'] as int?) ?? 0;
    final paidCount = (stats['paid_count'] as int?) ?? 0;
    final overdueCount = (stats['overdue_count'] as int?) ?? 0;
    final collectionRate = (stats['collection_rate'] as num?)?.toDouble() ?? 0.0;

    return Row(
      children: [
        // 1. Total Invoiced
        Expanded(
          child: _StatCard(
            title: "Total Invoiced",
            value: formatter.format(totalBilled),
            subtext: "$totalInvoices invoices • ${collectionRate.toStringAsFixed(1)}% collected",
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
            subtextColor: overdueCount > 0 ? AppColors.errorRed : AppColors.successGreen,
            icon: Icons.warning_amber_rounded,
            iconColor: overdueCount > 0 ? AppColors.errorRed : AppColors.successGreen,
          ),
        ),
        const SizedBox(width: 16),

        // 4. Create New Action Card
        Expanded(
          child: _CreateInvoiceCard(onTap: onCreateInvoice),
        ),
      ],
    );
  }

  Widget _buildLoadingRow() {
    return Row(
      children: List.generate(4, (index) => Expanded(
        child: Container(
          margin: EdgeInsets.only(right: index < 3 ? 16 : 0),
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
      )),
    );
  }

  Widget _buildErrorRow(WidgetRef ref, String error) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.errorRed.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.errorRed.withValues(alpha: 0.3)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppColors.errorRed, size: 32),
            const SizedBox(height: 8),
            const Text(
              'Failed to load invoice stats',
              style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => ref.invalidate(invoiceStatsProvider(InvoiceStatsParams(schoolId: schoolId))),
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
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
              Text(title, style: const TextStyle(color: AppColors.textGrey, fontSize: 13)),
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
              Text(value, style: const TextStyle(color: AppColors.textWhite, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(subtext, style: TextStyle(color: subtextColor, fontSize: 12, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}

class _CreateInvoiceCard extends StatelessWidget {
  final VoidCallback onTap;
  const _CreateInvoiceCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceDarkGrey,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider, style: BorderStyle.solid), // Dashed effect requires custom painter, using solid for now to stay clean
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: AppColors.primaryBlue, size: 24),
            ),
            const SizedBox(height: 12),
            const Text(
              "Create New Invoice",
              style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}