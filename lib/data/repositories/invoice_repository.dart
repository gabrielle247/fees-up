import '../database/drift_database.dart';
import '../services/app_logger.dart';

class InvoiceRepository {
  final AppDatabase _db;
  InvoiceRepository(this._db);

  Future<List<Invoice>> allForSchool(String schoolId) async {
    try {
      return await (_db.select(_db.invoices)
            ..where((t) => t.schoolId.equals(schoolId)))
          .get();
    } catch (e, stack) {
      AppLogger.error('InvoiceRepository: allForSchool failed', e, stack);
      rethrow;
    }
  }

  Future<List<InvoiceItem>> itemsForInvoice(String invoiceId) async {
    try {
      return await (_db.select(_db.invoiceItems)
            ..where((t) => t.invoiceId.equals(invoiceId)))
          .get();
    } catch (e, stack) {
      AppLogger.error('InvoiceRepository: itemsForInvoice failed', e, stack);
      rethrow;
    }
  }

  Future<void> saveInvoice(Invoice invoice) async {
    try {
      await _db.into(_db.invoices).insertOnConflictUpdate(invoice);
    } catch (e, stack) {
      AppLogger.error('InvoiceRepository: saveInvoice failed', e, stack);
      rethrow;
    }
  }

  Future<void> saveItem(InvoiceItem item) async {
    try {
      await _db.into(_db.invoiceItems).insertOnConflictUpdate(item);
    } catch (e, stack) {
      AppLogger.error('InvoiceRepository: saveItem failed', e, stack);
      rethrow;
    }
  }
}
