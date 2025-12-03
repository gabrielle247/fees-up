import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:fees_up/core/services/database_service.dart';

class PaymentRepository {
  final DatabaseService _dbService = DatabaseService();
  final Uuid _uuid = const Uuid();

  /// WATERFALL PAYMENT LOGIC
  /// 1. Accepts a total amount from student.
  /// 2. Finds oldest unpaid bills.
  /// 3. Pays them off one by one until money runs out.
  /// 4. Any excess is stored as Credit (Future implementation) or overpayment.
  Future<void> processPayment(String studentId, double amount, String method) async {
    final db = await _dbService.database;

    await db.transaction((txn) async {
      double remainingAmount = amount;

      // 1. Get unpaid bills sorted by OLDEST first
      // We assume _billRepo logic here, but inside a transaction we query directly 
      // to ensure atomicity.
      final pendingBillsData = await txn.rawQuery('''
        SELECT * FROM bills 
        WHERE student_id = ? AND paid_amount < total_amount
        ORDER BY billing_cycle_start ASC
      ''', [studentId]);

      // 2. Iterate and Pay
      for (final billRow in pendingBillsData) {
        if (remainingAmount <= 0) break;

        final String billId = billRow['id'] as String;
        final double total = billRow['total_amount'] as double;
        final double paid = billRow['paid_amount'] as double;
        final double outstanding = total - paid;

        double amountToPayForThisBill = 0.0;

        if (remainingAmount >= outstanding) {
          // Pay off this bill completely
          amountToPayForThisBill = outstanding;
          remainingAmount -= outstanding;
        } else {
          // Pay partial
          amountToPayForThisBill = remainingAmount;
          remainingAmount = 0;
        }

        // 3. Record the Payment Record
        final newPayment = {
          'id': _uuid.v4(),
          'bill_id': billId,
          'student_id': studentId,
          'amount': amountToPayForThisBill,
          'date_paid': DateTime.now().toIso8601String(),
          'method': method,
        };
        await txn.insert('payments', newPayment);

        // 4. Update the Bill Balance
        await txn.update(
          'bills',
          {'paid_amount': paid + amountToPayForThisBill},
          where: 'id = ?',
          whereArgs: [billId],
        );
      }

      // 5. Handle Overpayment (Optional: Store as credit)
      if (remainingAmount > 0) {
        debugPrint("User overpaid by $remainingAmount. Logic needed for Wallet/Credit.");
      }
    });
  }
}