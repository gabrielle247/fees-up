import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../services/database_service.dart';
import '../providers/school_year_seeder.dart';
import 'year_configuration_repository.dart';

/// Implementation of YearConfigurationRepository
/// All database operations for years, months, and terms happen here.
/// Widgets NEVER call the database directly.
class YearConfigurationRepositoryImpl implements YearConfigurationRepository {
  final DatabaseService _db;
  final SchoolYearSeeder _seeder;

  YearConfigurationRepositoryImpl({
    DatabaseService? db,
    SchoolYearSeeder? seeder,
  })  : _db = db ?? DatabaseService(),
        _seeder = seeder ?? SchoolYearSeeder();

  @override
  Future<Map<String, dynamic>?> loadYear(
    String yearId,
    String schoolId,
  ) async {
    try {
      // Load year
      final results = await _db.db.getAll(
        'SELECT * FROM school_years WHERE id = ? AND school_id = ?',
        [yearId, schoolId],
      );

      if (results.isEmpty) {
        return null;
      }

      final year = results.first;

      // Load terms
      final termRows = await _db.db.getAll(
        '''SELECT id, name, start_date, end_date
           FROM school_terms
           WHERE school_year_id = ? AND school_id = ?
           ORDER BY start_date''',
        [yearId, schoolId],
      );

      List<Map<String, dynamic>> terms = [];
      if (termRows.isNotEmpty) {
        terms = termRows
            .map((t) => {
                  'id': t['id'],
                  'name': (t['name'] ?? '').toString(),
                  'start_date': (t['start_date'] ?? '').toString(),
                  'end_date': (t['end_date'] ?? '').toString(),
                })
            .toList();
      } else {
        // Try to parse from description
        final desc = year['description'] as String? ?? '';
        if (desc.isNotEmpty) {
          try {
            final decoded = jsonDecode(desc);
            if (decoded is Map && decoded.containsKey('terms')) {
              final termsList = decoded['terms'] as List?;
              if (termsList != null) {
                terms = termsList
                    .map((t) => {
                          'id': (t['id'] ?? '').toString().isEmpty
                              ? null
                              : t['id'],
                          'name': (t['name'] ?? '').toString(),
                          'start_date': (t['start_date'] ?? '').toString(),
                          'end_date': (t['end_date'] ?? '').toString(),
                        })
                    .toList();
              }
            }
          } catch (_) {
            // Not JSON, ignore
          }
        }
      }

      // Load or auto-seed months
      final months = await _seeder.getOrCreateMonthsForYear(
        yearId: yearId,
        schoolId: schoolId,
        startDate: DateTime.parse(year['start_date'] as String? ?? ''),
        endDate: DateTime.parse(year['end_date'] as String? ?? ''),
      );

      return {
        'year': year,
        'terms': terms,
        'months': months
            .map((m) => {
                  'id': m['id'],
                  'name': (m['name'] ?? '').toString(),
                  'month_index': m['month_index'],
                  'start_date': (m['start_date'] ?? '').toString(),
                  'end_date': (m['end_date'] ?? '').toString(),
                  'is_billable': (m['is_billable'] as int? ?? 0) == 1,
                  'term_id': (m['term_id'] ?? '').toString().isEmpty
                      ? null
                      : m['term_id'],
                })
            .toList(),
      };
    } catch (e) {
      throw YearConfigurationException('Failed to load year: $e');
    }
  }

