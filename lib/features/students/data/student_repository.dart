import '../../../core/services/database_service.dart'; // Adjust if your path is different
import 'student_model.dart';

class StudentRepository {
  final DatabaseService _dbService = DatabaseService();

  // --- CREATE ---
  // This is the method the RegisterViewModel calls
  Future<void> addStudent(Student student) async {
    await _dbService.insert('students', student.toMap());
  }

  // --- READ ---
  Future<List<Student>> getAllStudents() async {
    final results = await _dbService.queryAll('students');
    return results.map((map) => Student.fromMap(map)).toList();
  }

  // --- UPDATE ---
  Future<void> updateStudent(Student student) async {
    await _dbService.update('students', student.toMap(), 'id = ?', [
      student.id,
    ]);
  }

  // --- DELETE ---
  Future<void> deleteStudent(String id) async {
    await _dbService.delete('students', 'id = ?', [id]);
  }

  Future<Student?> getStudentById(String id) async {
    final results = await _dbService.queryWhere('students', 'id = ?', [id]);
    if (results.isNotEmpty) {
      return Student.fromMap(results.first);
    }
    return null;
  }
}