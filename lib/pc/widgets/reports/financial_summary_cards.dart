import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/providers/financial_reports_provider.dart';

/// Financial Summary Cards Fragment - Displays invoice and transaction stats
/// Complies with Law of Fragments: Encapsulated financial data cards
class FinancialSummaryCards extends ConsumerWidget {
  final String schoolId;
  final VoidCallback? onInvoiceCardTap;
  final VoidCallback? onTransactionCardTap;
  final VoidCallback? onGenerateReport;

  const FinancialSummaryCards({
    super.key,
    required this.schoolId,
    this.onInvoiceCardTap,
    this.onTransactionCardTap,
    this.onGenerateReport,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoiceStatsAsync = ref.watch(invoiceStatsProvider(
      InvoiceStatsParams(schoolId: schoolId),
    ));
    final transactionSummaryAsync = ref.watch(transactionSummaryProvider(
      TransactionSummaryParams(schoolId: schoolId),
    ));

    return SizedBox(
      height: 220,
      child: Row(
        children: [
          Expanded(
            child: invoiceStatsAsync.when(
              data: (stats) => _InvoiceStatsCard(
                stats: stats,
                onTap: onInvoiceCardTap,
              ),
              loading: () => _buildLoadingCard(0),
              error: (err, _) => _buildErrorCard(
                'Failed to load invoice stats: $err',
                ref,
                schoolId,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: transactionSummaryAsync.when(
              data: (summary) => _TransactionSummaryCard(
                summary: summary,
                onTap: onTransactionCardTap,
              ),
              loading: () => _buildLoadingCard(1),
              error: (err, _) => _buildErrorCard(
                'Failed to load transactions: $err',
                ref,
                schoolId,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _QuickActionCard(onGenerateReport: onGenerateReport),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard(int index) {
    return Container(
      margin: EdgeInsets.only(right: index < 2 ? 16 : 0),
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
    );
  }

  Widget _buildErrorCard(String error, WidgetRef ref, String schoolId) {
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
            const Icon(Icons.error_outline,
                color: AppColors.errorRed, size: 32),
            const SizedBox(height: 8),
            const Text(
              'Failed to load',
              style: TextStyle(
                color: AppColors.textWhite,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(invoiceStatsProvider(
                  InvoiceStatsParams(schoolId: schoolId),
                ));
                ref.invalidate(transactionSummaryProvider(
                  TransactionSummaryParams(schoolId: schoolId),
                ));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text('Retry', style: TextStyle(fontSize: 11)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Invoice Stats Card Widget
class _InvoiceStatsCard extends StatelessWidget {
  final Map<String, dynamic> stats;
  final VoidCallback? onTap;

  const _InvoiceStatsCard({required this.stats, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceGrey,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Invoice Statistics',
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlueBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.receipt_long,
                    color: AppColors.primaryBlue,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              '\$${NumberFormat('#,##0.00').format(stats['total_billed'] ?? 0)}',
              style: const TextStyle(
                color: AppColors.textWhite,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Total Billed (${stats['total_invoices'] ?? 0} invoices)',
              style:
                  const TextStyle(color: AppColors.textWhite54, fontSize: 12),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildMiniStat('Collected',
                    '\$${NumberFormat('#,##0').format(stats['total_collected'] ?? 0)}'),
                const Spacer(),
                _buildMiniStat('Rate', '${stats['collection_rate'] ?? 0}%'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textWhite38, fontSize: 10),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

/// Transaction Summary Card Widget
class _TransactionSummaryCard extends StatelessWidget {
  final Map<String, dynamic> summary;
  final VoidCallback? onTap;

  const _TransactionSummaryCard({required this.summary, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceGrey,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Transaction Summary',
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.successGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet,
                    color: AppColors.successGreen,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              '${summary['total_count'] ?? 0} Transactions',
              style: const TextStyle(
                color: AppColors.textWhite,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Last 30 days',
              style: TextStyle(color: AppColors.textWhite54, fontSize: 12),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildMiniStat('Revenue',
                    '\$${NumberFormat('#,##0').format(summary['total_revenue'] ?? 0)}'),
                const Spacer(),
                _buildMiniStat('Expenses',
                    '\$${NumberFormat('#,##0').format(summary['total_expenses'] ?? 0)}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textWhite38, fontSize: 10),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.successGreen,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

/// Quick Action Card - Generate Report Button
class _QuickActionCard extends StatelessWidget {
  final VoidCallback? onGenerateReport;

  const _QuickActionCard({this.onGenerateReport});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryBlue, AppColors.accentPurple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.auto_graph, color: Colors.white, size: 40),
          const SizedBox(height: 16),
          const Text(
            'Quick Export',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Generate a comprehensive financial report',
            style: TextStyle(color: Colors.white70, fontSize: 11),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onGenerateReport,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primaryBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Generate'),
          ),
        ],
      ),
    );
  }
}
