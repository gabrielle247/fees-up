import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../services/database_service.dart';
import '../models/announcement_model.dart';

final announcementsRepositoryProvider =
    Provider((ref) => AnnouncementsRepository());

class AnnouncementsRepository {
  final _db = DatabaseService();

  Stream<List<Announcement>> watchAnnouncements(String schoolId) {
    return _db.db.watch(
      'SELECT * FROM notifications WHERE school_id = ? ORDER BY created_at DESC',
      parameters: [schoolId],
    ).map((rows) {
      return rows.map((row) => Announcement.fromRow(row)).toList();
    });
  }

// Look for the createAnnouncement method
  Future<void> createAnnouncement({
    required String schoolId,
    required String userId, // <--- CRITICAL: Must be required
    required String title,
    required String body,
    required AnnouncementCategory category,
  }) async {
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

    // --- THE FIX ---
    // We explicitly add the user_id to the map before inserting.
    // If this is missing, the database rejects it with Error 23502.
    data['user_id'] = userId;
    // ----------------

    await _db.insert('notifications', data);
  }

  Future<void> markAllAsRead(String schoolId) async {
    await _db.db.execute(
      'UPDATE notifications SET is_read = 1 WHERE school_id = ?',
      [schoolId],
    );
  }
}
