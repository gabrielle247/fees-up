import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/payment_repository.dart';
import '../repositories/payment_repository_impl.dart';
import '../services/database_service.dart';

/// ============================================================================
/// CORE REPOSITORY PROVIDER
/// ============================================================================

/// Provides singleton access to the PaymentRepository.
///
/// This provider:
/// - Creates a single PaymentRepositoryImpl instance (singleton pattern)
/// - Automatically passes the DatabaseService to the repository
/// - Allows all widgets to access payment operations consistently
///
/// Usage in widgets:
/// ```dart
/// final paymentRepo = ref.watch(paymentRepositoryProvider);
/// final payment = await paymentRepo.recordPayment(...);
/// ```
///
/// Usage with other providers:
/// ```dart
/// final futurePayment = FutureProvider<Payment>((ref) async {
///   final repo = ref.watch(paymentRepositoryProvider);
///   return repo.recordPayment(...);
/// });
/// ```
final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepositoryImpl(
    dbService: DatabaseService(),
  );
});

/// ============================================================================
/// STREAM PROVIDER: PAYMENT HISTORY
/// ============================================================================

/// Real-time payment history for a specific student.
///
/// This is a family provider that watches payment records for a particular
/// student_id. It automatically re-emits whenever payments are added, updated,
/// or deleted.
///
/// State Flow:
/// - AsyncValue.loading: Initially fetching payment history
/// - AsyncValue.data: Successfully retrieved List<Payment> (may be empty)
/// - AsyncValue.error: Database error occurred
///
/// Usage in Widgets:
/// ```dart
/// ConsumerWidget {
///   Widget build(context, ref) {
///     final paymentsAsync = ref.watch(paymentHistoryProvider(studentId));
///
///     return paymentsAsync.when(
///       data: (payments) => PaymentListView(payments: payments),
///       loading: () => const LoadingSpinner(),
///       error: (error, stack) => ErrorBanner(error: error),
///     );
///   }
/// }
/// ```
///
/// Key Benefits Over Manual Subscription:
/// - ✅ Automatic stream cleanup (no leak risk)
/// - ✅ Automatic error handling
/// - ✅ Automatic rebuild on data changes
/// - ✅ Automatic retry on error
/// - ✅ Integrates with Riverpod's caching/invalidation
///
/// Invalidation Example:
/// ```dart
/// // After recording a payment, invalidate the stream
/// ref.invalidate(paymentHistoryProvider(studentId));
/// ```
final paymentHistoryProvider =
    StreamProvider.family<List<Payment>, String>((ref, studentId) {
  final repository = ref.watch(paymentRepositoryProvider);
  return repository.watchPaymentsForStudent(studentId);
});

/// ============================================================================
/// COMPUTED PROVIDER: TOTAL PAID BY STUDENT
/// ============================================================================

/// Calculates the total amount paid by a student (excluding deleted payments).
///
/// This provider:
/// - Depends on paymentHistoryProvider (will recompute when history changes)
/// - Sums all non-deleted payments
/// - Returns 0.0 if no payments
///
/// Usage:
/// ```dart
/// final totalPaid = ref.watch(totalPaidByStudentProvider(studentId));
/// Text('Total Paid: \$${totalPaid.toStringAsFixed(2)}')
/// ```
///
/// NOTE: This uses the repository method for efficiency over mapping the stream.
/// If you need it to update in real-time, consider an AsyncProvider instead:
final totalPaidByStudentProvider =
    FutureProvider.family<double, String>((ref, studentId) async {
  final repository = ref.watch(paymentRepositoryProvider);
  return repository.getTotalPaidByStudent(studentId: studentId);
});

/// ============================================================================
/// COMPUTED PROVIDER: OUTSTANDING BALANCE
/// ============================================================================

/// Calculates the outstanding balance for a student.
///
/// Outstanding balance = Total Invoiced - Total Paid
///
/// This provider:
/// - Queries outstanding amount (may be negative if student overpaid)
/// - Updates when payments or invoices change
/// - Returns 0.0 if no outstanding balance
///
/// Usage:
/// ```dart
/// final balanceAsync = ref.watch(outstandingBalanceProvider(studentId));
/// balanceAsync.when(
///   data: (balance) => StudentCard(balance: balance),
///   loading: () => Skeleton(),
///   error: (err, stack) => ErrorText(err),
/// );
/// ```
final outstandingBalanceProvider =
    FutureProvider.family<double, String>((ref, studentId) async {
  final repository = ref.watch(paymentRepositoryProvider);
  return repository.getOutstandingBalance(studentId);
});

/// ============================================================================
/// CONVENIENCE PROVIDERS FOR COMMON OPERATIONS
/// ============================================================================

/// Family provider for recording a new payment.
///
/// Usage:
/// ```dart
/// final recordPaymentAsync = ref.watch(
///   recordPaymentProvider((
///     studentId: 'student-123',
///     amount: 100.0,
///     method: 'cash',
///     invoiceId: 'invoice-456',
///   ))
/// );
/// ```
final recordPaymentProvider =
    FutureProvider.family<Payment, _RecordPaymentParams>((ref, params) async {
  final repository = ref.watch(paymentRepositoryProvider);
  return repository.recordPayment(
    studentId: params.studentId,
    amount: params.amount,
    method: params.method,
    invoiceId: params.invoiceId,
    description: params.description,
  );
});

/// Family provider for allocating a payment.
final allocatePaymentProvider =
    FutureProvider.family<void, _AllocatePaymentParams>((ref, params) async {
  final repository = ref.watch(paymentRepositoryProvider);
  await repository.allocatePayment(
    paymentId: params.paymentId,
    allocations: params.allocations,
  );
});

/// Family provider for deleting a payment.
final deletePaymentProvider =
    FutureProvider.family<void, String>((ref, paymentId) async {
  final repository = ref.watch(paymentRepositoryProvider);
  await repository.deletePayment(paymentId);
});

/// ============================================================================
/// PARAMETER CLASSES FOR FAMILY PROVIDERS
/// ============================================================================

/// Parameters for the recordPaymentProvider family.
class _RecordPaymentParams {
  final String studentId;
  final double amount;
  final String method;
  final String invoiceId;
  final String? description;

  _RecordPaymentParams({
    required this.studentId,
    required this.amount,
    required this.method,
    required this.invoiceId,
    required this.description,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _RecordPaymentParams &&
          runtimeType == other.runtimeType &&
          studentId == other.studentId &&
          amount == other.amount &&
          method == other.method &&
          invoiceId == other.invoiceId &&
          description == other.description;

  @override
  int get hashCode =>
      studentId.hashCode ^
      amount.hashCode ^
      method.hashCode ^
      invoiceId.hashCode ^
      (description?.hashCode ?? 0);
}

/// Parameters for the allocatePaymentProvider family.
class _AllocatePaymentParams {
  final String paymentId;
  final Map<String, double> allocations;

  _AllocatePaymentParams({
    required this.paymentId,
    required this.allocations,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _AllocatePaymentParams &&
          runtimeType == other.runtimeType &&
          paymentId == other.paymentId &&
          allocations == other.allocations;

  @override
  int get hashCode => paymentId.hashCode ^ allocations.hashCode;
}
