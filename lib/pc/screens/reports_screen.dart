import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../data/providers/dashboard_provider.dart';
import '../widgets/sidebar.dart';
import '../widgets/reports/reports_header.dart';
import '../widgets/reports/financial_summary_cards.dart';
import '../widgets/reports/custom_report_builder.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardDataProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      body: Row(
        children: [
          const DashboardSidebar(),
          Expanded(
            child: Column(
              children: [
                const ReportsHeader(),
                const Divider(height: 1, color: AppColors.divider),
                Expanded(
                  child: dashboardAsync.when(
                    data: (dashboard) => SingleChildScrollView(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader(context),
                          const SizedBox(height: 24),
                          FinancialSummaryCards(
                            schoolId: dashboard.schoolId,
                            onGenerateReport: () =>
                                _generateQuickReport(context),
                          ),
                          const SizedBox(height: 32),
                          CustomReportBuilderWidget(
                            schoolId: dashboard.schoolId,
                          ),
                        ],
                      ),
                    ),
                    loading: () => const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    error: (err, stack) => Center(
                      child: Text(
                        'Error loading dashboard: $err',
                        style: const TextStyle(color: AppColors.errorRed),
                      ),
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

  Widget _buildSectionHeader(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Generate Reports",
          style: TextStyle(
            color: AppColors.textWhite,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          "Select parameters to create custom insights or view recent exports.",
          style: TextStyle(color: AppColors.textWhite54),
        ),
      ],
    );
  }

  void _generateQuickReport(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Quick export is coming soon'),
        backgroundColor: AppColors.primaryBlue,
      ),
    );
  }
}
