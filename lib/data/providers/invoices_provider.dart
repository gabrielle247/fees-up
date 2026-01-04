import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database_service.dart';

/// 📄 INVOICES PROVIDER
/// All invoice/bill data flows through here. NO hardcoding.
/// Everything reads from local SQLite via DatabaseService (PowerSync).

// ============================================================
// PROVIDERS
// ============================================================

/// Stream of all bills/invoices for a school (Real-time updates via PowerSync)
final invoicesProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>(
  (ref, schoolId) {
    final db = DatabaseService();
    return db.db.watch(
      'SELECT * FROM bills WHERE school_id = ? ORDER BY created_at DESC',
      parameters: [schoolId],
    );
  },
);

/// Get invoices for a specific student
final studentInvoicesProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>(
  (ref, studentId) {
    final db = DatabaseService();
    return db.db.watch(
      'SELECT * FROM bills WHERE student_id = ? ORDER BY created_at DESC',
      parameters: [studentId],
    );
  },
);

/// Get a single invoice/bill by ID
final invoiceByIdProvider =
    FutureProvider.family<Map<String, dynamic>?, String>(
  (ref, invoiceId) async {
    final db = DatabaseService();
    return await db.getById('bills', invoiceId);
  },
);

/// Invoice stats (total billed, collected, pending, overdue)
final invoiceStatsProvider = Provider.family<InvoiceStats, String>(
  (ref, schoolId) {
    final invoicesAsync = ref.watch(invoicesProvider(schoolId));

    return invoicesAsync.when(
      data: (invoices) {
        final totalBilled = invoices.fold<double>(
          0,
          (sum, inv) => sum + ((inv['total_amount'] as num?)?.toDouble() ?? 0),
        );

        final totalCollected = invoices.fold<double>(
          0,
          (sum, inv) => sum + ((inv['paid_amount'] as num?)?.toDouble() ?? 0),
        );

        final now = DateTime.now();
        final overdueInvoices = invoices.where((inv) {
          if (inv['billing_cycle_end'] == null) return false;
          final dueDate =
              DateTime.tryParse(inv['billing_cycle_end'].toString());
          final isPaid = (inv['is_paid'] as int?) == 1;
          return !isPaid && dueDate != null && dueDate.isBefore(now);
        }).toList();

        final overdueAmount = overdueInvoices.fold<double>(
          0,
          (sum, inv) {
            final total = (inv['total_amount'] as num?)?.toDouble() ?? 0;
            final paid = (inv['paid_amount'] as num?)?.toDouble() ?? 0;
            return sum + (total - paid);
          },
        );

        final paidCount =
            invoices.where((inv) => (inv['is_paid'] as int?) == 1).length;
        final collectionRate =
            totalBilled > 0 ? (totalCollected / totalBilled * 100) : 0.0;

        return InvoiceStats(
          totalInvoices: invoices.length,
          totalBilled: totalBilled,
          totalCollected: totalCollected,
          pendingAmount: totalBilled - totalCollected,
          overdueAmount: overdueAmount,
          overdueCount: overdueInvoices.length,
          paidCount: paidCount,
          collectionRate: collectionRate,
        );
      },
      loading: () => InvoiceStats.empty(),
      error: (_, __) => InvoiceStats.empty(),
    );
  },
);

/// Get outstanding (unpaid) bills for a student
final outstandingBillsProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>(
  (ref, studentId) {
    final db = DatabaseService();
    return db.db.watch(
      'SELECT * FROM bills WHERE student_id = ? AND is_paid = 0 ORDER BY billing_cycle_end ASC',
      parameters: [studentId],
    );
  },
);

/// Get payment allocations for a specific bill
final billAllocationsProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>(
  (ref, billId) {
    final db = DatabaseService();
    return db.db.watch(
      'SELECT * FROM payment_allocations WHERE bill_id = ? ORDER BY created_at DESC',
      parameters: [billId],
    );
  },
);

// ============================================================
// DATA MODELS
// ============================================================

class InvoiceStats {
  final int totalInvoices;
  final double totalBilled;
  final double totalCollected;
  final double pendingAmount;
  final double overdueAmount;
  final int overdueCount;
  final int paidCount;
  final double collectionRate;

  InvoiceStats({
    required this.totalInvoices,
    required this.totalBilled,
    required this.totalCollected,
    required this.pendingAmount,
    required this.overdueAmount,
    required this.overdueCount,
    required this.paidCount,
    required this.collectionRate,
  });

  factory InvoiceStats.empty() => InvoiceStats(
        totalInvoices: 0,
        totalBilled: 0,
        totalCollected: 0,
        pendingAmount: 0,
        overdueAmount: 0,
        overdueCount: 0,
        paidCount: 0,
        collectionRate: 0,
      );
}
