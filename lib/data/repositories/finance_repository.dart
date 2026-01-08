import 'package:isar/isar.dart';
import '../models/finance.dart';

class FinanceRepository {
  final Isar _isar;

  FinanceRepository(this._isar);

  /// Get total outstanding amount (sum of unpaid invoice balances) for a school
  /// Note: This is a simplified calculation. Real accounting might require summing Ledger entries.
  /// For now, we sum 'pending' and 'overdue' invoices.
  Future<int> getTotalOutstanding(String schoolId) async {
    final invoices = await _isar.invoices
        .filter()
        .schoolIdEqualTo(schoolId)
        .statusEqualTo('pending')
        .or()
        .statusEqualTo('overdue')
        .findAll();

    // Since Invoice model doesn't store 'balance', we might need to calculate it from ledger or invoice items.
    // However, the Invoice model has 'status'.
    // Let's assume for this simple dashboard, we query the *Ledger* for debit balances,
    // OR we sum up Invoice totals (which requires fetching InvoiceItems).
    // Given the complexity, let's look at LedgerEntry which handles accounting.
    // Total Owing = Sum of DEBIT entries - Sum of CREDIT entries (for student accounts).

    // Simpler approach for now: Sum of all invoices not paid.
    // But we need the amount. Invoice doesn't have 'amount' field directly, InvoiceItems do.
    // This is expensive to calculate on the fly.
    // Let's check LedgerEntry.
    // LedgerEntry has 'amount' and 'type' (DEBIT/CREDIT).
    // Total Outstanding = (Total DEBITs) - (Total CREDITs) across all students.

    final debitTotal = await _isar.ledgerEntries
        .filter()
        .schoolIdEqualTo(schoolId)
        .typeEqualTo('DEBIT')
        .amountProperty()
        .sum();

    final creditTotal = await _isar.ledgerEntries
        .filter()
        .schoolIdEqualTo(schoolId)
        .typeEqualTo('CREDIT')
        .amountProperty()
        .sum();

    return debitTotal - creditTotal;
  }

  /// Get total cash collected TODAY (Payments received today)
  Future<int> getTotalCashToday(String schoolId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return await _isar.payments
        .filter()
        .schoolIdEqualTo(schoolId)
        .receivedAtBetween(startOfDay, endOfDay)
        .amountProperty()
        .sum();
  }

  /// Get total cash collected ALL TIME
  Future<int> getTotalCashCollected(String schoolId) async {
    return await _isar.payments
        .filter()
        .schoolIdEqualTo(schoolId)
        .amountProperty()
        .sum();
  }

  /// Get count of pending invoices
  Future<int> getPendingInvoicesCount(String schoolId) async {
    return await _isar.invoices
        .filter()
        .schoolIdEqualTo(schoolId)
        .statusEqualTo('pending')
        .count();
  }

  /// Get recent activity (mixed Payments and Invoices)
  /// Returns a list of maps or a custom object.
  /// Since we need to return specific fields for the UI, let's return a list of dynamic for now
  /// or we can rely on the caller to fetch separate lists.
  /// But 'Recent Activity' usually interleaves them.
  Future<List<dynamic>> getRecentActivity(String schoolId, {int limit = 10}) async {
    // Fetch recent payments
    final payments = await _isar.payments
        .filter()
        .schoolIdEqualTo(schoolId)
        .sortByReceivedAtDesc()
        .limit(limit)
        .findAll();

    // Fetch recent invoices (using createdAt or dueDate?)
    // Usually 'Activity' implies creation.
    final invoices = await _isar.invoices
        .filter()
        .schoolIdEqualTo(schoolId)
        .sortByCreatedAtDesc()
        .limit(limit)
        .findAll();

    // Combine and sort
    final combined = <dynamic>[...payments, ...invoices];
    combined.sort((a, b) {
      DateTime timeA;
      if (a is Payment) timeA = a.receivedAt;
      else if (a is Invoice) timeA = a.createdAt ?? DateTime(2000);
      else timeA = DateTime(2000);

      DateTime timeB;
      if (b is Payment) timeB = b.receivedAt;
      else if (b is Invoice) timeB = b.createdAt ?? DateTime(2000);
      else timeB = DateTime(2000);

      return timeB.compareTo(timeA); // Descending
    });

    return combined.take(limit).toList();
  }

  /// Get full ledger entries for Finance Screen
  /// Returns LedgerEntry objects which are the source of truth for the finance log.
  Future<List<LedgerEntry>> getLedgerEntries(String schoolId) async {
    return await _isar.ledgerEntries
        .filter()
        .schoolIdEqualTo(schoolId)
        .sortByOccurredAtDesc()
        .findAll();
  }
}
