import '../services/database_service.dart';

class DashboardRepository {
  final DatabaseService _db;

  DashboardRepository(this._db);

  /// 1. Get the Current User's School ID and Name
  Future<Map<String, dynamic>?> getSchoolDetails(String userId) async {
    // First, find the user's profile to get the school_id
    final profile = await _db.getById('user_profiles', userId);
    if (profile == null || profile['school_id'] == null) return null;

    final schoolId = profile['school_id'];
    
    // Then get the school details
    final school = await _db.getById('schools', schoolId);
    
    return {
      'school_id': schoolId,
      'school_name': school?['name'] ?? 'My School',
      'user_role': profile['role'] ?? 'Admin',
      'user_name': profile['full_name'] ?? 'User',
    };
  }

  /// 2. Watch Key Stats (Real-time)
  /// We combine multiple streams into one or just watch specific tables.
  /// For performance, we usually watch tables and calculate sums in Dart for small datasets,
  /// or use SQL queries if PowerSync supports the aggregate subscription (it does via watch()).
  
  Stream<int> watchStudentCount(String schoolId) {
    return _db.db.watch(
      'SELECT count(*) as count FROM students WHERE school_id = ? AND is_active = 1',
      parameters: [schoolId]
    ).map((results) => results.first['count'] as int);
  }

  Stream<double> watchOutstandingBills(String schoolId) {
    return _db.db.watch(
      'SELECT sum(total_amount - paid_amount) as total FROM bills WHERE school_id = ? AND is_paid = 0',
      parameters: [schoolId]
    ).map((results) => (results.first['total'] as num?)?.toDouble() ?? 0.0);
  }

  Stream<double> watchDailyAttendance(String schoolId) {
    // Simple calculation: Present / Total Students today
    // This is a simplified logic for the dashboard view
    final today = DateTime.now().toIso8601String().split('T')[0];
    return _db.db.watch(
      "SELECT count(*) as count FROM attendance WHERE school_id = ? AND date = ? AND status = 'present'",
      parameters: [schoolId, today]
    ).map((results) => (results.first['count'] as num?)?.toDouble() ?? 0.0);
  }

  /// 3. Get Recent Transactions
  Stream<List<Map<String, dynamic>>> watchRecentPayments(String schoolId) {
    return _db.db.watch(
      'SELECT * FROM payments WHERE school_id = ? ORDER BY date_paid DESC LIMIT 5',
      parameters: [schoolId]
    );
  }
}