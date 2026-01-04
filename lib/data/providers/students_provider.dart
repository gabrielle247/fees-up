import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database_service.dart';

/// 🎓 STUDENTS PROVIDER
/// All student data flows through here. NO hardcoding.
/// Everything reads/writes to local SQLite via DatabaseService.

// ============================================================
// PROVIDERS
// ============================================================

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

/// Stream of all students for a school (Real-time updates via PowerSync)
final studentsProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>(
  (ref, schoolId) {
    final db = ref.watch(databaseServiceProvider);
    return db.watchStudents(schoolId);
  },
);

/// Get a single student by ID
final studentByIdProvider =
    FutureProvider.family<Map<String, dynamic>?, String>(
  (ref, studentId) async {
    final db = ref.watch(databaseServiceProvider);
    return await db.getById('students', studentId);
  },
);

/// Student stats (count, totals) - calculated from the stream
final studentStatsProvider = Provider.family<StudentStats, String>(
  (ref, schoolId) {
    final studentsAsync = ref.watch(studentsProvider(schoolId));

    return studentsAsync.when(
      data: (students) {
        final count = students.length;
        final totalOwed = students.fold<double>(
          0,
          (sum, s) => sum + ((s['owed_total'] as num?)?.toDouble() ?? 0),
        );
        final totalPaid = students.fold<double>(
          0,
          (sum, s) => sum + ((s['paid_total'] as num?)?.toDouble() ?? 0),
        );

        return StudentStats(
          totalCount: count,
          totalOwed: totalOwed,
          totalPaid: totalPaid,
        );
      },
      loading: () => StudentStats(totalCount: 0, totalOwed: 0, totalPaid: 0),
      error: (_, __) => StudentStats(totalCount: 0, totalOwed: 0, totalPaid: 0),
    );
  },
);

// ============================================================
// DATA MODELS
// ============================================================

class StudentStats {
  final int totalCount;
  final double totalOwed;
  final double totalPaid;

  StudentStats({
    required this.totalCount,
    required this.totalOwed,
    required this.totalPaid,
  });
}
