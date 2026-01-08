import 'package:fees_up/constants/app_colors.dart';
import 'package:flutter/material.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  String _selectedPeriod = 'All Time';
  String _selectedFilter = 'All';
  String _selectedSort = 'Date (Newest)';
  bool _showAdvancedFilters = false;

  final Map<String, List<Map<String, dynamic>>> _ledgerByMonth = {
    'JANUARY 2026': [
      {
        'name': 'Tinashe M.',
        'description': 'School Fees',
        'reference': 'POP-001',
        'date': 'JAN 15',
        'amount': 150.00,
        'type': 'receipt',
        'status': 'paid',
        'category': 'Fees',
      },
      {
        'name': 'Tinashe M.',
        'description': 'Term1',
        'reference': 'Inv #2026-001',
        'date': 'JAN 01',
        'amount': 400.00,
        'type': 'invoice',
        'status': 'pending',
        'category': 'Invoice',
      },
      {
        'name': 'Rutendo K.',
        'description': 'Uniforms',
        'reference': 'ECO-882',
        'date': 'JAN 12',
        'amount': 85.00,
        'type': 'receipt',
        'status': 'paid',
        'category': 'Other',
      },
      {
        'name': 'Rutendo K.',
        'description': 'Levy',
        'reference': 'Inv #2026-002',
        'date': 'JAN 05',
        'amount': 120.00,
        'type': 'invoice',
        'status': 'overdue',
        'category': 'Levy',
      },
    ],
    'DECEMBER 2025': [
      {
        'name': 'Tariro C.',
        'description': 'Late Fees',
        'reference': 'CASH',
        'date': 'DEC 20',
        'amount': 50.00,
        'type': 'receipt',
        'status': 'paid',
        'category': 'Fees',
      },
      {
        'name': 'Farai G.',
        'description': 'Bus Levy',
        'reference': 'Inv #2025-099',
        'date': 'DEC 15',
        'amount': 450.00,
        'type': 'invoice',
        'status': 'pending',
        'category': 'Levy',
      },
      {
        'name': 'Blessing T.',
        'description': 'Sports',
        'reference': 'Inv #2025-098',
        'date': 'DEC 12',
        'amount': 35.00,
        'type': 'invoice',
        'status': 'paid',
        'category': 'Other',
      },
      {
        'name': 'Nyasha G.',
        'description': 'School Fees',
        'reference': 'POP-045',
        'date': 'DEC 08',
        'amount': 200.00,
        'type': 'receipt',
        'status': 'paid',
        'category': 'Fees',
      },
      {
        'name': 'Alice K.',
        'description': 'Books',
        'reference': 'POP-044',
        'date': 'DEC 01',
        'amount': 75.00,
        'type': 'receipt',
        'status': 'paid',
        'category': 'Fees',
      },
    ],
  };

  double _getTotalReceipts() {
    double total = 0;
    _ledgerByMonth.forEach((_, transactions) {
      for (var tx in transactions) {
        if (tx['type'] == 'receipt' && _matchesFilters(tx)) {
          total += tx['amount'];
        }
      }
    });
    return total;
  }

  double _getTotalInvoices() {
    double total = 0;
    _ledgerByMonth.forEach((_, transactions) {
      for (var tx in transactions) {
        if (tx['type'] == 'invoice' && _matchesFilters(tx)) {
          total += tx['amount'];
        }
      }
    });
    return total;
  }

  double _getTotalPending() {
    double total = 0;
    _ledgerByMonth.forEach((_, transactions) {
      for (var tx in transactions) {
        if (tx['status'] == 'pending' && _matchesFilters(tx)) {
          total += tx['amount'];
        }
      }
    });
    return total;
  }

  bool _matchesFilters(Map<String, dynamic> transaction) {
    if (_selectedFilter != 'All' &&
        transaction['type'] != _selectedFilter.toLowerCase()) {
      return false;
    }
    return true;
  }

  Widget _getTransactionIcon(String type, String status) {
    IconData icon;
    Color bgColor;

    if (type == 'receipt') {
      icon = Icons.arrow_downward;
      bgColor = AppColors.successGreen.withValues(alpha: 0.2);
    } else {
      icon = Icons.description;
      bgColor = AppColors.primaryBlue.withValues(alpha: 0.2);
    }

    final statusColor = status == 'paid'
        ? AppColors.successGreen
        : status == 'pending'
            ? AppColors.warningOrange
            : AppColors.errorRed;

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: Icon(
        icon,
        color: statusColor,
        size: 24,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      body: SafeArea(
        child: Column(
          children: [
            // Header with title and filter button
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Ledger',
                    style: TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(
                          () => _showAdvancedFilters = !_showAdvancedFilters);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: AppColors.primaryBlue, width: 1.5),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.tune,
                            color: AppColors.primaryBlue,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Filter',
                            style: TextStyle(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Advanced Filters (Collapsible)
            if (_showAdvancedFilters)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Period Filter
                    const Text(
                      'Period',
                      style: TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _FilterChip(
                            label: 'All Time',
                            isSelected: _selectedPeriod == 'All Time',
                            onTap: () =>
                                setState(() => _selectedPeriod = 'All Time'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _FilterChip(
                            label: 'This Month',
                            isSelected: _selectedPeriod == 'This Month',
                            onTap: () =>
                                setState(() => _selectedPeriod = 'This Month'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _FilterChip(
                            label: 'Last 3 Months',
                            isSelected: _selectedPeriod == 'Last 3 Months',
                            onTap: () => setState(
                                () => _selectedPeriod = 'Last 3 Months'),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Type Filter
                    const Text(
                      'Type',
                      style: TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _FilterChip(
                            label: 'All',
                            isSelected: _selectedFilter == 'All',
                            onTap: () =>
                                setState(() => _selectedFilter = 'All'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _FilterChip(
                            label: 'Receipt',
                            isSelected: _selectedFilter == 'Receipt',
                            onTap: () =>
                                setState(() => _selectedFilter = 'Receipt'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _FilterChip(
                            label: 'Invoice',
                            isSelected: _selectedFilter == 'Invoice',
                            onTap: () =>
                                setState(() => _selectedFilter = 'Invoice'),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Sort Filter
                    const Text(
                      'Sort By',
                      style: TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _FilterChip(
                            label: 'Date (Newest)',
                            isSelected: _selectedSort == 'Date (Newest)',
                            onTap: () =>
                                setState(() => _selectedSort = 'Date (Newest)'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _FilterChip(
                            label: 'Amount (High)',
                            isSelected: _selectedSort == 'Amount (High)',
                            onTap: () =>
                                setState(() => _selectedSort = 'Amount (High)'),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),

            // Summary Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      title: 'Receipts',
                      amount: _getTotalReceipts(),
                      color: AppColors.successGreen,
                      icon: Icons.arrow_downward,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SummaryCard(
                      title: 'Invoices',
                      amount: _getTotalInvoices(),
                      color: AppColors.primaryBlue,
                      icon: Icons.description,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SummaryCard(
                      title: 'Pending',
                      amount: _getTotalPending(),
                      color: AppColors.warningOrange,
                      icon: Icons.schedule,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Transactions List
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: _ledgerByMonth.entries.map((entry) {
                      final month = entry.key;
                      final transactions = entry.value;

                      // Filter transactions
                      final filtered = transactions
                          .where((tx) => _matchesFilters(tx))
                          .toList();

                      if (filtered.isEmpty) return const SizedBox.shrink();

                      final monthTotal = filtered.fold<double>(
                          0, (sum, tx) => sum + tx['amount']);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Month Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                month,
                                style: const TextStyle(
                                  color: AppColors.textWhite,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceDarkGrey,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${filtered.length} entries',
                                  style: const TextStyle(
                                    color: AppColors.textGrey,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Month Total
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceGrey,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.successGreen
                                    .withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Month Total',
                                  style: TextStyle(
                                    color: AppColors.textGrey,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  '\$${monthTotal.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: AppColors.successGreen,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Transactions
                          ...filtered.map((transaction) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceGrey,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    _getTransactionIcon(
                                      transaction['type'],
                                      transaction['status'],
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            transaction['name'],
                                            style: const TextStyle(
                                              color: AppColors.textWhite,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  '${transaction['reference']} • ${transaction['description']}',
                                                  style: const TextStyle(
                                                    color: AppColors.textGrey,
                                                    fontSize: 11,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 6,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: transaction[
                                                              'status'] ==
                                                          'paid'
                                                      ? AppColors.successGreen
                                                          .withValues(
                                                              alpha: 0.15)
                                                      : transaction['status'] ==
                                                              'pending'
                                                          ? AppColors
                                                              .warningOrange
                                                              .withValues(
                                                                  alpha: 0.15)
                                                          : AppColors.errorRed
                                                              .withValues(
                                                                  alpha: 0.15),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  transaction['status']
                                                      .toUpperCase(),
                                                  style: TextStyle(
                                                    color: transaction[
                                                                'status'] ==
                                                            'paid'
                                                        ? AppColors.successGreen
                                                        : transaction[
                                                                    'status'] ==
                                                                'pending'
                                                            ? AppColors
                                                                .warningOrange
                                                            : AppColors
                                                                .errorRed,
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            transaction['date'],
                                            style: const TextStyle(
                                              color: AppColors.textGrey,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          transaction['type'] == 'receipt'
                                              ? '+\$${transaction['amount'].toStringAsFixed(2)}'
                                              : '\$${transaction['amount'].toStringAsFixed(2)}',
                                          style: TextStyle(
                                            color:
                                                transaction['type'] == 'receipt'
                                                    ? AppColors.successGreen
                                                    : AppColors.textWhite,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        const Text(
                                          'USD',
                                          style: TextStyle(
                                            color: AppColors.textGrey,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),

                          const SizedBox(height: 20),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(icon, color: color, size: 16),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryBlue.withValues(alpha: 0.15)
              : AppColors.surfaceGrey,
          border: Border.all(
            color:
                isSelected ? AppColors.primaryBlue : AppColors.surfaceLightGrey,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.primaryBlue : AppColors.textGrey,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
