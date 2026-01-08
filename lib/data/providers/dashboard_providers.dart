import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  // TODO: Connect to IsarService once DB is initialized
  final now = DateTime.now();
  return [
    ActivityFeedItem(
      type: 'payment',
      title: 'Tuition Payment from John Doe',
      amount: 50000,
      timestamp: DateTime(now.year, now.month, now.day, 10, 23),
    ),
    ActivityFeedItem(
      type: 'invoice',
      title: 'Term 1 Invoice for Grade 5A',
      amount: 50000,
      timestamp: DateTime(now.year, now.month, now.day - 1, 16, 15),
    ),
    ActivityFeedItem(
      type: 'payment',
      title: 'Sports Fee from Sarah Smith',
      amount: 4500,
      timestamp: DateTime(now.year, now.month, now.day - 1, 14, 30),
    ),
    ActivityFeedItem(
      type: 'invoice',
      title: 'Bus Levy for Route 4',
      amount: 12000,
      timestamp: DateTime(now.year, 3, 12, 9, 0),
    ),
  ];
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