  @override
  Future<void> saveYear({
    required String yearId,
    required String schoolId,
    required String yearLabel,
    required String startDate,
    required String endDate,
    required String description,
    required bool active,
    required List<Map<String, dynamic>> terms,
    required List<String> removedTermIds,
    required List<Map<String, dynamic>> months,
  }) async {
    try {
      // Basic date sanity checks
      final start = DateTime.tryParse(startDate);
      final end = DateTime.tryParse(endDate);
      if (start == null || end == null) {
        throw YearConfigurationException('Invalid start/end date format');
      }
      if (start.isAfter(end)) {
        throw YearConfigurationException(
            'Start date must be on/before end date');
      }

      // Ensure this year does not overlap existing years for the same school
      final conflicts = await _db.db.getAll(
        '''SELECT id, year_label, start_date, end_date
           FROM school_years
           WHERE school_id = ? AND id != ?
             AND NOT (date(end_date) < date(?) OR date(start_date) > date(?))
           LIMIT 1''',
        [schoolId, yearId, startDate, endDate],
      );

      if (conflicts.isNotEmpty) {
        final c = conflicts.first;
        final label = (c['year_label'] ?? '').toString();
        final cStart = (c['start_date'] ?? '').toString();
        final cEnd = (c['end_date'] ?? '').toString();
        throw YearConfigurationException(
            'Year dates overlap with "$label" ($cStart → $cEnd)');
      }

      // Build description JSON if there are terms
      String descriptionValue;
      if (terms.isNotEmpty) {
        descriptionValue = jsonEncode({
          'description': description,
          'terms': terms,
        });
      } else {
        descriptionValue = description;
      }

      // ✅ ATOMIC TRANSACTION: Year + all months + terms together
      await _db.db.writeTransaction((tx) async {
        // 1. UPDATE school_years
        await tx.execute(
          '''UPDATE school_years 
             SET year_label = ?, start_date = ?, end_date = ?, description = ?, active = ?
             WHERE id = ? AND school_id = ?''',
          [
            yearLabel,
            startDate,
            endDate,
            descriptionValue,
            active ? 1 : 0,
            yearId,
            schoolId,
          ],
        );

        // 2. UPDATE each month in the transaction
        for (final month in months) {
          final monthId = month['id'];
          if (monthId == null) continue;

          await tx.execute(
            '''UPDATE school_year_months 
               SET start_date = ?, end_date = ?, is_billable = ?, term_id = ?
               WHERE id = ? AND school_year_id = ?''',
            [
              month['start_date'] ?? '',
              month['end_date'] ?? '',
              (month['is_billable'] ?? false) ? 1 : 0,
              month['term_id'],
              monthId,
              yearId,
            ],
          );
        }
      });

      // 3. Upsert terms (outside transaction for clarity)
      for (final term in terms) {
        final termId = (term['id']?.toString().isNotEmpty ?? false)
            ? term['id'].toString()
            : const Uuid().v4();
        term['id'] = termId;

        await _db.db.execute(
          '''INSERT OR REPLACE INTO school_terms
             (id, school_id, school_year_id, name, start_date, end_date, academic_year, created_at)
             VALUES (?, ?, ?, ?, ?, ?, ?, COALESCE((SELECT created_at FROM school_terms WHERE id = ?), datetime('now')))''',
          [
            termId,
            schoolId,
            yearId,
            (term['name'] ?? '').toString().trim(),
            (term['start_date'] ?? '').toString().trim(),
            (term['end_date'] ?? '').toString().trim(),
            null,
            termId,
          ],
        );
      }

      // 4. Delete removed terms
      for (final termId in removedTermIds) {
        await _db.db.execute(
          'DELETE FROM school_terms WHERE id = ? AND school_id = ?',
          [termId, schoolId],
        );
      }
    } catch (e) {
      throw YearConfigurationException('Failed to save year: $e');
    }
  }

  @override
  Stream<Map<String, dynamic>?> watchYear(
    String yearId,
    String schoolId,
  ) {
    return _db.db.watch(
      'SELECT * FROM school_years WHERE id = ? AND school_id = ?',
      parameters: [yearId, schoolId],
    ).map((results) => results.isNotEmpty ? results.first : null);
  }

  @override
  Stream<List<Map<String, dynamic>>> watchMonths(
    String yearId,
    String schoolId,
  ) {
    return _db.db.watch(
      '''SELECT id, name, month_index, start_date, end_date, is_billable, term_id
         FROM school_year_months
         WHERE school_year_id = ? AND school_id = ?
         ORDER BY month_index''',
      parameters: [yearId, schoolId],
    ).map((months) => months.cast<Map<String, dynamic>>());
  }
}
