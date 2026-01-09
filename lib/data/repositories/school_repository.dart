import '../database/drift_database.dart';
import '../services/app_logger.dart';

class SchoolRepository {
  final AppDatabase _db;

  SchoolRepository(this._db);

  /// Get the current school (fetches the first available school).
  /// In a single-tenant local-first app, there is typically only one school.
  Future<School?> getCurrentSchool() async {
    try {
      return await _db.select(_db.schools).getSingleOrNull();
    } catch (e, stack) {
      AppLogger.error('SchoolRepository: getCurrentSchool failed', e, stack);
      rethrow;
    }
  }

  /// Create or update a school.
  /// Use this to initialize the school if it doesn't exist.
  Future<void> save(School school) async {
    try {
      await _db.into(_db.schools).insertOnConflictUpdate(school);
    } catch (e, stack) {
      AppLogger.error('SchoolRepository: save failed', e, stack);
      rethrow;
    }
  }

  /// Check if any school exists.
  Future<bool> hasSchool() async {
    try {
      final countExp = _db.schools.id.count();
      final query = _db.selectOnly(_db.schools)..addColumns([countExp]);
      final result = await query.getSingle();
      final count = result.read(countExp) ?? 0;
      return count > 0;
    } catch (e) {
      return false;
    }
  }
}
