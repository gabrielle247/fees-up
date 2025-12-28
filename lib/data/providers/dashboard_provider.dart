import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/dashboard_repository.dart';
import '../services/database_service.dart';
import 'auth_provider.dart';
import 'school_provider.dart'; // ✅ Imported

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(DatabaseService());
});

// A simple class to hold our dashboard data snapshot
class DashboardData {
  final String schoolId;
  final String schoolName;
  final String userName;
  final int studentCount;
  final double outstandingBalance;
  final List<Map<String, dynamic>> recentPayments;

  DashboardData({
    required this.schoolId,
    required this.schoolName,
    required this.userName,
    required this.studentCount,
    required this.outstandingBalance,
    required this.recentPayments,
  });
}
final dashboardDataProvider = StreamProvider<DashboardData>((ref) async* {
  final user = ref.watch(currentUserProvider);
  if (user == null) throw 'User not logged in';

  // 1. Get the school data (caches after first successful fetch)
  final school = await ref.watch(currentSchoolProvider.future);
  
  if (school == null) {
    yield DashboardData(
      schoolId: '',
      schoolName: 'Loading...',
      userName: '',
      studentCount: 0,
      outstandingBalance: 0,
      recentPayments: [],
    );
    return;
  }

  final schoolId = school['id'];
  final schoolName = school['name'];
  final dbService = DatabaseService();

  // 2. Listen for ANY changes in the relevant tables
  // This keeps the Batch Tech dashboard live and reactive
  await for (final _ in dbService.db.onChange(['students', 'bills', 'payments', 'user_profiles'])) {
    
    // Fetch profile and stats in parallel for better performance
    final results = await Future.wait([
      dbService.getUserProfile(user.id),
      dbService.db.get('SELECT count(*) as c FROM students WHERE school_id = ?', [schoolId]),
      dbService.db.get('SELECT sum(total_amount - paid_amount) as t FROM bills WHERE school_id = ?', [schoolId]),
      dbService.db.getAll('SELECT * FROM payments WHERE school_id = ? ORDER BY date_paid DESC LIMIT 5', [schoolId]),
    ]);

    final profile = results[0] as Map<String, dynamic>?;
    final students = results[1] as Map<String, dynamic>;
    final bills = results[2] as Map<String, dynamic>;
    final payments = results[3] as List<Map<String, dynamic>>;

    yield DashboardData(
      schoolId: schoolId,
      schoolName: schoolName,
      userName: profile?['full_name'] ?? 'Admin',
      studentCount: (students['c'] as int),
      outstandingBalance: (bills['t'] as num?)?.toDouble() ?? 0.0,
      recentPayments: payments,
    );
  }
});