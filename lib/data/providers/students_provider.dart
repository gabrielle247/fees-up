import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database_service.dart';
import 'auth_provider.dart';
import '../../core/utils/safe_data.dart';

/// 🎓 STUDENTS PROVIDER
/// All student data flows through here. NO hardcoding.
/// Everything reads/writes to local SQLite via DatabaseService.

// ============================================================
// PROVIDERS
// ============================================================

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

/// Stream of all students for a school (Real-time updates via PowerSync)
final studentsProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>(
  (ref, schoolId) {
    final db = ref.watch(databaseServiceProvider);
    return db.watchStudents(schoolId);
  },
);

/// Get a single student by ID
final studentByIdProvider =
    FutureProvider.family<Map<String, dynamic>?, String>(
  (ref, studentId) async {
    final db = ref.watch(databaseServiceProvider);
    return await db.getById('students', studentId);
  },
);

/// � CLASSES PROVIDER
/// Stream of all classes for a school (Real-time updates via PowerSync)
// 🟢 [FIX 1] Real Classes Data
final classesProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>(
  (ref, schoolId) {
    final db = ref.watch(databaseServiceProvider);
    return db.watchClasses(schoolId);
  },
);

/// 🎯 SELECTED STUDENT PROVIDER
/// Tracks which student is currently selected for viewing details
final selectedStudentProvider =
    StateProvider<Map<String, dynamic>?>((ref) => null);

/// 📢 NOTIFICATIONS PROVIDER
/// Stream of all notifications for a user (Real-time updates via PowerSync)
// 🟢 [FIX 2] Real Notification Data
final notificationsProvider = StreamProvider<List<Map<String, dynamic>>>(
  (ref) {
    final user = ref.watch(currentUserProvider);
    if (user == null) return Stream.value([]);

    final db = ref.watch(databaseServiceProvider);
    return db.watchNotifications(user.id);
  },
);

/// 🔍 FILTER STATE NOTIFIERS
/// Manage filter state for the students table

final studentSearchProvider = StateProvider<String>((ref) => '');

final studentGradeFilterProvider = StateProvider<String?>((ref) => null);

final studentClassFilterProvider = StateProvider<String?>((ref) => null);

final studentStatusFilterProvider = StateProvider<String?>((ref) => null);

final studentFinancialFilterProvider = StateProvider<String?>((ref) => null);

/// Filtered & Searched Students
final filteredStudentsProvider =
    Provider.family<List<Map<String, dynamic>>, String>(
  (ref, schoolId) {
    final studentsAsync = ref.watch(studentsProvider(schoolId));
    final searchQuery = ref.watch(studentSearchProvider).toLowerCase();
    final gradeFilter = ref.watch(studentGradeFilterProvider);
    final classFilter = ref.watch(studentClassFilterProvider);
    final statusFilter = ref.watch(studentStatusFilterProvider);
    final financialFilter = ref.watch(studentFinancialFilterProvider);

    return studentsAsync.when(
      data: (students) {
        return students.where((student) {
          // Search filter
          if (searchQuery.isNotEmpty) {
            final name = (student['full_name'] ?? '').toString().toLowerCase();
            final id = (student['student_id'] ?? '').toString().toLowerCase();
            final contact =
                (student['parent_contact'] ?? '').toString().toLowerCase();
            final parentName = (student['emergency_contact_name'] ?? '')
                .toString()
                .toLowerCase();

            if (!name.contains(searchQuery) &&
                !id.contains(searchQuery) &&
                !contact.contains(searchQuery) &&
                !parentName.contains(searchQuery)) {
              return false;
            }
          }

          // Grade filter
          if (gradeFilter != null && gradeFilter != 'All Grades') {
            final grade = (student['grade'] ?? '').toString();
            if (grade != gradeFilter) return false;
          }

          // Class filter
          if (classFilter != null && classFilter != 'All Classes') {
            final studentClass = (student['class'] ?? '').toString();
            if (studentClass != classFilter) return false;
          }

          // Status filter
          if (statusFilter != null && statusFilter != 'Status: All') {
            // 🛡️ Issue #2 Fix: Safe type parsing instead of unsafe 'as int?'
            final isActive = SafeData.parseInt(student['is_active']) == 1;
            final isSuspended = SafeData.parseInt(student['is_suspended']) == 1;

            if (statusFilter == 'Status: Active' &&
                (!isActive || isSuspended)) {
              return false;
            }
            if (statusFilter == 'Status: Inactive' && isActive) return false;
            if (statusFilter == 'Status: Suspended' && !isSuspended) {
              return false;
            }
            if (statusFilter == 'Status: Banned Forever' &&
                (!isSuspended || isActive)) {
              return false;
            }
          }

          // Financial filter
          if (financialFilter != null && financialFilter != 'Financial: All') {
            // 🛡️ Issue #2 Fix: Safe double parsing
            final owed = SafeData.parseDouble(student['owed_total']);
            if (financialFilter == 'Financial: Owed' && owed <= 0) return false;
            if (financialFilter == 'Financial: Paid' && owed > 0) return false;
          }

          return true;
        }).toList();
      },
      loading: () => [],
      error: (_, __) => [],
    );
  },
);

// ============================================================
// ZIMBABWE ZIMSEC GRADES/FORMS
// ============================================================
/// Grades 1-7 (Primary): Grade 1, Grade 2, ..., Grade 7
/// Forms 1-6 (Secondary): Form 1 (O-Level), Form 2 (O-Level), Form 3 (A-Level),
///                        Form 4 (A-Level), Form 5 (A-Level), Form 6 (A-Level)
const List<String> zimsecGrades = [
  'Grade 1',
  'Grade 2',
  'Grade 3',
  'Grade 4',
  'Grade 5',
  'Grade 6',
  'Grade 7',
  'Form 1 (O-Level)',
  'Form 2 (O-Level)',
  'Form 3 (A-Level)',
  'Form 4 (A-Level)',
  'Form 5 (A-Level)',
  'Form 6 (A-Level)',
];

const List<String> studentStatusOptions = [
  'Status: All',
  'Status: Active',
  'Status: Inactive',
  'Status: Suspended',
  'Status: Banned Forever',
];

// ============================================================
// DATA MODELS
// ============================================================

class StudentStats {
  final int totalCount;
  final double totalOwed;
  final double totalPaid;

  StudentStats({
    required this.totalCount,
    required this.totalOwed,
    required this.totalPaid,
  });
}
