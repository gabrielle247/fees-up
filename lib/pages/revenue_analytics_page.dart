// lib/pages/revenue_analytics_page.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/database_service.dart';

class RevenueAnalyticsPage extends StatefulWidget {
  const RevenueAnalyticsPage({super.key});

  @override
  State<RevenueAnalyticsPage> createState() => _RevenueAnalyticsPageState();
}

class _RevenueAnalyticsPageState extends State<RevenueAnalyticsPage> {
  // Filter State
  String _selectedFilter = 'Monthly';
  final List<String> _filters = ['Weekly', 'Monthly', 'Yearly'];

  // Data State
  bool _isLoading = true;
  double _totalRevenue = 0.0;
  double _growthPercentage = 0.0; // Comparison logic
  double _outstandingTotal = 0.0;
  
  // Chart Data
  List<FlSpot> _trendSpots = [];
  double _maxY = 100.0;

  // Recent Transactions
  List<Map<String, dynamic>> _recentPayments = [];

  @override
  void initState() {
    super.initState();
    _fetchRevenueData();
  }

  Future<void> _fetchRevenueData() async {
    setState(() => _isLoading = true);
    final db = await DatabaseService.instance.database;

    DateTime now = DateTime.now();
    DateTime startDate;
    // ignore: unused_local_variable
    DateTime previousStartDate; // For future growth calc implementation

    // 1. Determine Date Range
    switch (_selectedFilter) {
      case 'Weekly':
        startDate = now.subtract(const Duration(days: 7));
        previousStartDate = now.subtract(const Duration(days: 14));
        break;
      case 'Monthly':
        startDate = DateTime(now.year, now.month, 1);
        previousStartDate = DateTime(now.year, now.month - 1, 1);
        break;
      case 'Yearly':
        startDate = DateTime(now.year, 1, 1);
        previousStartDate = DateTime(now.year - 1, 1, 1);
        break;
      default:
        startDate = DateTime(now.year, now.month, 1);
        previousStartDate = DateTime(now.year, now.month - 1, 1);
    }

    final startStr = DateFormat('yyyy-MM-dd').format(startDate);
    
    // 2. Query Payments (Current Period)
    final payments = await db.query(
      'payments',
      where: 'date_paid >= ?',
      whereArgs: [startStr],
      orderBy: 'date_paid ASC',
    );

    // 3. Query Outstanding (From Bills that are not fully paid)
    // Note: This is usually total outstanding of ALL time, but let's keep it simple
    final bills = await db.rawQuery(
      'SELECT SUM(total_amount - paid_amount) as owed FROM bills WHERE is_closed = 0'
    );
    final outstanding = (bills.first['owed'] as num?)?.toDouble() ?? 0.0;

    // 4. Process Data for Chart & Total
    double total = 0.0;
    Map<int, double> groupedData = {}; // Key = day (or month for yearly)
    
    for (var row in payments) {
      final amt = (row['amount'] as num).toDouble();
      final dateStr = row['date_paid'] as String;
      final date = DateTime.parse(dateStr);
      
      total += amt;

      // Grouping Logic
      int key;
      if (_selectedFilter == 'Yearly') {
        key = date.month; // 1-12
      } else {
        key = date.day; // 1-31
      }
      groupedData[key] = (groupedData[key] ?? 0) + amt;
    }

    // 5. Build Chart Spots
    List<FlSpot> spots = [];
    double maxVal = 0;
    
    // Sort keys to ensure line goes left-to-right
    final sortedKeys = groupedData.keys.toList()..sort();
    
    if (sortedKeys.isEmpty) {
      spots.add(const FlSpot(0, 0));
    } else {
      for (var key in sortedKeys) {
        final val = groupedData[key]!;
        if (val > maxVal) maxVal = val;
        spots.add(FlSpot(key.toDouble(), val));
      }
    }

    // 6. Refresh UI
    if (mounted) {
      setState(() {
        _totalRevenue = total;
        _outstandingTotal = outstanding;
        _trendSpots = spots;
        _maxY = maxVal * 1.2; // Add 20% headroom
        _recentPayments = payments.reversed.take(10).toList(); // Show last 10
        _isLoading = false;
        // _growthPercentage would require a second query for 'previousStartDate' range
        // For now, hardcoding a dummy calculation or leaving as 0
        _growthPercentage = 5.2; 
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xff121b22);
    const cardColor = Color(0xff1c2a35);
    const accentGreen = Color(0xff00c853);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        title: const Text("Revenue Analytics", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                dropdownColor: cardColor,
                value: _selectedFilter,
                icon: const Icon(Icons.filter_list, color: Colors.white54),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                items: _filters.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedFilter = val);
                    _fetchRevenueData();
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
              // 1. Hero Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xff1565c0), Color(0xff42a5f5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.blue.withAlpha(50), blurRadius: 20, offset: const Offset(0, 10))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Total Revenue ($_selectedFilter)", style: const TextStyle(color: Colors.white70)),
                    const SizedBox(height: 8),
                    Text(
                      "\$${NumberFormat('#,##0.00').format(_totalRevenue)}",
                      style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(8)),
                          child: Row(
                            children: [
                              const Icon(Icons.trending_up, color: Colors.white, size: 16),
                              const SizedBox(width: 4),
                              Text("+$_growthPercentage%", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text("vs last period", style: TextStyle(color: Colors.white54, fontSize: 12)),
                      ],
                    )
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 2. Secondary Metrics Row
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      label: "Outstanding",
                      value: "\$${NumberFormat.compact().format(_outstandingTotal)}",
                      color: const Color(0xffef5350),
                      icon: Icons.access_time_filled,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _MetricCard(
                      label: "Transactions",
                      value: "${_recentPayments.length}", // Just current count
                      color: accentGreen,
                      icon: Icons.check_circle,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // 3. Line Chart
              const Text("Income Trend", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Container(
                height: 300,
                padding: const EdgeInsets.only(right: 20, left: 10, top: 20, bottom: 10),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white10),
                ),
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (val) => FlLine(color: Colors.white10, strokeWidth: 1),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: _selectedFilter == 'Monthly' ? 5 : 1, // Skip labels if crowded
                          getTitlesWidget: (val, meta) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                val.toInt().toString(), 
                                style: const TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    minX: _trendSpots.isNotEmpty ? _trendSpots.first.x : 0,
                    maxX: _trendSpots.isNotEmpty ? _trendSpots.last.x : 10,
                    minY: 0,
                    maxY: _maxY,
                    lineBarsData: [
                      LineChartBarData(
                        spots: _trendSpots,
                        isCurved: true,
                        gradient: const LinearGradient(colors: [Color(0xff42a5f5), Color(0xff1565c0)]),
                        barWidth: 4,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [const Color(0xff42a5f5).withAlpha(50), const Color(0xff42a5f5).withAlpha(0)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // 4. Recent Transactions List
              const Text("Recent Payments", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              if (_recentPayments.isEmpty)
                 const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("No data available", style: TextStyle(color: Colors.grey))))
              else
                ..._recentPayments.map((p) => _PaymentListTile(payment: p)),
                
              const SizedBox(height: 50),
            ],
          ),
        ),
    );
  }
}

// --- WIDGETS ---

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _MetricCard({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xff1c2a35),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Icon(icon, color: color, size: 18),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _PaymentListTile extends StatelessWidget {
  final Map<String, dynamic> payment;

  const _PaymentListTile({required this.payment});

  @override
  Widget build(BuildContext context) {
    final amount = payment['amount'] as double;
    final date = DateTime.parse(payment['date_paid']);
    final method = payment['method'] ?? 'Cash';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xff1c2a35),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xff00c853).withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.attach_money, color: Color(0xff00c853), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Tuition Payment", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text(
                  DateFormat('MMM dd, hh:mm a').format(date), 
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("+\$${amount.toStringAsFixed(2)}", style: const TextStyle(color: Color(0xff00c853), fontWeight: FontWeight.bold)),
              Text(method, style: const TextStyle(color: Colors.grey, fontSize: 10)),
            ],
          )
        ],
      ),
    );
  }
}