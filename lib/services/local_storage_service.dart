// lib/services/local_storage_service.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:fees_up/models/admin_profile.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart'; // Required for DateFormat
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Required for Supabase user check
import '../models/student.dart';
import '../models/finance.dart';
import '../models/notification_item.dart';
import 'database_service.dart';

// Helper function
String generateShortId() {
  return DateTime.now().millisecondsSinceEpoch.toString().substring(8) +
      Random().nextInt(999).toString();
}

class LocalStorageService {
  static const String _studentsFile = 'students.json';
  static const String _billsFile = 'bills.json';
  static const String _paymentsFile = 'payments.json';
  static const String _notificationsFile = 'notifications.json';
  static const String migrationCompleteKey = 'is_json_migration_complete';

  final DatabaseService _db = DatabaseService();
  Completer<void>? _writeLock;

  LocalStorageService();

  // ----------------------------
  // Data Conversion Helpers
  // ----------------------------
  Map<String, dynamic> _studentToRow(Student s) {
    return {
      'studentId': s.studentId,
      'studentName': s.studentName,
      'registrationDate': s.registrationDate.toIso8601String(),
      'isActive': s.isActive ? 1 : 0,
      'defaultMonthlyFee': s.defaultMonthlyFee,
      'parentContact': s.parentContact,
      'subjects': jsonEncode(s.subjects),
      'frequency': s.frequency,
    };
  }

  Student _rowToStudent(Map<String, dynamic> row) {
    return Student(
      id: row['id'] is int ? row['id'] : int.tryParse('${row['id']}') ?? 0,
      studentId: row['studentId'] ?? '',
      studentName: row['studentName'] ?? '',
      registrationDate:
          DateTime.tryParse(row['registrationDate'] ?? '') ?? DateTime.now(),
      isActive: (row['isActive'] == 1 || row['isActive'] == true),
      defaultMonthlyFee: (row['defaultMonthlyFee'] as num?)?.toDouble() ?? 0.0,
      parentContact: row['parentContact'] ?? '',
      subjects: (row['subjects'] != null && row['subjects'].isNotEmpty)
          ? List<String>.from(jsonDecode(row['subjects']))
          : <String>[],
      frequency: row['frequency'] ?? 'Monthly',
    );
  }

  Map<String, dynamic> _billToRow(Bill b) {
    return {
      'id': b.id,
      'studentId': b.studentId,
      'totalAmount': b.totalAmount,
      'paidAmount': b.paidAmount,
      'monthYear': b.monthYear.toIso8601String(),
      'dueDate': b.dueDate.toIso8601String(),
      'createdAt': b.createdAt.toIso8601String(),
    };
  }

  Bill _rowToBill(Map<String, dynamic> row) {
    return Bill(
      id: row['id'],
      studentId: row['studentId'],
      totalAmount: (row['totalAmount'] as num).toDouble(),
      paidAmount: (row['paidAmount'] as num?)?.toDouble() ?? 0.0,
      monthYear: DateTime.parse(row['monthYear']),
      dueDate: DateTime.parse(row['dueDate']),
      createdAt: DateTime.parse(row['createdAt']),
    );
  }

  Map<String, dynamic> _paymentToRow(Payment p) {
    return {
      'id': p.id,
      'billId': p.billId,
      'studentId': p.studentId,
      'amount': p.amount,
      'datePaid': p.datePaid.toIso8601String(),
      'method': p.method,
    };
  }

  Payment _rowToPayment(Map<String, dynamic> row) {
    return Payment(
      id: row['id'],
      billId: row['billId'] ?? '',
      studentId: row['studentId'] ?? '',
      amount: (row['amount'] as num).toDouble(),
      datePaid: DateTime.parse(row['datePaid']),
      method: row['method'] ?? 'Cash',
    );
  }

  Map<String, dynamic> _notificationToRow(NotificationItem n) {
    return {
      'id': n.id,
      'title': n.title,
      'body': n.body,
      'timestamp': n.timestamp.toIso8601String(),
      'isRead': n.isRead ? 1 : 0,
      'type': n.type,
    };
  }

