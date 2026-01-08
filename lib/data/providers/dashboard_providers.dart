import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fees_up/data/repositories/finance_repository.dart';
import 'package:fees_up/data/models/finance.dart';
import 'package:fees_up/data/providers/student_providers.dart';
import 'core_providers.dart';

/// Provides the FinanceRepository instance.
final financeRepositoryProvider = Provider<Future<FinanceRepository>>((ref) async {
  final isar = await ref.watch(isarInstanceProvider);
  return FinanceRepository(isar);
});

/// Provides total count of enrolled learners
final learnerCountProvider = FutureProvider<int>((ref) async {
  final schoolId = await ref.watch(currentSchoolIdProvider.future);
  return ref.watch(activeStudentCountProvider(schoolId).future);
});

/// Provides total outstanding fees (owes)
final totalOutstandingProvider = FutureProvider<int>((ref) async {
  final schoolId = await ref.watch(currentSchoolIdProvider.future);
  final repo = await ref.watch(financeRepositoryProvider);
  return repo.getTotalOutstanding(schoolId);
});

/// Provides total collected cash (payments received today)
final totalCashTodayProvider = FutureProvider<int>((ref) async {
  final schoolId = await ref.watch(currentSchoolIdProvider.future);
  final repo = await ref.watch(financeRepositoryProvider);
  return repo.getTotalCashToday(schoolId);
});

/// Provides total collected cash (all time)
final totalCashCollectedProvider = FutureProvider<int>((ref) async {
  final schoolId = await ref.watch(currentSchoolIdProvider.future);
  final repo = await ref.watch(financeRepositoryProvider);
  return repo.getTotalCashCollected(schoolId);
});

/// Provides pending invoices count
final pendingInvoicesCountProvider = FutureProvider<int>((ref) async {
  final schoolId = await ref.watch(currentSchoolIdProvider.future);
  final repo = await ref.watch(financeRepositoryProvider);
  return repo.getPendingInvoicesCount(schoolId);
});

/// Provides recent activity feed (payments + invoices)
final recentActivityProvider = FutureProvider<List<ActivityFeedItem>>((ref) async {
  final schoolId = await ref.watch(currentSchoolIdProvider.future);
  final repo = await ref.watch(financeRepositoryProvider);
  final rawActivities = await repo.getRecentActivity(schoolId);

  return rawActivities.map((item) {
    if (item is Payment) {
      return ActivityFeedItem(
        type: 'payment',
        title: 'Payment Received', // Can enhance with Student Name if we fetch it
        amount: item.amount,
        timestamp: item.receivedAt,
      );
    } else if (item is Invoice) {
      return ActivityFeedItem(
        type: 'invoice',
        title: 'Invoice #${item.invoiceNumber}',
        amount: 0, // Invoices don't have a single amount field easily accessible without items, or we can add it to Invoice model
        timestamp: item.createdAt ?? DateTime.now(),
      );
    }
    return ActivityFeedItem(
      type: 'unknown',
      title: 'Unknown Activity',
      timestamp: DateTime.now(),
    );
  }).toList();
});


/// Activity feed item model
class ActivityFeedItem {
  final String type; // 'payment', 'invoice'
  final String title;
  final int? amount; // in cents
  final DateTime timestamp;

  ActivityFeedItem({
    required this.type,
    required this.title,
    this.amount,
    required this.timestamp,
  });

  String get formattedAmount {
    if (amount == null) return '';
    final dollars = amount! / 100;
    return '\$${dollars.toStringAsFixed(2)}';
  }
}
