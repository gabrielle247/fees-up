import 'package:flutter/foundation.dart';
import '../models/notification_preferences_model.dart';
import '../services/database_service.dart';

/// Interface for notification preferences operations
abstract class INotificationPreferencesRepository {
  /// Load preferences for a user in a school
  Future<NotificationPreferences> loadPreferences(
    String userId,
    String schoolId,
  );

  /// Watch preferences changes in real-time
  Stream<NotificationPreferences> watchPreferences(
    String userId,
    String schoolId,
  );

  /// Save preferences atomically
  Future<void> savePreferences(
    String userId,
    String schoolId,
    NotificationPreferences preferences,
  );
}

/// Repository implementation
class NotificationPreferencesRepositoryImpl
    implements INotificationPreferencesRepository {
  final DatabaseService _db = DatabaseService();

  @override
  Future<NotificationPreferences> loadPreferences(
    String userId,
    String schoolId,
  ) async {
    try {
      // Try loading from user_school_preferences (primary source)
      final results = await _db.db.getAll(
        '''SELECT 
             notify_payment_received, 
             notify_payment_overdue, 
             notify_daily_digest, 
             notify_student_attendance
           FROM user_school_preferences 
           WHERE user_id = ? AND school_id = ?''',
        [userId, schoolId],
      );

      if (results.isNotEmpty) {
        final prefs = results.first;
        return NotificationPreferences(
          billingInApp: (prefs['notify_payment_received'] as int? ?? 1) == 1,
          billingEmail: (prefs['notify_payment_received'] as int? ?? 1) == 1,
          campaignInApp: (prefs['notify_daily_digest'] as int? ?? 0) == 1,
          campaignEmail: false,
          attendanceInApp:
              (prefs['notify_student_attendance'] as int? ?? 0) == 1,
          attendanceEmail: false,
          announceInApp: true,
          announceEmail: (prefs['notify_payment_overdue'] as int? ?? 1) == 1,
        );
      }

      // Fallback to defaults
      return const NotificationPreferences();
    } catch (e) {
      debugPrint('⚠️ Error loading notification preferences: $e');
      return const NotificationPreferences();
    }
  }

  @override
  Stream<NotificationPreferences> watchPreferences(
    String userId,
    String schoolId,
  ) async* {
    try {
      // Initial load
      yield await loadPreferences(userId, schoolId);

      // Set up periodic polling (PowerSync doesn't provide real-time for queries yet)
      while (true) {
        await Future.delayed(const Duration(seconds: 5));
        yield await loadPreferences(userId, schoolId);
      }
    } catch (e) {
      debugPrint('⚠️ Error in watchPreferences: $e');
      yield const NotificationPreferences();
    }
  }

  @override
  Future<void> savePreferences(
    String userId,
    String schoolId,
    NotificationPreferences preferences,
  ) async {
    try {
      // Validate inputs
      if (userId.isEmpty || schoolId.isEmpty) {
        throw ArgumentError('User ID and School ID are required');
      }

      // Use atomic transaction
      await _db.db.writeTransaction((tx) async {
        // Check if record exists
        final existing = await tx.getAll(
          'SELECT 1 FROM user_school_preferences WHERE user_id = ? AND school_id = ?',
          [userId, schoolId],
        );

        if (existing.isEmpty) {
          // Insert
          await tx.execute(
            '''INSERT INTO user_school_preferences (
              user_id, 
              school_id, 
              notify_payment_received, 
              notify_payment_overdue, 
              notify_daily_digest, 
              notify_student_attendance, 
              updated_at
            ) VALUES (?, ?, ?, ?, ?, ?, datetime('now'))''',
            [
              userId,
              schoolId,
              preferences.billingInApp ? 1 : 0,
              preferences.announceEmail ? 1 : 0,
              preferences.campaignInApp ? 1 : 0,
              preferences.attendanceInApp ? 1 : 0,
            ],
          );
        } else {
          // Update
          await tx.execute(
            '''UPDATE user_school_preferences 
               SET notify_payment_received = ?,
                   notify_payment_overdue = ?,
                   notify_daily_digest = ?,
                   notify_student_attendance = ?,
                   updated_at = datetime('now')
               WHERE user_id = ? AND school_id = ?''',
            [
              preferences.billingInApp ? 1 : 0,
              preferences.announceEmail ? 1 : 0,
              preferences.campaignInApp ? 1 : 0,
              preferences.attendanceInApp ? 1 : 0,
              userId,
              schoolId,
            ],
          );
        }
      });

      debugPrint('✅ Notification preferences saved for $userId');
    } catch (e) {
      debugPrint('❌ Error saving notification preferences: $e');
      rethrow;
    }
  }
}
