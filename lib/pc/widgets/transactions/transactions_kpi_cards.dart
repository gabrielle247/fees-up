import 'package:fees_up/data/models/transaction_stats.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/providers/dashboard_provider.dart';
import '../../../data/providers/transactions_provider.dart';

class TransactionsKpiCards extends ConsumerWidget {
  const TransactionsKpiCards({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardDataProvider);

    return dashboardAsync.when(
      data: (dashboard) {
        final statsAsync =
            ref.watch(transactionStatsProvider(dashboard.schoolId));

        return statsAsync.when(
          data: (stats) => _buildCards(stats),
          loading: () => _buildLoadingCards(),
          error: (err, stack) =>
              _buildErrorCards(ref, dashboard.schoolId, err.toString()),
        );
      },
      loading: () => _buildLoadingCards(),
      error: (err, stack) => _buildSimpleErrorCards(err.toString()),
    );
  }

  Widget _buildCards(TransactionStats stats) {
    final formatter = NumberFormat.simpleCurrency();

    return Row(
      children: [
        _buildCard(
          title: "TOTAL INCOME",
          value: formatter.format(stats.totalIncome),
          icon: Icons.trending_up,
          color: AppColors.successGreen,
        ),
        const SizedBox(width: 24),
        _buildCard(
          title: "TOTAL EXPENSES",
          value: formatter.format(stats.totalExpenses),
          icon: Icons.trending_down,
          color: AppColors.errorRed,
        ),
        const SizedBox(width: 24),
        _buildCard(
          title: "PENDING",
          value: formatter.format(stats.pendingAmount),
          icon: Icons.pending_actions,
          color: AppColors.primaryBlue,
        ),
        const SizedBox(width: 24),
        _buildCard(
          title: "DONATIONS",
          value: formatter.format(stats.totalDonations),
          icon: Icons.volunteer_activism,
          color: AppColors.accentPurple,
        ),
      ],
    );
  }

  Widget _buildLoadingCards() {
    return Row(
      children: List.generate(
          4,
          (index) => Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: index < 3 ? 24 : 0),
                  height: 100,
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

  Widget _buildErrorCards(WidgetRef ref, String schoolId, String error) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.errorRed.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.errorRed.withValues(alpha: 0.3)),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline,
                color: AppColors.errorRed, size: 24),
            const SizedBox(width: 12),
            const Text('Failed to load stats',
                style: TextStyle(color: AppColors.textWhite)),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: () =>
                  ref.invalidate(transactionStatsProvider(schoolId)),
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

  Widget _buildSimpleErrorCards(String error) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.errorRed.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Text('Error loading data',
            style: TextStyle(color: AppColors.errorRed)),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
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
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textWhite54,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                      style: const TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
