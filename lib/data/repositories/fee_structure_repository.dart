import '../database/drift_database.dart';

class FeeStructureRepository {
  final AppDatabase _db;
  FeeStructureRepository(this._db);

  Future<List<FeeStructure>> allForSchool(String schoolId) async {
    return await (_db.select(_db.feeStructures)
          ..where((t) => t.schoolId.equals(schoolId)))
        .get();
  }

  Future<void> save(FeeStructure f) async {
    await _db.into(_db.feeStructures).insertOnConflictUpdate(f);
  }
}
