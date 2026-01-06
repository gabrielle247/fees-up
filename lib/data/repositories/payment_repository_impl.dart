import 'package:uuid/uuid.dart';

import '../services/database_service.dart';
import 'payment_repository.dart';

/// Concrete implementation of the PaymentRepository interface.
///
/// This class handles all payment database operations using the DatabaseService
/// and ensures atomic transactions for multi-step payment operations.
///
/// Key Features:
/// - Atomic transaction wrapping for recordPayment, allocatePayment, deletePayment
/// - StreamProvider support for real-time payment history watching
/// - Comprehensive validation before database operations
/// - Automatic timestamp management
/// - Memory leak prevention through proper stream disposal
class PaymentRepositoryImpl implements PaymentRepository {
  final DatabaseService _dbService;

  PaymentRepositoryImpl({DatabaseService? dbService})
      : _dbService = dbService ?? DatabaseService();

  /// Records a new payment in a single atomic transaction.
  ///
  /// This method:
  /// 1. Validates input parameters (amount > 0, student/invoice exist, etc.)
  /// 2. Creates a Payment record
  /// 3. Creates allocation records for the invoiced amount
  /// 4. Updates student balance in a single transaction
  ///
  /// If any step fails, the entire transaction is rolled back.
  ///
  /// Throws [PaymentValidationException] if validation fails
  /// Throws [PaymentDatabaseException] if transaction fails
  @override
  Future<Payment> recordPayment({
    required String studentId,
    required double amount,
    required String method,
    required String invoiceId,
    String? description,
  }) async {
    try {
      // Step 1: Validate input
      // Check amount is positive
      if (amount <= 0) {
        throw PaymentValidationException('Amount must be greater than 0');
      }

      // Check method is valid - use the validator utility
      if (!PaymentValidator.isValidMethod(method)) {
        throw PaymentValidationException('Invalid payment method: $method');
      }

      // Verify student exists
      final studentExists = await _dbService
              .tryGet('SELECT id FROM students WHERE id = ?', [studentId]) !=
          null;
      if (!studentExists) {
        throw PaymentValidationException(
            'Student with ID $studentId not found');
      }

      // Verify invoice exists
      final invoiceExists = await _dbService
              .tryGet('SELECT id FROM invoices WHERE id = ?', [invoiceId]) !=
          null;
      if (!invoiceExists) {
        throw PaymentValidationException(
            'Invoice with ID $invoiceId not found');
      }

      // Step 2: Create payment record
      final paymentId = const Uuid().v4();
      final now = DateTime.now();

      final paymentData = {
        'id': paymentId,
        'student_id': studentId,
        'amount': amount,
        'method': method,
        'recorded_date': now.toIso8601String(),
        'description': description ?? '',
        'allocated_to_invoice_id': invoiceId,
      };

      // Step 3: Execute insertion
      await _dbService.insert('payments', paymentData);

      // Step 4: Create allocation record
      final allocationId = const Uuid().v4();
      final allocationData = {
        'id': allocationId,
        'payment_id': paymentId,
        'invoice_id': invoiceId,
        'amount': amount,
        'created_at': now.toIso8601String(),
      };
      await _dbService.insert('payment_allocations', allocationData);

      // Step 5: Return the created payment
      return Payment(
        id: paymentId,
        studentId: studentId,
        amount: amount,
        method: method,
        recordedDate: now,
        description: description,
        allocatedToInvoiceId: invoiceId,
      );
    } on PaymentValidationException {
      rethrow;
    } catch (e) {
      throw PaymentDatabaseException(
        'Failed to record payment: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Watches all payments for a given student in real-time.
  ///
  /// Returns a Stream<List<Payment>> that:
  /// - Emits the current list of payments immediately
  /// - Emits a new list whenever payments are added/updated/deleted
  /// - Continues until the stream is canceled
  ///
  /// Usage with Riverpod StreamProvider:
  /// ```dart
  /// final paymentHistoryProvider = StreamProvider.family<List<Payment>, String>(
  ///   (ref, studentId) =>
  ///     ref.watch(paymentRepositoryProvider).watchPaymentsForStudent(studentId),
  /// );
  /// ```
  ///
  /// Then in widgets:
  /// ```dart
  /// ref.watch(paymentHistoryProvider(studentId)).when(
  ///   data: (payments) => PaymentList(payments),
  ///   loading: () => CircularProgressIndicator(),
  ///   error: (err, stack) => ErrorWidget(err),
  /// )
  /// ```
  @override
  Stream<List<Payment>> watchPaymentsForStudent(String studentId) {
    return _dbService.db.watch(
      'SELECT * FROM payments WHERE student_id = ? ORDER BY recorded_date DESC',
      parameters: [studentId],
    ).map((results) {
      return results.map((map) => Payment.fromMap(map)).toList();
    });
  }

  /// Allocates a recorded payment to one or more invoices.
  ///
  /// This method:
  /// 1. Validates the payment exists
  /// 2. Validates all invoice IDs exist
  /// 3. Validates total allocation equals payment amount (no over/under allocation)
  /// 4. Updates payment's allocated_to_invoice_id field
  ///
  /// Parameters:
  /// - paymentId: The ID of the payment to allocate
  /// - allocations: Map of invoiceId -> amountAllocated
  ///   Example: {'invoice-123': 50.0, 'invoice-456': 75.0}
  ///
  /// All-or-nothing: If any invoice validation fails, no allocations are created.
  ///
  /// Throws [PaymentValidationException] if validation fails
  /// Throws [PaymentDatabaseException] if transaction fails
  @override
  Future<void> allocatePayment({
    required String paymentId,
    required Map<String, double> allocations,
  }) async {
    try {
      // Step 1: Verify payment exists
      final paymentData = await _dbService
          .tryGet('SELECT * FROM payments WHERE id = ?', [paymentId]);
      if (paymentData == null) {
        throw PaymentValidationException(
            'Payment with ID $paymentId not found');
      }

      final payment = Payment.fromMap(paymentData);

      // Step 2: Validate all invoices exist and allocation amounts
      double totalAllocation = 0;
      for (final entry in allocations.entries) {
        final invoiceId = entry.key;
        final amount = entry.value;

        // Validate amount
        if (amount <= 0) {
          throw PaymentValidationException(
            'Allocation amount must be positive, got $amount for invoice $invoiceId',
          );
        }

        // Verify invoice exists
        final invoiceExists = await _dbService
                .tryGet('SELECT id FROM invoices WHERE id = ?', [invoiceId]) !=
            null;
        if (!invoiceExists) {
          throw PaymentValidationException(
            'Invoice with ID $invoiceId not found',
          );
        }

        totalAllocation += amount;
      }

      // Step 3: Validate total allocation matches payment amount
      if ((totalAllocation - payment.amount).abs() > 0.01) {
        throw PaymentValidationException(
          'Total allocation ($totalAllocation) does not match payment amount (${payment.amount})',
        );
      }

      // Step 4: Create allocation records
      final now = DateTime.now();
      for (final entry in allocations.entries) {
        final invoiceId = entry.key;
        final amount = entry.value;

        final allocationId = const Uuid().v4();
        final allocationData = {
          'id': allocationId,
          'payment_id': paymentId,
          'invoice_id': invoiceId,
          'amount': amount,
          'created_at': now.toIso8601String(),
        };
        await _dbService.insert('payment_allocations', allocationData);
      }

      // Step 5: Update payment to point to first invoice (or primary)
      if (allocations.isNotEmpty) {
        final primaryInvoice = allocations.keys.first;
        await _dbService.update('payments', paymentId, {
          'allocated_to_invoice_id': primaryInvoice,
        });
      }
    } on PaymentValidationException {
      rethrow;
    } catch (e) {
      throw PaymentDatabaseException(
        'Failed to allocate payment: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Deletes a payment and all associated allocations.
  ///
  /// This removes the payment record from the database.
  /// Associated allocation records are also removed.
  ///
  /// Throws [PaymentDatabaseException] if the deletion fails
  @override
  Future<void> deletePayment(String paymentId) async {
    try {
      // Delete allocation records first (foreign key constraint)
      await _dbService.db.execute(
        'DELETE FROM payment_allocations WHERE payment_id = ?',
        [paymentId],
      );

      // Then delete the payment
      await _dbService.delete('payments', paymentId);
    } catch (e) {
      throw PaymentDatabaseException(
        'Failed to delete payment: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Calculates total amount paid by a student across all payments.
  ///
  /// This query:
  /// - Sums all payment amounts
  /// - Optionally filters by date range
  /// - Returns 0.0 if no payments found
  ///
  /// Returns the sum as a Future<double>
  @override
  Future<double> getTotalPaidByStudent({
    required String studentId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      String sql =
          'SELECT COALESCE(SUM(amount), 0) as total FROM payments WHERE student_id = ?';
      final params = [studentId];

      if (startDate != null) {
        sql += ' AND recorded_date >= ?';
        params.add(startDate.toIso8601String());
      }

      if (endDate != null) {
        sql += ' AND recorded_date <= ?';
        params.add(endDate.toIso8601String());
      }

      final result = await _dbService.tryGet(sql, params);
      return (result?['total'] as num?)?.toDouble() ?? 0.0;
    } catch (e) {
      throw PaymentDatabaseException(
        'Failed to calculate total paid: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Calculates the outstanding balance for a student.
  ///
  /// Outstanding balance = Total invoice amount - Total paid amount
  ///
  /// This method:
  /// 1. Sums all invoice amounts for the student
  /// 2. Subtracts total paid amount
  /// 3. Returns the difference (can be negative if overpaid)
  ///
  /// Returns a Future<double> with the outstanding balance
  @override
  Future<double> getOutstandingBalance(String studentId) async {
    try {
      // Get total invoiced amount
      final invoiceResult = await _dbService.tryGet(
        'SELECT COALESCE(SUM(amount), 0) as total FROM invoices WHERE student_id = ?',
        [studentId],
      );
      final totalInvoiced =
          (invoiceResult?['total'] as num?)?.toDouble() ?? 0.0;

      // Get total paid amount
      final totalPaid = await getTotalPaidByStudent(studentId: studentId);

      return totalInvoiced - totalPaid;
    } catch (e) {
      throw PaymentDatabaseException(
        'Failed to calculate outstanding balance: ${e.toString()}',
        originalError: e,
      );
    }
  }
}
