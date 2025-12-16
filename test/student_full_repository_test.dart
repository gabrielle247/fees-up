import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:fees_up/services/database_service.dart';
import 'package:fees_up/repositories/student_full_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('StudentFullRepository', () {
    final db = DatabaseService.instance;
    final repo = StudentFullRepository(db: db);

    setUpAll(() async {
      // Initialize `sqflite_common_ffi` for desktop tests so the
      // global `databaseFactory` used by `sqflite` is available.
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      // Remove any existing DB from previous test runs to ensure migrations run.
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'fees_up.db');
      try {
        if (await File(path).exists()) await databaseFactory.deleteDatabase(path);
      } catch (_) {
        // ignore
      }
      await db.database;
      // Clean DB for deterministic tests
      await db.rawDelete('DELETE FROM payments');
      await db.rawDelete('DELETE FROM bills');
      await db.rawDelete('DELETE FROM students');
    });

    test('hydrate and compute indicators', () async {
      // create a student
      final sid = await db.createStudent({
        'full_name': 'Test Student',
        'default_fee': 100.0,
        'billing_type': 'monthly',
        'registration_date': DateTime.now().subtract(Duration(days: 90)).toIso8601String(),
      }, queueForSync: false, createBackdatedBills: false);

      // create a bill for last month
      final now = DateTime.now();
      final lastMonth = DateTime(now.year, now.month - 1, 1);
      final monthYear = '${lastMonth.year.toString().padLeft(4, '0')}-${lastMonth.month.toString().padLeft(2, '0')}';
      await db.createBillForStudent(studentId: sid, totalAmount: 100.0, billType: 'monthly', monthYear: monthYear, cycleStart: lastMonth, cycleEnd: DateTime(lastMonth.year, lastMonth.month + 1, 0), queueForSync: false, createdAt: lastMonth);

      // make a half payment on that bill
      final bills = await db.getStudentBills(sid);
      expect(bills.length, 1);
      final bid = bills.first['id'] as String;
      await db.recordPayment(billId: bid, studentId: sid, amount: 50.0, datePaid: DateTime.now(), queueForSync: false);

      final hydrated = await repo.refresh();
      final sf = hydrated.firstWhere((s) => s.student.id == sid);
      expect(sf.payments.length, 1);
      expect(sf.bills.length, 1);

      final indicators = repo.computeIndicators(sf);
      expect(indicators['previousDebt'], 50.0, reason: 'Past owed after partial payment should be 50');
      expect(indicators['currentCycleStatus'], 'missing');
    });
  });
}
