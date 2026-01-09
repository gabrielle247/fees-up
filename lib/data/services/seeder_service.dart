import 'package:fees_up/data/services/isar_service.dart';
import 'package:fees_up/data/models/people.dart';
import 'package:fees_up/data/models/saas.dart';
import 'package:fees_up/data/models/finance.dart';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

class SeederService {
  final _uuid = const Uuid();

  Future<void> seedExampleData() async {
    final isar = await IsarService()
        .db; // Direct access or via provider if strictly needed

    // Check if school already exists (Double check)
    final existingSchool = await isar.schools.where().findFirst();
    if (existingSchool != null) return; // Don't seed if data exists

    await isar.writeTxn(() async {
      // 1. Create School
      final schoolId = _uuid.v4();
      final school = School()
        ..id = schoolId
        ..name = "Fees Up Demo School"
        ..subdomain = "demo"
        ..createdAt = DateTime.now();

      await isar.schools.put(school);

      // 2. Create Students
      final students = [
        Student()
          ..id = _uuid.v4()
          ..schoolId = schoolId
          ..firstName = "David"
          ..lastName = "Kariuki"
          ..status = "ACTIVE"
          ..createdAt = DateTime.now(),
        Student()
          ..id = _uuid.v4()
          ..schoolId = schoolId
          ..firstName = "Emily"
          ..lastName = "Nakitare"
          ..status = "ACTIVE"
          ..createdAt = DateTime.now(),
        Student()
          ..id = _uuid.v4()
          ..schoolId = schoolId
          ..firstName = "Peter"
          ..lastName = "Kipkemboi"
          ..status = "ACTIVE"
          ..createdAt = DateTime.now(),
        Student()
          ..id = _uuid.v4()
          ..schoolId = schoolId
          ..firstName = "John"
          ..lastName = "Doe"
          ..status = "ACTIVE"
          ..createdAt =
              DateTime.now().subtract(const Duration(days: 400)), // Old student
      ];

      for (var s in students) {
        await isar.students.put(s);

        // Enroll them
        final enrollment = Enrollment()
          ..id = _uuid.v4()
          ..schoolId = schoolId
          ..studentId = s.id
          ..academicYearId = "2024" // specific
          ..gradeLevel = (students.indexOf(s) % 2 == 0) ? "Form 2" : "Form 3"
          ..isActive = true;
        await isar.enrollments.put(enrollment);
      }

      // 3. Create Finances
      final now = DateTime.now();

      // Invoice for David (Unpaid)
      final inv1 = Invoice()
        ..id = _uuid.v4()
        ..schoolId = schoolId
        ..studentId = students[0].id // David
        ..invoiceNumber = "INV-001"
        ..dueDate = now.add(const Duration(days: 30))
        ..status = "ISSUED" // Unpaid
        ..createdAt = now.subtract(const Duration(days: 2));
      await isar.invoices.put(inv1);

      final item1 = InvoiceItem()
        ..id = _uuid.v4()
        ..invoiceId = inv1.id
        ..description = "Term 1 Tuition"
        ..amount = 3100000; // 31,000.00
      await isar.invoiceItems.put(item1);

      // Ledger for David (Debt)
      final ledger1 = LedgerEntry()
        ..id = _uuid.v4()
        ..schoolId = schoolId
        ..studentId = students[0].id
        ..type = "DEBIT"
        ..category = "TUITION"
        ..amount = 3100000
        ..description = "Term 1 Fees"
        ..occurredAt = now.subtract(const Duration(days: 2));
      await isar.ledgerEntrys.put(ledger1);

      // Invoice for Emily (Partially Paid)
      final inv2 = Invoice()
        ..id = _uuid.v4()
        ..schoolId = schoolId
        ..studentId = students[1].id // Emily
        ..invoiceNumber = "INV-002"
        ..dueDate = now.add(const Duration(days: 30))
        ..status = "PARTIAL"
        ..createdAt = now.subtract(const Duration(days: 5));
      await isar.invoices.put(inv2);

      final item2 = InvoiceItem()
        ..id = _uuid.v4()
        ..invoiceId = inv2.id
        ..description = "Term 1 Tuition"
        ..amount = 1500000; // 15,000.00
      await isar.invoiceItems.put(item2);

      // Ledger Debit Emily
      final ledger2 = LedgerEntry()
        ..id = _uuid.v4()
        ..schoolId = schoolId
        ..studentId = students[1].id
        ..type = "DEBIT"
        ..category = "TUITION"
        ..amount = 1500000
        ..occurredAt = now.subtract(const Duration(days: 5));
      await isar.ledgerEntrys.put(ledger2);

      // Payment from Emily (Today)
      final pay1 = Payment()
        ..id = _uuid.v4()
        ..schoolId = schoolId
        ..studentId = students[1].id
        ..amount = 1000000 // 10,000.00
        ..method = "CASH"
        ..receivedAt = now; // Today
      await isar.payments.put(pay1);

      // Ledger Credit Emily
      final ledger3 = LedgerEntry()
        ..id = _uuid.v4()
        ..schoolId = schoolId
        ..studentId = students[1].id
        ..type = "CREDIT" // Payment
        ..category = "PAYMENT"
        ..amount = 1000000
        ..occurredAt = now;
      await isar.ledgerEntrys.put(ledger3);
      // Emily still owes 5,000 (15k - 10k)

      // Payment from John Doe (Last Month for Growth Chart)
      final pay2 = Payment()
        ..id = _uuid.v4()
        ..schoolId = schoolId
        ..studentId = students[3].id
        ..amount = 500000 // 5,000.00
        ..method = "BANK"
        ..receivedAt = now.subtract(const Duration(days: 35));
      await isar.payments.put(pay2);
    });
  }
}
