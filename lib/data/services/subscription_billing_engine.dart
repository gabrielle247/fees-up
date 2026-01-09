import '../database/drift_database.dart';

/// Subscription-based billing engine.
/// For each student: get enrolled billables → sum prices → create single invoice.
/// Idempotent: won't create duplicate invoices in the same month.
class SubscriptionBillingEngine {
  // ignore: unused_field
  final AppDatabase _db;

  SubscriptionBillingEngine(this._db);

  /// Generate invoices for all students in a school based on their subscriptions.
  /// Creates one invoice per student per billing cycle (e.g., monthly on the 1st).
  Future<void> generateMonthlyInvoices(String schoolId) async {
    // This is a placeholder. Full implementation requires StudentBillables and BillableItems tables
    // which are not yet in the Drift schema.
    return;
  }
}
