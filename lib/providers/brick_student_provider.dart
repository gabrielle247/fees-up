// lib/providers/brick_student_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../services/brick_student_service.dart';
import '../models/student_full.dart';

/// Riverpod provider for Brick-based student operations
/// This shows how to integrate Brick with your existing Riverpod setup

// Service provider
final brickStudentServiceProvider = Provider<BrickStudentService>((ref) {
  return BrickStudentService();
});

// Students list provider
final studentsProvider = FutureProvider<List<StudentModel>>((ref) async {
  final service = ref.watch(brickStudentServiceProvider);
  return await service.getAllStudents();
});

// Active students provider
final activeStudentsProvider = FutureProvider<List<StudentModel>>((ref) async {
  final service = ref.watch(brickStudentServiceProvider);
  return await service.getActiveStudents();
});

// Students with balances provider
final studentsWithBalancesProvider = FutureProvider<List<StudentModel>>((ref) async {
  final service = ref.watch(brickStudentServiceProvider);
  return await service.getStudentsWithBalances();
});

// Single student provider (by ID)
final studentProvider = FutureProvider.family<StudentModel?, String>((ref, id) async {
  final service = ref.watch(brickStudentServiceProvider);
  return await service.getStudent(id);
});

// Students by grade provider
final studentsByGradeProvider = FutureProvider.family<List<StudentModel>, String>((ref, grade) async {
  final service = ref.watch(brickStudentServiceProvider);
  return (await service.getStudentsByGrade(grade)).cast<StudentModel>();
});

// Search provider
final studentSearchProvider = FutureProvider.family<List<StudentModel>, String>((ref, query) async {
  final service = ref.watch(brickStudentServiceProvider);
  return await service.searchStudents(query);
});

// Statistics provider
final studentStatisticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.watch(brickStudentServiceProvider);
  return await service.getStatistics();
});

// State notifier for managing student operations
class StudentNotifier extends StateNotifier<AsyncValue<List<StudentModel>>> {
  final BrickStudentService _service;

  StudentNotifier(this._service) : super(const AsyncValue.loading()) {
    loadStudents();
  }

  /// Load all students
  Future<void> loadStudents() async {
    state = const AsyncValue.loading();
    try {
      final students = await _service.getAllStudents();
      state = AsyncValue.data(students);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Refresh from remote
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      await _service.syncStudents();
      final students = await _service.getAllStudents(requireRemote: true);
      state = AsyncValue.data(students);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Add student
  Future<bool> addStudent(StudentModel student) async {
    try {
      final saved = await _service.saveStudent(student);
      if (saved != null) {
        await loadStudents();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error adding student: $e');
      return false;
    }
  }

  /// Update student
  Future<bool> updateStudent(StudentModel student) async {
    try {
      final updated = await _service.saveStudent(student);
      if (updated != null) {
        await loadStudents();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error updating student: $e');
      return false;
    }
  }

  /// Delete student
  Future<bool> deleteStudent(String id) async {
    try {
      final deleted = await _service.deleteStudent(id);
      if (deleted) {
        await loadStudents();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting student: $e');
      return false;
    }
  }

  /// Search students
  Future<void> search(String query) async {
    if (query.isEmpty) {
      await loadStudents();
      return;
    }

    state = const AsyncValue.loading();
    try {
      final results = await _service.searchStudents(query);
      state = AsyncValue.data(results);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Filter by grade
  Future<void> filterByGrade(String grade) async {
    state = const AsyncValue.loading();
    try {
      final students = await _service.getStudentsByGrade(grade);
      state = AsyncValue.data(students);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Show only active
  Future<void> showActiveOnly() async {
    state = const AsyncValue.loading();
    try {
      final students = await _service.getActiveStudents();
      state = AsyncValue.data(students);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

// Student notifier provider
final studentNotifierProvider = StateNotifierProvider<StudentNotifier, AsyncValue<List<StudentModel>>>((ref) {
  final service = ref.watch(brickStudentServiceProvider);
  return StudentNotifier(service);
});
