import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

// Logic
import '../view_models/notification_view_model.dart';
import '../models/notification_item.dart';
import '../services/smart_sync_manager.dart'; // 👈 Import the Brain

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    // 1. Load Local Data Instantly
    final vm = context.read<NotificationViewModel>();
    await vm.loadNotifications();

    // 2. Trigger Background Sync (Fetch remote alerts)
    SmartSyncManager().forceSync().then((_) {
      if (mounted) {
        // Reload to show any new alerts from server
        vm.loadNotifications();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: "Mark all as read",
            onPressed: () {
              context.read<NotificationViewModel>().markAllAsRead();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Manual Force Sync
          await SmartSyncManager().forceSync();
          if (mounted) {
            await context.read<NotificationViewModel>().refresh();
          }
        },
        child: Consumer<NotificationViewModel>(
          builder: (context, vm, child) {
            // Handle Loading State
            if (vm.isLoading && vm.notifications.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (vm.notifications.isEmpty) {
              // Stack used to ensure RefreshIndicator works on empty list
              return Stack(
                children: [
                  ListView(), // Invisible list to allow pull-to-refresh
                  const Center(
                    child: Text(
                      "No notifications yet.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              );
            }

            return ListView.builder(
              itemCount: vm.notifications.length,
              itemBuilder: (context, index) {
                final item = vm.notifications[index];
                return _NotificationTile(item: item);
              },
            );
          },
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationItem item;

  const _NotificationTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    IconData icon;
    Color color;

    // Visual logic based on notification type
    switch (item.type) {
      case 'success':
        icon = Icons.emoji_events_rounded;
        color = Colors.green;
        break;
      case 'warning':
        icon = Icons.warning_amber_rounded;
        color = Colors.orange;
        break;
      default:
        icon = Icons.info_outline_rounded;
        color = colorScheme.primary;
    }

    return Container(
      // Highlight unread items with a subtle tint
      color: item.isRead ? null : colorScheme.primary.withValues(alpha: 0.05),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          item.title,
          style: TextStyle(
            fontWeight: item.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.body),
            const SizedBox(height: 4),
            Text(
              DateFormat('MMM d, h:mm a').format(item.timestamp),
              style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
            ),
          ],
        ),
        onTap: () {
          // Mark as read when tapped
          if (!item.isRead) {
            context.read<NotificationViewModel>().markAsRead(item.id);
          }
        },
        // Optional: Allow deleting via long press?
        onLongPress: () {
          // Could add delete logic here later
        },
      ),
    );
  }
}
