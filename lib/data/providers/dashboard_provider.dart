import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/dashboard_repository.dart';
import '../services/database_service.dart';
import 'auth_provider.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(DatabaseService());
});

// A simple class to hold our dashboard data snapshot
class DashboardData {
  final String schoolName;
  final String userName;
  final int studentCount;
  final double outstandingBalance;
  final List<Map<String, dynamic>> recentPayments;

  DashboardData({
    required this.schoolName,
    required this.userName,
    required this.studentCount,
    required this.outstandingBalance,
    required this.recentPayments,
  });
}

// THE MAIN PROVIDER WATCHED BY THE UI
final dashboardDataProvider = StreamProvider<DashboardData>((ref) async* {
  final user = ref.watch(currentUserProvider);
  if (user == null) throw 'User not logged in';

  final repo = ref.watch(dashboardRepositoryProvider);
  
  // 1. Get School Context
  final details = await repo.getSchoolDetails(user.id);
  if (details == null) throw 'No school linked to this account';
  
  final schoolId = details['school_id'];

  // 2. Combine Streams (RxDart style, or just yielding for simplicity)
  // For a true reactive app, we listen to the database changes.
  
  // Create a combined stream of the critical data points
  // Note: In a large app, we might split these. For this Dashboard, we want them consistent.
  
  // We yield a new DashboardData whenever the database emits a change on relevant tables
  // This is a simplified stream generator for the example:
  
  final stream = DatabaseService().db.watch('SELECT 1'); // Dummy trigger to keep stream alive if needed, but better to watch distincts.
  
  // Actually, let's just listen to the payments/students tables combined
  await for (final _ in DatabaseService().db.onChange(['students', 'bills', 'payments'])) {
     
     // Fetch latest values locally (fast since it's SQLite)
     // We use direct queries inside the loop because they are synchronous-like in speed locally
     final students = await DatabaseService().db.get('SELECT count(*) as c FROM students WHERE school_id = ?', [schoolId]);
     final bills = await DatabaseService().db.get('SELECT sum(total_amount - paid_amount) as t FROM bills WHERE school_id = ?', [schoolId]);
     final payments = await DatabaseService().db.getAll('SELECT * FROM payments WHERE school_id = ? ORDER BY date_paid DESC LIMIT 5', [schoolId]);

     yield DashboardData(
       schoolName: details['school_name'],
       userName: details['user_name'],
       studentCount: (students['c'] as int),
       outstandingBalance: (bills['t'] as num?)?.toDouble() ?? 0.0,
       recentPayments: payments,
     );
  }
});