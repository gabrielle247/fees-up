import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import 'core_providers.dart';
import 'school_providers.dart';
import 'student_providers.dart';

/// Provides total count of enrolled learners
final learnerCountProvider = FutureProvider<int>((ref) async {
  final currentSchool = await ref.watch(currentSchoolProvider.future);
  if (currentSchool == null) return 0;

  final repo = ref.watch(studentRepositoryProvider);
  return repo.countActive(currentSchool.id);
});

/// Provides total outstanding fees (owes)
/// Calculated as Sum(Ledger DEBITs) - Sum(Ledger CREDITs)
final totalOutstandingProvider = FutureProvider<int>((ref) async {
  final db = ref.watch(driftDatabaseProvider);
  final school = await ref.watch(currentSchoolProvider.future);
  if (school == null) return 0;

  final debits = await (db.selectOnly(db.ledgerEntries)
        ..addColumns([db.ledgerEntries.amount.sum()])
        ..where(db.ledgerEntries.schoolId.equals(school.id) &
            db.ledgerEntries.type.equals('DEBIT')))
      .getSingle();

  final credits = await (db.selectOnly(db.ledgerEntries)
        ..addColumns([db.ledgerEntries.amount.sum()])
        ..where(db.ledgerEntries.schoolId.equals(school.id) &
            db.ledgerEntries.type.equals('CREDIT')))
      .getSingle();

  final totalDebits = debits.read(db.ledgerEntries.amount.sum()) ?? 0;
  final totalCredits = credits.read(db.ledgerEntries.amount.sum()) ?? 0;

  return totalDebits - totalCredits;
});

/// Provides total collected cash (payments received today)
final totalCashTodayProvider = FutureProvider<int>((ref) async {
  final db = ref.watch(driftDatabaseProvider);
  final school = await ref.watch(currentSchoolProvider.future);
  if (school == null) return 0;

  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);
  final endOfDay = startOfDay.add(const Duration(days: 1));

  final result = await (db.selectOnly(db.payments)
        ..addColumns([db.payments.amount.sum()])
        ..where(db.payments.schoolId.equals(school.id) &
            db.payments.receivedAt.isBiggerOrEqualValue(startOfDay) &
            db.payments.receivedAt.isSmallerThanValue(endOfDay)))
      .getSingle();

  return result.read(db.payments.amount.sum()) ?? 0;
});

/// Provides revenue growth percentage (This Month vs Last Month)
final revenueGrowthProvider = FutureProvider<double>((ref) async {
  final db = ref.watch(driftDatabaseProvider);
  final school = await ref.watch(currentSchoolProvider.future);
  if (school == null) return 0.0;

  final now = DateTime.now();
  final startOfThisMonth = DateTime(now.year, now.month, 1);
  final startOfNextMonth = DateTime(now.year, now.month + 1, 1);
  final startOfLastMonth = DateTime(now.year, now.month - 1, 1);

  final thisMonth = await (db.selectOnly(db.payments)
        ..addColumns([db.payments.amount.sum()])
        ..where(db.payments.schoolId.equals(school.id) &
            db.payments.receivedAt.isBiggerOrEqualValue(startOfThisMonth) &
            db.payments.receivedAt.isSmallerThanValue(startOfNextMonth)))
      .getSingle();

  final lastMonth = await (db.selectOnly(db.payments)
        ..addColumns([db.payments.amount.sum()])
        ..where(db.payments.schoolId.equals(school.id) &
            db.payments.receivedAt.isBiggerOrEqualValue(startOfLastMonth) &
            db.payments.receivedAt.isSmallerThanValue(startOfThisMonth)))
      .getSingle();

  final thisMonthRevenue = thisMonth.read(db.payments.amount.sum()) ?? 0;
  final lastMonthRevenue = lastMonth.read(db.payments.amount.sum()) ?? 0;

  if (lastMonthRevenue == 0) {
    return thisMonthRevenue > 0 ? 100.0 : 0.0;
  }

  return ((thisMonthRevenue - lastMonthRevenue) / lastMonthRevenue) * 100;
});

/// Provides total collected cash (all time)
final totalCashCollectedProvider = FutureProvider<int>((ref) async {
  final db = ref.watch(driftDatabaseProvider);
  final school = await ref.watch(currentSchoolProvider.future);
  if (school == null) return 0;

  final result = await (db.selectOnly(db.payments)
        ..addColumns([db.payments.amount.sum()])
        ..where(db.payments.schoolId.equals(school.id)))
      .getSingle();

  return result.read(db.payments.amount.sum()) ?? 0;
});

