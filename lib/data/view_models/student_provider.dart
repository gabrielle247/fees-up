import 'package:fees_up/data/models/student_models.dart';
import 'package:fees_up/data/view_models/prodivers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'session_provider.dart';

// -----------------------------------------------------------------------------
// FILTER STATE
// -----------------------------------------------------------------------------
final studentSearchQueryProvider = StateProvider<String>((ref) => '');

// -----------------------------------------------------------------------------
// LIST PROVIDER (AsyncValue)
// -----------------------------------------------------------------------------
final studentListProvider = FutureProvider.autoDispose<List<Student>>((ref) async {
  // 1. Get Dependencies
  final session = ref.watch(sessionProvider);
  final repo = ref.watch(studentRepositoryProvider);
  final query = ref.watch(studentSearchQueryProvider);

  // 2. Guard: Must have a school
  if (!session.hasSchool) {
    return [];
  }

  final schoolId = session.currentSchool!.id;

  // 3. Fetch Data
  if (query.isEmpty) {
    return await repo.getAllStudents(schoolId);
  } else {
    return await repo.searchStudents(schoolId, query);
  }
});

// -----------------------------------------------------------------------------
// CONTROLLER (Actions)
// -----------------------------------------------------------------------------
final studentControllerProvider = Provider((ref) {
  return StudentController(ref);
});

class StudentController {
  final Ref _ref;

  StudentController(this._ref);

  Future<void> addStudent(Student student) async {
    try {
      await _ref.read(studentRepositoryProvider).createStudent(student);
      _ref.invalidate(studentListProvider); // Auto-refresh the list
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateStudent(Student student) async {
    try {
      await _ref.read(studentRepositoryProvider).updateStudent(student);
      _ref.invalidate(studentListProvider);
    } catch (e) {
      rethrow;
    }
  }
}