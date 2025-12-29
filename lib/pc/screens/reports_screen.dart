import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/providers/report_builder_provider.dart';
import '../widgets/sidebar.dart';
import '../widgets/reports/reports_header.dart';
import '../widgets/reports/report_card.dart'; // Ensure this file exists or remove import

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // A. Top Cards Section
                        _buildTopCardsSection(context),
                        const SizedBox(height: 32),
                        
                        // B. Custom Report Builder
                        _buildCustomReportBuilder(context, ref),
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

  // --- TOP CARDS SECTION ---
  Widget _buildTopCardsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Generate Reports", style: TextStyle(color: AppColors.textWhite, fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text("Select parameters to create custom insights or view recent exports.", style: TextStyle(color: AppColors.textWhite54)),
              ],
            ),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () {}, 
                  icon: const Icon(Icons.history, size: 16),
                  label: const Text("Saved Reports"),
                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.textWhite, side: const BorderSide(color: AppColors.divider), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18)),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {
                     // Implement Create Template Dialog
                     // showDialog(context: context, builder: (_) => const CreateTemplateDialog());
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text("Create New Template"),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18)),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 220, // Fixed height for uniformity
          child: Row(
            children: [
              Expanded(child: ReportCard(
                title: "Financial Summary",
                desc: "Comprehensive overview of income, expenses, and net revenue.",
                icon: Icons.account_balance,
                color: AppColors.primaryBlue,
                tags: const ["PDF", "CSV", "Excel"],
                isPopular: true,
                onTap: () {},
              )),
              const SizedBox(width: 24),
              Expanded(child: ReportCard(
                title: "Enrollment Trends",
                desc: "Analyze student capacity, retention rates, and new admissions.",
                icon: Icons.people_alt,
                color: AppColors.accentPurple,
                tags: const ["PDF", "Excel"],
                onTap: () {},
              )),
              const SizedBox(width: 24),
              Expanded(child: ReportCard(
                title: "Outstanding Balances",
                desc: "Detailed list of unpaid tuitions and payment aging reports.",
                icon: Icons.warning_amber_rounded,
                color: AppColors.errorRed,
                tags: const ["PDF", "CSV"],
                onTap: () {},
              )),
            ],
          ),
        ),
      ],
    );
  }

  // --- REPORT BUILDER SECTION ---
  Widget _buildCustomReportBuilder(BuildContext context, WidgetRef ref) {
    // Watching the state provided in previous steps
    final reportState = ref.watch(reportBuilderProvider);
    final notifier = ref.read(reportBuilderProvider.notifier);
    // This calls the helper provider to get the summary map
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
                    Text("Custom Report Builder", style: TextStyle(color: AppColors.textWhite, fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text("Configure specific data points to generate a one-time report.", style: TextStyle(color: AppColors.textWhite54)),
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
                        items: ["Tuition & Fee Collection", "Expense Analysis", "Student Attendance", "Payroll Summary"],
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
                                _buildDateRangePicker(context, reportState.dateRange, (range) => notifier.setDateRange(range)),
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
                                  items: ["All Grades", "Grade 1", "Grade 2", "Grade 3", "Grade 4", "Grade 5"],
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
                          _buildRadioTile("PDF Document", "Best for printing", reportState.exportFormat == 'PDF', () => notifier.setExportFormat('PDF')),
                          const SizedBox(width: 16),
                          _buildRadioTile("Excel / CSV", "Best for analysis", reportState.exportFormat == 'Excel/CSV', () => notifier.setExportFormat('Excel/CSV')),
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
                        const Text("SUMMARY", style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 12)),
                        const SizedBox(height: 24),
                        
                        _buildSummaryRow("Type:", summary['Type']!),
                        _buildSummaryRow("Period:", summary['Period']!),
                        _buildSummaryRow("Scope:", summary['Scope']!),
                        _buildSummaryRow("Format:", summary['Format']!), 
                        
                        const SizedBox(height: 32),
                        
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // Trigger Report Generation Logic via Provider
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text("Generate Report", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              // Trigger Preview Dialog
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.divider),
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text("Preview Data", style: TextStyle(color: AppColors.textWhite)),
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
      child: Text(text, style: const TextStyle(color: AppColors.textWhite70, fontSize: 13)),
    );
  }

  Widget _buildDropdown({required String value, required List<String> items, required Function(String?) onChanged}) {
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
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textWhite54),
          style: const TextStyle(color: AppColors.textWhite),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildDateRangePicker(BuildContext context, DateTimeRange current, Function(DateTimeRange) onSelect) {
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
            const Icon(Icons.calendar_today, size: 16, color: AppColors.textWhite54),
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

  Widget _buildRadioTile(String title, String sub, bool selected, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryBlue.withValues(alpha: 0.1) : AppColors.backgroundBlack,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: selected ? AppColors.primaryBlue : AppColors.divider),
          ),
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: selected ? AppColors.primaryBlue : AppColors.textWhite54,
                size: 20,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: selected ? AppColors.primaryBlue : AppColors.textWhite, fontWeight: FontWeight.bold, fontSize: 13)),
                  Text(sub, style: const TextStyle(color: AppColors.textWhite38, fontSize: 11)),
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
          Text(label, style: const TextStyle(color: AppColors.textWhite54, fontSize: 13)),
          Text(value, style: const TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.w600, fontSize: 13, letterSpacing: 0.5), textAlign: TextAlign.end),
        ],
      ),
    );
  }
}