  NotificationItem _rowToNotification(Map<String, dynamic> row) {
    return NotificationItem(
      id: row['id'],
      title: row['title'],
      body: row['body'],
      timestamp: DateTime.parse(row['timestamp']),
      isRead: row['isRead'] == 1,
      type: row['type'] ?? 'info',
    );
  }

  // ---------------------------------------------------------
  // SECTION 2: CRUD OPERATIONS (Sync Aware)
  // ---------------------------------------------------------

  Future<bool> saveStudent(Student student) async {
    try {
      final db = await _db.database;
      await db.transaction((txn) async {
        await txn.insert(
          'students',
          _studentToRow(student),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        await txn.insert('local_sync_status', {
          'table_name': 'students',
          'record_id': student.studentId,
          'action': 'INSERT',
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      });
      return true;
    } catch (e) {
      debugPrint("❌ Failed to save student: $e");
      return false;
    }
  }

  Future<List<Student>> getAllStudents() async {
    final rows = await _db.queryAll('students');
    return rows.map((r) => _rowToStudent(r)).toList();
  }

  // lib/services/local_storage_service.dart (Around line 398)

  Future<Student?> getStudent(String id) async {
    // Directly use the underlying DB method for consistency. [cite: 399, 400, 401]
    final rows = await _db.queryWhere('students', 'studentId = ?', [id]);
    if (rows.isEmpty) return null;
    return _rowToStudent(rows.first);
  }

  Future<bool> saveBill(Bill bill) async {
    try {
      final db = await _db.database;
      await db.transaction((txn) async {
        await txn.insert(
          'bills',
          _billToRow(bill),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        await txn.insert('local_sync_status', {
          'table_name': 'bills',
          'record_id': bill.id,
          'action': 'INSERT',
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      });
      return true;
    } catch (e) {
      debugPrint("❌ Failed to save bill: $e");
      return false;
    }
  }

  Future<List<Bill>> getBillsForStudent(String studentId) async {
    final rows = await _db.queryWhere('bills', 'studentId = ?', [studentId]);
    final list = rows.map((r) => _rowToBill(r)).toList();
    list.sort((a, b) => a.monthYear.compareTo(b.monthYear));
    return list;
  }

  Future<List<Bill>> getAllBills() async {
    final rows = await _db.queryAll('bills');
    return rows.map((r) => _rowToBill(r)).toList();
  }

  Future<bool> savePayment(Payment payment) async {
    try {
      final db = await _db.database;
      await db.transaction((txn) async {
        await txn.insert(
          'payments',
          _paymentToRow(payment),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        await txn.insert('local_sync_status', {
          'table_name': 'payments',
          'record_id': payment.id,
          'action': 'INSERT',
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      });
      return true;
    } catch (e) {
      debugPrint("❌ Failed to save payment: $e");
      return false;
    }
  }

  Future<List<Payment>> getPaymentsForBill(String billId) async {
    final rows = await _db.queryWhere('payments', 'billId = ?', [billId]);
    return rows.map((r) => _rowToPayment(r)).toList();
  }

  Future<List<Payment>> getPaymentsForStudent(String studentId) async {
    final rows = await _db.queryWhere('payments', 'studentId = ?', [studentId]);
    return rows.map((r) => _rowToPayment(r)).toList();
  }

  Future<List<Payment>> getAllPayments() async {
    final rows = await _db.queryAll('payments');
    return rows.map((r) => _rowToPayment(r)).toList();
  }

  // ---------------------------------------------------------
  // SECTION 3: INTELLIGENT LOGIC (Restored & Sync Aware)
  // ---------------------------------------------------------

  Bill? _findBillForMonth(
    List<Bill> bills,
    DateTime targetDate,
    String studentId,
  ) {
    try {
      return bills.firstWhere(
        (b) =>
            b.studentId == studentId &&
            b.monthYear.year == targetDate.year &&
            b.monthYear.month == targetDate.month,
      );
    } catch (e) {
      return null;
    }
  }

  Future<bool> ensureBillsForAllStudents() async {
    while (_writeLock != null) {
      await _writeLock!.future;
    }
    _writeLock = Completer<void>();
    bool dataChanged = false;
    try {
      final students = await getAllStudents();
      final allBills = await getAllBills();
      final now = DateTime.now();
      final currentMonthKey =
          "${now.year}-${now.month.toString().padLeft(2, '0')}";

      for (var student in students) {
        if (!student.isActive) continue;
        bool exists = allBills.any(
          (b) =>
              b.studentId == student.studentId &&
              b.uniqueMonthKey == currentMonthKey,
        );
        if (!exists) {
          debugPrint(
            "🤖 Auto-generating Bill for ${student.studentName} ($currentMonthKey)",
          );
          final newBill = Bill(
            id: generateShortId(),
            studentId: student.studentId,
            totalAmount: student.defaultMonthlyFee,
            paidAmount: 0.0,
            monthYear: DateTime(now.year, now.month, 1),
            dueDate: DateTime(now.year, now.month, 5),
            createdAt: now,
          );
          await saveBill(newBill); // Uses Sync-Aware Save
          dataChanged = true;
        }
      }
      return dataChanged;
    } catch (e) {
      debugPrint("❌ Error in batch bill check: $e");
      return false;
    } finally {
      final c = _writeLock;
      _writeLock = null;
      c?.complete();
    }
  }

  Future<Bill?> checkAndEnsureMonthlyBill(String studentId) async {
    try {
      final students = await getAllStudents();
      final allBills = await getAllBills();
      final student = students.firstWhere((s) => s.studentId == studentId);
      if (!student.isActive) return null;

      final now = DateTime.now();
      final currentMonthKey =
          "${now.year}-${now.month.toString().padLeft(2, '0')}";

      bool exists = allBills.any(
        (b) => b.studentId == studentId && b.uniqueMonthKey == currentMonthKey,
      );

      if (!exists) {
        final newBill = Bill(
          id: generateShortId(),
          studentId: studentId,
          totalAmount: student.defaultMonthlyFee,
          paidAmount: 0.0,
          monthYear: DateTime(now.year, now.month, 1),
          dueDate: DateTime(now.year, now.month, 5),
          createdAt: now,
        );
        await saveBill(newBill);
        return newBill;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> processLumpSumPayment(String studentId, double amount) async {
    if (amount <= 0) return;

    try {
      List<Bill> studentBills = await getBillsForStudent(studentId);
      studentBills.sort((a, b) => a.monthYear.compareTo(b.monthYear));
      double remainingCash = amount;

      // 1. Pay Debts
      for (var bill in studentBills) {
        if (remainingCash <= 0) break;
        if (bill.status == BillStatus.paid) continue;

        double debt = bill.outstandingBalance;
        double payThisBill = (remainingCash >= debt) ? debt : remainingCash;

        if (payThisBill > 0) {
          final newPayment = Payment(
            id: generateShortId(),
            billId: bill.id,
            studentId: studentId,
            amount: payThisBill,
            datePaid: DateTime.now(),
          );
          await savePayment(newPayment);

          final updatedBill = bill.copyWith(
            paidAmount: bill.paidAmount + payThisBill,
          );
          await saveBill(updatedBill);

          remainingCash -= payThisBill;
        }
      }

      // 2. Surplus Logic
      if (remainingCash > 0.01) {
        final allBills = await getAllBills();
        final student = (await getStudent(studentId))!;

        DateTime nextDate = studentBills.isNotEmpty
            ? DateTime(
                studentBills.last.monthYear.year,
                studentBills.last.monthYear.month + 1,
                1,
              )
            : DateTime.now();

        while (remainingCash > 0.01) {
          Bill? existingFutureBill = _findBillForMonth(
            allBills,
            nextDate,
            studentId,
          );

          double payAmount = 0.0;
          String billIdForPayment;

          if (existingFutureBill != null) {
            double debt = existingFutureBill.outstandingBalance;
            payAmount = (remainingCash >= debt) ? debt : remainingCash;
            final updatedBill = existingFutureBill.copyWith(
              paidAmount: existingFutureBill.paidAmount + payAmount,
            );
            await saveBill(updatedBill);
            billIdForPayment = existingFutureBill.id;
          } else {
            final futureBill = Bill(
              id: generateShortId(),
              studentId: studentId,
              totalAmount: student.defaultMonthlyFee,
              paidAmount: 0.0,
              monthYear: nextDate,
              dueDate: nextDate.add(const Duration(days: 5)),
              createdAt: DateTime.now(),
            );
            payAmount = (remainingCash >= futureBill.totalAmount)
                ? futureBill.totalAmount
                : remainingCash;
            final paidBill = futureBill.copyWith(paidAmount: payAmount);
            await saveBill(paidBill);
            billIdForPayment = paidBill.id;
          }

          final newPayment = Payment(
            id: generateShortId(),
            billId: billIdForPayment,
            studentId: studentId,
            amount: payAmount,
            datePaid: DateTime.now(),
            method: 'Cash (Surplus)',
          );
          await savePayment(newPayment);

          remainingCash -= payAmount;
          nextDate = DateTime(nextDate.year, nextDate.month + 1, 1);
        }
      }
    } catch (e) {
      debugPrint("❌ Error in lump sum process: $e");
    }
  }

  Future<String?> registerNewStudent({
    required String name,
    required double fee,
    required double initialPayment,
    required String parentContact,
    required List<String> subjects,
    required String frequency,
  }) async {
    try {
      final random = Random();
      final int uniqueNum = 100000 + random.nextInt(900000);
      final String publicId = "STU-$uniqueNum";

      final newStudent = Student(
        id: uniqueNum,
        studentId: publicId,
        studentName: name,
        registrationDate: DateTime.now(),
        isActive: true,
        defaultMonthlyFee: fee,
        parentContact: parentContact,
        subjects: subjects,
        frequency: frequency,
      );

      await saveStudent(newStudent);

      if (initialPayment > 0) {
        await processLumpSumPayment(publicId, initialPayment);
      } else {
        final now = DateTime.now();
        final firstBill = Bill(
          id: generateShortId(),
          studentId: publicId,
          totalAmount: fee,
          paidAmount: 0.0,
          monthYear: DateTime(now.year, now.month, 1),
          dueDate: DateTime(now.year, now.month, 5),
          createdAt: now,
        );
        await saveBill(firstBill);
      }
      return publicId;
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateStudentAndFee(Student updatedStudent) async {
    try {
      final db = await _db.database;
      final oldStudent = await getStudent(updatedStudent.studentId);

      if (oldStudent == null) return false;

      // Smart Save: Skip if nothing changed
      if (_areStudentsIdentical(oldStudent, updatedStudent)) {
        debugPrint("🧠 Smart Save: No changes detected. Skipping sync.");
        return true;
      }

      bool feeChanged =
          oldStudent.defaultMonthlyFee != updatedStudent.defaultMonthlyFee;

      await db.transaction((txn) async {
        await txn.update(
          'students',
          _studentToRow(updatedStudent),
          where: 'studentId = ?',
          whereArgs: [updatedStudent.studentId],
        );
        await txn.insert('local_sync_status', {
          'table_name': 'students',
          'record_id': updatedStudent.studentId,
          'action': 'UPDATE',
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      });

      // 🛑 FIX FOR WARNING: Restored logic that uses 'firstWhereOrNull'
      if (feeChanged) {
        final allBills = await getAllBills();
        final now = DateTime.now();
        final currentMonthKey =
            "${now.year}-${now.month.toString().padLeft(2, '0')}";

        // Using the extension to find the current bill safely
        final currentBill = allBills.firstWhereOrNull(
          (b) =>
              b.studentId == updatedStudent.studentId &&
              b.uniqueMonthKey == currentMonthKey,
        );

        if (currentBill != null) {
          final updatedBill = currentBill.copyWith(
            totalAmount: updatedStudent.defaultMonthlyFee,
          );
          await saveBill(updatedBill);
        }
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  bool _areStudentsIdentical(Student a, Student b) {
    return a.studentName == b.studentName &&
        a.defaultMonthlyFee == b.defaultMonthlyFee &&
        a.isActive == b.isActive &&
        a.parentContact == b.parentContact &&
        jsonEncode(a.subjects) == jsonEncode(b.subjects);
  }

  // ─────────────────────────────────────────────────────────────
  // 🛠 SECTION 5: HELPERS & CLEANUP
  // ─────────────────────────────────────────────────────────────

  Future<bool> wipeAllData() async {
    try {
      await _db.clearTable('students');
      await _db.clearTable('bills');
      await _db.clearTable('payments');
      await _db.clearTable('notifications');
      await _db.clearTable('local_sync_status');

      final path = await getApplicationDocumentsDirectory();
      final filesToClear = [
        _studentsFile,
        _billsFile,
        _paymentsFile,
        _notificationsFile,
      ];
      for (final fileName in filesToClear) {
        final file = File('${path.path}/$fileName');
        if (await file.exists()) await file.delete();
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(migrationCompleteKey);

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> wipeOldJsonFilesAndSetFlag() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(migrationCompleteKey) == true) return;

    try {
      final dir = await getApplicationDocumentsDirectory();
      final filesToClear = [
        _studentsFile,
        _billsFile,
        _paymentsFile,
        _notificationsFile,
      ];

      for (final fileName in filesToClear) {
        final file = File('${dir.path}/$fileName');
        if (await file.exists()) await file.delete();
      }
      await prefs.setBool(migrationCompleteKey, true);
    } catch (e) {
      debugPrint('Warning: JSON cleanup failed: $e');
    }
  }

  Future<List<String>> listJsonFiles() async {
    final directory = await getApplicationDocumentsDirectory();
    final files = directory
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.json'))
        .toList();
    return files.map((file) => file.path.split('/').last).toList();
  }

  // ─────────────────────────────────────────────────────────────
  // 🧠 SECTION 6: NOTIFICATIONS & INSIGHTS
  // ─────────────────────────────────────────────────────────────

  Future<void> saveNotification(NotificationItem notification) async {
    final db = await _db.database;
    await db.transaction((txn) async {
      await txn.insert(
        'notifications',
        _notificationToRow(notification),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await txn.insert('local_sync_status', {
        'table_name': 'notifications',
        'record_id': notification.id,
        'action': 'INSERT',
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  Future<List<NotificationItem>> getNotifications() async {
    final rows = await _db.queryAll('notifications');
    final list = rows.map((r) => _rowToNotification(r)).toList();
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }

  Future<void> markNotificationAsRead(String id) async {
    final db = await _db.database;
    await db.transaction((txn) async {
      await txn.update(
        'notifications',
        {'isRead': 1},
        where: 'id = ?',
        whereArgs: [id],
      );
      await txn.insert('local_sync_status', {
        'table_name': 'notifications',
        'record_id': id,
        'action': 'UPDATE',
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  Future<void> markAllAsRead() async {
    final db = await _db.database;
    await db.transaction((txn) async {
      final unreadNotifications = await txn.query(
        'notifications',
        columns: ['id'],
        where: 'isRead = 0',
      );

      if (unreadNotifications.isEmpty) return;

      await txn.update('notifications', {'isRead': 1}, where: 'isRead = 0');

      final batch = txn.batch();
      for (var row in unreadNotifications) {
        batch.insert('local_sync_status', {
          'table_name': 'notifications',
          'record_id': row['id'],
          'action': 'UPDATE',
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
      await batch.commit(noResult: true);
    });
  }

  Future<void> deleteNotification(String id) async {
    final db = await _db.database;
    await db.transaction((txn) async {
      await txn.delete('notifications', where: 'id = ?', whereArgs: [id]);
      await txn.insert('local_sync_status', {
        'table_name': 'notifications',
        'record_id': id,
        'action': 'DELETE',
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  Future<void> generateSmartInsights() async {
    while (_writeLock != null) {
      await _writeLock!.future;
    }
    _writeLock = Completer<void>();

    try {
      debugPrint("🧠 AI Engine: Analyzing financial data...");

      final students = await getAllStudents();
      final bills = await getAllBills();
      final payments = await getAllPayments();
      final notifications = await getNotifications();

      final now = DateTime.now();
      final currentMonthKey =
          "${now.year}-${now.month.toString().padLeft(2, '0')}";
      final currentMonthName = DateFormat('MMMM').format(now);

      // 0. Security Check
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null && user.emailConfirmedAt == null) {
        const id = "urgent_verify_email_action";
        if (!notifications.any((n) => n.id == id)) {
          await _createSmartNotification(
            id: id,
            title: "⚠️ Verification Required",
            body:
                "Your account is currently unverified. To ensure data safety, please verify your email.",
            type: 'warning',
          );
        }
      }

      // A. Current Month's Financials
      final currentMonthPayments = payments
          .where(
            (p) => p.datePaid.year == now.year && p.datePaid.month == now.month,
          )
          .toList();
      final double revenueThisMonth = currentMonthPayments.fold(
        0.0,
        (sum, p) => sum + p.amount,
      );

      // B. Current Month's Bills
      final currentMonthBills = bills
          .where((b) => b.uniqueMonthKey == currentMonthKey)
          .toList();

      // C. Global Debt
      final double totalDebt = bills.fold(
        0.0,
        (sum, b) => sum + b.outstandingBalance,
      );

      // D. Active Students
      final activeStudents = students.where((s) => s.isActive).toList();

      // 1. Record Breaker
      Map<String, double> monthlyTotals = {};
      for (var p in payments) {
        if (p.datePaid.year == now.year) {
          String key = "${p.datePaid.month}";
          monthlyTotals[key] = (monthlyTotals[key] ?? 0) + p.amount;
        }
      }
      double previousRecord = 0.0;
      monthlyTotals.forEach((month, amount) {
        if (int.parse(month) != now.month) {
          if (amount > previousRecord) previousRecord = amount;
        }
      });

      if (revenueThisMonth > previousRecord && previousRecord > 0) {
        final id = "record_breaker_$currentMonthKey";
        if (!notifications.any((n) => n.id == id)) {
          await _createSmartNotification(
            id: id,
            title: "🏆 Record Breaking Month!",
            body:
                "You've generated \$${revenueThisMonth.toStringAsFixed(0)}, beating your previous record.",
            type: 'success',
          );
        }
      }

      // 2. Payment Balancing
      if (currentMonthBills.isNotEmpty) {
        int paidCount = currentMonthBills
            .where((b) => b.status == BillStatus.paid)
            .length;
        int totalCount = currentMonthBills.length;

        if (paidCount >= (totalCount / 2) && totalCount > 2) {
          final id = "milestone_50_$currentMonthKey";
          if (!notifications.any((n) => n.id == id)) {
            await _createSmartNotification(
              id: id,
              title: "Halfway There! 🚀",
              body:
                  "Over 50% of students ($paidCount/$totalCount) have paid for $currentMonthName.",
              type: 'info',
            );
          }
        }
        if (paidCount == totalCount && totalCount > 0) {
          final id = "milestone_100_$currentMonthKey";
          if (!notifications.any((n) => n.id == id)) {
            await _createSmartNotification(
              id: id,
              title: "🎉 Perfect Collection",
              body: "100% of active students have paid for $currentMonthName.",
              type: 'success',
            );
          }
        }
      }

      // 3. Growth
      final newStudentsThisMonth = students
          .where(
            (s) =>
                s.registrationDate.year == now.year &&
                s.registrationDate.month == now.month,
          )
          .toList();
      if (newStudentsThisMonth.isNotEmpty && now.day > 20) {
        final id = "growth_report_$currentMonthKey";
        if (!notifications.any((n) => n.id == id)) {
          await _createSmartNotification(
            id: id,
            title: "📈 Monthly Growth Report",
            body:
                "You welcomed ${newStudentsThisMonth.length} new students in $currentMonthName.",
            type: 'info',
          );
        }
      }

      // 4. Debt Watch
      if (totalDebt > (revenueThisMonth * 2) && revenueThisMonth > 0) {
        final id = "debt_warning_$currentMonthKey";
        if (!notifications.any((n) => n.id == id)) {
          await _createSmartNotification(
            id: id,
            title: "⚠️ High Outstanding Debt",
            body:
                "Outstanding debt (\$$totalDebt) is 2x higher than this month's revenue.",
            type: 'warning',
          );
        }
      }

      // 5. Ghost Student
      for (var student in activeStudents) {
        final studentPayments = payments
            .where((p) => p.studentId == student.studentId)
            .toList();
        bool isGhost = false;
        if (studentPayments.isEmpty) {
          if (now.difference(student.registrationDate).inDays > 45) {
            isGhost = true;
          }
        } else {
          studentPayments.sort((a, b) => b.datePaid.compareTo(a.datePaid));
          final lastPay = studentPayments.first.datePaid;
          if (now.difference(lastPay).inDays > 60) isGhost = true;
        }

        if (isGhost) {
          final id =
              "ghost_alert_${student.studentId}_${now.year}_${now.month}";
          if (!notifications.any((n) => n.id == id)) {
            await _createSmartNotification(
              id: id,
              title: "👻 Ghost Student Detected",
              body:
                  "${student.studentName} hasn't paid in over 60 days. Review status?",
              type: 'warning',
            );
          }
        }
      }

      // 6. Revenue Summary
      if (now.day >= 28) {
        final id = "eom_summary_$currentMonthKey";
        if (!notifications.any((n) => n.id == id)) {
          await _createSmartNotification(
            id: id,
            title: "📅 End of Month Summary",
            body:
                "Generated: \$${revenueThisMonth.toStringAsFixed(2)}\nActive Students: ${activeStudents.length}\nOutstanding: \$${totalDebt.toStringAsFixed(2)}",
            type: 'info',
          );
        }
      }
    } catch (e) {
      debugPrint("❌ Error generating AI insights: $e");
    } finally {
      final c = _writeLock;
      _writeLock = null;
      c?.complete();
    }
  }

  Future<void> _createSmartNotification({
    required String id,
    required String title,
    required String body,
    required String type,
  }) async {
    final notif = NotificationItem(
      id: id,
      title: title,
      body: body,
      timestamp: DateTime.now(),
      type: type,
      isRead: false,
    );
    await saveNotification(notif);
    debugPrint("🔔 Smart Insight Generated: $title");
  }

  // ---------------------------------------------------------
  // SECTION 7: ADMIN PROFILE & FORCE QUEUE
  // ---------------------------------------------------------

  Future<AdminProfile?> getAdminProfile() async {
    // Query the local admin_profile table via DatabaseService [cite: 1084]
    final rows = await _db.queryAll('admin_profile');

    // If no rows, return null [cite: 1085]
    if (rows.isEmpty) return null;

    // Convert the SQLite row (Map) to the AdminProfile model [cite: 1086]
    return AdminProfile.fromRow(rows.first);
  }

  Future<bool> saveAdminProfile(AdminProfile profile) async {
    try {
      // Insert/Replace the profile row in the local SQLite database [cite: 1090]
      // The profile.toRow() handles the conversion to a Map<String, dynamic>
      await _db.insert('admin_profile', profile.toRow());

      // NOTE: This intentionally skips local_sync_status queuing
      // because AdminProfile is typically handled by the dedicated
      // ProfileService and Master Sync Manager for cloud-first logic.

      return true;
    } catch (e) {
      debugPrint("❌ Failed to save admin profile: $e");
      return false;
    }
  }

  Future<void> forceQueueAllDataForSync() async {
    final db = await _db.database;
    await db.transaction((txn) async {
      await txn.delete('local_sync_status');
      final students = await txn.query('students');
      for (var s in students) {
        await txn.insert('local_sync_status', {
          'table_name': 'students',
          'record_id': s['studentId'],
          'action': 'INSERT',
        });
      }
      final bills = await txn.query('bills');
      for (var b in bills) {
        await txn.insert('local_sync_status', {
          'table_name': 'bills',
          'record_id': b['id'],
          'action': 'INSERT',
        });
      }
      final payments = await txn.query('payments');
      for (var p in payments) {
        await txn.insert('local_sync_status', {
          'table_name': 'payments',
          'record_id': p['id'],
          'action': 'INSERT',
        });
      }
      final notifications = await txn.query('notifications');
      for (var n in notifications) {
        await txn.insert('local_sync_status', {
          'table_name': 'notifications',
          'record_id': n['id'],
          'action': 'INSERT',
        });
      }
    });
    debugPrint("✅ FORCE QUEUE COMPLETE.");
  }

  Future<int> getStudentCount() async {
    try {
      final db = await _db.database;
      // Uses the database service to query the table directly
      final count =
          Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM students'),
          ) ??
          0;
      return count;
    } catch (e) {
      debugPrint("⚠️ Error getting local student count: $e");
      return 0;
    }
  }
}

// 🛑 EXTENSION RESTORED to fix 'unused_element'
extension _IterableX<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E element) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
