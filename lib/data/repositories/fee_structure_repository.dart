import '../database/drift_database.dart';
import '../services/app_logger.dart';

class FeeStructureRepository {
  final AppDatabase _db;
  FeeStructureRepository(this._db);

  Future<List<FeeStructure>> allForSchool(String schoolId) async {
    try {
      return await (_db.select(_db.feeStructures)
            ..where((t) => t.schoolId.equals(schoolId)))
          .get();
    } catch (e, stack) {
      AppLogger.error('FeeStructureRepository: allForSchool failed', e, stack);
      rethrow;
    }
  }

  Future<void> save(FeeStructure f) async {
    try {
      await _db.into(_db.feeStructures).insertOnConflictUpdate(f);
    } catch (e, stack) {
      AppLogger.error('FeeStructureRepository: save failed', e, stack);
      rethrow;
    }
  }
}
