// lib/providers/dashboard_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database_service.dart';
import '../models/dashboard_summary.dart';

// 1. Expose the DatabaseService instance
final databaseServiceProvider = Provider((ref) => DatabaseService.instance);

// 2. Dashboard Summary Provider
final dashboardSummaryProvider = FutureProvider.autoDispose<DashboardSummary>((ref) async {
  final dbService = ref.watch(databaseServiceProvider);
  
  // Force a refresh to get the latest data before calculation
  await dbService.refreshStudentFullCache(includeInactive: true); 

  // Fetch all hydrated student data
  final allStudents = await dbService.getAllStudentsWithFinancials(includeInactive: true);

  if (allStudents.isEmpty) {
    return DashboardSummary.initial();
  }

  // Aggregate metrics
  final activeStudents = allStudents.where((s) => s.student.isActive).length;
  final inactiveStudents = allStudents.length - activeStudents;
  
  // Calculate Financials
  // accurate summing using the getters in StudentFull
  final totalBilled = allStudents.fold(0.0, (sum, s) => sum + s.totalBilled);
  final totalPaid = allStudents.fold(0.0, (sum, s) => sum + s.totalPaid);
  final totalOwed = allStudents.fold(0.0, (sum, s) => sum + s.owed); 

  return DashboardSummary(
    activeStudents: activeStudents,
    inactiveStudents: inactiveStudents,
    totalFeesBilled: totalBilled,
    totalFeesPaid: totalPaid,
    totalFeesOwed: totalOwed,
  );
});