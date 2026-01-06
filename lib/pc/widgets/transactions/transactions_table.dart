import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/providers/dashboard_provider.dart';
import '../../../../data/providers/transactions_provider.dart';

class TransactionsTable extends ConsumerStatefulWidget {
  const TransactionsTable({super.key});

  @override
  ConsumerState<TransactionsTable> createState() => _TransactionsTableState();
}

class _TransactionsTableState extends ConsumerState<TransactionsTable> {
  late int _selectedFilterIndex = 0;
  late String _searchQuery = '';
  late final String _sortColumn = 'transaction_date';
  late final bool _sortAscending = false;
  late int _currentPage = 1;
  late final int _pageSize = 10;
  late String _selectedDateFilter =
      'this_month'; // 'this_month', 'last_month', 'all_time'

  final List<String> _filters = [
    "All Transactions",
    "Income",
    "Expenses",
    "Pending"
  ];

  final List<MapEntry<String, String>> _dateFilters = [
    const MapEntry('this_month', 'This Month'),
    const MapEntry('last_month', 'Last Month'),
    const MapEntry('last_3_months', 'Last 3 Months'),
    const MapEntry('this_year', 'This Year'),
    const MapEntry('all_time', 'All Time'),
  ];

  @override
  Widget build(BuildContext context) {
    final dashboardAsync = ref.watch(dashboardDataProvider);

    return dashboardAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (dashboardData) {
        final schoolId = dashboardData.schoolId;
        final transactionsAsync = ref.watch(allTransactionsProvider(schoolId));

        return transactionsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
          data: (transactions) => _buildContent(transactions),
        );
      },
    );
  }

  Widget _buildContent(List<Map<String, dynamic>> transactions) {
    // Apply filters
    var filtered = _applyFilters(transactions);

    // Calculate pagination
    final totalItems = filtered.length;
    final totalPages = (totalItems / _pageSize).ceil().clamp(1, 999);
    if (_currentPage > totalPages) {
      _currentPage = totalPages;
    }

    final startIndex = (_currentPage - 1) * _pageSize;
    final endIndex = (startIndex + _pageSize).clamp(0, totalItems);
    final paginatedItems = filtered.sublist(
      startIndex,
      endIndex > totalItems ? totalItems : endIndex,
    );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          // 1. TOOLBAR
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Filter Tabs (Pills)
                ...List.generate(_filters.length, (index) {
                  return _buildFilterTab(
                    label: _filters[index],
                    isSelected: _selectedFilterIndex == index,
                    onTap: () => setState(() => _selectedFilterIndex = index),
                  );
                }),

                const Spacer(),

                // Date Filter (Standardized)
                Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundBlack,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedDateFilter,
                    underline: const SizedBox(),
                    dropdownColor: AppColors.backgroundBlack,
                    style: const TextStyle(
                        color: AppColors.textWhite, fontSize: 13),
                    icon: const Icon(Icons.keyboard_arrow_down,
                        color: AppColors.textWhite54, size: 16),
                    items: _dateFilters
                        .map((entry) => DropdownMenuItem(
                              value: entry.key,
                              child: Text(entry.value),
                            ))
                        .toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedDateFilter = newValue ?? 'this_month';
                        _currentPage = 1; // Reset to first page
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),

                // More Actions Icon
                IconButton(
                  onPressed: () => _resetFilters(),
                  icon: const Icon(Icons.filter_list,
                      color: AppColors.textWhite70, size: 20),
                  tooltip: "Reset Filters",
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),

          // 2. COLUMN HEADERS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                _headerText("REFERENCE ID", flex: 2),
                _headerText("DATE", flex: 2),
                _headerText("ENTITY / STUDENT", flex: 3),
                _headerText("CATEGORY", flex: 3),
                _headerText("METHOD", flex: 2),
                _headerText("AMOUNT", flex: 2, alignRight: true),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),

          // 3. ROWS
          ..._buildTransactionRows(paginatedItems),

          // 4. FOOTER (Pagination)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text("Showing ${startIndex + 1} to $endIndex of $totalItems",
                    style: const TextStyle(
                        color: AppColors.textWhite54, fontSize: 13)),
                const SizedBox(width: 24),
                _paginationBtn(
                  icon: Icons.chevron_left,
                  onPressed: _currentPage > 1
                      ? () => setState(() => _currentPage = (_currentPage - 1))
                      : null,
                ),
                const SizedBox(width: 8),
                ..._buildPageButtons(totalPages),
                const SizedBox(width: 8),
                _paginationBtn(
                  icon: Icons.chevron_right,
                  onPressed: _currentPage < totalPages
                      ? () => setState(() => _currentPage = (_currentPage + 1))
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTransactionRows(List<Map<String, dynamic>> transactions) {
    if (transactions.isEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
              child: Text('No transactions found',
                  style: TextStyle(color: AppColors.textWhite54))),
        )
      ];
    }

    final rows = <Widget>[];
    for (final transaction in transactions) {
      rows.add(_TransactionRowFromMap(transaction: transaction));
      rows.add(const Divider(height: 1, color: AppColors.divider));
    }
    // Remove last divider
    if (rows.isNotEmpty) rows.removeLast();
    return rows;
  }

  // --- FILTERS ---

  List<Map<String, dynamic>> _applyFilters(
      List<Map<String, dynamic>> transactions) {
    // Create mutable copy to avoid read-only error
    var filtered = List<Map<String, dynamic>>.from(transactions);

    // Apply filter based on selected index
    if (_selectedFilterIndex == 1) {
      // Income (payments + donations)
      filtered = filtered.where((t) {
        final type = t['transaction_type'] as String?;
        return type == 'payment' || type == 'donation';
      }).toList();
    } else if (_selectedFilterIndex == 2) {
      // Expenses
      filtered =
          filtered.where((t) => t['transaction_type'] == 'expense').toList();
    } else if (_selectedFilterIndex == 3) {
      // Pending - would need bills data, skip for now
      filtered = [];
    }

    // Apply search if needed (for future)
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((t) {
        final id = (t['id'] as String? ?? '').toLowerCase();
        final entity = (t['entity_name'] as String? ?? '').toLowerCase();
        final category = (t['category'] as String? ?? '').toLowerCase();
        final method = (t['method'] as String? ?? '').toLowerCase();
        final query = _searchQuery.toLowerCase();
        return id.contains(query) ||
            entity.contains(query) ||
            category.contains(query) ||
            method.contains(query);
      }).toList();
    }

    // Apply sorting
    if (_sortColumn.isNotEmpty) {
      filtered.sort((a, b) {
        final aVal = a[_sortColumn];
        final bVal = b[_sortColumn];
        if (aVal == null && bVal == null) return 0;
        if (aVal == null) return 1;
        if (bVal == null) return -1;
        final comparison = aVal.toString().compareTo(bVal.toString());
        return _sortAscending ? comparison : -comparison;
      });
    }

    return filtered;
  }

  // --- HELPERS ---

  Widget _buildFilterTab(
      {required String label,
      required bool isSelected,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          // Add border for unselected state to define clickable area clearly
          border: isSelected ? null : Border.all(color: Colors.transparent),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textWhite70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _headerText(String text, {int flex = 1, bool alignRight = false}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: alignRight ? TextAlign.right : TextAlign.left,
        style: const TextStyle(
          color: AppColors.textWhite38,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8, // Slightly increased spacing for legibility
        ),
      ),
    );
  }

  Widget _paginationBtn(
      {String? label,
      IconData? icon,
      bool isActive = false,
      VoidCallback? onPressed}) {
    final isDisabled = onPressed == null;
    return GestureDetector(
      onTap: isDisabled ? null : onPressed,
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
              color: isDisabled
                  ? AppColors.divider.withValues(alpha: 0.3)
                  : isActive
                      ? AppColors.primaryBlue
                      : AppColors.divider),
        ),
        child: icon != null
            ? Icon(icon,
                size: 16,
                color:
                    isDisabled ? AppColors.textWhite38 : AppColors.textWhite70)
            : Text(label!,
                style: TextStyle(
                    color: isDisabled
                        ? AppColors.textWhite38
                        : isActive
                            ? Colors.white
                            : AppColors.textWhite70,
                    fontSize: 12)),
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      _selectedFilterIndex = 0;
      _searchQuery = '';
      _currentPage = 1;
      _selectedDateFilter = 'this_month';
    });
  }

  List<Widget> _buildPageButtons(int totalPages) {
    final buttons = <Widget>[];
    int startPage = 1;
    int endPage = totalPages;

    // Show max 5 page buttons
    if (totalPages > 5) {
      startPage = (_currentPage - 2).clamp(1, totalPages - 4);
      endPage = startPage + 4;
    }

    if (startPage > 1) {
      buttons.add(_paginationBtn(
        label: "1",
        onPressed: () => setState(() => _currentPage = 1),
      ));
      buttons.add(const SizedBox(width: 8));
      if (startPage > 2) {
        buttons.add(_paginationBtn(label: "..."));
        buttons.add(const SizedBox(width: 8));
      }
    }

    for (int i = startPage; i <= endPage; i++) {
      buttons.add(_paginationBtn(
        label: i.toString(),
        isActive: i == _currentPage,
        onPressed: () => setState(() => _currentPage = i),
      ));
      if (i < endPage) {
        buttons.add(const SizedBox(width: 8));
      }
    }

    if (endPage < totalPages) {
      buttons.add(const SizedBox(width: 8));
      if (endPage < totalPages - 1) {
        buttons.add(_paginationBtn(label: "..."));
        buttons.add(const SizedBox(width: 8));
      }
      buttons.add(_paginationBtn(
        label: totalPages.toString(),
        onPressed: () => setState(() => _currentPage = totalPages),
      ));
    }

    return buttons;
  }
}

