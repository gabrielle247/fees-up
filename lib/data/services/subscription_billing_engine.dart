import 'package:isar/isar.dart';
import '../models/billable.dart';
import '../models/finance.dart';
import '../models/people.dart';
import 'isar_service.dart';

/// Subscription-based billing engine.
/// For each student: get enrolled billables → sum prices → create single invoice.
/// Idempotent: won't create duplicate invoices in the same month.
class SubscriptionBillingEngine {
  final _isarService = IsarService();

  /// Generate invoices for all students in a school based on their subscriptions.
  /// Creates one invoice per student per billing cycle (e.g., monthly on the 1st).
  Future<void> generateMonthlyInvoices(String schoolId) async {
    final isar = await _isarService.db;

    final students = await isar.students
        .filter()
        .schoolIdEqualTo(schoolId)
        .statusEqualTo('ACTIVE')
        .findAll();

    await isar.writeTxn(() async {
      for (final student in students) {
        // Get this student's subscriptions
        final subscription = await isar.studentBillables
            .filter()
            .studentIdEqualTo(student.id)
            .findFirst();
        if (subscription == null || subscription.billableIds.isEmpty) continue;

        // Get the billable items and sum their prices
        final billables = <BillableItem>[];
        for (final billableId in subscription.billableIds) {
          final billable = await isar.billableItems
              .filter()
              .idEqualTo(billableId)
              .findFirst();
          if (billable != null && billable.isActive) {
            billables.add(billable);
          }
        }

        if (billables.isEmpty) continue;

        final totalPrice = billables.fold<int>(0, (sum, b) => sum + b.price);

        // Check if invoice already exists for this month
        final now = DateTime.now();
        final monthStart = DateTime(now.year, now.month, 1);
        final monthEnd = DateTime(now.year, now.month + 1, 0);

        final existingInvoice = await isar.invoices
            .filter()
            .studentIdEqualTo(student.id)
            .dueDateGreaterThan(monthStart, include: true)
            .dueDateLessThan(monthEnd, include: true)
            .findFirst();

        if (existingInvoice != null) continue; // Already billed this month

        // Create invoice
        final invoice = Invoice()
          ..id = '${DateTime.now().millisecondsSinceEpoch}-${student.id}'
          ..schoolId = schoolId
          ..studentId = student.id
          ..invoiceNumber =
              'INV-${now.year}${now.month.toString().padLeft(2, '0')}-${student.id.substring(0, 8)}'
          ..termId = null
          ..dueDate = DateTime(now.year, now.month + 1, 0) // Last day of month
          ..status = 'DRAFT'
          ..snapshotGrade = null
          ..createdAt = DateTime.now();

        await isar.invoices.put(invoice);

        // Create single invoice item with total
        final item = InvoiceItem()
          ..id = '${invoice.id}-item'
          ..invoiceId = invoice.id
          ..feeStructureId = null
          ..description = billables.map((b) => b.name).join(', ')
          ..amount = totalPrice
          ..quantity = 1
          ..createdAt = DateTime.now();

        await isar.invoiceItems.put(item);

        // Post to ledger
        final ledgerEntry = LedgerEntry()
          ..id = '${invoice.id}-ledger'
          ..schoolId = schoolId
          ..studentId = student.id
          ..type = 'DEBIT'
          ..category = 'invoice'
          ..amount = totalPrice
          ..currency = 'USD'
          ..invoiceId = invoice.id
          ..referenceCode = invoice.invoiceNumber
          ..description =
              'Monthly billing for ${billables.map((b) => b.name).join(", ")}'
          ..occurredAt = DateTime.now();

        await isar.ledgerEntrys.put(ledgerEntry);
      }
    });
  }

  /// Get the enrolled billables for a student (their subscription list).
  Future<List<BillableItem>> getStudentBillables(
      String schoolId, String studentId) async {
    final isar = await _isarService.db;

    final subscription = await isar.studentBillables
        .filter()
        .studentIdEqualTo(studentId)
        .findFirst();

    if (subscription == null || subscription.billableIds.isEmpty) {
      return [];
    }

    final billables = <BillableItem>[];
    for (final billableId in subscription.billableIds) {
      final billable =
          await isar.billableItems.filter().idEqualTo(billableId).findFirst();
      if (billable != null && billable.isActive) {
        billables.add(billable);
      }
    }
    return billables;
  }

  /// Calculate the total amount due for a student based on their subscriptions.
  Future<int> calculateStudentBillAmount(
      String schoolId, String studentId) async {
    final billables = await getStudentBillables(schoolId, studentId);
    return billables.fold<int>(0, (sum, b) => sum + b.price);
  }
}
