import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../services/isar_service.dart';
import '../models/finance.dart';
import '../models/people.dart';
import '../models/saas.dart';
import '../repositories/student_repository.dart';
import 'core_providers.dart';
import 'school_providers.dart';
import 'student_providers.dart';

/// Provides total count of enrolled learners
final learnerCountProvider = FutureProvider<int>((ref) async {
  final currentSchool = await ref.watch(currentSchoolProvider.future);
  if (currentSchool == null) return 0;

  final repo = await ref.watch(studentRepositoryProvider);
  return repo.countActive(currentSchool.id);
});

/// Provides total outstanding fees (owes)
/// Calculated as Sum(Ledger DEBITs) - Sum(Ledger CREDITs)
final totalOutstandingProvider = FutureProvider<int>((ref) async {
  final isar = await ref.watch(isarInstanceProvider);
  final currentSchool = await ref.watch(currentSchoolProvider.future);
  if (currentSchool == null) return 0;

  final totalDebits = await isar.ledgerEntrys
      .filter()
      .schoolIdEqualTo(currentSchool.id)
      .typeEqualTo('DEBIT')
      .amountProperty()
      .sum();

  final totalCredits = await isar.ledgerEntrys
      .filter()
      .schoolIdEqualTo(currentSchool.id)
      .typeEqualTo('CREDIT')
      .amountProperty()
      .sum();

  return totalDebits - totalCredits;
});

/// Provides total collected cash (payments received today)
final totalCashTodayProvider = FutureProvider<int>((ref) async {
  final isar = await ref.watch(isarInstanceProvider);
  final currentSchool = await ref.watch(currentSchoolProvider.future);
  if (currentSchool == null) return 0;

  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);
  final endOfDay = startOfDay.add(const Duration(days: 1));

  return await isar.payments
      .filter()
      .schoolIdEqualTo(currentSchool.id)
      .receivedAtBetween(startOfDay, endOfDay)
      .amountProperty()
      .sum();
});

/// Provides revenue growth percentage (This Month vs Last Month)
final revenueGrowthProvider = FutureProvider<double>((ref) async {
  final isar = await ref.watch(isarInstanceProvider);
  final currentSchool = await ref.watch(currentSchoolProvider.future);
  if (currentSchool == null) return 0.0;

  final now = DateTime.now();
  final startOfThisMonth = DateTime(now.year, now.month, 1);
  final startOfNextMonth = DateTime(now.year, now.month + 1, 1);

  final startOfLastMonth = DateTime(now.year, now.month - 1, 1);
  final endOfLastMonth = startOfThisMonth; // Last month ends when this month starts

  final thisMonthRevenue = await isar.payments
      .filter()
      .schoolIdEqualTo(currentSchool.id)
      .receivedAtBetween(startOfThisMonth, startOfNextMonth)
      .amountProperty()
      .sum();

  final lastMonthRevenue = await isar.payments
      .filter()
      .schoolIdEqualTo(currentSchool.id)
      .receivedAtBetween(startOfLastMonth, endOfLastMonth)
      .amountProperty()
      .sum();

  if (lastMonthRevenue == 0) {
    return thisMonthRevenue > 0 ? 100.0 : 0.0;
  }

  return ((thisMonthRevenue - lastMonthRevenue) / lastMonthRevenue) * 100;
});


/// Provides total collected cash (all time)
final totalCashCollectedProvider = FutureProvider<int>((ref) async {
  final isar = await ref.watch(isarInstanceProvider);
  final currentSchool = await ref.watch(currentSchoolProvider.future);
  if (currentSchool == null) return 0;

  return await isar.payments
      .filter()
      .schoolIdEqualTo(currentSchool.id)
      .amountProperty()
      .sum();
});

/// Provides recent activity feed (payments + invoices)
final recentActivityProvider = FutureProvider<List<ActivityFeedItem>>((ref) async {
  try {
    final isar = await ref.watch(isarInstanceProvider);
    final currentSchool = await ref.watch(currentSchoolProvider.future);
    if (currentSchool == null) return [];

    // Fetch recent payments
    final payments = await isar.payments
        .filter()
        .schoolIdEqualTo(currentSchool.id)
        .sortByReceivedAtDesc()
        .limit(5)
        .findAll();

    // Fetch recent invoices
    final invoices = await isar.invoices
        .filter()
        .schoolIdEqualTo(currentSchool.id)
        .sortByCreatedAtDesc()
        .limit(5)
        .findAll();

    // Helper to fetch student name safely
    Future<String> getStudentName(String studentId) async {
      final student = await isar.students
          .filter()
          .idEqualTo(studentId)
          .findFirst();
      return student?.fullName ?? 'Unknown Student';
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
        // Skip malformed items
        return null;
      }
    }));

    // Convert Invoices to Items
    final invoiceItems = await Future.wait(invoices.map((inv) async {
      try {
        final name = await getStudentName(inv.studentId);

        final totalAmount = await isar.invoiceItems
            .filter()
            .invoiceIdEqualTo(inv.id)
            .amountProperty()
            .sum();

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
    // Return empty list on global failure instead of crashing
    return [];
  }
});

/// Provides pending invoices count
final pendingInvoicesCountProvider = FutureProvider<int>((ref) async {
  final isar = await ref.watch(isarInstanceProvider);
  final currentSchool = await ref.watch(currentSchoolProvider.future);
  if (currentSchool == null) return 0;

  return await isar.invoices
      .filter()
      .schoolIdEqualTo(currentSchool.id)
      .not()
      .statusEqualTo('PAID')
      .count();
});

/// Provides learners by form/class
final learnersByFormProvider = FutureProvider<Map<String, int>>((ref) async {
  final isar = await ref.watch(isarInstanceProvider);
  final currentSchool = await ref.watch(currentSchoolProvider.future);
  if (currentSchool == null) return {};

  final enrollments = await isar.enrollments
      .filter()
      .schoolIdEqualTo(currentSchool.id)
      .isActiveEqualTo(true)
      .findAll();

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