class _TransactionRowFromMap extends StatelessWidget {
  final Map<String, dynamic> transaction;
  const _TransactionRowFromMap({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final id = transaction['id'] as String? ?? 'Unknown';
    final date = transaction['date_paid'] as String? ?? '';
    final method = transaction['method'] as String? ?? 'Unknown';
    final amount = transaction['amount'] as num? ?? 0;
    final isExpense = amount < 0;
    final amountText = isExpense
        ? '-\$${amount.abs().toStringAsFixed(2)}'
        : '+\$${amount.toStringAsFixed(2)}';
    final amountColor =
        isExpense ? AppColors.textWhite : AppColors.successGreen;

    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          hoverColor: AppColors.textWhite.withValues(alpha: 0.03),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                // 1. REF ID
                Expanded(
                  flex: 2,
                  child: Text(
                    id,
                    style: const TextStyle(
                        color: AppColors.textWhite,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace'),
                  ),
                ),
                // 2. DATE
                Expanded(
                  flex: 2,
                  child: Text(
                    date,
                    style: const TextStyle(color: AppColors.textWhite),
                  ),
                ),
                // 3. METHOD
                Expanded(
                  flex: 2,
                  child: Text(
                    method,
                    style: const TextStyle(color: AppColors.textWhite),
                  ),
                ),
                // 4. AMOUNT
                Expanded(
                  flex: 2,
                  child: Text(
                    amountText,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        color: amountColor, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
