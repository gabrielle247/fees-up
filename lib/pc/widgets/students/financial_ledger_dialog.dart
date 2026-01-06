import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/safe_data.dart';

/// Enhanced Financial Ledger Dialog - displays comprehensive transaction history
class FinancialLedgerDialog extends ConsumerStatefulWidget {
  final String studentId;
  final String studentName;
  final String studentRid;
  final AsyncValue<List<Map<String, dynamic>>> billsAsync;
  final AsyncValue<List<Map<String, dynamic>>> paymentsAsync;

  const FinancialLedgerDialog({
    super.key,
    required this.studentId,
    required this.studentName,
    required this.studentRid,
    required this.billsAsync,
    required this.paymentsAsync,
  });

  @override
  ConsumerState<FinancialLedgerDialog> createState() =>
      _FinancialLedgerDialogState();
}

class _FinancialLedgerDialogState extends ConsumerState<FinancialLedgerDialog> {
  late String _selectedTransactionFilter;
  late String _selectedYearFilter;
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _selectedTransactionFilter = 'All Transactions';
    _selectedYearFilter = 'This Academic Year';
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  String _formatCurrency(dynamic value) {
    final amount = SafeData.parseDouble(value, 0.0);
    return NumberFormat.simpleCurrency().format(amount);
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (_) {
      return isoDate;
    }
  }

  /// Build unified transaction list (bills + payments) with chronological ordering
  List<Map<String, dynamic>> _buildTransactionList(
    List<Map<String, dynamic>> bills,
    List<Map<String, dynamic>> payments,
  ) {
    final transactions = <Map<String, dynamic>>[];

    // Add bills as debits
    for (final bill in bills) {
      transactions.add({
        'type': 'bill',
        'date': bill['created_at'] ?? '',
        'ref_id': bill['id'] ?? 'INV-${bill['created_at']?.substring(0, 10)}',
        'description': bill['title'] ?? 'Bill',
        'category': bill['category'] ?? 'General',
        'debit': SafeData.parseDouble(bill['total_amount'], 0.0),
        'credit': 0.0,
        'is_paid': SafeData.parseInt(bill['is_paid']) == 1,
        'notes': bill['notes'] ?? '',
        'original': bill,
      });
    }

    // Add payments as credits
    for (final payment in payments) {
      transactions.add({
        'type': 'payment',
        'date': payment['date_paid'] ?? '',
        'ref_id':
            payment['reference'] ?? 'PAY-${payment['id']?.substring(0, 8)}',
        'description': 'Payment Received',
        'category': payment['payment_method'] ?? 'Bank Transfer',
        'debit': 0.0,
        'credit': SafeData.parseDouble(payment['amount'], 0.0),
        'is_paid': true,
        'notes': payment['notes'] ?? '',
        'original': payment,
      });
    }

    // Sort by date descending (newest first)
    transactions.sort((a, b) {
      final dateA = DateTime.tryParse(a['date'] ?? '') ?? DateTime(2000);
      final dateB = DateTime.tryParse(b['date'] ?? '') ?? DateTime(2000);
      return dateB.compareTo(dateA);
    });

    return transactions;
  }

  /// Calculate running balance and totals
  Map<String, dynamic> _calculateTotals(
      List<Map<String, dynamic>> transactions) {
    double totalDebit = 0.0;
    double totalCredit = 0.0;
    double balance = 0.0;

    // Calculate from oldest to newest for proper balance progression
    final sorted = List<Map<String, dynamic>>.from(transactions.reversed);
    for (final tx in sorted) {
      final debit = SafeData.parseDouble(tx['debit'], 0.0);
      final credit = SafeData.parseDouble(tx['credit'], 0.0);
      totalDebit += debit;
      totalCredit += credit;
      balance = totalCredit -
          totalDebit; // Positive = credit (overpaid), Negative = debit (owed)
    }

    return {
      'total_invoiced': totalDebit,
      'total_paid': totalCredit,
      'balance': balance,
    };
  }

  /// Get transaction color based on type
  Color _getTransactionColor(Map<String, dynamic> tx) {
    if (tx['type'] == 'payment') {
      return AppColors.successGreen;
    }
    return tx['is_paid'] ? AppColors.successGreen : AppColors.errorRed;
  }

  /// Detect missing billing-period metadata on bills to warn the user.
  List<String> _collectBillingPeriodIssues(List<Map<String, dynamic>> bills) {
    int missingYear = 0;
    int missingMonth = 0;
    int missingCycle = 0;

    for (final bill in bills) {
      final hasYear = (bill['school_year_id']?.toString().isNotEmpty ?? false);
      final hasMonth = (bill['month_index']?.toString().isNotEmpty ?? false);
      final hasCycle =
          (bill['billing_cycle_start']?.toString().isNotEmpty ?? false) &&
              (bill['billing_cycle_end']?.toString().isNotEmpty ?? false);

      if (!hasYear) missingYear++;
      if (!hasMonth) missingMonth++;
      if (!hasCycle) missingCycle++;
    }

    final issues = <String>[];
    if (missingYear > 0) {
      issues.add('$missingYear bill(s) missing school year linkage.');
    }
    if (missingMonth > 0) {
      issues.add('$missingMonth bill(s) missing month index.');
    }
    if (missingCycle > 0) {
      issues.add('$missingCycle bill(s) missing billing cycle dates.');
    }

    return issues;
  }

