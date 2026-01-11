import 'package:logging/logging.dart';
import 'package:powersync/powersync.dart';

// -----------------------------------------------------------------------------
// IMPORTS
// -----------------------------------------------------------------------------
import '../models/student_models.dart';
import '../constants/app_strings.dart';

class StudentRepository {
  final PowerSyncDatabase _db;
  final Logger _log = Logger('StudentRepository');

  StudentRepository(this._db);

  /// ==========================================================================
  /// 1. CREATE
  /// ==========================================================================

  /// Enrolls a new student into the school.
  Future<void> createStudent(Student student) async {
    try {
      _log.info('Enrolling student: ${student.firstName} ${student.lastName}');

      await _db.execute('''
        INSERT INTO students (
          id, 
          school_id, 
          first_name, 
          last_name, 
          national_id, 
          dob, 
          gender, 
          status, 
          enrollment_date, 
          admission_number, 
          guardian_name, 
          guardian_phone, 
          guardian_email, 
          guardian_relationship, 
          student_type, 
          admission_date, 
          is_archived, 
          updated_at, 
          fees_owed, 
          created_at
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''', [
        student.id,
        student.schoolId,
        student.firstName,
        student.lastName,
        student.nationalId,
        student.dob?.toIso8601String(),
        student.gender,
        student.status,
        student.enrollmentDate.toIso8601String(),
        student.admissionNumber,
        student.guardianName,
        student.guardianPhone,
        student.guardianEmail,
        student.guardianRelationship,
        student.studentType,
        student.admissionDate.toIso8601String(),
        student.isArchived ? 1 : 0, // SQLite boolean
        DateTime.now().toIso8601String(), // updated_at
        student.feesOwed,
        student.createdAt.toIso8601String(),
      ]);

      _log.info('✅ Student enrolled successfully: ${student.id}');
    } catch (e, stack) {
      _log.severe('❌ ${AppStrings.studentRepositorySaveFailed}', e, stack);
      throw Exception(AppStrings.studentRepositorySaveFailed);
    }
  }

  /// ==========================================================================
  /// 2. READ
  /// ==========================================================================

  /// Fetches a single student by ID.
  Future<Student?> getStudentById(String studentId) async {
    try {
      final result = await _db.getOptional(
        'SELECT * FROM students WHERE id = ?',
        [studentId],
      );

      if (result == null) return null;
      return Student.fromJson(result);
    } catch (e, stack) {
      _log.severe('❌ ${AppStrings.studentRepositoryGetByIdFailed}', e, stack);
      throw Exception(AppStrings.studentRepositoryGetByIdFailed);
    }
  }

  /// Fetches ALL students for a specific school (Active only by default).
  /// Ordered by Last Name.
  Future<List<Student>> getAllStudents(String schoolId, {bool includeArchived = false}) async {
    try {
      String query = 'SELECT * FROM students WHERE school_id = ?';
      if (!includeArchived) {
        query += ' AND is_archived = 0';
      }
      query += ' ORDER BY last_name ASC';

      final results = await _db.getAll(query, [schoolId]);

      return results.map((row) => Student.fromJson(row)).toList();
    } catch (e, stack) {
      _log.severe('❌ ${AppStrings.studentRepositoryGetAllFailed}', e, stack);
      throw Exception(AppStrings.studentRepositoryGetAllFailed);
    }
  }

  /// Searches for students by Name or Admission Number.
  Future<List<Student>> searchStudents(String schoolId, String query) async {
    try {
      final sanitizedQuery = '%$query%';
      final results = await _db.getAll('''
        SELECT * FROM students 
        WHERE school_id = ? 
        AND (
          first_name LIKE ? OR 
          last_name LIKE ? OR 
          admission_number LIKE ?
        )
        AND is_archived = 0
        ORDER BY first_name ASC
        LIMIT 20
      ''', [schoolId, sanitizedQuery, sanitizedQuery, sanitizedQuery]);

      return results.map((row) => Student.fromJson(row)).toList();
    } catch (e, stack) {
      _log.severe('❌ Search failed', e, stack);
      throw Exception(AppStrings.genericError);
    }
  }

  /// ==========================================================================
  /// 3. UPDATE
  /// ==========================================================================

  /// Updates a student's profile details.
  Future<void> updateStudent(Student student) async {
    try {
      _log.info('Updating student: ${student.id}');

      await _db.execute('''
        UPDATE students SET 
          first_name = ?, 
          last_name = ?, 
          national_id = ?, 
          dob = ?, 
          gender = ?, 
          status = ?, 
          admission_number = ?, 
          guardian_name = ?, 
          guardian_phone = ?, 
          guardian_email = ?, 
          guardian_relationship = ?, 
          student_type = ?, 
          updated_at = ?
        WHERE id = ?
      ''', [
        student.firstName,
        student.lastName,
        student.nationalId,
        student.dob?.toIso8601String(),
        student.gender,
        student.status,
        student.admissionNumber,
        student.guardianName,
        student.guardianPhone,
        student.guardianEmail,
        student.guardianRelationship,
        student.studentType,
        DateTime.now().toIso8601String(), // updated_at
        student.id,
      ]);

      _log.info('✅ Student updated successfully');
    } catch (e, stack) {
      _log.severe('❌ Failed to update student', e, stack);
      throw Exception(AppStrings.genericError);
    }
  }

  /// Updates just the financial balance of a student.
  /// NOTE: This is usually called by the PaymentService, not directly by UI.
  Future<void> updateBalance(String studentId, double newBalance) async {
    try {
      await _db.execute('''
        UPDATE students SET fees_owed = ?, updated_at = ? WHERE id = ?
      ''', [newBalance, DateTime.now().toIso8601String(), studentId]);
      
      _log.fine('💰 Balance updated for student: $studentId -> $newBalance');
    } catch (e) {
      _log.severe('❌ Failed to update balance: $e');
      throw Exception(AppStrings.genericError);
    }
  }

  /// ==========================================================================
  /// 4. ARCHIVE (DELETE)
  /// ==========================================================================

  /// Soft-deletes a student (Archives them).
  /// We rarely hard delete students to preserve financial history.
  Future<void> archiveStudent(String studentId) async {
    try {
      await _db.execute('''
        UPDATE students SET is_archived = 1, status = ?, updated_at = ? WHERE id = ?
      ''', [AppStrings.inactive, DateTime.now().toIso8601String(), studentId]);
      
      _log.warning('🗄️ Student archived: $studentId');
    } catch (e, stack) {
      _log.severe('❌ ${AppStrings.studentRepositoryDeleteFailed}', e, stack);
      throw Exception(AppStrings.studentRepositoryDeleteFailed);
    }
  }
}