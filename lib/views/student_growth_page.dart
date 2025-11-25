import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../view_models/student_growth_view_model.dart';

class StudentGrowthPage extends StatelessWidget {
  const StudentGrowthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StudentGrowthViewModel()..loadGrowthData(),
      child: const _GrowthView(),
    );
  }
}

class _GrowthView extends StatelessWidget {
  const _GrowthView();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<StudentGrowthViewModel>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Student Growth"),
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
                  // 1. HEADLINE KPI
                  _buildKpiRow(context, vm),
                  
                  const SizedBox(height: 24),

                  // 2. LINE CHART
                  Text(
                    "ENROLLMENT HISTORY (CUMULATIVE)",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: Colors.grey.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildChartContainer(context, vm),

                  const SizedBox(height: 24),

                  // 3. STATUS BREAKDOWN
                  Text(
                    "STATUS BREAKDOWN",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: Colors.grey.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildStatusCard(context, vm),
                ],
              ),
            ),
    );
  }

  Widget _buildKpiRow(BuildContext context, StudentGrowthViewModel vm) {
    return Row(
      children: [
        Expanded(
          child: _buildKpiCard(
            context,
            "Total Students",
            "${vm.totalStudents}",
            Icons.school_rounded,
            Colors.blueAccent,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildKpiCard(
            context,
            "New This Month",
            "+${vm.newThisMonth}",
            Icons.person_add_alt_1_rounded,
            Colors.greenAccent,
          ),
        ),
      ],
    );
  }

  Widget _buildKpiCard(BuildContext context, String title, String value, IconData icon, Color color) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
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
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey.withValues(alpha: 0.8)),
          ),
        ],
      ),
    );
  }

  Widget _buildChartContainer(BuildContext context, StudentGrowthViewModel vm) {
    final scheme = Theme.of(context).colorScheme;
    
    // Gradient for the area under the line
    final gradientColors = [
      scheme.primary.withValues(alpha: 0.4),
      scheme.primary.withValues(alpha: 0.0),
    ];

    return Container(
      height: 280,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 10),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.tertiary.withValues(alpha: 0.2)),
      ),
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: vm.maxY,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();
                  if (index < 0 || index >= vm.monthLabels.length) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      vm.monthLabels[index],
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
          lineBarsData: [
            LineChartBarData(
              spots: vm.growthSpots,
              isCurved: true, // Smooth lines
              color: scheme.primary,
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, StudentGrowthViewModel vm) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.tertiary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text("${vm.activeStudents}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                const Text("Active", style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Container(width: 1, height: 40, color: Colors.grey.withValues(alpha: 0.2)),
          Expanded(
            child: Column(
              children: [
                Text("${vm.inactiveStudents}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                const Text("Inactive", style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}