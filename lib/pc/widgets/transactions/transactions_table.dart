import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/providers/dashboard_provider.dart';
import '../../../../data/providers/financial_providers.dart';

class TransactionsTable extends ConsumerStatefulWidget {
  const TransactionsTable({super.key});

  @override
  ConsumerState<TransactionsTable> createState() => _TransactionsTableState();
}

class _TransactionsTableState extends ConsumerState<TransactionsTable> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = ["All Transactions", "Income", "Expenses", "Pending"];

  @override
  Widget build(BuildContext context) {
    final dashboardAsync = ref.watch(dashboardDataProvider);
    
    if (dashboardAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (dashboardAsync.hasError) {
      return Center(child: Text('Error: ${dashboardAsync.error}'));
    }
    
    final schoolId = dashboardAsync.value!.schoolId;
    final transactionsAsync = ref.watch(schoolTransactionsProvider(schoolId));
    
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceGrey,
        borderRadius: BorderRadius.circular(12), // Matching Invoices Table Radius
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          // 1. TOOLBAR (Standardized to match Invoices Table)
          Padding(
            padding: const EdgeInsets.all(16), // Standard padding
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
                  height: 36, // Standard height for secondary actions
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundBlack, // Contrast background for dropdowns
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: const Row(
                    children: [
                      Text("This Month", style: TextStyle(color: AppColors.textWhite, fontSize: 13)),
                      SizedBox(width: 8),
                      Icon(Icons.keyboard_arrow_down, color: AppColors.textWhite54, size: 16),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // More Actions Icon
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.filter_list, color: AppColors.textWhite70, size: 20),
                  tooltip: "Filter List",
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
          if (transactionsAsync.isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (transactionsAsync.hasError)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(child: Text('Error loading transactions: ${transactionsAsync.error}')),
            )
          else
            ..._buildTransactionRows(transactionsAsync.value ?? []),

          // 4. FOOTER (Pagination)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text("Showing 1 to 7 of 128 results", style: TextStyle(color: AppColors.textWhite54, fontSize: 13)),
                const SizedBox(width: 24),
                _paginationBtn(icon: Icons.chevron_left),
                const SizedBox(width: 8),
                _paginationBtn(label: "1", isActive: true),
                const SizedBox(width: 8),
                _paginationBtn(label: "2"),
                const SizedBox(width: 8),
                _paginationBtn(label: "..."),
                const SizedBox(width: 8),
                _paginationBtn(icon: Icons.chevron_right),
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
          child: Center(child: Text('No transactions found', style: TextStyle(color: AppColors.textWhite54))),
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

  // --- HELPERS ---

  Widget _buildFilterTab({required String label, required bool isSelected, required VoidCallback onTap}) {
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

  Widget _paginationBtn({String? label, IconData? icon, bool isActive = false}) {
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryBlue : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: isActive ? AppColors.primaryBlue : AppColors.divider),
      ),
      child: icon != null 
        ? Icon(icon, size: 16, color: AppColors.textWhite70)
        : Text(label!, style: TextStyle(color: isActive ? Colors.white : AppColors.textWhite70, fontSize: 12)),
    );
  }
}

// --- PRIVATE ROW WIDGET ---

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
    final amountText = isExpense ? '-\$${amount.abs().toStringAsFixed(2)}' : '+\$${amount.toStringAsFixed(2)}';
    final amountColor = isExpense ? AppColors.textWhite : AppColors.successGreen;
    
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
                    style: const TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
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
                    style: TextStyle(color: amountColor, fontWeight: FontWeight.bold),
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