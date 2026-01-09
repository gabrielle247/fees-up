import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/drift_database.dart';
import '../repositories/student_repository.dart';
import 'core_providers.dart';

/// Provides the StudentRepository instance.
final studentRepositoryProvider = Provider<StudentRepository>((ref) {
  final db = ref.watch(driftDatabaseProvider);
  return StudentRepository(db);
});

/// Stream of all students for a given school ID.
final studentsProvider =
    StreamProvider.family<List<Student>, String>((ref, schoolId) {
  final db = ref.watch(driftDatabaseProvider);
  return (db.select(db.students)..where((s) => s.schoolId.equals(schoolId)))
      .watch();
});

/// Future provider for active student count (Dashboard KPI)
final activeStudentCountProvider =
    FutureProvider.family<int, String>((ref, schoolId) async {
  final repo = ref.watch(studentRepositoryProvider);
  return repo.countActive(schoolId);
});
