import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../models/people.dart';
import '../repositories/student_repository.dart';
import 'core_providers.dart';

/// Provides the StudentRepository instance.
final studentRepositoryProvider = Provider<Future<StudentRepository>>((ref) async {
  final isar = await ref.watch(isarInstanceProvider);
  return StudentRepository(isar);
});

/// Stream of all students for a given school ID.
final studentsProvider = StreamProvider.family<List<Student>, String>((ref, schoolId) async* {
  final isar = await ref.watch(isarInstanceProvider);

  // Return initial data
  yield await isar.students.filter().schoolIdEqualTo(schoolId).findAll();

  // Listen for changes
  final stream = isar.students
      .filter()
      .schoolIdEqualTo(schoolId)
      .watch(fireImmediately: true);

  await for (final students in stream) {
    yield students;
  }
});

/// Future provider for active student count (Dashboard KPI)
final activeStudentCountProvider = FutureProvider.family<int, String>((ref, schoolId) async {
  final repo = await ref.watch(studentRepositoryProvider);
  return repo.countActive(schoolId);
});
