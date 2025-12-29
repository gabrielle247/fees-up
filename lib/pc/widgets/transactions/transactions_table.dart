import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class TransactionsTable extends StatefulWidget {
  const TransactionsTable({super.key});

  @override
  State<TransactionsTable> createState() => _TransactionsTableState();
}

class _TransactionsTableState extends State<TransactionsTable> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = ["All Transactions", "Income", "Expenses", "Pending"];

  @override
  Widget build(BuildContext context) {
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

          // 3. ROWS (Mock Data Loop)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 7, 
            itemBuilder: (context, index) {
              return _TransactionRow(index: index);
            },
          ),

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

class _TransactionRow extends StatelessWidget {
  final int index;
  const _TransactionRow({required this.index});

  @override
  Widget build(BuildContext context) {
    // Mock Data Logic for Visuals
    final isExpense = index == 1 || index == 4 || index == 5;
    final amount = isExpense ? "-\$450.00" : "+\$1,200.00";
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
                    "#TRX-0092$index",
                    style: const TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                  ),
                ),
                // 2. DATE
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Oct 24, 2023", style: TextStyle(color: AppColors.textWhite, fontSize: 13)),
                      Text("10:45 AM", style: TextStyle(color: AppColors.textWhite.withValues(alpha: 0.4), fontSize: 11)),
                    ],
                  ),
                ),
                // 3. ENTITY / STUDENT
                Expanded(
                  flex: 3,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: index.isEven 
                            ? AppColors.primaryBlue.withValues(alpha: 0.2) 
                            : AppColors.warningOrange.withValues(alpha: 0.2),
                        child: Text(
                          index.isEven ? "AM" : "OS",
                          style: TextStyle(
                            fontSize: 10, 
                            color: index.isEven ? AppColors.primaryBlue : AppColors.warningOrange,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(index.isEven ? "Alex Morgan" : "Office Supplies Inc.", 
                              style: const TextStyle(color: AppColors.textWhite, fontSize: 13, fontWeight: FontWeight.w500)),
                          Text(index.isEven ? "Grade 5" : "Vendor", 
                              style: TextStyle(color: AppColors.textWhite.withValues(alpha: 0.4), fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                ),
                // 4. CATEGORY
                const Expanded(
                  flex: 3,
                  child: Text("Tuition Fee - Term 2", style: TextStyle(color: AppColors.textWhite70, fontSize: 13)),
                ),
                // 5. METHOD
                Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      const Icon(Icons.credit_card, size: 16, color: AppColors.textWhite54),
                      const SizedBox(width: 8),
                      Text(index.isEven ? "Credit Card" : "Bank Transfer", 
                          style: const TextStyle(color: AppColors.textWhite70, fontSize: 13)),
                    ],
                  ),
                ),
                // 6. AMOUNT
                Expanded(
                  flex: 2,
                  child: Text(
                    amount,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: amountColor,
                      fontWeight: FontWeight.bold,
                    ),
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