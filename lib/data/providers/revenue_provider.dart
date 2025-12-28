import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../services/database_service.dart';
import 'dashboard_provider.dart';

// --- FILTER ENUM ---
enum RevenueFilter { thisWeek, lastWeek }

final revenueFilterProvider = StateProvider<RevenueFilter>((ref) => RevenueFilter.thisWeek);

class WeeklyRevenueData {
  final double totalWeekRevenue;
  final Map<int, double> dailyTotals; // Key: Weekday (1=Mon ... 7=Sun)

  WeeklyRevenueData({required this.totalWeekRevenue, required this.dailyTotals});
}

final weeklyRevenueProvider = FutureProvider<WeeklyRevenueData>((ref) async {
  final dashboardData = await ref.watch(dashboardDataProvider.future);
  final schoolId = dashboardData.schoolId;
  final filter = ref.watch(revenueFilterProvider);

  // 1. Calculate Date Range
  final now = DateTime.now();
  final currentWeekStart = now.subtract(Duration(days: now.weekday - 1)); // This Monday
  
  DateTime startOfWeek;
  DateTime endOfWeek;

  if (filter == RevenueFilter.thisWeek) {
    startOfWeek = DateTime(currentWeekStart.year, currentWeekStart.month, currentWeekStart.day);
    endOfWeek = startOfWeek.add(const Duration(days: 6, hours: 23, minutes: 59));
  } else {
    // Last Week
    startOfWeek = currentWeekStart.subtract(const Duration(days: 7));
    endOfWeek = startOfWeek.add(const Duration(days: 6, hours: 23, minutes: 59));
  }

  final startStr = DateFormat('yyyy-MM-dd').format(startOfWeek);
  final endStr = DateFormat('yyyy-MM-dd').format(endOfWeek);

  // 2. Query Database
  final db = DatabaseService().db;
  final results = await db.getAll(
    'SELECT amount, date_paid FROM payments WHERE school_id = ? AND date_paid >= ? AND date_paid <= ?',
    [schoolId, startStr, endStr],
  );

  // 3. Group by Day
  double total = 0.0;
  final Map<int, double> dailyMap = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0};

  for (var row in results) {
    final amount = (row['amount'] as num).toDouble();
    final dateStr = row['date_paid'] as String;
    final date = DateTime.parse(dateStr);
    
    // Ensure we map correctly even if the date parsing varies slightly
    dailyMap[date.weekday] = (dailyMap[date.weekday] ?? 0) + amount;
    total += amount;
  }

  return WeeklyRevenueData(totalWeekRevenue: total, dailyTotals: dailyMap);
});