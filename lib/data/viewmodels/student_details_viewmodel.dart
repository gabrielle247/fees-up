import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/safe_data.dart';
import '../providers/students_provider.dart';

// ============================================================================
// DATA PROVIDERS (MOVED FROM UI)
// ============================================================================

/// Real-time student data provider - watches database for updates
final studentDetailProvider =
    StreamProvider.family<Map<String, dynamic>, String>(
  (ref, studentId) {
    final db = ref.watch(databaseServiceProvider);
    return db.db.watch(
      'SELECT * FROM students WHERE id = ?',
      parameters: [studentId],
    ).map<Map<String, dynamic>>((results) {
      if (results.isNotEmpty) {
        final row = results.first;
        return Map<String, dynamic>.from(row);
      }
      return <String, dynamic>{};
    }).asBroadcastStream();
  },
);

/// Real-time student academic data provider
final studentEnrollmentsProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>(
  (ref, studentId) {
    final db = ref.watch(databaseServiceProvider);
    return db.db.watch(
      '''SELECT e.*, c.name as class_name, t.full_name as teacher_name
         FROM enrollments e
         LEFT JOIN classes c ON e.class_id = c.id
         LEFT JOIN teachers t ON c.teacher_id = t.id
         WHERE e.student_id = ?
         ORDER BY e.enrolled_at DESC''',
      parameters: [studentId],
    ).asBroadcastStream();
  },
);

/// Real-time student attendance data provider
final studentAttendanceProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>(
  (ref, studentId) {
    final db = ref.watch(databaseServiceProvider);
    return db.db.watch(
      '''SELECT * FROM attendance
         WHERE student_id = ?
         ORDER BY date DESC LIMIT 30''',
      parameters: [studentId],
    ).asBroadcastStream();
  },
);

/// Real-time student bills provider
final studentBillsProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>(
  (ref, studentId) {
    final db = ref.watch(databaseServiceProvider);
    return db.db.watch(
      '''SELECT * FROM bills
         WHERE student_id = ?
         ORDER BY created_at DESC''',
      parameters: [studentId],
    ).asBroadcastStream();
  },
);

/// Real-time student payments provider
final studentPaymentsProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>(
  (ref, studentId) {
    final db = ref.watch(databaseServiceProvider);
    return db.db.watch(
      '''SELECT * FROM payments
         WHERE student_id = ?
         ORDER BY date_paid DESC''',
      parameters: [studentId],
    ).asBroadcastStream();
  },
);

// ============================================================================
// BUSINESS LOGIC PROVIDER
// ============================================================================

final studentDetailsLogicProvider = Provider((ref) => StudentDetailsLogic());

class StudentDetailsLogic {
  String getInitials(String name) {
    if (name.isEmpty) return "U";
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return "${parts[0][0]}${parts[1][0]}".toUpperCase();
    }
    return name[0].toUpperCase();
  }

  String getStatusLabel(Map<String, dynamic> studentData) {
    final isActive = SafeData.parseInt(studentData['is_active']) == 1;
    if (!isActive) return "Inactive";
    return "Active";
  }

  Color getStatusColor(Map<String, dynamic> studentData) {
    final isActive = SafeData.parseInt(studentData['is_active']) == 1;
    if (!isActive) return AppColors.textGrey;
    return AppColors.successGreen;
  }

  String formatDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return 'Not provided';
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('MMM d, yyyy').format(date);
    } catch (_) {
      return isoDate;
    }
  }

  String formatCurrency(double? value) {
    final amount = value ?? 0;
    return NumberFormat.simpleCurrency().format(amount);
  }

  String calculateAge(String? dob) {
    if (dob == null || dob == 'Not provided') return '10 yo';
    try {
      final dobDate = DateTime.parse(dob);
      final now = DateTime.now();
      final years = now.year - dobDate.year;
      return '$years yo';
    } catch (e) {
      return '10 yo';
    }
  }
}
