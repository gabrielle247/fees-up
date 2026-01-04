import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/providers/dashboard_provider.dart';
import '../../../../data/providers/financial_providers.dart';

class InvoicesTable extends ConsumerWidget {
  const InvoicesTable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardDataProvider);
    
    if (dashboardAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (dashboardAsync.hasError) {
      return Center(child: Text('Error: ${dashboardAsync.error}'));
    }
    
    final schoolId = dashboardAsync.value!.schoolId;
    final invoicesAsync = ref.watch(schoolInvoicesProvider(schoolId));
    
    return Column(
      children: [
        // --- FILTER BAR ---
        _buildFilterBar(),
        const SizedBox(height: 16),

        // --- DATA TABLE ---
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceGrey,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            children: [
              // Header Row
              _buildTableHeader(),
              const Divider(height: 1, color: AppColors.divider),
              
              // Data Rows
              if (invoicesAsync.isLoading)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (invoicesAsync.hasError)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(child: Text('Error loading invoices: ${invoicesAsync.error}')),
                )
              else
                ..._buildInvoiceRows(invoicesAsync.value ?? []),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildInvoiceRows(List<Map<String, dynamic>> invoices) {
    if (invoices.isEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: Text('No invoices found', style: TextStyle(color: AppColors.textWhite54))),
        )
      ];
    }

    final rows = <Widget>[];
    for (final invoice in invoices) {
      rows.add(_buildInvoiceRowFromMap(invoice));
      rows.add(const Divider(height: 1, color: AppColors.divider));
    }
    // Remove last divider
    if (rows.isNotEmpty) rows.removeLast();
    return rows;
  }

  Widget _buildInvoiceRowFromMap(Map<String, dynamic> invoice) {
    final id = invoice['id'] as String? ?? 'Unknown';
    final title = invoice['title'] as String? ?? 'Invoice';
    final student = invoice['student_name'] as String? ?? 'Unknown Student';
    final date = invoice['created_at'] as String? ?? '';
    final due = invoice['due_date'] as String? ?? '';
    final amount = '\$${(invoice['amount'] as num?)?.toStringAsFixed(2) ?? '0.00'}';
    final status = invoice['status'] as String? ?? 'Unpaid';
    final avatarColor = Colors.blue; // Default, could be based on student

    return _buildInvoiceRow(
      id: id,
      title: title,
      student: student,
      date: date,
      due: due,
      amount: amount,
      status: status,
      avatarColor: avatarColor,
    );
  }

  Widget _buildFilterBar() {
    return Row(
      children: [
        // --- Fixed Search Bar ---
        Expanded(
          child: SizedBox(
            height: 44,
            child: TextField(
              textAlignVertical: TextAlignVertical.center,
              style: const TextStyle(color: AppColors.textWhite),
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: AppColors.surfaceGrey,
                hintText: "Filter by invoice # or student",
                hintStyle: const TextStyle(color: AppColors.textWhite38, fontSize: 13),
                prefixIcon: const Icon(Icons.search, color: AppColors.textWhite38, size: 18),
                
                // Borders moved inside for perfect alignment
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.divider),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.divider),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.primaryBlue),
                ),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Status Dropdown
        _buildFilterButton(label: "Status: All", icon: Icons.keyboard_arrow_down),
        const SizedBox(width: 12),

        // Date Picker
        _buildFilterButton(label: "Select Date Range", icon: Icons.calendar_today),
        const SizedBox(width: 12),

        // More Filters
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surfaceGrey,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.divider),
          ),
          child: const Row(
            children: [
              Icon(Icons.filter_list, color: AppColors.textWhite70, size: 16),
              SizedBox(width: 8),
              Text("More Filters", style: TextStyle(color: AppColors.textWhite, fontSize: 13)),
            ],
          ),
        ),
        const SizedBox(width: 12),

        // Export Button
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            children: [
              Icon(Icons.download, color: Colors.white, size: 16),
              SizedBox(width: 8),
              Text("Export CSV", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterButton({required String label, required IconData icon}) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceGrey,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          if (icon == Icons.calendar_today) ...[
             Icon(icon, color: AppColors.textWhite54, size: 16),
             const SizedBox(width: 8),
          ],
          Text(label, style: const TextStyle(color: AppColors.textWhite, fontSize: 13)),
          if (icon == Icons.keyboard_arrow_down) ...[
             const SizedBox(width: 8),
             Icon(icon, color: AppColors.textWhite54, size: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          _col("INVOICE DETAILS", 3),
          _col("STUDENT", 3),
          _col("ISSUE DATE", 2),
          _col("DUE DATE", 2),
          _col("AMOUNT", 2),
          _col("STATUS", 2),
          _col("ACTIONS", 1, align: TextAlign.end),
        ],
      ),
    );
  }

  Widget _col(String text, int flex, {TextAlign align = TextAlign.start}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: align,
        style: const TextStyle(color: AppColors.textWhite38, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8),
      ),
    );
  }

  Widget _buildInvoiceRow({
    required String id, required String title, required String student, 
    required String date, required String due, required String amount, 
    required String status, required Color avatarColor
  }) {
    Color statusColor;
    Color statusBg;
    
    switch (status) {
      case "Paid": statusColor = AppColors.successGreen; statusBg = AppColors.successGreenBg; break;
      case "Overdue": statusColor = AppColors.errorRed; statusBg = AppColors.errorRedBg; break;
      default: statusColor = AppColors.warningOrange; statusBg = AppColors.warningOrange.withAlpha(51);
    }
    
    // Highlight overdue dates in red
    final isOverdue = status == "Overdue";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          // Invoice Details
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(id, style: const TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                const SizedBox(height: 2),
                Text(title, style: const TextStyle(color: AppColors.textWhite54, fontSize: 12)),
              ],
            ),
          ),
          // Student
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: avatarColor.withAlpha(51),
                  child: Text(student.substring(0,2).toUpperCase(), style: TextStyle(color: avatarColor, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Text(student, style: const TextStyle(color: AppColors.textWhite)),
              ],
            ),
          ),
          // Dates
          Expanded(flex: 2, child: Text(date, style: const TextStyle(color: AppColors.textWhite70))),
          Expanded(flex: 2, child: Text(due, style: TextStyle(color: isOverdue ? AppColors.errorRed : AppColors.textWhite70))),
          // Amount
          Expanded(flex: 2, child: Text(amount, style: const TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold))),
          // Status
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(4)),
                  child: Text(status, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          // Actions
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(icon: const Icon(Icons.visibility, size: 18, color: AppColors.textWhite54), onPressed: (){}),
                IconButton(icon: const Icon(Icons.more_vert, size: 18, color: AppColors.textWhite54), onPressed: (){}),
              ],
            ),
          ),
        ],
      ),
    );
  }
}