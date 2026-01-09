import '../database/drift_database.dart';
import '../services/app_logger.dart';

class LedgerRepository {
  final AppDatabase _db;
  LedgerRepository(this._db);

  Future<List<LedgerEntry>> allForStudent(String studentId) async {
    try {
      return await (_db.select(_db.ledgerEntries)
            ..where((t) => t.studentId.equals(studentId)))
          .get();
    } catch (e, stack) {
      AppLogger.error('LedgerRepository: allForStudent failed', e, stack);
      rethrow;
    }
  }

  Future<List<LedgerEntry>> allForSchool(String schoolId) async {
    try {
      return await (_db.select(_db.ledgerEntries)
            ..where((t) => t.schoolId.equals(schoolId)))
          .get();
    } catch (e, stack) {
      AppLogger.error('LedgerRepository: allForSchool failed', e, stack);
      rethrow;
    }
  }
}
