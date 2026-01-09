import '../database/drift_database.dart';
import '../services/app_logger.dart';

class StudentRepository {
  final AppDatabase _db;

  StudentRepository(this._db);

  /// Get all students for a specific school
  Future<List<Student>> getAll(String schoolId) async {
    try {
      return await (_db.select(_db.students)
            ..where((s) => s.schoolId.equals(schoolId)))
          .get();
    } catch (e, stack) {
      AppLogger.error('StudentRepository: getAll failed', e, stack);
      rethrow;
    }
  }

  /// Get a single student by ID
  Future<Student?> getById(String id) async {
    try {
      return await (_db.select(_db.students)..where((s) => s.id.equals(id)))
          .getSingleOrNull();
    } catch (e, stack) {
      AppLogger.error('StudentRepository: getById failed', e, stack);
      rethrow;
    }
  }

  /// Add or update a student
  Future<void> save(Student student) async {
    try {
      await _db.into(_db.students).insertOnConflictUpdate(student);
    } catch (e, stack) {
      AppLogger.error('StudentRepository: save failed', e, stack);
      rethrow;
    }
  }

  /// Delete a student by ID
  Future<void> delete(String id) async {
    try {
      await (_db.delete(_db.students)..where((s) => s.id.equals(id))).go();
    } catch (e, stack) {
      AppLogger.error('StudentRepository: delete failed', e, stack);
      rethrow;
    }
  }

  /// Get active students count for dashboard
  Future<int> countActive(String schoolId) async {
    try {
      final countExp = _db.students.id.count();
      final query = _db.selectOnly(_db.students)
        ..addColumns([countExp])
        ..where(_db.students.schoolId.equals(schoolId) &
            _db.students.status.equals('ACTIVE'));

      final result = await query.getSingle();
      return result.read(countExp) ?? 0;
    } catch (e) {
      // Return 0 or rethrow based on strategy. For dashboard safety, 0 is better than crash.
      return 0;
    }
  }
}
