import '../database/drift_database.dart';

class InvoiceRepository {
  final AppDatabase _db;
  InvoiceRepository(this._db);

  Future<List<Invoice>> allForSchool(String schoolId) async {
    return await (_db.select(_db.invoices)
          ..where((t) => t.schoolId.equals(schoolId)))
        .get();
  }

  Future<List<InvoiceItem>> itemsForInvoice(String invoiceId) async {
    return await (_db.select(_db.invoiceItems)
          ..where((t) => t.invoiceId.equals(invoiceId)))
        .get();
  }

  Future<void> saveInvoice(Invoice invoice) async {
    await _db.into(_db.invoices).insertOnConflictUpdate(invoice);
  }

  Future<void> saveItem(InvoiceItem item) async {
    await _db.into(_db.invoiceItems).insertOnConflictUpdate(item);
  }
}
