import '../database/drift_database.dart';

class SchoolRepository {
  final AppDatabase _db;

  SchoolRepository(this._db);

  /// Get the current school (fetches the first available school).
  /// In a single-tenant local-first app, there is typically only one school.
  Future<School?> getCurrentSchool() async {
    return await _db.select(_db.schools).getSingleOrNull();
  }

  /// Create or update a school.
  /// Use this to initialize the school if it doesn't exist.
  Future<void> save(School school) async {
    await _db.into(_db.schools).insertOnConflictUpdate(school);
  }

  /// Check if any school exists.
  Future<bool> hasSchool() async {
    final count = await _db.select(_db.schools).get();
    return count.isNotEmpty;
  }
}
