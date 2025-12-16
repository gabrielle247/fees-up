// lib/pages/expenses_dashboard_page.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart'; // Ensure you have uuid in pubspec
import '../services/database_service.dart';

class ExpensesDashboardPage extends StatefulWidget {
  const ExpensesDashboardPage({super.key});

  @override
  State<ExpensesDashboardPage> createState() => _ExpensesDashboardPageState();
}

class _ExpensesDashboardPageState extends State<ExpensesDashboardPage> {
  // Filter State
  String _selectedFilter = 'Monthly'; // Default
  final List<String> _filters = ['Today', 'Weekly', 'Monthly', 'Yearly'];

  // Data State
  // ignore: unused_field
  List<Map<String, dynamic>> _expenses = [];
  bool _isLoading = true;
  double _totalAmount = 0.0;
  double _avgAmount = 0.0;

  // Chart Data
  List<double> _chartValues = List.filled(7, 0.0);
  Map<String, double> _categoryData = {};

  @override
  void initState() {
    super.initState();
    _fetchExpenses();
  }

  /// Fetch expenses based on the selected filter
  Future<void> _fetchExpenses() async {
    setState(() => _isLoading = true);
    final db = await DatabaseService.instance.database;
    
    // Determine date range
    DateTime now = DateTime.now();
    DateTime startDate;
    
    switch (_selectedFilter) {
      case 'Today':
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 'Weekly':
        // Last 7 days
        startDate = now.subtract(const Duration(days: 6));
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
        break;
      case 'Monthly':
        // Start of current month
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'Yearly':
        // Start of current year
        startDate = DateTime(now.year, 1, 1);
        break;
      default:
        startDate = DateTime(now.year, now.month, 1);
    }

    final startDateStr = DateFormat('yyyy-MM-dd').format(startDate);

    // Query DB
    final result = await db.query(
      'expenses',
      where: 'date_incurred >= ?',
      whereArgs: [startDateStr],
      orderBy: 'date_incurred DESC',
    );

    // Process Data
    double total = 0.0;
    Map<String, double> cats = {};
    List<double> chartBuckets = List.filled(7, 0.0); // Simple 7-bucket distribution for now

    for (var row in result) {
      final amt = (row['amount'] as num).toDouble();
      final cat = (row['category'] as String?) ?? 'Other';
      final dateStr = row['date_incurred'] as String;
      final date = DateTime.parse(dateStr);
      
      total += amt;
      cats[cat] = (cats[cat] ?? 0) + amt;

      // Simple Chart Logic: Distribute based on day of week (0-6)
      // This works best for "Weekly", for others it just aggregates by weekday
      // A more complex logic would vary buckets based on filter (e.g. 12 buckets for Year)
      if (_selectedFilter == 'Weekly' || _selectedFilter == 'Today') {
        int dayIndex = date.weekday - 1; // Mon=0, Sun=6
        chartBuckets[dayIndex] += amt;
      } else {
        // For Month/Year, maybe just arbitrary buckets for visual flow or first 7 chunks
        // keeping simple weekday aggregation for visual demo
        int dayIndex = date.weekday - 1; 
        chartBuckets[dayIndex] += amt;
      }
    }

    // Sort categories by value desc
    final sortedCats = Map.fromEntries(
      cats.entries.toList()..sort((e1, e2) => e2.value.compareTo(e1.value))
    );

    if (mounted) {
      setState(() {
        _expenses = result;
        _totalAmount = total;
        _categoryData = sortedCats;
        _chartValues = chartBuckets;
        
        // Avg calc
        int daysDivisor = 1;
        if (_selectedFilter == 'Weekly') daysDivisor = 7;
        if (_selectedFilter == 'Monthly') daysDivisor = now.day; // Avg per day so far
        if (_selectedFilter == 'Yearly') daysDivisor = 365;
        if (_totalAmount > 0) {
           _avgAmount = _totalAmount / daysDivisor;
        } else {
          _avgAmount = 0.0;
        }
        
        _isLoading = false;
      });
    }
  }

