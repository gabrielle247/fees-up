import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/providers/revenue_provider.dart';

class RevenueChart extends ConsumerWidget {
  const RevenueChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final revenueAsync = ref.watch(weeklyRevenueProvider);
    final currentFilter = ref.watch(revenueFilterProvider);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceGrey,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: revenueAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red, fontSize: 12))),
        data: (data) {
          // Dynamic Y-Axis Scale
          double maxY = 100;
          for (var val in data.dailyTotals.values) {
            if (val > maxY) maxY = val;
          }
          maxY = maxY * 1.2; // Add breathing room

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Revenue & Collections", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(
                        "Total: ${NumberFormat.simpleCurrency().format(data.totalWeekRevenue)}", 
                        style: const TextStyle(color: Colors.white54, fontSize: 13)
                      ),
                    ],
                  ),
                  
                  // --- FUNCTIONAL DROPDOWN ---
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(6)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<RevenueFilter>(
                        value: currentFilter,
                        dropdownColor: const Color(0xFF2C2F36),
                        icon: const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.white),
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                        onChanged: (RevenueFilter? newValue) {
                          if (newValue != null) {
                            // This triggers the provider to refresh
                            ref.read(revenueFilterProvider.notifier).state = newValue;
                          }
                        },
                        items: const [
                          DropdownMenuItem(value: RevenueFilter.thisWeek, child: Text("This Week")),
                          DropdownMenuItem(value: RevenueFilter.lastWeek, child: Text("Last Week")),
                        ],
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 24),
              
              // --- CHART ---
              Expanded(
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (value) => const FlLine(color: Colors.white10, strokeWidth: 1),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          interval: 1, 
                          getTitlesWidget: (value, meta) {
                            const style = TextStyle(color: Colors.white38, fontSize: 12);
                            // Visual Map: 0=Mon, 2=Tue, 4=Wed, 6=Thu, 8=Fri
                            switch (value.toInt()) {
                              case 0: return const Text('Mon', style: style);
                              case 2: return const Text('Tue', style: style);
                              case 4: return const Text('Wed', style: style);
                              case 6: return const Text('Thu', style: style);
                              case 8: return const Text('Fri', style: style);
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            if (value == 0) return const SizedBox.shrink();
                            return Text(
                              NumberFormat.compact().format(value),
                              style: const TextStyle(color: Colors.white38, fontSize: 10),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    minX: 0,
                    maxX: 8,
                    minY: 0,
                    maxY: maxY,
                    lineBarsData: [
                      LineChartBarData(
                        spots: [
                          // Mapping Real Data to Visual X Coordinates
                          FlSpot(0, data.dailyTotals[1] ?? 0),
                          FlSpot(2, data.dailyTotals[2] ?? 0),
                          FlSpot(4, data.dailyTotals[3] ?? 0),
                          FlSpot(6, data.dailyTotals[4] ?? 0),
                          FlSpot(8, data.dailyTotals[5] ?? 0),
                        ],
                        isCurved: true,
                        color: AppColors.primaryBlue,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppColors.primaryBlue.withAlpha(25),
                        ),
                      ),
                    ],
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (spot) => Colors.black87,
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            return LineTooltipItem(
                              "\$${spot.y.toStringAsFixed(2)}",
                              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            );
                          }).toList();
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}