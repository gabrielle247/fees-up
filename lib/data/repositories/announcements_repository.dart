import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../services/database_service.dart';
import '../models/announcement_model.dart';

final announcementsRepositoryProvider = Provider((ref) => AnnouncementsRepository());

class AnnouncementsRepository {
  final _db = DatabaseService();

  /// Watch local notifications - The heartbeat of the Rainbow UI
  /// Listens for real-time changes in the 'notifications' table.
  Stream<List<Announcement>> watchAnnouncements(String schoolId) {
    return _db.db.watch(
      'SELECT * FROM notifications WHERE school_id = ? ORDER BY created_at DESC',
      parameters: [schoolId],
    ).map((rows) => rows.map((row) => Announcement.fromRow(row)).toList());
  }

  /// Create Announcement with CEO-Grade Security (Explicit user_id)
  /// Ensures RLS is satisfied by injecting both school_id and user_id.
  Future<void> createAnnouncement({
    required String schoolId,
    required String userId, 
    required String title,
    required String body,
    required AnnouncementCategory category,
  }) async {
    try {
      final newAnnouncement = Announcement(
        id: const Uuid().v4(),
        schoolId: schoolId,
        title: title,
        body: body,
        time: DateTime.now(),
        category: category,
        isRead: false,
      );

      final data = newAnnouncement.toMap();

      // --- THE FORTRESS FIX ---
      // Manually injecting the User ID and School ID to satisfy Postgres RLS Constraints
      data['user_id'] = userId;
      data['school_id'] = schoolId;

      await _db.insert('notifications', data);
    } catch (e) {
      throw Exception('Fees Up Security: Failed to create announcement. Details: $e');
    }
  }

  /// Mark all as read - Clean up the Rainbow UI state
  /// Updates all unread notifications for a specific school.
  Future<void> markAllAsRead(String schoolId) async {
    try {
      await _db.db.execute(
        'UPDATE notifications SET is_read = 1 WHERE school_id = ? AND is_read = 0',
        [schoolId],
      );
    } catch (e) {
      throw Exception('Fees Up Logic Error: Failed to mark all notifications as read: $e');
    }
  }

  /// Single Action: Mark specific notification as read
  /// Explicitly added to handle individual item toggles in the UI.
  Future<void> markOneAsRead(String id) async {
    try {
      await _db.db.execute(
        'UPDATE notifications SET is_read = 1 WHERE id = ?',
        [id],
      );
    } catch (e) {
      throw Exception('Fees Up Logic Error: Failed to mark notification $id as read: $e');
    }
  }

  /// Delete specific notification (Utility)
  /// Permanently removes a notification from the local and remote Fortress.
  Future<void> deleteNotification(String id) async {
    try {
      await _db.db.execute('DELETE FROM notifications WHERE id = ?', [id]);
    } catch (e) {
      throw Exception('Fees Up Security: Unauthorized or failed deletion of $id: $e');
    }
  }
}