import '../database/drift_database.dart';

class StudentRepository {
  final AppDatabase _db;

  StudentRepository(this._db);

  /// Get all students for a specific school
  Future<List<Student>> getAll(String schoolId) async {
    return await (_db.select(_db.students)
          ..where((s) => s.schoolId.equals(schoolId)))
        .get();
  }

  /// Get a single student by ID
  Future<Student?> getById(String id) async {
    return await (_db.select(_db.students)..where((s) => s.id.equals(id)))
        .getSingleOrNull();
  }

  /// Add or update a student
  Future<void> save(Student student) async {
    await _db.into(_db.students).insertOnConflictUpdate(student);
  }

  /// Delete a student by ID
  Future<void> delete(String id) async {
    await (_db.delete(_db.students)..where((s) => s.id.equals(id))).go();
  }

  /// Get active students count for dashboard
  Future<int> countActive(String schoolId) async {
    final students = await (_db.select(_db.students)
          ..where((s) => s.schoolId.equals(schoolId))
          ..where((s) => s.status.equals('ACTIVE')))
        .get();

    return students.length;
  }
}
