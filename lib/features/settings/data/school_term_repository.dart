import 'package:fees_up/core/services/database_service.dart';
import 'package:sqflite/sqflite.dart';
import 'school_term_model.dart';

class SchoolTermRepository {
  final DatabaseService _dbService = DatabaseService();

  Future<void> saveTerm(SchoolTerm term) async {
    final db = await _dbService.database;
    
    await db.transaction((txn) async {
      // If setting this term to Active, deactivate others for cleaner logic
      if (term.isActive) {
        await txn.rawUpdate('UPDATE school_terms SET is_active = 0');
      }
      
      await txn.insert(
        'school_terms', 
        term.toMap(), 
        conflictAlgorithm: ConflictAlgorithm.replace
      );
    });
  }

  Future<List<SchoolTerm>> getAllTerms() async {
    final db = await _dbService.database;
    final res = await db.query('school_terms', orderBy: 'start_date DESC');
    return res.map((e) => SchoolTerm.fromMap(e)).toList();
  }

  /// Vital for Billing: Finds which term a specific date belongs to.
  Future<SchoolTerm?> getTermForDate(DateTime date) async {
    final db = await _dbService.database;
    final dateStr = date.toIso8601String();

    // SQL Logic: Find term where date is between start and end
    final res = await db.rawQuery('''
      SELECT * FROM school_terms 
      WHERE ? >= start_date AND ? <= end_date
      LIMIT 1
    ''', [dateStr, dateStr]);

    if (res.isNotEmpty) {
      return SchoolTerm.fromMap(res.first);
    }
    return null;
  }
  
  /// Gets the "Active" term (shortcut for Dashboard)
  Future<SchoolTerm?> getCurrentTerm() async {
    final db = await _dbService.database;
    final res = await db.query('school_terms', where: 'is_active = 1', limit: 1);
    
    if (res.isNotEmpty) return SchoolTerm.fromMap(res.first);
    return null;
  }
}