  void _openAddExpenseSheet() async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xff1c2a35),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const _AddExpenseSheetContent(),
    );

    // If returned true, refresh data
    if (result == true) {
      _fetchExpenses();
    }
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xff121b22);
    const cardColor = Color(0xff1c2a35);
    const primaryColor = Color(0xff3498db);

    return Scaffold(
      backgroundColor: bgColor,
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: _openAddExpenseSheet,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      appBar: AppBar(
        backgroundColor: bgColor,
        title: const Text("Expenses Dashboard", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Filter Dropdown
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                dropdownColor: cardColor,
                value: _selectedFilter,
                icon: const Icon(Icons.calendar_today, color: Colors.white54, size: 20),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                items: _filters.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedFilter = val);
                    _fetchExpenses();
                  }
                },
              ),
            ),
          )
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Overview Cards
              Row(
                children: [
                  Expanded(child: _ExpenseSummaryCard(title: "Total ($_selectedFilter)", amount: _totalAmount, color: const Color(0xffef5350))),
                  const SizedBox(width: 16),
                  Expanded(child: _ExpenseSummaryCard(title: "Avg/Day", amount: _avgAmount, color: const Color(0xffffa726))),
                ],
              ),
              const SizedBox(height: 24),

              // 2. Bar Chart
              Text("Spending Trend ($_selectedFilter)", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Container(
                height: 250,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20)),
                child: BarChart(
                  BarChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (val, meta) {
                            const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                            if (val.toInt() < days.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(days[val.toInt()], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              );
                            }
                            return const SizedBox();
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: _chartValues.asMap().entries.map((e) {
                      return BarChartGroupData(
                        x: e.key,
                        barRods: [
                          BarChartRodData(
                            toY: e.value,
                            color: e.value > (_totalAmount/7) * 1.5 ? const Color(0xffef5350) : primaryColor, // Highlight spikes
                            width: 16,
                            borderRadius: BorderRadius.circular(4),
                          )
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 3. Breakdown
              const Text("Category Breakdown", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              if (_categoryData.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: Text("No expenses found for this period.", style: TextStyle(color: Colors.grey))),
                )
              else
                ..._categoryData.entries.map((e) => _CategoryRow(category: e.key, amount: e.value)),

              const SizedBox(height: 80),
            ],
          ),
        ),
    );
  }
}

// --- WIDGETS ---

class _ExpenseSummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;

  const _ExpenseSummaryCard({required this.title, required this.amount, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xff1c2a35),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withAlpha(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
          const SizedBox(height: 8),
          Text(
            "\$${amount.toStringAsFixed(0)}",
            style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final String category;
  final double amount;

  const _CategoryRow({required this.category, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xff1c2a35),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 10, height: 10,
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blue.withAlpha(150)),
              ),
              const SizedBox(width: 12),
              Text(category, style: const TextStyle(color: Colors.white, fontSize: 14)),
            ],
          ),
          Text("\$${amount.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// --- ADD EXPENSE FORM (STATEFUL FOR LOGIC) ---

class _AddExpenseSheetContent extends StatefulWidget {
  const _AddExpenseSheetContent();

  @override
  State<_AddExpenseSheetContent> createState() => _AddExpenseSheetContentState();
}

class _AddExpenseSheetContentState extends State<_AddExpenseSheetContent> {
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  
  String _selectedCategory = 'Supplies';
  final List<String> _categories = [
    'Supplies', 'Maintenance', 'Utilities', 'Salaries', 'Events', 'Other'
  ];
  
  bool _isSaving = false;

  Future<void> _saveExpense() async {
    final amount = double.tryParse(_amountCtrl.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Invalid Amount")));
      return;
    }
    if (_descCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Description Required")));
      return;
    }

    setState(() => _isSaving = true);

    try {
      final db = await DatabaseService.instance.database;
      
      // Assuming you have a school_id or using a default. 
      // For single-user simplicity on mobile, we can generate one or query user profile.
      // Here we assume a simple insert into local DB first.
      
      await db.insert('expenses', {
        'id': const Uuid().v4(),
        'school_id': 'local_school_id', // Placeholder or fetch from prefs
        'title': _descCtrl.text.trim(),
        'category': _selectedCategory,
        'amount': amount,
        'date_incurred': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        'description': _descCtrl.text.trim(),
        'created_at': DateTime.now().millisecondsSinceEpoch,
      });

      if (mounted) {
        Navigator.pop(context, true); // Return true to trigger refresh
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Expense Saved")));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20, 
        bottom: MediaQuery.of(context).viewInsets.bottom + 20
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("New Expense", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          
          // Amount
          TextField(
            controller: _amountCtrl,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xff121b22),
              hintText: "Amount (e.g. 50.00)",
              hintStyle: const TextStyle(color: Colors.grey),
              prefixIcon: const Icon(Icons.attach_money, color: Colors.grey),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 12),
          
          // Description
          TextField(
            controller: _descCtrl,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xff121b22),
              hintText: "Description (e.g. Printer Paper)",
              hintStyle: const TextStyle(color: Colors.grey),
              prefixIcon: const Icon(Icons.description, color: Colors.grey),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 12),

          // Category Selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xff121b22),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCategory,
                isExpanded: true,
                dropdownColor: const Color(0xff121b22),
                icon: const Icon(Icons.category, color: Colors.grey),
                style: const TextStyle(color: Colors.white),
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategory = val);
                },
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Save Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveExpense,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff3498db),
                disabledBackgroundColor: Colors.grey.withAlpha(50),
              ),
              child: _isSaving 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text("Save Record", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}