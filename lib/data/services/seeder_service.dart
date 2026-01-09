import 'package:drift/drift.dart';
import '../database/drift_database.dart';
import 'package:uuid/uuid.dart';

class SeederService {
  final AppDatabase _db;
  final _uuid = const Uuid();

  SeederService(this._db);

  Future<void> seedExampleData() async {
    // Check if school already exists
    final existingSchool = await _db.select(_db.schools).getSingleOrNull();
    if (existingSchool != null) return; // Don't seed if data exists

    await _db.transaction(() async {
      // 1. Create School
      final schoolId = _uuid.v4();
      final school = SchoolsCompanion(
        id: Value(schoolId),
        name: const Value("Fees Up Demo School"),
        subdomain: const Value("demo"),
        createdAt: Value(DateTime.now()),
      );

      await _db.into(_db.schools).insert(school);

      // 2. Create Students
      final now = DateTime.now();
      final studentIds = <String>[];

      final studentsData = [
        {'firstName': 'David', 'lastName': 'Kariuki', 'daysAgo': 0},
        {'firstName': 'Emily', 'lastName': 'Nakitare', 'daysAgo': 0},
        {'firstName': 'Peter', 'lastName': 'Kipkemboi', 'daysAgo': 0},
        {'firstName': 'John', 'lastName': 'Doe', 'daysAgo': 400},
      ];

      for (var i = 0; i < studentsData.length; i++) {
        final data = studentsData[i];
        final studentId = _uuid.v4();
        studentIds.add(studentId);

        final student = StudentsCompanion(
          id: Value(studentId),
          schoolId: Value(schoolId),
          firstName: Value(data['firstName'] as String),
          lastName: Value(data['lastName'] as String),
          status: const Value('ACTIVE'),
          createdAt:
              Value(now.subtract(Duration(days: data['daysAgo'] as int))),
        );

        await _db.into(_db.students).insert(student);

        // Enroll them
        final enrollment = EnrollmentsCompanion(
          id: Value(_uuid.v4()),
          schoolId: Value(schoolId),
          studentId: Value(studentId),
          academicYearId: const Value("2024"),
          gradeLevel: Value((i % 2 == 0) ? "Form 2" : "Form 3"),
          isActive: const Value(true),
        );
        await _db.into(_db.enrollments).insert(enrollment);
      }

      // 3. Create Finances
      // Invoice for David (Unpaid)
      final inv1Id = _uuid.v4();
      final inv1 = InvoicesCompanion(
        id: Value(inv1Id),
        schoolId: Value(schoolId),
        studentId: Value(studentIds[0]), // David
        invoiceNumber: const Value("INV-001"),
        dueDate: Value(now.add(const Duration(days: 30))),
        status: const Value("ISSUED"),
        createdAt: Value(now.subtract(const Duration(days: 2))),
      );
      await _db.into(_db.invoices).insert(inv1);

      final item1 = InvoiceItemsCompanion(
        id: Value(_uuid.v4()),
        invoiceId: Value(inv1Id),
        description: const Value("Term 1 Tuition"),
        amount: const Value(3100000), // 31,000.00
      );
      await _db.into(_db.invoiceItems).insert(item1);

      // Ledger for David (Debt)
      final ledger1 = LedgerEntriesCompanion(
        id: Value(_uuid.v4()),
        schoolId: Value(schoolId),
        studentId: Value(studentIds[0]),
        type: const Value("DEBIT"),
        category: const Value("TUITION"),
        amount: const Value(3100000),
        description: const Value("Term 1 Fees"),
        occurredAt: Value(now.subtract(const Duration(days: 2))),
      );
      await _db.into(_db.ledgerEntries).insert(ledger1);

      // Invoice for Emily (Partially Paid)
      final inv2Id = _uuid.v4();
      final inv2 = InvoicesCompanion(
        id: Value(inv2Id),
        schoolId: Value(schoolId),
        studentId: Value(studentIds[1]), // Emily
        invoiceNumber: const Value("INV-002"),
        dueDate: Value(now.add(const Duration(days: 30))),
        status: const Value("PARTIAL"),
        createdAt: Value(now.subtract(const Duration(days: 5))),
      );
      await _db.into(_db.invoices).insert(inv2);

      final item2 = InvoiceItemsCompanion(
        id: Value(_uuid.v4()),
        invoiceId: Value(inv2Id),
        description: const Value("Term 1 Tuition"),
        amount: const Value(1500000), // 15,000.00
      );
      await _db.into(_db.invoiceItems).insert(item2);

      // Ledger Debit Emily
      final ledger2 = LedgerEntriesCompanion(
        id: Value(_uuid.v4()),
        schoolId: Value(schoolId),
        studentId: Value(studentIds[1]),
        type: const Value("DEBIT"),
        category: const Value("TUITION"),
        amount: const Value(1500000),
        description: const Value("Term 1 Tuition"),
        occurredAt: Value(now.subtract(const Duration(days: 5))),
      );
      await _db.into(_db.ledgerEntries).insert(ledger2);

      // Payment from Emily (Today)
      final pay1 = PaymentsCompanion(
        id: Value(_uuid.v4()),
        schoolId: Value(schoolId),
        studentId: Value(studentIds[1]),
        amount: const Value(1000000), // 10,000.00
        method: const Value("CASH"),
        receivedAt: Value(now), // Today
      );
      await _db.into(_db.payments).insert(pay1);

      // Ledger Credit Emily
      final ledger3 = LedgerEntriesCompanion(
        id: Value(_uuid.v4()),
        schoolId: Value(schoolId),
        studentId: Value(studentIds[1]),
        type: const Value("CREDIT"),
        category: const Value("PAYMENT"),
        amount: const Value(1000000),
        description: const Value("Payment received"),
        occurredAt: Value(now),
      );
      await _db.into(_db.ledgerEntries).insert(ledger3);
      // Emily still owes 5,000 (15k - 10k)

      // Payment from John Doe (Last Month for Growth Chart)
      final pay2 = PaymentsCompanion(
        id: Value(_uuid.v4()),
        schoolId: Value(schoolId),
        studentId: Value(studentIds[3]),
        amount: const Value(500000), // 5,000.00
        method: const Value("BANK"),
        receivedAt: Value(now.subtract(const Duration(days: 35))),
      );
      await _db.into(_db.payments).insert(pay2);
    });
  }
}
