/// Payment Repository Interface
///
/// Defines the contract for payment-related operations.
/// This abstracts the database layer from the UI layer.
///
/// **Why this exists:**
/// The QuickPaymentDialog was directly calling _dbService.db.watch(),
/// which tightly couples the widget to the database implementation.
/// This repository provides a clean interface for all payment operations.
library;

/// Represents a single payment record from the database.
class Payment {
  final String id;
  final String studentId;
  final double amount;
  final String method; // 'Cash', 'Check', 'Card', 'Mobile'
  final DateTime recordedDate;
  final String? description;
  final String allocatedToInvoiceId;

  Payment({
    required this.id,
    required this.studentId,
    required this.amount,
    required this.method,
    required this.recordedDate,
    this.description,
    required this.allocatedToInvoiceId,
  });

  /// Convert from database Map to Payment object
  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'] as String,
      studentId: map['student_id'] as String,
      amount: (map['amount'] as num).toDouble(),
      method: map['method'] as String,
      recordedDate: DateTime.parse(map['recorded_date'] as String),
      description: map['description'] as String?,
      allocatedToInvoiceId: map['allocated_to_invoice_id'] as String,
    );
  }

  /// Convert Payment object to database Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_id': studentId,
      'amount': amount,
      'method': method,
      'recorded_date': recordedDate.toIso8601String(),
      'description': description,
      'allocated_to_invoice_id': allocatedToInvoiceId,
    };
  }
}

/// Abstract repository interface for payment operations.
///
/// All database access should go through this interface.
/// This allows:
/// - Easy testing (mock the interface)
/// - Database implementation changes without affecting UI
/// - Shared payment logic across the app (not duplicated in dialogs)
abstract class PaymentRepository {
  /// Record a new payment for a student.
  ///
  /// **Atomicity guaranteed:** This operation is atomic at the database level.
  /// Either the payment is recorded AND the bill is updated, or neither happens.
  /// This prevents database inconsistency even if the app crashes mid-operation.
  ///
  /// Parameters:
  /// - [studentId]: The student receiving the payment
  /// - [amount]: Payment amount in currency units
  /// - [method]: Payment method ('Cash', 'Check', 'Card', 'Mobile', etc)
  /// - [invoiceId]: Which invoice this payment is allocated to
  /// - [description]: Optional notes about the payment
  ///
  /// Returns: The newly created Payment object
  ///
  /// Throws: [PaymentException] if recording fails
  Future<Payment> recordPayment({
    required String studentId,
    required double amount,
    required String method,
    required String invoiceId,
    String? description,
  });

  /// Get the payment history for a specific student.
  ///
  /// Returns a stream of payment lists that updates in real-time
  /// when new payments are recorded (by this app or others).
  ///
  /// Parameters:
  /// - [studentId]: The student whose payments to retrieve
  ///
  /// Returns: Stream<List<Payment>> ordered by date (newest first)
  Stream<List<Payment>> watchPaymentsForStudent(String studentId);

  /// Allocate an existing payment to different invoices.
  ///
  /// Example: A $100 payment can be split:
  /// - $50 to Invoice A
  /// - $50 to Invoice B
  ///
  /// **Atomicity guaranteed** at the database level.
  ///
  /// Parameters:
  /// - [paymentId]: The payment to reallocate
  /// - [allocations]: Map of invoiceId → amount
  ///
  /// Throws: [PaymentException] if allocations don't sum correctly
  Future<void> allocatePayment({
    required String paymentId,
    required Map<String, double> allocations,
  });

  /// Delete a payment record.
  ///
  /// WARNING: This also reverses any bill updates made when the payment
  /// was recorded. Use with caution - consider marking as "void" instead
  /// for audit trail purposes.
  ///
  /// **Atomicity guaranteed** at the database level.
  ///
  /// Throws: [PaymentException] if payment not found
  Future<void> deletePayment(String paymentId);

  /// Get total amount paid by a student (for summary/stats).
  ///
  /// Parameters:
  /// - [studentId]: The student to summarize
  /// - [startDate]: Optional filter (only payments on/after this date)
  /// - [endDate]: Optional filter (only payments on/before this date)
  ///
  /// Returns: Total amount paid in the period
  Future<double> getTotalPaidByStudent({
    required String studentId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get outstanding balance for a student.
  ///
  /// This is calculated as: Total invoiced - Total paid
  ///
  /// Parameters:
  /// - [studentId]: The student to check
  ///
  /// Returns: Outstanding amount (negative = overpaid)
  Future<double> getOutstandingBalance(String studentId);
}

/// Custom exception for payment-related errors.
class PaymentException implements Exception {
  final String message;
  final String? code;

  PaymentException(this.message, {this.code});

  @override
  String toString() =>
      'PaymentException: $message${code != null ? ' ($code)' : ''}';
}

/// Validation rules for payments.
abstract class PaymentValidator {
  /// Check if an amount is valid.
  static bool isValidAmount(double amount) {
    return amount > 0 && amount < 1000000; // Reasonable upper limit
  }

  /// Check if a payment method is recognized.
  static bool isValidMethod(String method) {
    const validMethods = ['Cash', 'Check', 'Card', 'Mobile', 'Bank Transfer'];
    return validMethods.contains(method);
  }

  /// Validate allocation totals.
  ///
  /// Ensures that allocated amounts sum to the original payment amount.
  static bool isValidAllocation(
      double originalAmount, Map<String, double> allocations) {
    final total = allocations.values.fold(0.0, (sum, amount) => sum + amount);
    // Allow for floating-point rounding errors (0.01 currency unit)
    return (total - originalAmount).abs() < 0.01;
  }
}
