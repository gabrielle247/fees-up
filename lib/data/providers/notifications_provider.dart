import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/announcement_model.dart';
import '../repositories/announcements_repository.dart';
import 'school_provider.dart';

/// 1. DATA STREAM
/// The "Single Source of Truth" for the Rainbow Notification system.
/// Listens to PowerSync for any changes in the notifications table.
final notificationsProvider = StreamProvider<List<Announcement>>((ref) {
  final schoolId = ref.watch(activeSchoolIdProvider);
  if (schoolId == null) return const Stream.empty();

  final repository = ref.watch(announcementsRepositoryProvider);
  return repository.watchAnnouncements(schoolId);
});

/// 2. LOGIC CONTROLLER
/// Handles user interactions for the notification system.
final notificationLogicProvider = Provider((ref) => NotificationLogic(ref));

class NotificationLogic {
  final Ref _ref;
  NotificationLogic(this._ref);

  /// Bulk Action: Clears the "Unread" status for everything in the school.
  Future<void> markAllRead() async {
    final schoolId = _ref.read(activeSchoolIdProvider);
    if (schoolId != null) {
      await _ref.read(announcementsRepositoryProvider).markAllAsRead(schoolId);
    }
  }

  /// Single Action: Mark one specific item as read.
  /// Seals the logic gap by calling the explicit repository method.
  Future<void> markAsRead(String notificationId) async {
    final repository = _ref.read(announcementsRepositoryProvider);
    await repository.markOneAsRead(notificationId);
  }

  /// Single Action: Delete a notification (Cleanup rights).
  /// Ensures the "Fortress" table stays clean of old logs.
  Future<void> delete(String notificationId) async {
    final repository = _ref.read(announcementsRepositoryProvider);
    await repository.deleteNotification(notificationId);
  }
}