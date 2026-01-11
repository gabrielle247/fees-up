import 'package:fees_up/data/services/invoice_service.dart';
import 'package:fees_up/data/services/payment_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// -----------------------------------------------------------------------------
// IMPORTS
// -----------------------------------------------------------------------------
import '../constants/init_backend.dart';
import '../repositories/auth_repository.dart';
import '../repositories/school_repository.dart';
import '../repositories/student_repository.dart';
import '../repositories/finance_repository.dart';
import '../repositories/payment_repository.dart';

// -----------------------------------------------------------------------------
// 1. DATABASE PROVIDER
// -----------------------------------------------------------------------------
// Provides the initialized PowerSync database instance
final dbProvider = Provider((ref) {
  return BackendInitializer().database;
});

// -----------------------------------------------------------------------------
// 2. REPOSITORY PROVIDERS
// -----------------------------------------------------------------------------
final authRepositoryProvider = Provider((ref) {
  return AuthRepository(ref.watch(dbProvider));
});

final schoolRepositoryProvider = Provider((ref) {
  return SchoolRepository(ref.watch(dbProvider));
});

final studentRepositoryProvider = Provider((ref) {
  return StudentRepository(ref.watch(dbProvider));
});

final financeRepositoryProvider = Provider((ref) {
  return FinanceRepository(ref.watch(dbProvider));
});

final paymentRepositoryProvider = Provider((ref) {
  return PaymentRepository(ref.watch(dbProvider));
});

// -----------------------------------------------------------------------------
// 3. SERVICE PROVIDERS (Business Logic)
// -----------------------------------------------------------------------------
final paymentServiceProvider = Provider((ref) {
  return PaymentService(
    ref.watch(paymentRepositoryProvider),
    ref.watch(financeRepositoryProvider),
  );
});

final invoiceServiceProvider = Provider((ref) {
  return InvoiceService(
    ref.watch(studentRepositoryProvider),
    ref.watch(financeRepositoryProvider),
  );
});