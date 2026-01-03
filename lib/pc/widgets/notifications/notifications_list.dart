import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/announcement_model.dart';
import '../../../../data/providers/notifications_provider.dart';

class NotificationsList extends ConsumerStatefulWidget {
  const NotificationsList({super.key});

  @override
  ConsumerState<NotificationsList> createState() => _NotificationsListState();
}

class _NotificationsListState extends ConsumerState<NotificationsList> {
  AnnouncementCategory? _categoryFilter;
  bool _showUnreadOnly = false;

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- DESKTOP OPTIMIZED FILTER PANEL ---
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text("Filters",
                        style: TextStyle(
                            color: AppColors.textWhite,
                            fontWeight: FontWeight.bold)),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () =>
                          ref.read(notificationLogicProvider).markAllRead(),
                      icon: const Icon(Icons.done_all, size: 16),
                      label: const Text("Mark All Read"),
                      style: TextButton.styleFrom(
                          foregroundColor: AppColors.textWhite70),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _buildFilterChip("All", null, Icons.all_inclusive),
                    _buildUnreadToggle(),
                    const _VerticalDivider(),
                    _buildFilterChip(
                        "Urgent", AnnouncementCategory.urgent, Icons.priority_high),
                    _buildFilterChip("Security", AnnouncementCategory.security,
                        Icons.shield_outlined),
                    _buildFilterChip(
                        "Errors", AnnouncementCategory.failure, Icons.error_outline),
                    _buildFilterChip("Warning", AnnouncementCategory.warning,
                        Icons.warning_amber),
                    const _VerticalDivider(),
                    _buildFilterChip("Financial", AnnouncementCategory.financial,
                        Icons.payments_outlined),
                    _buildFilterChip("Success", AnnouncementCategory.success,
                        Icons.check_circle_outline),
                    _buildFilterChip("System", AnnouncementCategory.system,
                        Icons.settings_input_component),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),

          // --- DATA LIST ---
          notificationsAsync.when(
            data: (list) {
              var filtered = list;
              if (_categoryFilter != null) {
                filtered =
                    filtered.where((n) => n.category == _categoryFilter).toList();
              }
              if (_showUnreadOnly) {
                filtered = filtered.where((n) => !n.isRead).toList();
              }

              if (filtered.isEmpty) return _buildEmptyState();

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filtered.length,
                separatorBuilder: (context, i) =>
                    const Divider(height: 1, color: AppColors.divider),
                itemBuilder: (context, i) => _buildNotificationItem(filtered[i]),
              );
            },
            loading: () => const Center(
                child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator())),
            error: (e, s) => Center(
                child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Text("System connection error: $e",
                        style: const TextStyle(color: AppColors.errorRed)))),
          ),
        ],
      ),
    );
  }

  // --- ITEM BUILDER ---

  Widget _buildNotificationItem(Announcement item) {
    final isUnread = !item.isRead;

    return InkWell(
      onTap: () => _showDetailsDialog(item),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        color: isUnread ? AppColors.backgroundBlack.withValues(alpha: 0.3) : null,
        child: Row(
          children: [
            // Category Icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(item.icon, color: item.color, size: 20),
            ),
            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          color: AppColors.textWhite,
                          fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                          fontSize: 14,
                        ),
                      ),
                      if (isUnread) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryBlue,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ]
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.body,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.textWhite70, fontSize: 13),
                  ),
                ],
              ),
            ),

            // Time & Quick Action
            const SizedBox(width: 16),
            Text(
              DateFormat('MMM d, h:mm a').format(item.time),
              style: const TextStyle(color: AppColors.textWhite38, fontSize: 12),
            ),
            const SizedBox(width: 16),
            if (isUnread)
              IconButton(
                onPressed: () => ref.read(notificationLogicProvider).markAsRead(item.id),
                icon: const Icon(Icons.check_circle_outline, size: 20),
                color: AppColors.textWhite38,
                tooltip: "Mark as read",
              )
            else
              const SizedBox(width: 48), // Spacer to maintain alignment
          ],
        ),
      ),
    );
  }

  // --- VISUAL DETAILS DIALOG ---

  void _showDetailsDialog(Announcement item) {
    // Auto-mark as read when opened
    if (!item.isRead) {
      ref.read(notificationLogicProvider).markAsRead(item.id);
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.surfaceGrey,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 450,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: item.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(item.icon, color: item.color, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.badgeLabel,
                          style: TextStyle(
                            color: item.color,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                        ),
                        Text(
                          item.title,
                          style: const TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: AppColors.textWhite38),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(color: AppColors.divider),
              const SizedBox(height: 16),
              Text(
                item.body,
                style: const TextStyle(
                  color: AppColors.textWhite70,
                  fontSize: 15,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('EEEE, MMMM d, yyyy • h:mm a').format(item.time),
                    style: const TextStyle(color: AppColors.textWhite38, fontSize: 12),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.backgroundBlack,
                      foregroundColor: AppColors.textWhite,
                      side: const BorderSide(color: AppColors.divider),
                    ),
                    child: const Text("Close"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- HELPERS (Previously defined) ---

  Widget _buildFilterChip(String label, AnnouncementCategory? category, IconData icon) {
    final isSelected = _categoryFilter == category;
    final Color activeColor = _getCategoryColor(category);

    return InkWell(
      onTap: () => setState(() => _categoryFilter = category),
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withValues(alpha: 0.15) : AppColors.backgroundBlack,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? activeColor : AppColors.divider, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? activeColor : AppColors.textWhite38),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                  color: isSelected ? AppColors.textWhite : AppColors.textWhite70,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildUnreadToggle() {
    return InkWell(
      onTap: () => setState(() => _showUnreadOnly = !_showUnreadOnly),
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: _showUnreadOnly ? AppColors.primaryBlue : AppColors.backgroundBlack,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _showUnreadOnly ? AppColors.primaryBlue : AppColors.divider),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.mark_email_unread_outlined,
                size: 16,
                color: _showUnreadOnly ? Colors.white : AppColors.textWhite38),
            const SizedBox(width: 8),
            Text("Unread Only",
                style: TextStyle(
                  color: _showUnreadOnly ? Colors.white : AppColors.textWhite70,
                  fontSize: 13,
                  fontWeight: _showUnreadOnly ? FontWeight.bold : FontWeight.normal,
                )),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(AnnouncementCategory? category) {
    if (category == null) return AppColors.primaryBlue;
    switch (category) {
      case AnnouncementCategory.urgent:
      case AnnouncementCategory.failure:
        return AppColors.errorRed;
      case AnnouncementCategory.warning:
        return Colors.amber;
      case AnnouncementCategory.success:
        return AppColors.successGreen;
      case AnnouncementCategory.security:
        return const Color(0xFF9333EA);
      default:
        return AppColors.primaryBlue;
    }
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(60),
      child: const Column(
        children: [
          Icon(Icons.inbox_outlined, size: 48, color: AppColors.textWhite38),
          SizedBox(height: 16),
          Text("No results found for these filters.",
              style: TextStyle(color: AppColors.textWhite54)),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Container(width: 1, height: 32, color: AppColors.divider),
      );
}