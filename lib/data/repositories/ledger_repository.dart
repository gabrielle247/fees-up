import '../database/drift_database.dart';

class LedgerRepository {
  final AppDatabase _db;
  LedgerRepository(this._db);

  Future<List<LedgerEntry>> allForStudent(String studentId) async {
    return await (_db.select(_db.ledgerEntries)
          ..where((t) => t.studentId.equals(studentId)))
        .get();
  }

  Future<List<LedgerEntry>> allForSchool(String schoolId) async {
    return await (_db.select(_db.ledgerEntries)
          ..where((t) => t.schoolId.equals(schoolId)))
        .get();
  }
}
