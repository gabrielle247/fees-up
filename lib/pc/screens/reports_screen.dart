import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/providers/report_builder_provider.dart';
import '../../../../data/providers/dashboard_provider.dart';
import '../../../../data/providers/financial_reports_provider.dart';
import '../widgets/sidebar.dart';
import '../widgets/reports/reports_header.dart';
import '../widgets/reports/report_card.dart'; // Ensure this file exists or remove import
import '../widgets/settings/billing_period_dialog.dart';

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
                // 1. Standardized Header
                const ReportsHeader(),
                const Divider(height: 1, color: AppColors.divider),

                // 2. Scrollable Body
                Expanded(
                  child: dashboardAsync.when(
                    data: (dashboard) => SingleChildScrollView(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // A. Top Cards Section
                          _buildTopCardsSection(
                              context, ref, dashboard.schoolId),
                          const SizedBox(height: 32),

                          // B. Custom Report Builder
                          _buildCustomReportBuilder(context, ref),
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

  Widget _buildTopCardsSection(
      BuildContext context, WidgetRef ref, String schoolId) {
    // Fetch real-time financial data
    final invoiceStatsAsync = ref.watch(invoiceStatsProvider(InvoiceStatsParams(
      schoolId: schoolId,
    )));
    final transactionSummaryAsync =
        ref.watch(transactionSummaryProvider(TransactionSummaryParams(
      schoolId: schoolId,
    )));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Generate Reports",
                    style: TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 24,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text(
                    "Select parameters to create custom insights or view recent exports.",
                    style: TextStyle(color: AppColors.textWhite54)),
              ],
            ),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    // Launch billing configuration dialog
                    showBillingPeriodDialog(context, schoolId: schoolId);
                  },
                  icon: const Icon(Icons.settings, size: 16),
                  label: const Text("Configure Billing"),
                  style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textWhite,
                      side: const BorderSide(color: AppColors.divider),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 18)),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    // Implement Create Template Dialog
                    // showDialog(context: context, builder: (_) => const CreateTemplateDialog());
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text("Create New Template"),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 18)),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Live Financial Stats Cards
        invoiceStatsAsync.when(
          data: (invoiceStats) => transactionSummaryAsync.when(
            data: (transactionStats) => SizedBox(
              height: 220,
              child: Row(
                children: [
                  Expanded(
                      child: ReportCard(
                    title: "Financial Summary",
                    desc:
                        "Total billed: \$${NumberFormat('#,##0.00').format(invoiceStats['total_billed'] ?? 0)} | Collected: \$${NumberFormat('#,##0.00').format(invoiceStats['total_collected'] ?? 0)}",
                    icon: Icons.account_balance,
                    color: AppColors.primaryBlue,
                    tags: const ["PDF", "CSV", "Excel"],
                    onTap: () => _generateReport(
                        context, ref, schoolId, 'financial_summary'),
                  )),
                  const SizedBox(width: 16),
                  Expanded(
                      child: ReportCard(
                    title: "Invoice Statistics",
                    desc:
                        "${invoiceStats['total_invoices'] ?? 0} invoices | ${invoiceStats['paid_count'] ?? 0} paid | ${invoiceStats['collection_rate'] ?? 0}% rate",
                    icon: Icons.receipt_long,
                    color: AppColors.successGreen,
                    tags: const ["PDF", "Excel"],
                    onTap: () => _generateReport(
                        context, ref, schoolId, 'invoice_stats'),
                  )),
                  const SizedBox(width: 16),
                  Expanded(
                      child: ReportCard(
                    title: "Transaction Summary",
                    desc:
                        "\$${NumberFormat('#,##0.00').format(transactionStats['total_revenue'] ?? 0)} revenue | ${transactionStats['transaction_count'] ?? 0} transactions",
                    icon: Icons.payment,
                    color: AppColors.successGreen,
                    tags: const ["PDF", "CSV"],
                    onTap: () => _generateReport(
                        context, ref, schoolId, 'transaction_summary'),
                  )),
                ],
              ),
            ),
            loading: () => _buildLoadingCards(),
            error: (err, stack) => _buildErrorCards(err.toString()),
          ),
          loading: () => _buildLoadingCards(),
          error: (err, stack) => _buildErrorCards(err.toString()),
        ),
      ],
    );
  }

  Widget _buildLoadingCards() {
    return SizedBox(
      height: 220,
      child: Row(
        children: List.generate(
          3,
          (index) => Expanded(
            child: Container(
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
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCards(String error) {
    return SizedBox(
      height: 220,
      child: Container(
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
                  color: AppColors.errorRed, size: 48),
              const SizedBox(height: 16),
              Text(
                'Failed to load reports',
                style: const TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: const TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _generateReport(
      BuildContext context, WidgetRef ref, String schoolId, String reportType) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Generating $reportType report...'),
        backgroundColor: AppColors.primaryBlue,
      ),
    );
  }

  Widget _buildCustomReportBuilder(BuildContext context, WidgetRef ref) {
    final reportState = ref.watch(reportBuilderProvider);
    final notifier = ref.read(reportBuilderProvider.notifier);
    final summary = ref.watch(reportSummaryProvider);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceGrey,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          // Header
          const Padding(
            padding: EdgeInsets.all(24),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Custom Report Builder",
                        style: TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text(
                        "Configure specific data points to generate a one-time report.",
                        style: TextStyle(color: AppColors.textWhite54)),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),

          // Form & Summary Row
          Padding(
            padding: const EdgeInsets.all(32),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // LEFT: FORM
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Report Category"),
                      _buildDropdown(
                        value: reportState.category,
                        items: [
                          "Tuition & Fee Collection",
                          "Expense Analysis",
                          "Student Attendance",
                          "Payroll Summary"
                        ],
                        onChanged: (v) => notifier.setCategory(v!),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel("Date Range"),
                                _buildDateRangePicker(
                                    context,
                                    reportState.dateRange,
                                    (range) => notifier.setDateRange(range)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel("Grade Level / Department"),
                                _buildDropdown(
                                  value: reportState.gradeFilter,
                                  items: [
                                    "All Grades",
                                    "Grade 1",
                                    "Grade 2",
                                    "Grade 3",
                                    "Grade 4",
                                    "Grade 5"
                                  ],
                                  onChanged: (v) => notifier.setGradeFilter(v!),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildLabel("Export Format"),
                      Row(
                        children: [
                          _buildRadioTile(
                              "PDF Document",
                              "Best for printing",
                              reportState.exportFormat == 'PDF',
                              () => notifier.setExportFormat('PDF')),
                          const SizedBox(width: 16),
                          _buildRadioTile(
                              "Excel / CSV",
                              "Best for analysis",
                              reportState.exportFormat == 'Excel/CSV',
                              () => notifier.setExportFormat('Excel/CSV')),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 48),

                // RIGHT: SUMMARY PANEL
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundBlack,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("SUMMARY",
                            style: TextStyle(
                                color: AppColors.textWhite,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                                fontSize: 12)),
                        const SizedBox(height: 24),
                        _buildSummaryRow("Type:", summary['Type']!),
                        _buildSummaryRow("Period:", summary['Period']!),
                        _buildSummaryRow("Scope:", summary['Scope']!),
                        _buildSummaryRow("Format:", summary['Format']!),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              // Trigger Report Generation Logic via Provider
                              final dashboard =
                                  await ref.read(dashboardDataProvider.future);
                              _generateReport(context, ref, dashboard.schoolId,
                                  reportState.category);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text("Generate Report",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final dashboard =
                                  await ref.read(dashboardDataProvider.future);
                              _showPreviewDialog(context, ref,
                                  dashboard.schoolId, reportState);
                            },
                            icon: const Icon(Icons.preview, size: 16),
                            label: const Text("Preview Data"),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textWhite,
                              side: const BorderSide(color: AppColors.divider),
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
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

  // --- UI HELPERS ---

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text,
          style: const TextStyle(color: AppColors.textWhite70, fontSize: 13)),
    );
  }

  Widget _buildDropdown(
      {required String value,
      required List<String> items,
      required Function(String?) onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.backgroundBlack,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : items.first,
          isExpanded: true,
          dropdownColor: AppColors.surfaceGrey,
          icon: const Icon(Icons.keyboard_arrow_down,
              color: AppColors.textWhite54),
          style: const TextStyle(color: AppColors.textWhite),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildDateRangePicker(BuildContext context, DateTimeRange current,
      Function(DateTimeRange) onSelect) {
    return InkWell(
      onTap: () async {
        final picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          initialDateRange: current,
          builder: (context, child) => Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: const ColorScheme.dark(
                primary: AppColors.primaryBlue,
                onPrimary: Colors.white,
                surface: AppColors.surfaceGrey,
                onSurface: AppColors.textWhite,
              ),
            ),
            child: child!,
          ),
        );
        if (picked != null) onSelect(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.backgroundBlack,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today,
                size: 16, color: AppColors.textWhite54),
            const SizedBox(width: 12),
            Text(
              "${DateFormat('MMM d, yyyy').format(current.start)} - ${DateFormat('MMM d, yyyy').format(current.end)}",
              style: const TextStyle(color: AppColors.textWhite),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioTile(
      String title, String sub, bool selected, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primaryBlue.withValues(alpha: 0.1)
                : AppColors.backgroundBlack,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: selected ? AppColors.primaryBlue : AppColors.divider),
          ),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: selected ? AppColors.primaryBlue : AppColors.textWhite54,
                size: 20,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          color: selected
                              ? AppColors.primaryBlue
                              : AppColors.textWhite,
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
                  Text(sub,
                      style: const TextStyle(
                          color: AppColors.textWhite38, fontSize: 11)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  const TextStyle(color: AppColors.textWhite54, fontSize: 13)),
          Text(value,
              style: const TextStyle(
                  color: AppColors.textWhite,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  letterSpacing: 0.5),
              textAlign: TextAlign.end),
        ],
      ),
    );
  }

  void _showPreviewDialog(BuildContext context, WidgetRef ref, String schoolId,
      ReportBuilderState reportState) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 800,
          height: 600,
          decoration: BoxDecoration(
            color: AppColors.backgroundBlack,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.surfaceLightGrey),
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    const Icon(Icons.preview, color: AppColors.primaryBlue),
                    const SizedBox(width: 16),
                    const Text(
                      'Report Preview',
                      style: TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: AppColors.textGrey),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.divider),

              // Content
              Expanded(
                child: Consumer(
                  builder: (context, ref, child) {
                    final invoiceStatsAsync =
                        ref.watch(invoiceStatsProvider(InvoiceStatsParams(
                      schoolId: schoolId,
                      startDate: reportState.dateRange.start,
                      endDate: reportState.dateRange.end,
                    )));

                    return invoiceStatsAsync.when(
                      data: (stats) => SingleChildScrollView(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildPreviewSection('Invoice Statistics', [
                              _buildPreviewRow('Total Invoices',
                                  stats['total_invoices'].toString()),
                              _buildPreviewRow('Paid Invoices',
                                  stats['paid_count'].toString()),
                              _buildPreviewRow('Pending Invoices',
                                  stats['sent_count'].toString()),
                              _buildPreviewRow('Total Billed',
                                  '\$${NumberFormat('#,##0.00').format(stats['total_billed'])}'),
                              _buildPreviewRow('Total Collected',
                                  '\$${NumberFormat('#,##0.00').format(stats['total_collected'])}'),
                              _buildPreviewRow('Collection Rate',
                                  '${stats['collection_rate']}%'),
                            ]),
                          ],
                        ),
                      ),
                      loading: () => const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primaryBlue),
                      ),
                      error: (err, stack) => Center(
                        child: Text(
                          'Error loading preview: $err',
                          style: const TextStyle(color: AppColors.errorRed),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Footer
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: AppColors.divider)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewSection(String title, List<Widget> rows) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textWhite,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceGrey,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(children: rows),
        ),
      ],
    );
  }

  Widget _buildPreviewRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.textWhite70),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textWhite,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
