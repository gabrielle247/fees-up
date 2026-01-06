import 'package:fees_up/data/models/transaction_stats.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database_service.dart';

// ========== TRANSACTIONS PROVIDERS ==========
// All providers use local database streams for real-time auto-updates
// Data is isolated per schoolId - zero hardcoding

/// Stream all payments for a school (real-time updates)
final paymentsProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>((ref, schoolId) {
  final db = DatabaseService();
  return db.db.watch(
    'SELECT * FROM payments WHERE school_id = ? ORDER BY date_paid DESC, created_at DESC',
    parameters: [schoolId],
  );
});

/// Stream all expenses for a school (real-time updates)
final expensesProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>((ref, schoolId) {
  final db = DatabaseService();
  return db.db.watch(
    'SELECT * FROM expenses WHERE school_id = ? ORDER BY incurred_at DESC, created_at DESC',
    parameters: [schoolId],
  );
});

/// Stream all donations for a school (real-time updates)
final donationsProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>((ref, schoolId) {
  final db = DatabaseService();
  return db.db.watch(
    'SELECT * FROM campaign_donations WHERE school_id = ? ORDER BY date_received DESC',
    parameters: [schoolId],
  );
});

/// Stream combined transactions (payments + expenses + donations)
/// Returns unified list with type field for filtering
final allTransactionsProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>(
        (ref, schoolId) async* {
  final db = DatabaseService();

  // Use PowerSync watch for real-time updates from local DB
  // This single query combines all transaction types with UNION ALL
  final stream = db.db.watch(
    '''
    SELECT id, school_id, student_id, amount, date_paid as transaction_date,
           category, method, payer_name as entity_name, created_at,
           'payment' as transaction_type
    FROM payments WHERE school_id = ?
    UNION ALL
    SELECT id, school_id, NULL as student_id, -amount as amount,
           incurred_at as transaction_date, category, 'Expense' as method,
           recipient as entity_name, created_at, 'expense' as transaction_type
    FROM expenses WHERE school_id = ?
    UNION ALL
    SELECT id, school_id, student_id, amount, date_received as transaction_date,
           'Donation' as category, payment_method as method, donor_name as entity_name,
           created_at, 'donation' as transaction_type
    FROM campaign_donations WHERE school_id = ?
    ORDER BY transaction_date DESC, created_at DESC
    ''',
    parameters: [schoolId, schoolId, schoolId],
  );

  await for (final transactions in stream) {
    yield transactions;
  }
});

/// Stream payment allocations for a specific payment
final paymentAllocationsProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>((ref, paymentId) {
  final db = DatabaseService();
  return db.db.watch(
    'SELECT * FROM payment_allocations WHERE payment_id = ? ORDER BY created_at DESC',
    parameters: [paymentId],
  );
});

/// Stream payments for a specific student
final studentPaymentsProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>((ref, studentId) {
  final db = DatabaseService();
  return db.db.watch(
    'SELECT * FROM payments WHERE student_id = ? ORDER BY date_paid DESC',
    parameters: [studentId],
  );
});

/// Stream transaction statistics for a school
final transactionStatsProvider =
    StreamProvider.family<TransactionStats, String>((ref, schoolId) async* {
  final db = DatabaseService();

  // Use PowerSync watch to get real-time stats from local DB
  final stream = db.db.watch(
    '''
    SELECT
      COALESCE(SUM(CASE WHEN p.amount IS NOT NULL THEN p.amount ELSE 0 END), 0) as total_income,
      COALESCE(SUM(CASE WHEN e.amount IS NOT NULL THEN e.amount ELSE 0 END), 0) as total_expenses,
      COALESCE(SUM(CASE WHEN d.amount IS NOT NULL THEN d.amount ELSE 0 END), 0) as total_donations,
      COALESCE(COUNT(DISTINCT p.id), 0) as payments_count,
      COALESCE(COUNT(DISTINCT e.id), 0) as expenses_count,
      COALESCE(COUNT(DISTINCT d.id), 0) as donations_count,
      (SELECT COUNT(*) FROM bills WHERE school_id = ? AND is_paid = 0) as pending_count,
      (SELECT COALESCE(SUM(total_amount - paid_amount), 0) FROM bills WHERE school_id = ? AND is_paid = 0) as pending_amount
    FROM
      (SELECT ? as school_id) s
      LEFT JOIN payments p ON p.school_id = s.school_id
      LEFT JOIN expenses e ON e.school_id = s.school_id
      LEFT JOIN campaign_donations d ON d.school_id = s.school_id
    ''',
    parameters: [schoolId, schoolId, schoolId],
  );

  await for (final result in stream) {
    if (result.isNotEmpty) {
      final row = result.first;
      final totalIncome = (row['total_income'] as num?)?.toDouble() ?? 0.0;
      final totalExpenses = (row['total_expenses'] as num?)?.toDouble() ?? 0.0;
      final totalDonations =
          (row['total_donations'] as num?)?.toDouble() ?? 0.0;

      yield TransactionStats(
        totalIncome: totalIncome,
        totalExpenses: totalExpenses,
        totalDonations: totalDonations,
        pendingCount: (row['pending_count'] as num?)?.toInt() ?? 0,
        pendingAmount: (row['pending_amount'] as num?)?.toDouble() ?? 0.0,
        netIncome: totalIncome - totalExpenses,
        paymentsCount: (row['payments_count'] as num?)?.toInt() ?? 0,
        expensesCount: (row['expenses_count'] as num?)?.toInt() ?? 0,
        donationsCount: (row['donations_count'] as num?)?.toInt() ?? 0,
      );
    }
  }
});
