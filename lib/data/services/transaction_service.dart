import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../core/errors/billing_exceptions.dart';
import 'device_authority_service.dart';
import 'database_service.dart';

/// 🔒 SECURE Transaction Processing Engine
/// Handles payment allocation, partial payments, and refunds
/// All operations support offline-first via PowerSync
/// 🔒 Only the billing engine device can record payments and allocate them
class TransactionService {
  final SupabaseClient supabase;
  final DeviceAuthorityService _deviceAuthority;

  TransactionService({required this.supabase})
      : _deviceAuthority = DeviceAuthorityService();

  // ========== PAYMENT PROCESSING ==========

  /// ✅ SECURE: Record payment with optional bill allocation
  /// Supports:
  /// - Full payment to single bill
  /// - Partial payment to single bill
  /// - Payment allocated across multiple bills
  /// 🔒 Only billing engine device can record payments
  Future<String> recordPayment({
    required String schoolId,
    required String studentId,
    required double amount,
    required String method, // 'Cash', 'Bank Transfer', 'Mobile Money', 'Cheque'
    required String
        category, // 'Tuition', 'Uniform', 'Levy', 'Transport', 'Donation'
    required DateTime datePaid,
    required String userId, // Required for RLS compliance
    String? payerName,
    String? description,
  }) async {
    // ✅ Check device authority
    final isBillingEngine =
        await _deviceAuthority.isBillingEngineForSchool(schoolId);
    if (!isBillingEngine) {
      throw BillingEnginePermissionException(
          'This device is not the billing engine for $schoolId. '
          'Only the billing engine device can record payments.');
    }

    try {
      final paymentId = const Uuid().v4();
      final now = DateTime.now();

      // Create payment record
      final paymentData = {
        'id': paymentId,
        'school_id': schoolId,
        'student_id': studentId,
        'amount': amount,
        'method': method,
        'category': category,
        'date_paid': DateFormat('yyyy-MM-dd').format(datePaid),
        'payer_name': payerName,
        'description': description,
        'user_id': userId, // ✅ Required for RLS compliance
        'device_id': _deviceAuthority
            .currentDeviceId, // ✅ Track which device recorded it
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      // ✅ Use PowerSync for offline-first write
      final db = DatabaseService();
      await db.insert('payments', paymentData);

      // Trigger audit logging via server-side function (similar to billing suspension)
      try {
        await supabase.rpc('log_payment_action', params: {
          'p_payment_id': paymentId,
          'p_school_id': schoolId,
          'p_action': 'payment_recorded',
          'p_amount': amount,
          'p_user_id': userId,
          'p_device_id': _deviceAuthority.currentDeviceId,
        });
      } catch (e) {
        // Log call is non-critical
        debugPrintError('Payment audit log failed: $e');
      }

      return paymentId;
    } catch (e) {
      rethrow;
    }
  }

  // ========== PAYMENT ALLOCATION ==========

  /// ✅ NEW: Allocate payment to specific bills
  /// Enables partial payment tracking and bill-level payment status
  /// 🔒 Only billing engine device can allocate payments
  Future<void> allocatePaymentToBill({
    required String schoolId,
    required String paymentId,
    required String billId,
    required double allocatedAmount,
  }) async {
    // ✅ Check device authority
    final isBillingEngine =
        await _deviceAuthority.isBillingEngineForSchool(schoolId);
    if (!isBillingEngine) {
      throw BillingEnginePermissionException(
          'This device is not the billing engine for $schoolId. '
          'Only the billing engine device can allocate payments.');
    }

    try {
      final allocationId = const Uuid().v4();

      // Create payment allocation record
      final allocationData = {
        'id': allocationId,
        'payment_id': paymentId,
        'bill_id': billId,
        'school_id': schoolId,
        'amount': allocatedAmount,
        'device_id': _deviceAuthority.currentDeviceId,
        'created_at': DateTime.now().toIso8601String(),
      };

      // ✅ Use PowerSync for offline-first write
      final db = DatabaseService();
      await db.insert('payment_allocations', allocationData);

      // Update bill paid_amount
      await _updateBillPaidAmount(billId, allocatedAmount);
    } catch (e) {
      rethrow;
    }
  }

  /// Allocate a payment across multiple bills (partial payment support)
  Future<void> allocatePaymentToMultipleBills({
    required String schoolId,
    required String paymentId,
    required List<MapEntry<String, double>> billAllocations,
    // billAllocations: List of MapEntry<billId, allocatedAmount>
  }) async {
    try {
      for (final allocation in billAllocations) {
        await allocatePaymentToBill(
          schoolId: schoolId,
          paymentId: paymentId,
          billId: allocation.key,
          allocatedAmount: allocation.value,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Get all allocations for a payment
  Future<List<Map<String, dynamic>>> getPaymentAllocations(
      String paymentId) async {
    try {
      final response = await supabase
          .from('payment_allocations')
          .select('id, bill_id, amount, created_at')
          .eq('payment_id', paymentId);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Get bills with outstanding balance for a student
  /// Shows how much is still owed per bill
  Future<List<Map<String, dynamic>>> getOutstandingBillsWithBalance(
      String studentId) async {
    try {
      final response =
          await supabase.rpc('get_outstanding_bills_with_balance', params: {
        'p_student_id': studentId,
      });

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }

  // ========== PARTIAL PAYMENT SUPPORT ==========

  /// ✅ NEW: Update bill paid amount and calculate remaining balance
  /// Automatically tracks if bill is fully paid
  Future<void> _updateBillPaidAmount(String billId, double addedAmount) async {
    try {
      final db = DatabaseService().db;

      // Get current bill state using PowerSync
      final billData = await db.getAll(
        'SELECT paid_amount, total_amount FROM bills WHERE id = ? LIMIT 1',
        [billId],
      );

      if (billData.isEmpty) {
        throw Exception('Bill not found: $billId');
      }

      final currentPaid = (billData[0]['paid_amount'] as num).toDouble();
      final totalAmount = (billData[0]['total_amount'] as num).toDouble();
      final newPaidAmount = currentPaid + addedAmount;
      final isFullyPaid = newPaidAmount >= totalAmount;

      // Update bill with new paid amount and status using PowerSync
      await db.execute(
        'UPDATE bills SET paid_amount = ?, is_paid = ?, status = ?, updated_at = ? WHERE id = ?',
        [
          newPaidAmount,
          isFullyPaid ? 1 : 0,
          isFullyPaid ? 'paid' : 'partial',
          DateTime.now().toIso8601String(),
          billId,
        ],
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Calculate remaining balance for a bill
  Future<double> calculateBillBalance(String billId) async {
    try {
      final response = await supabase
          .from('bills')
          .select('paid_amount, total_amount')
          .eq('id', billId)
          .single();

      final paidAmount = (response['paid_amount'] as num).toDouble();
      final totalAmount = (response['total_amount'] as num).toDouble();

      return (totalAmount - paidAmount).clamp(0.0, totalAmount);
    } catch (e) {
      rethrow;
    }
  }

  /// Get payment allocation summary for a bill
  /// Shows total allocated, remaining, and allocation history
  Future<Map<String, dynamic>> getBillPaymentSummary(String billId) async {
    try {
      final response = await supabase.rpc('get_bill_payment_summary', params: {
        'p_bill_id': billId,
      });

      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  // ========== REFUND PROCESSING ==========

  /// ✅ NEW: Process refund for overpayment
  /// Creates reverse payment entry and adjusts bill status
  /// 🔒 Only billing engine device can process refunds
  Future<String> processRefund({
    required String originalPaymentId,
    required String studentId,
    required String schoolId,
    required double refundAmount,
    required String reason,
    required String refundMethod, // 'Cash', 'Bank Transfer', etc.
    required String userId, // Required for RLS compliance
    String? approvedBy,
  }) async {
    // ✅ Check device authority
    final isBillingEngine =
        await _deviceAuthority.isBillingEngineForSchool(schoolId);
    if (!isBillingEngine) {
      throw BillingEnginePermissionException(
          'This device is not the billing engine for $schoolId. '
          'Only the billing engine device can process refunds.');
    }

    try {
      final refundId = const Uuid().v4();
      final now = DateTime.now();

      // Create refund record (negative payment)
      final refundData = {
        'id': refundId,
        'school_id': schoolId,
        'student_id': studentId,
        'amount': -refundAmount, // Negative to indicate refund
        'method': refundMethod,
        'category': 'Refund',
        'date_paid': DateFormat('yyyy-MM-dd').format(now),
        'payer_name': 'School Refund',
        'description':
            'Refund for payment: $originalPaymentId. Reason: $reason',
        'original_payment_id': originalPaymentId,
        'refund_reason': reason,
        'approved_by': approvedBy,
        'user_id': userId, // ✅ Required for RLS compliance
        'device_id': _deviceAuthority.currentDeviceId,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      // ✅ Use PowerSync for offline-first write
      final db = DatabaseService();
      await db.insert('payments', refundData);

      // Log refund action
      try {
        await supabase.rpc('log_refund_action', params: {
          'p_refund_id': refundId,
          'p_school_id': schoolId,
          'p_original_payment_id': originalPaymentId,
          'p_amount': refundAmount,
          'p_reason': reason,
          'p_approved_by': approvedBy,
          'p_user_id': userId,
          'p_device_id': _deviceAuthority.currentDeviceId,
        });
      } catch (e) {
        debugPrintError('Refund audit log failed: $e');
      }

      return refundId;
    } catch (e) {
      rethrow;
    }
  }

  /// Reverse payment allocation (for refunded payments)
  Future<void> reversePaymentAllocation({
    required String allocationId,
    required String billId,
    required double allocationAmount,
  }) async {
    try {
      // Delete allocation
      await supabase
          .from('payment_allocations')
          .delete()
          .eq('id', allocationId);

      // Reduce bill paid amount
      await _reduceBillPaidAmount(billId, allocationAmount);
    } catch (e) {
      rethrow;
    }
  }

  /// Internal: Reduce paid amount (for refunds)
  Future<void> _reduceBillPaidAmount(String billId, double deductAmount) async {
    try {
      final db = DatabaseService().db;

      // Get current bill state using PowerSync
      final billData = await db.getAll(
        'SELECT paid_amount, total_amount FROM bills WHERE id = ? LIMIT 1',
        [billId],
      );

      if (billData.isEmpty) {
        throw Exception('Bill not found: $billId');
      }

      final currentPaid = (billData[0]['paid_amount'] as num).toDouble();
      final newPaidAmount =
          (currentPaid - deductAmount).clamp(0.0, double.infinity);
      final totalAmount = (billData[0]['total_amount'] as num).toDouble();
      final isFullyPaid = newPaidAmount >= totalAmount;

      // Update using PowerSync
      await db.execute(
        'UPDATE bills SET paid_amount = ?, is_paid = ?, status = ?, updated_at = ? WHERE id = ?',
        [
          newPaidAmount,
          isFullyPaid ? 1 : 0,
          isFullyPaid ? 'paid' : (newPaidAmount > 0 ? 'partial' : 'sent'),
          DateTime.now().toIso8601String(),
          billId,
        ],
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get refund history for a student
  Future<List<Map<String, dynamic>>> getRefundHistory(String studentId) async {
    try {
      final response = await supabase
          .from('payments')
          .select(
              'id, amount, date_paid, refund_reason, approved_by, original_payment_id')
          .eq('student_id', studentId)
          .lt('amount', 0) // Negative amounts are refunds
          .order('date_paid', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }

  // ========== TRANSACTION HISTORY & REPORTING ==========

  /// Get all payments for a student with date range filtering
  Future<List<Map<String, dynamic>>> getPaymentHistory({
    required String studentId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final query = supabase.from('payments').select(
          'id, amount, method, category, date_paid, payer_name, created_at');

      var filtered = query.eq('student_id', studentId).gt('amount', 0);

      // Apply optional date filters inline
      final response = await (startDate != null && endDate != null
          ? filtered
              .gte('date_paid', DateFormat('yyyy-MM-dd').format(startDate))
              .lte('date_paid', DateFormat('yyyy-MM-dd').format(endDate))
              .order('date_paid', ascending: false)
          : startDate != null
              ? filtered
                  .gte('date_paid', DateFormat('yyyy-MM-dd').format(startDate))
                  .order('date_paid', ascending: false)
              : endDate != null
                  ? filtered
                      .lte(
                          'date_paid', DateFormat('yyyy-MM-dd').format(endDate))
                      .order('date_paid', ascending: false)
                  : filtered.order('date_paid', ascending: false));

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Get transaction summary for school (dashboard)
  Future<Map<String, dynamic>> getTransactionSummary(String schoolId) async {
    try {
      final response = await supabase.rpc('get_transaction_summary', params: {
        'p_school_id': schoolId,
      });

      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Reconcile payments with allocations (for auditing)
  Future<Map<String, dynamic>> reconcilePayments({
    required String schoolId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await supabase.rpc('reconcile_payments', params: {
        'p_school_id': schoolId,
        'p_start_date': startDate.toIso8601String(),
        'p_end_date': endDate.toIso8601String(),
      });

      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Get recent transactions for school (payments and expenses)
  Future<List<Map<String, dynamic>>> getSchoolTransactions(String schoolId,
      {int limit = 50}) async {
    try {
      final response = await supabase
          .from('payments')
          .select('*, students(name)')
          .eq('school_id', schoolId)
          .order('date_paid', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrintError('Failed to fetch school transactions: $e');
      rethrow;
    }
  }
}

void debugPrintError(String message) {
  // TODO: Replace with proper logging service
  // Integrate with a logging framework like: Firebase Crashlytics, Sentry, or custom logger
  // ignore: avoid_print
  print('❌ ERROR: $message');
}
