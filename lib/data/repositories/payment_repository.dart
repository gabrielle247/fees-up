import '../database/drift_database.dart';
import '../services/app_logger.dart';

class PaymentRepository {
  final AppDatabase _db;
  PaymentRepository(this._db);

  Future<List<Payment>> allForSchool(String schoolId) async {
    try {
      return await (_db.select(_db.payments)
            ..where((t) => t.schoolId.equals(schoolId)))
          .get();
    } catch (e, stack) {
      AppLogger.error('PaymentRepository: allForSchool failed', e, stack);
      rethrow;
    }
  }

  Future<void> save(Payment p) async {
    try {
      await _db.into(_db.payments).insertOnConflictUpdate(p);
    } catch (e, stack) {
      AppLogger.error('PaymentRepository: save failed', e, stack);
      rethrow;
    }
  }
}
