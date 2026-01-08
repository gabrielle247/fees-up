import 'package:isar/isar.dart';
import '../models/people.dart';

class StudentRepository {
  final Isar _isar;

  StudentRepository(this._isar);

  /// Get all students for a specific school
  Future<List<Student>> getAll(String schoolId) async {
    return await _isar.students
        .filter()
        .schoolIdEqualTo(schoolId)
        .findAll();
  }

  /// Get a single student by ID
  Future<Student?> getById(String id) async {
    return await _isar.students
        .filter()
        .idEqualTo(id)
        .findFirst();
  }

  /// Add or update a student
  Future<void> save(Student student) async {
    await _isar.writeTxn(() async {
      await _isar.students.put(student);
    });
  }

  /// Delete a student by ID
  Future<void> delete(String id) async {
    await _isar.writeTxn(() async {
      // Isar delete requires the integer ID (isarId), not the string UUID.
      // So we first find the object to get the isarId.
      final student = await _isar.students
          .filter()
          .idEqualTo(id)
          .findFirst();

      if (student != null) {
        await _isar.students.delete(student.isarId);
      }
    });
  }

  /// Get active students count for dashboard
  Future<int> countActive(String schoolId) async {
    return await _isar.students
        .filter()
        .schoolIdEqualTo(schoolId)
        .statusEqualTo('ACTIVE')
        .count();
  }
}