  Widget _buildWarningBanner(List<String> issues) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warningOrange.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border:
            Border.all(color: AppColors.warningOrange.withValues(alpha: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: AppColors.warningOrange, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Billing period issues detected',
                  style: TextStyle(
                      color: AppColors.textWhite,
                      fontWeight: FontWeight.w600,
                      fontSize: 13),
                ),
                const SizedBox(height: 4),
                ...issues.map(
                  (issue) => Text(
                    issue,
                    style: const TextStyle(
                        color: AppColors.textWhite70, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.backgroundBlack,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: AppColors.backgroundBlack,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.divider)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.receipt_long_outlined,
                      color: AppColors.primaryBlue, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Financial Ledger',
                          style: TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Transaction history for ${widget.studentName} (${widget.studentRid})',
                          style: const TextStyle(
                            color: AppColors.textWhite54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: AppColors.textWhite),
                  ),
                ],
              ),
            ),

            // Filters Row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  // Transaction Type Filter
                  Expanded(
                    child: _buildFilterDropdown(
                      label: 'All Transactions',
                      value: _selectedTransactionFilter,
                      options: [
                        'All Transactions',
                        'Invoices Only',
                        'Payments Only',
                        'Outstanding',
                      ],
                      onChanged: (value) {
                        setState(() => _selectedTransactionFilter = value);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Year Filter
                  Expanded(
                    child: _buildFilterDropdown(
                      label: 'This Academic Year',
                      value: _selectedYearFilter,
                      options: [
                        'This Academic Year',
                        'Last Academic Year',
                        'All Time',
                      ],
                      onChanged: (value) {
                        setState(() => _selectedYearFilter = value);
                      },
                    ),
                  ),
                  const SizedBox(width: 32),

                  // Summary Totals
                  widget.billsAsync.when(
                    data: (bills) {
                      final transactions = _buildTransactionList(bills, []);
                      final totals = _calculateTotals(transactions);
                      return Row(
                        children: [
                          _buildSummaryChip(
                            label: 'Total Invoiced',
                            amount: totals['total_invoiced'],
                            color: AppColors.errorRed,
                          ),
                          const SizedBox(width: 16),
                          _buildSummaryChip(
                            label: 'Total Paid',
                            amount: totals['total_paid'],
                            color: AppColors.successGreen,
                          ),
                        ],
                      );
                    },
                    loading: () => const SizedBox(
                      width: 200,
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation(AppColors.primaryBlue),
                        strokeWidth: 2,
                      ),
                    ),
                    error: (err, _) => const Text(
                      'Error loading totals',
                      style: TextStyle(color: AppColors.errorRed),
                    ),
                  ),
                ],
              ),
            ),

            // Transactions Table
            Expanded(
              child: widget.billsAsync.when(
                data: (bills) {
                  return widget.paymentsAsync.when(
                    data: (payments) {
                      final transactions =
                          _buildTransactionList(bills, payments);
                      final filtered = transactions.where((tx) {
                        if (_selectedTransactionFilter == 'Invoices Only' &&
                            tx['type'] != 'bill') {
                          return false;
                        }
                        if (_selectedTransactionFilter == 'Payments Only' &&
                            tx['type'] != 'payment') {
                          return false;
                        }
                        if (_selectedTransactionFilter == 'Outstanding' &&
                            tx['is_paid'] == true) {
                          return false;
                        }
                        return true;
                      }).toList();

                      final periodIssues = _collectBillingPeriodIssues(bills);

                      if (filtered.isEmpty) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (periodIssues.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 8),
                                child: _buildWarningBanner(periodIssues),
                              ),
                            const Expanded(
                              child: Center(
                                child: Text(
                                  'No transactions found',
                                  style: TextStyle(
                                    color: AppColors.textWhite54,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }

                      double runningBalance = 0.0;
                      final txWithBalance = filtered.map((tx) {
                        final debit = SafeData.parseDouble(tx['debit'], 0.0);
                        final credit = SafeData.parseDouble(tx['credit'], 0.0);
                        runningBalance = credit - debit + runningBalance;
                        return {...tx, 'balance': runningBalance};
                      }).toList();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (periodIssues.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 8),
                              child: _buildWarningBanner(periodIssues),
                            ),
                          Expanded(
                            child: Scrollbar(
                              controller: _verticalScrollController,
                              child: SingleChildScrollView(
                                controller: _verticalScrollController,
                                child: Scrollbar(
                                  controller: _horizontalScrollController,
                                  child: SingleChildScrollView(
                                    controller: _horizontalScrollController,
                                    scrollDirection: Axis.horizontal,
                                    child: DataTable(
                                      dataRowMinHeight: 48,
                                      headingRowHeight: 44,
                                      headingRowColor: WidgetStateProperty.all(
                                        AppColors.surfaceGrey,
                                      ),
                                      columns: const [
                                        DataColumn(
                                          label: Text(
                                            'DATE',
                                            style: TextStyle(
                                              color: AppColors.textWhite38,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            'REF ID',
                                            style: TextStyle(
                                              color: AppColors.textWhite38,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            'DESCRIPTION',
                                            style: TextStyle(
                                              color: AppColors.textWhite38,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            'DEBIT',
                                            style: TextStyle(
                                              color: AppColors.textWhite38,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                          numeric: true,
                                        ),
                                        DataColumn(
                                          label: Text(
                                            'CREDIT',
                                            style: TextStyle(
                                              color: AppColors.textWhite38,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                          numeric: true,
                                        ),
                                        DataColumn(
                                          label: Text(
                                            'BALANCE',
                                            style: TextStyle(
                                              color: AppColors.textWhite38,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                          numeric: true,
                                        ),
                                        DataColumn(
                                          label: Text(
                                            'STATUS',
                                            style: TextStyle(
                                              color: AppColors.textWhite38,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            'NOTES',
                                            style: TextStyle(
                                              color: AppColors.textWhite38,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ),
                                      ],
                                      rows: txWithBalance.map((tx) {
                                        return DataRow(
                                          cells: [
                                            DataCell(Text(
                                              _formatDate(tx['date']),
                                              style: const TextStyle(
                                                  color: AppColors.textWhite,
                                                  fontSize: 12),
                                            )),
                                            DataCell(Text(
                                              tx['ref_id'],
                                              style: const TextStyle(
                                                  color: AppColors.textWhite,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600),
                                            )),
                                            DataCell(Text(
                                              tx['description'],
                                              style: const TextStyle(
                                                  color: AppColors.textWhite,
                                                  fontSize: 12),
                                            )),
                                            DataCell(Text(
                                              tx['debit'] > 0
                                                  ? _formatCurrency(tx['debit'])
                                                  : '-',
                                              style: const TextStyle(
                                                  color: AppColors.errorRed,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600),
                                            )),
                                            DataCell(Text(
                                              tx['credit'] > 0
                                                  ? _formatCurrency(
                                                      tx['credit'])
                                                  : '-',
                                              style: const TextStyle(
                                                  color: AppColors.successGreen,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600),
                                            )),
                                            DataCell(Text(
                                              _formatCurrency(tx['balance']),
                                              style: const TextStyle(
                                                  color: AppColors.textWhite,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold),
                                            )),
                                            DataCell(Row(
                                              children: [
                                                Container(
                                                  width: 8,
                                                  height: 8,
                                                  decoration: BoxDecoration(
                                                    color: _getTransactionColor(
                                                        tx),
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  tx['type'] == 'payment'
                                                      ? 'Payment'
                                                      : tx['is_paid']
                                                          ? 'Paid'
                                                          : 'Due',
                                                  style: TextStyle(
                                                    color: _getTransactionColor(
                                                        tx),
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            )),
                                            DataCell(Text(
                                              tx['notes'] ?? '-',
                                              style: const TextStyle(
                                                  color: AppColors.textWhite54,
                                                  fontSize: 12),
                                            )),
                                          ],
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                    loading: () => const Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation(AppColors.primaryBlue),
                      ),
                    ),
                    error: (err, _) => Center(
                      child: Text(
                        'Error loading payments: $err',
                        style: const TextStyle(color: AppColors.errorRed),
                      ),
                    ),
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(AppColors.primaryBlue),
                  ),
                ),
                error: (err, _) => Center(
                  child: Text(
                    'Error loading bills: $err',
                    style: const TextStyle(color: AppColors.errorRed),
                  ),
                ),
              ),
            ),

            // Footer with Action Buttons
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.divider)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Print functionality coming soon'),
                          backgroundColor: AppColors.primaryBlue,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.print_outlined, size: 18),
                    label: const Text('Print Statement'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryBlue,
                      side: const BorderSide(color: AppColors.primaryBlue),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('PDF download coming soon'),
                          backgroundColor: AppColors.primaryBlue,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.download_outlined, size: 18),
                    label: const Text('Download PDF'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required String value,
    required List<String> options,
    required Function(String) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceGrey,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider),
      ),
      child: DropdownButton<String>(
        value: value,
        onChanged: (newValue) {
          if (newValue != null) onChanged(newValue);
        },
        isExpanded: true,
        underline: const SizedBox.shrink(),
        icon: const Icon(Icons.expand_more, color: AppColors.textWhite54),
        style: const TextStyle(
          color: AppColors.textWhite,
          fontSize: 13,
        ),
        dropdownColor: AppColors.surfaceGrey,
        items: options
            .map((option) => DropdownMenuItem(
                  value: option,
                  child: Text(option),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildSummaryChip({
    required String label,
    required double amount,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceGrey,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha((0.3 * 255) as int)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textWhite54,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatCurrency(amount),
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
