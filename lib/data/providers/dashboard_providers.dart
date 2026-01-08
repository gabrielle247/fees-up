import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../models/finance.dart';
import '../models/people.dart';
import 'core_providers.dart';

/// Provides total count of enrolled learners
final learnerCountProvider = FutureProvider<int>((ref) async {
  // TODO: Connect to IsarService once DB is initialized
  return 24;
});

/// Provides total outstanding fees (owes)
final totalOutstandingProvider = FutureProvider<int>((ref) async {
  // TODO: Connect to IsarService once DB is initialized
  return 420000; // in cents = $4,200
});

/// Provides total collected cash (payments received today)
final totalCashTodayProvider = FutureProvider<int>((ref) async {
  // TODO: Connect to IsarService once DB is initialized
  return 1542000; // in cents = $15,420
});

/// Provides total collected cash (all time)
final totalCashCollectedProvider = FutureProvider<int>((ref) async {
  // TODO: Connect to IsarService once DB is initialized
  return 895000; // in cents = $8,950.00
});

/// Provides recent activity feed (payments + invoices)
final recentActivityProvider =
    FutureProvider<List<ActivityFeedItem>>((ref) async {
  final isar = await ref.watch(isarInstanceProvider.future);

  // 1. Fetch recent payments (limit 5)
  final payments = await isar.payments
      .where()
      .sortByReceivedAtDesc()
      .limit(5)
      .findAll();

  // 2. Fetch recent invoices (limit 5)
  final invoices = await isar.invoices
      .where()
      .sortByCreatedAtDesc()
      .limit(5)
      .findAll();

  // 3. Combine and sort
  final allItems = <dynamic>[...payments, ...invoices];
  allItems.sort((a, b) {
    DateTime dateA;
    if (a is Payment) {
      dateA = a.receivedAt;
    } else {
      dateA = (a as Invoice).createdAt ?? DateTime(2000);
    }

    DateTime dateB;
    if (b is Payment) {
      dateB = b.receivedAt;
    } else {
      dateB = (b as Invoice).createdAt ?? DateTime(2000);
    }

    return dateB.compareTo(dateA); // Descending
  });

  // 4. Take top 5
  final topItems = allItems.take(5).toList();

  final feedItems = <ActivityFeedItem>[];

  for (final item in topItems) {
    if (item is Payment) {
      // Lookup Student
      final student =
          await isar.students.filter().idEqualTo(item.studentId).findFirst();
      final studentName = student?.fullName ?? 'Unknown Student';

      feedItems.add(ActivityFeedItem(
        type: 'payment',
        title: 'Payment from $studentName',
        amount: item.amount,
        timestamp: item.receivedAt,
      ));
    } else if (item is Invoice) {
      // Lookup Student
      final student =
          await isar.students.filter().idEqualTo(item.studentId).findFirst();
      final studentName = student?.fullName ?? 'Unknown Student';

      // Calculate total amount for invoice
      final invoiceItems = await isar.invoiceItems
          .filter()
          .invoiceIdEqualTo(item.id)
          .findAll();
      final totalAmount = invoiceItems.fold<int>(
          0, (sum, invItem) => sum + invItem.amount);

      feedItems.add(ActivityFeedItem(
        type: 'invoice',
        title: 'Invoice #${item.invoiceNumber} for $studentName',
        amount: totalAmount,
        timestamp: item.createdAt ?? DateTime.now(),
      ));
    }
  }

  return feedItems;
});

/// Provides pending invoices count
final pendingInvoicesCountProvider = FutureProvider<int>((ref) async {
  // TODO: Connect to IsarService once DB is initialized
  return 128;
});

/// Provides learners by form/class
final learnersByFormProvider = FutureProvider<Map<String, int>>((ref) async {
  // TODO: Connect to IsarService once DB is initialized
  return {
    'Form 1': 8,
    'Form 2': 12,
    'Form 3': 4,
  };
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
