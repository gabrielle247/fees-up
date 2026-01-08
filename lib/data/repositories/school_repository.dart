import 'package:isar/isar.dart';
import '../models/saas.dart';

class SchoolRepository {
  final Isar _isar;

  SchoolRepository(this._isar);

  /// Get the current school (fetches the first available school).
  /// In a single-tenant local-first app, there is typically only one school.
  Future<School?> getCurrentSchool() async {
    return await _isar.schools.where().findFirst();
  }

  /// Create or update a school.
  /// Use this to initialize the school if it doesn't exist.
  Future<void> save(School school) async {
    await _isar.writeTxn(() async {
      await _isar.schools.put(school);
    });
  }

  /// Check if any school exists.
  Future<bool> hasSchool() async {
    return await _isar.schools.count() > 0;
  }
}
