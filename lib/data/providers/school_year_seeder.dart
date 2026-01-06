/// ============================================================================
/// SCHOOL YEAR SEEDER - Auto-create and seed months for academic years
/// ============================================================================
///
/// This module automatically seeds school years with 12 months in the
/// academic calendar format (November - October) whenever a year is created.
///
/// This ensures billing periods are always available and properly initialized.
library;

import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import '../services/database_service.dart';

class SchoolYearSeeder {
  final DatabaseService _db = DatabaseService();
  static const _uuid = Uuid();

  /// Seed months for a school year
  ///
  /// Academic year format: November (month 1) → October (month 12)
  ///
  /// Returns: true if seeding succeeded, false otherwise
  Future<bool> seedMonthsForYear({
    required String yearId,
    required String schoolId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Check if months already exist
      final existing = await _db.db.getAll(
        'SELECT id FROM school_year_months WHERE school_year_id = ? LIMIT 1',
        [yearId],
      );

      if (existing.isNotEmpty) {
        // Months already exist, skip seeding
        return true;
      }

      // Generate 12 months in academic year order (Nov-Oct)
      await _db.db.writeTransaction((tx) async {
        for (int monthNumber = 1; monthNumber <= 12; monthNumber++) {
          // Map academic month number to calendar month
          // monthNumber 1 = November (11)
          // monthNumber 2 = December (12)
          // monthNumber 3 = January (1), etc.
          // monthNumber 12 = October (10)

          int calendarMonth = monthNumber + 10;
          int monthYear = startDate.year;

          if (calendarMonth > 12) {
            calendarMonth -= 12;
            monthYear = startDate.year + 1;
          }

          // Calculate month dates
          final monthStart = DateTime(monthYear, calendarMonth, 1);
          final monthEnd = DateTime(
            calendarMonth == 12 ? monthYear + 1 : monthYear,
            calendarMonth == 12 ? 1 : calendarMonth + 1,
            0,
          );

          // Clamp to year boundaries
          final adjustedStart =
              monthStart.isBefore(startDate) ? startDate : monthStart;
          final adjustedEnd = monthEnd.isAfter(endDate) ? endDate : monthEnd;

          final monthName = DateFormat('MMMM').format(monthStart);
          final monthId = _uuid.v4();

          // Insert month
          await tx.execute(
            '''INSERT INTO school_year_months 
               (id, school_year_id, school_id, name, month_index, start_date, end_date, is_billable, created_at)
               VALUES (?, ?, ?, ?, ?, ?, ?, 1, ?)''',
            [
              monthId,
              yearId,
              schoolId,
              monthName,
              monthNumber,
              DateFormat('yyyy-MM-dd').format(adjustedStart),
              DateFormat('yyyy-MM-dd').format(adjustedEnd),
              DateTime.now().toIso8601String(),
            ],
          );
        }
      });

      return true;
    } catch (e) {
      debugPrint('❌ Error seeding months for year: $e');
      return false;
    }
  }

  /// Get or create months for a year
  /// If months don't exist, create them automatically
  Future<List<Map<String, dynamic>>> getOrCreateMonthsForYear({
    required String yearId,
    required String schoolId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Try to fetch existing months
      final months = await _db.db.getAll(
        '''SELECT id, name, month_index, start_date, end_date, is_billable, term_id
           FROM school_year_months
           WHERE school_year_id = ? AND school_id = ?
           ORDER BY month_index''',
        [yearId, schoolId],
      );

      if (months.isNotEmpty) {
        return months.cast<Map<String, dynamic>>();
      }

      // No months exist, seed them
      final seeded = await seedMonthsForYear(
        yearId: yearId,
        schoolId: schoolId,
        startDate: startDate,
        endDate: endDate,
      );

      if (!seeded) {
        return [];
      }

      // Fetch newly created months
      return await _db.db.getAll(
        '''SELECT id, name, month_index, start_date, end_date, is_billable, term_id
           FROM school_year_months
           WHERE school_year_id = ? AND school_id = ?
           ORDER BY month_index''',
        [yearId, schoolId],
      ).then((m) => m.cast<Map<String, dynamic>>());
    } catch (e) {
      debugPrint('❌ Error getting/creating months: $e');
      return [];
    }
  }
}
