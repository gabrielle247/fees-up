import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database_service.dart';

/// Get payment allocation history for a specific payment
final paymentAllocationsProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>(
  (ref, paymentId) {
    final db = DatabaseService();
    return db.db.watch(
      '''SELECT pa.*, b.title as bill_title, b.total_amount, b.paid_amount 
         FROM payment_allocations pa 
         LEFT JOIN bills b ON pa.bill_id = b.id 
         WHERE pa.payment_id = ? 
         ORDER BY pa.created_at DESC''',
      parameters: [paymentId],
    );
  },
);

/// Get all payment allocations for a student
final studentPaymentAllocationsProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>(
  (ref, studentId) {
    final db = DatabaseService();
    return db.db.watch(
      '''SELECT pa.*, p.amount as payment_amount, p.date_paid,
                b.title as bill_title, b.total_amount, b.paid_amount
         FROM payment_allocations pa
         JOIN payments p ON pa.payment_id = p.id
         JOIN bills b ON pa.bill_id = b.id
         WHERE p.student_id = ?
         ORDER BY p.date_paid DESC''',
      parameters: [studentId],
    );
  },
);

/// Get unallocated portion of a payment
final unallocatedPaymentAmountProvider = FutureProvider.family<double, String>(
  (ref, paymentId) async {
    final db = DatabaseService();

    // Get payment total
    final paymentResult = await db.db.getAll(
      'SELECT amount FROM payments WHERE id = ?',
      [paymentId],
    );

    if (paymentResult.isEmpty) return 0.0;
    final paymentAmount =
        (paymentResult.first['amount'] as num?)?.toDouble() ?? 0.0;

    // Get allocated amount
    final allocatedResult = await db.db.getAll(
      'SELECT SUM(amount) as total FROM payment_allocations WHERE payment_id = ?',
      [paymentId],
    );

    final allocatedAmount =
        (allocatedResult.first['total'] as num?)?.toDouble() ?? 0.0;

    return paymentAmount - allocatedAmount;
  },
);

/// Create a new payment allocation
class PaymentAllocationNotifier
    extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  PaymentAllocationNotifier(this._db) : super(const AsyncData(null));

  final DatabaseService _db;

  Future<void> allocatePayment({
    required String paymentId,
    required String billId,
    required double amount,
  }) async {
    state = const AsyncLoading();
    try {
      final allocationId = DateTime.now().millisecondsSinceEpoch.toString();

      await _db.db.execute(
        '''INSERT INTO payment_allocations (payment_id, bill_id, school_id, amount, created_at)
           SELECT ?, ?, school_id, ?, ? FROM payments WHERE id = ?''',
        [
          paymentId,
          billId,
          amount,
          DateTime.now().toIso8601String(),
          paymentId,
        ],
      );

      // Recalculate bill paid_amount
      await _db.db.execute(
        '''UPDATE bills 
           SET paid_amount = (SELECT COALESCE(SUM(amount), 0) FROM payment_allocations WHERE bill_id = ?)
           WHERE id = ?''',
        [billId, billId],
      );

      state = AsyncData({'id': allocationId, 'paymentId': paymentId});
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> removeAllocation({
    required String allocationId,
    required String billId,
  }) async {
    try {
      await _db.db.execute(
        'DELETE FROM payment_allocations WHERE id = ?',
        [allocationId],
      );

      // Recalculate bill paid_amount
      await _db.db.execute(
        '''UPDATE bills 
           SET paid_amount = (SELECT COALESCE(SUM(amount), 0) FROM payment_allocations WHERE bill_id = ?)
           WHERE id = ?''',
        [billId, billId],
      );
    } catch (e) {
      rethrow;
    }
  }
}

final paymentAllocationNotifierProvider = StateNotifierProvider.autoDispose<
    PaymentAllocationNotifier, AsyncValue<Map<String, dynamic>?>>(
  (ref) => PaymentAllocationNotifier(DatabaseService()),
);
