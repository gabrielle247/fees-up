import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/announcement_model.dart';
import '../repositories/announcements_repository.dart';
import 'school_provider.dart';
import 'auth_provider.dart';

// 1. DATA STREAM
final notificationsProvider = StreamProvider<List<Announcement>>((ref) {
  final schoolId = ref.watch(activeSchoolIdProvider);
  if (schoolId == null) return const Stream.empty();

  final repository = ref.watch(announcementsRepositoryProvider);
  return repository.watchAnnouncements(schoolId);
});

// 2. LOGIC CONTROLLER
final notificationLogicProvider = Provider((ref) => NotificationLogic(ref));

class NotificationLogic {
  final Ref _ref;
  NotificationLogic(this._ref);

  /// Bulk Action: Clears the "Unread" status for everything
  Future<void> markAllRead() async {
    final schoolId = _ref.read(activeSchoolIdProvider);
    if (schoolId != null) {
      await _ref.read(announcementsRepositoryProvider).markAllAsRead(schoolId);
    }
  }

  /// Single Action: Mark one specific item as read
  Future<void> markAsRead(String notificationId) async {
    // We assume the repository has a method for this, or we run a raw query
    // For now, we reuse the repo's generic update capabilities if available,
    // or add a specific method to the repo.
    // implementation details depend on repo, but conceptually:
    final repo = _ref.read(announcementsRepositoryProvider);
    // await repo.markOneAsRead(notificationId); 
    // (Assuming you'll add this SQL: UPDATE notifications SET is_read = true WHERE id = ?)
  }

  /// Single Action: Delete a notification (Cleanup rights)
  Future<void> delete(String notificationId) async {
    final schoolId = _ref.read(activeSchoolIdProvider);
    if (schoolId != null) {
      // Calls repo delete
      final repo = _ref.read(announcementsRepositoryProvider);
      // await repo.deleteNotification(notificationId);
    }
  }
}