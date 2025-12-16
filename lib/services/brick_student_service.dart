// lib/services/brick_student_service.dart
import 'package:flutter/foundation.dart';
import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import '../brick/repository/brick_repository.dart';
import '../models/student_brick.dart';
import '../models/student_full.dart';

/// Example service showing how to use Brick repository
/// This wraps Brick operations and provides backward compatibility
class BrickStudentService {
  final _repo = BrickRepository.instance;

  /// Get all students with offline-first approach
  Future<List<StudentModel>> getAllStudents({
    bool requireRemote = false,
    String? adminUid,
    bool? isActive,
  }) async {
    try {
      // Build query based on filters
      Query? query;
      
      if (adminUid != null) {
        query = Query.where('adminUid', adminUid);
      }
      
      if (isActive != null) {
        query = query?.where('isActive', isActive) ?? 
                Query.where('isActive', isActive);
      }

      // Fetch from Brick repository
      final brickStudents = await _repo.getAll<Student>(
        query: query,
        requireRemote: requireRemote,
      );

      // Convert to legacy StudentModel for backward compatibility
      return brickStudents.map((s) => s.toStudentModel()).toList();
    } catch (e) {
      debugPrint('Error getting students from Brick: $e');
      return [];
    }
  }

  /// Get single student by ID
  Future<StudentModel?> getStudent(String id, {bool requireRemote = false}) async {
    try {
      final student = await _repo.get<Student>(
        id,
        requireRemote: requireRemote,
      );
      
      return student?.toStudentModel();
    } catch (e) {
      debugPrint('Error getting student from Brick: $e');
      return null;
    }
  }

  /// Search students by name
  Future<List<StudentModel>> searchStudents(String searchTerm) async {
    try {
      // Get all students (from local cache)
      final allStudents = await _repo.getAll<Student>(requireRemote: false);
      
      // Filter by name (you could add this as a Brick query too)
      final filtered = allStudents.where((student) {
        final name = student.fullName?.toLowerCase() ?? '';
        return name.contains(searchTerm.toLowerCase());
      }).toList();

      return filtered.map((s) => s.toStudentModel()).toList();
    } catch (e) {
      debugPrint('Error searching students: $e');
      return [];
    }
  }

  /// Create or update student
  Future<StudentModel?> saveStudent(StudentModel student) async {
    try {
      // Convert to Brick model
      final brickStudent = Student.fromStudentModel(student);
      
      // Upsert (creates or updates)
      final saved = await _repo.upsert(brickStudent);
      
      return saved?.toStudentModel();
    } catch (e) {
      debugPrint('Error saving student to Brick: $e');
      return null;
    }
  }

  /// Delete student
  Future<bool> deleteStudent(String id) async {
    try {
      final student = await _repo.get<Student>(id);
      if (student == null) return false;
      
      return await _repo.delete(student);
    } catch (e) {
      debugPrint('Error deleting student: $e');
      return false;
    }
  }

  /// Get students by grade
  Future<List<StudentModel>> getStudentsByGrade(String grade) async {
    try {
      final students = await _repo.getAll<Student>(
        query: Query.where('grade', grade),
        requireRemote: false,
      );
      
      return students.map((s) => s.toStudentModel()).toList();
    } catch (e) {
      debugPrint('Error getting students by grade: $e');
      return [];
    }
  }

  /// Get active students only
  Future<List<StudentModel>> getActiveStudents() async {
    return await getAllStudents(isActive: true);
  }

  /// Get students with outstanding balances
  Future<List<StudentModel>> getStudentsWithBalances() async {
    try {
      final students = await _repo.getAll<Student>(requireRemote: false);
      
      // Filter students with owed amount > 0
      final withBalances = students.where((s) => s.owedTotal > 0).toList();
      
      return withBalances.map((s) => s.toStudentModel()).toList();
    } catch (e) {
      debugPrint('Error getting students with balances: $e');
      return [];
    }
  }

  /// Sync students from Supabase
  Future<bool> syncStudents() async {
    try {
      await _repo.sync<Student>();
      debugPrint('Students synced successfully');
      return true;
    } catch (e) {
      debugPrint('Error syncing students: $e');
      return false;
    }
  }

  /// Subscribe to student changes (real-time updates)
  void subscribeToChanges(Function(List<StudentModel>) onUpdate) {
    _repo.subscribe<Student>(
      onData: (brickStudents) {
        final models = brickStudents.map((s) => s.toStudentModel()).toList();
        onUpdate(models);
      },
      onError: (error) {
        debugPrint('Error in student subscription: $error');
      },
    );
  }

  /// Get statistics
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      final students = await _repo.getAll<Student>(requireRemote: false);
      
      final totalStudents = students.length;
      final activeStudents = students.where((s) => s.isActive).length;
      final totalOwed = students.fold<double>(
        0.0,
        (sum, s) => sum + s.owedTotal,
      );
      final totalPaid = students.fold<double>(
        0.0,
        (sum, s) => sum + s.paidTotal,
      );
      
      return {
        'totalStudents': totalStudents,
        'activeStudents': activeStudents,
        'inactiveStudents': totalStudents - activeStudents,
        'totalOwed': totalOwed,
        'totalPaid': totalPaid,
        'totalRevenue': totalPaid + totalOwed,
      };
    } catch (e) {
      debugPrint('Error calculating statistics: $e');
      return {};
    }
  }

  /// Bulk operations
  Future<bool> bulkSaveStudents(List<StudentModel> students) async {
    try {
      for (final student in students) {
        final brickStudent = Student.fromStudentModel(student);
        await _repo.upsert(brickStudent);
      }
      debugPrint('Bulk saved ${students.length} students');
      return true;
    } catch (e) {
      debugPrint('Error bulk saving students: $e');
      return false;
    }
  }

  /// Clear local cache (useful for logout)
  Future<void> clearLocalCache() async {
    try {
      await _repo.clearLocal<Student>();
      debugPrint('Student cache cleared');
    } catch (e) {
      debugPrint('Error clearing cache: $e');
    }
  }
}
