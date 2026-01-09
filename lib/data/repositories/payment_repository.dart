import '../database/drift_database.dart';

class PaymentRepository {
  final AppDatabase _db;
  PaymentRepository(this._db);

  Future<List<Payment>> allForSchool(String schoolId) async {
    return await (_db.select(_db.payments)
          ..where((t) => t.schoolId.equals(schoolId)))
        .get();
  }

  Future<void> save(Payment p) async {
    await _db.into(_db.payments).insertOnConflictUpdate(p);
  }
}
