import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/providers/report_builder_provider.dart';
import 'report_preview_dialog.dart';

/// Custom Report Builder Fragment - Form for building custom reports
/// Complies with Law of Fragments: Self-contained report builder logic
class CustomReportBuilderWidget extends ConsumerWidget {
  final String schoolId;

  const CustomReportBuilderWidget({
    super.key,
    required this.schoolId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          const _BuilderHeader(),
          const Divider(height: 1, color: AppColors.divider),
          Padding(
            padding: const EdgeInsets.all(32),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: _ReportFormSection(
                    reportState: reportState,
                    notifier: notifier,
                  ),
                ),
                const SizedBox(width: 48),
                Expanded(
                  flex: 2,
                  child: _ReportSummaryPanel(
                    summary: summary,
                    reportState: reportState,
                    schoolId: schoolId,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Builder Header Widget
class _BuilderHeader extends StatelessWidget {
  const _BuilderHeader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Custom Report Builder",
                style: TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "Configure specific data points to generate a one-time report.",
                style: TextStyle(color: AppColors.textWhite54),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Report Form Section Widget
class _ReportFormSection extends StatelessWidget {
  final ReportBuilderState reportState;
  final ReportBuilderNotifier notifier;

  const _ReportFormSection({
    required this.reportState,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel("Report Category"),
        _buildDropdown(
          value: reportState.category,
          items: [
            "Tuition & Fee Collection",
            "Expense Analysis",
            "Student Attendance",
            "Payroll Summary",
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
                    (range) => notifier.setDateRange(range),
                  ),
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
                      "Grade 5",
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
              () => notifier.setExportFormat('PDF'),
            ),
            const SizedBox(width: 16),
            _buildRadioTile(
              "Excel / CSV",
              "Best for analysis",
              reportState.exportFormat == 'Excel/CSV',
              () => notifier.setExportFormat('Excel/CSV'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(color: AppColors.textWhite70, fontSize: 13),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
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
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.textWhite54,
          ),
          style: const TextStyle(color: AppColors.textWhite),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildDateRangePicker(
    BuildContext context,
    DateTimeRange current,
    Function(DateTimeRange) onSelect,
  ) {
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
            const Icon(
              Icons.calendar_today,
              size: 16,
              color: AppColors.textWhite54,
            ),
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
    String title,
    String sub,
    bool selected,
    VoidCallback onTap,
  ) {
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
              color: selected ? AppColors.primaryBlue : AppColors.divider,
            ),
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
                  Text(
                    title,
                    style: TextStyle(
                      color: selected
                          ? AppColors.primaryBlue
                          : AppColors.textWhite,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    sub,
                    style: const TextStyle(
                      color: AppColors.textWhite38,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Report Summary Panel Widget
class _ReportSummaryPanel extends ConsumerWidget {
  final Map<String, String> summary;
  final ReportBuilderState reportState;
  final String schoolId;

  const _ReportSummaryPanel({
    required this.summary,
    required this.reportState,
    required this.schoolId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.backgroundBlack,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "SUMMARY",
            style: TextStyle(
              color: AppColors.textWhite,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 24),
          _buildSummaryRow("Type:", summary['Type']!),
          _buildSummaryRow("Period:", summary['Period']!),
          _buildSummaryRow("Scope:", summary['Scope']!),
          _buildSummaryRow("Format:", summary['Format']!),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _generateReport(context, ref, reportState),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Generate Report",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => showReportPreviewDialog(
                context,
                ref,
                schoolId,
                reportState,
              ),
              icon: const Icon(Icons.preview, size: 16),
              label: const Text("Preview Data"),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textWhite,
                side: const BorderSide(color: AppColors.divider),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.textWhite54, fontSize: 13),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textWhite,
              fontWeight: FontWeight.w600,
              fontSize: 13,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.end,
          ),
        ],
      ),
    );
  }

  void _generateReport(
    BuildContext context,
    WidgetRef ref,
    ReportBuilderState reportState,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${reportState.category} export is coming soon'),
        backgroundColor: AppColors.primaryBlue,
      ),
    );
  }
}
