import 'package:fees_up/constants/app_colors.dart';
import 'package:fees_up/data/models/finance.dart';
import 'package:fees_up/data/providers/finance_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class FinanceScreen extends ConsumerStatefulWidget {
  const FinanceScreen({super.key});

  @override
  ConsumerState<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends ConsumerState<FinanceScreen> {
  String _selectedPeriod = 'All Time';
  String _selectedFilter = 'All';
  String _selectedSort = 'Date (Newest)';
  bool _showAdvancedFilters = false;

  double _getTotalReceipts(List<LedgerEntry> entries) {
    return entries
        .where((e) => e.type == 'CREDIT' && _matchesFilters(e))
        .fold(0.0, (sum, e) => sum + e.amountInDollars);
  }

  double _getTotalInvoices(List<LedgerEntry> entries) {
    // Usually DEBITs are invoices or charges
    return entries
        .where((e) => e.type == 'DEBIT' && _matchesFilters(e))
        .fold(0.0, (sum, e) => sum + e.amountInDollars);
  }

  double _getTotalPending(List<LedgerEntry> entries) {
    // Ledger entries don't track pending status directly.
    // This would typically come from Invoice status.
    // For this screen, if we only have LedgerEntries, we can't easily show "Pending".
    // We might need to fetch Invoices separately or just hide this card if data is unavailable.
    // For now, returning 0.
    return 0.0;
  }

  bool _matchesFilters(LedgerEntry entry) {
    if (_selectedFilter == 'Receipt' && entry.type != 'CREDIT') return false;
    if (_selectedFilter == 'Invoice' && entry.type != 'DEBIT') return false;

    // Date filtering (Simplified)
    final now = DateTime.now();
    if (_selectedPeriod == 'This Month') {
      if (entry.occurredAt.month != now.month || entry.occurredAt.year != now.year) {
        return false;
      }
    }
    // Add other date filters as needed

    return true;
  }

  // Group entries by Month Year (e.g. "JANUARY 2026")
  Map<String, List<LedgerEntry>> _groupEntriesByMonth(List<LedgerEntry> entries) {
    final Map<String, List<LedgerEntry>> grouped = {};
    for (var entry in entries) {
      if (!_matchesFilters(entry)) continue;

      final key = DateFormat('MMMM yyyy').format(entry.occurredAt).toUpperCase();
      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(entry);
    }
    return grouped;
  }

  Widget _getTransactionIcon(String type) {
    IconData icon;
    Color bgColor;
    Color iconColor;

    if (type == 'CREDIT') {
      icon = Icons.arrow_downward;
      bgColor = AppColors.successGreen.withValues(alpha: 0.2);
      iconColor = AppColors.successGreen;
    } else {
      icon = Icons.description;
      bgColor = AppColors.primaryBlue.withValues(alpha: 0.2);
      iconColor = AppColors.primaryBlue;
    }

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: iconColor.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: Icon(
        icon,
        color: iconColor,
        size: 24,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ledgerAsync = ref.watch(ledgerProvider);

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
                  ],
                ),
              ),

            // Content
            Expanded(
              child: ledgerAsync.when(
                data: (entries) {
                  final grouped = _groupEntriesByMonth(entries);

                  return Column(
                    children: [
                      // Summary Cards
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: _SummaryCard(
                                title: 'Receipts',
                                amount: _getTotalReceipts(entries),
                                color: AppColors.successGreen,
                                icon: Icons.arrow_downward,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _SummaryCard(
                                title: 'Invoices',
                                amount: _getTotalInvoices(entries),
                                color: AppColors.primaryBlue,
                                icon: Icons.description,
                              ),
                            ),
                            // Pending removed as we can't easily calculate it from Ledger
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      Expanded(
                        child: grouped.isEmpty
                        ? const Center(child: Text('No transactions found', style: TextStyle(color: AppColors.textGrey)))
                        : SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                children: grouped.entries.map((entry) {
                                  final month = entry.key;
                                  final monthEntries = entry.value;

                                  // Sort by date desc
                                  monthEntries.sort((a, b) => b.occurredAt.compareTo(a.occurredAt));

                                  final monthTotal = monthEntries.fold<double>(
                                      0, (sum, e) => sum + e.amountInDollars);

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
                                              '${monthEntries.length} entries',
                                              style: const TextStyle(
                                                color: AppColors.textGrey,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 12),

                                      // Month Total (Just a sum, meaning might vary based on credit/debit mix)
                                      // Usually we want Net Cash Flow? Or just total volume?
                                      // Displaying total volume for now.
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
                                              'Month Volume',
                                              style: TextStyle(
                                                color: AppColors.textGrey,
                                                fontSize: 12,
                                              ),
                                            ),
                                            Text(
                                              '\$${monthTotal.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                color: AppColors.textWhite,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(height: 12),

                                      // Transactions
                                      ...monthEntries.map((transaction) {
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
                                                _getTransactionIcon(transaction.type),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        // Use description or category as name substitute
                                                        transaction.description ?? transaction.category,
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
                                                              '${transaction.referenceCode ?? '-'} • ${transaction.category}',
                                                              style: const TextStyle(
                                                                color: AppColors.textGrey,
                                                                fontSize: 11,
                                                              ),
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow.ellipsis,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 6),
                                                      Text(
                                                        DateFormat('MMM dd').format(transaction.occurredAt).toUpperCase(),
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
                                                      transaction.type == 'CREDIT'
                                                          ? '+\$${transaction.amountInDollars.toStringAsFixed(2)}'
                                                          : '\$${transaction.amountInDollars.toStringAsFixed(2)}',
                                                      style: TextStyle(
                                                        color:
                                                            transaction.type == 'CREDIT'
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
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue)),
                error: (e, s) => Center(child: Text('Error: $e', style: const TextStyle(color: AppColors.errorRed))),
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