/// Provides student balance (DEBIT - CREDIT from ledger)
final studentBalanceProvider =
    FutureProvider.family<int, String>((ref, studentId) async {
  final db = ref.watch(driftDatabaseProvider);

  final debits = await (db.selectOnly(db.ledgerEntries)
        ..addColumns([db.ledgerEntries.amount.sum()])
        ..where(db.ledgerEntries.studentId.equals(studentId) &
            db.ledgerEntries.type.equals('DEBIT')))
      .getSingle();

  final credits = await (db.selectOnly(db.ledgerEntries)
        ..addColumns([db.ledgerEntries.amount.sum()])
        ..where(db.ledgerEntries.studentId.equals(studentId) &
            db.ledgerEntries.type.equals('CREDIT')))
      .getSingle();

  final totalDebits = debits.read(db.ledgerEntries.amount.sum()) ?? 0;
  final totalCredits = credits.read(db.ledgerEntries.amount.sum()) ?? 0;

  return totalDebits - totalCredits;
});

/// Provides recent activity feed (payments + invoices)
final recentActivityProvider =
    FutureProvider<List<ActivityFeedItem>>((ref) async {
  try {
    final db = ref.watch(driftDatabaseProvider);
    final currentSchool = await ref.watch(currentSchoolProvider.future);
    if (currentSchool == null) return [];

    // Fetch recent payments
    final payments = await (db.select(db.payments)
          ..where((p) => p.schoolId.equals(currentSchool.id))
          ..orderBy([(p) => OrderingTerm.desc(p.receivedAt)])
          ..limit(5))
        .get();

    // Fetch recent invoices
    final invoices = await (db.select(db.invoices)
          ..where((i) => i.schoolId.equals(currentSchool.id))
          ..orderBy([(i) => OrderingTerm.desc(i.createdAt)])
          ..limit(5))
        .get();

    // Helper to fetch student name safely
    Future<String> getStudentName(String studentId) async {
      final student = await (db.select(db.students)
            ..where((s) => s.id.equals(studentId)))
          .getSingleOrNull();
      if (student == null) return 'Unknown Student';
      return '${student.firstName} ${student.lastName}'.trim();
    }

    // Convert Payments to Items
    final paymentItems = await Future.wait(payments.map((p) async {
      try {
        final name = await getStudentName(p.studentId);
        return ActivityFeedItem(
          type: 'payment',
          title: 'Payment from $name',
          amount: p.amount,
          timestamp: p.receivedAt,
        );
      } catch (e) {
        return null;
      }
    }));

    // Convert Invoices to Items
    final invoiceItems = await Future.wait(invoices.map((inv) async {
      try {
        final name = await getStudentName(inv.studentId);

        final totalAmountResult = await (db.selectOnly(db.invoiceItems)
              ..addColumns([db.invoiceItems.amount.sum()])
              ..where(db.invoiceItems.invoiceId.equals(inv.id)))
            .getSingle();

        final totalAmount =
            totalAmountResult.read(db.invoiceItems.amount.sum()) ?? 0;

        return ActivityFeedItem(
          type: 'invoice',
          title: 'Invoice for $name',
          amount: totalAmount,
          timestamp: inv.createdAt ?? DateTime.now(),
        );
      } catch (e) {
        return null;
      }
    }));

    // Filter nulls, combine, and sort
    final allItems = [...paymentItems, ...invoiceItems]
        .whereType<ActivityFeedItem>()
        .toList();

    allItems.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return allItems.take(10).toList();
  } catch (e) {
    return [];
  }
});

/// Provides pending invoices count
final pendingInvoicesCountProvider = FutureProvider<int>((ref) async {
  final db = ref.watch(driftDatabaseProvider);
  final currentSchool = await ref.watch(currentSchoolProvider.future);
  if (currentSchool == null) return 0;

  final count = await (db.selectOnly(db.invoices, distinct: true)
        ..addColumns([db.invoices.id.count()])
        ..where(db.invoices.schoolId.equals(currentSchool.id) &
            db.invoices.status.equals('PAID').not()))
      .getSingle();

  return count.read(db.invoices.id.count()) ?? 0;
});

/// Provides learners by form/class
final learnersByFormProvider = FutureProvider<Map<String, int>>((ref) async {
  final db = ref.watch(driftDatabaseProvider);
  final currentSchool = await ref.watch(currentSchoolProvider.future);
  if (currentSchool == null) return {};

  final enrollments = await (db.select(db.enrollments)
        ..where((e) => e.schoolId.equals(currentSchool.id))
        ..where((e) => e.isActive.equals(true)))
      .get();

  final Map<String, int> distribution = {};

  for (var enrollment in enrollments) {
    final grade = enrollment.gradeLevel;
    distribution[grade] = (distribution[grade] ?? 0) + 1;
  }

  return distribution;
});

/// Activity feed item model
class ActivityFeedItem {
  final String type; // 'payment', 'invoice', 'enrollment'
  final String title;
  final int? amount; // in cents
  final DateTime timestamp;

  ActivityFeedItem({
    required this.type,
    required this.title,
    this.amount,
    required this.timestamp,
  });

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).floor()}w ago';
    }
  }

  String get formattedAmount {
    if (amount == null) return '';
    final dollars = amount! / 100;
    return '\$$dollars';
  }
}
