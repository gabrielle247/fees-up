import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../view_models/revenue_view_model.dart';

class RevenueReportsPage extends StatelessWidget {
  const RevenueReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RevenueViewModel()..loadRevenueData(),
      child: const _RevenueView(),
    );
  }
}

class _RevenueView extends StatelessWidget {
  const _RevenueView();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RevenueViewModel>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Revenue Reports"),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. MAIN KPI CARD
                  _buildTotalRevenueCard(context, vm),
                  const SizedBox(height: 20),

                  // 2. BAR CHART
                  Text(
                    "REVENUE TREND (6 MONTHS)",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: Colors.grey.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildChartContainer(context, vm),

                  const SizedBox(height: 20),

                  // 3. DETAILED STATS ROW
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatTile(
                          context,
                          "This Month",
                          "\$${vm.thisMonth.toStringAsFixed(0)}",
                          Icons.calendar_today_rounded,
                          colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatTile(
                          context,
                          "Growth",
                          "${vm.growthPercent >= 0 ? '+' : ''}${vm.growthPercent.toStringAsFixed(1)}%",
                          vm.growthPercent >= 0
                              ? Icons.trending_up
                              : Icons.trending_down,
                          vm.growthPercent >= 0 ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTotalRevenueCard(BuildContext context, RevenueViewModel vm) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [scheme.primary, scheme.tertiary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            "Total Lifetime Revenue",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            "\$${vm.totalAllTime.toStringAsFixed(2)}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartContainer(BuildContext context, RevenueViewModel vm) {
    final scheme = Theme.of(context).colorScheme;

    // Find max value for dynamic scaling
    double maxY = 100;
    if (vm.chartData.isNotEmpty) {
      // Get largest value in list
      maxY = vm.chartData.reduce((curr, next) => curr > next ? curr : next);
      if (maxY == 0) maxY = 100;
      maxY = maxY * 1.2; // Add 20% buffer for visual headroom
    }

    return Container(
      height: 250,
      padding: const EdgeInsets.fromLTRB(12, 24, 12, 12),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.tertiary.withValues(alpha: 0.2)),
      ),
      child: BarChart(
        BarChartData(
          maxY: maxY,
          minY: 0,
          gridData: const FlGridData(show: false), // Cleaner look
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();
                  if (index < 0 || index >= vm.chartLabels.length) {
                    return const Text('');
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      vm.chartLabels[index],
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: List.generate(vm.chartData.length, (index) {
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: vm.chartData[index],
                  color:
                      index ==
                          5 // Highlight current month
                      ? scheme.primary
                      : scheme.primary.withValues(alpha: 0.3),
                  width: 16,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: maxY,
                    color: scheme.tertiary.withValues(alpha: 0.05),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildStatTile(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.tertiary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
