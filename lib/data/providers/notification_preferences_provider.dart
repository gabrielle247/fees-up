import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database_service.dart';

class NotificationPreferences {
  final bool billingInApp;
  final bool billingEmail;
  final String billingFreq;
  final bool campaignInApp;
  final bool campaignEmail;
  final bool attendanceInApp;
  final bool attendanceEmail;
  final bool announceInApp;
  final bool announceEmail;
  final bool channelEmail;
  final bool channelPush;
  final bool channelSMS;
  final bool dndEnabled;
  final String dndStart;
  final String dndEnd;

  NotificationPreferences({
    this.billingInApp = true,
    this.billingEmail = true,
    this.billingFreq = 'Immediate',
    this.campaignInApp = true,
    this.campaignEmail = false,
    this.attendanceInApp = true,
    this.attendanceEmail = false,
    this.announceInApp = true,
    this.announceEmail = true,
    this.channelEmail = true,
    this.channelPush = true,
    this.channelSMS = false,
    this.dndEnabled = false,
    this.dndStart = '22:00',
    this.dndEnd = '07:00',
  });

  Map<String, dynamic> toJson() => {
        'billingInApp': billingInApp,
        'billingEmail': billingEmail,
        'billingFreq': billingFreq,
        'campaignInApp': campaignInApp,
        'campaignEmail': campaignEmail,
        'attendanceInApp': attendanceInApp,
        'attendanceEmail': attendanceEmail,
        'announceInApp': announceInApp,
        'announceEmail': announceEmail,
        'channelEmail': channelEmail,
        'channelPush': channelPush,
        'channelSMS': channelSMS,
        'dndEnabled': dndEnabled,
        'dndStart': dndStart,
        'dndEnd': dndEnd,
      };

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      billingInApp: json['billingInApp'] as bool? ?? true,
      billingEmail: json['billingEmail'] as bool? ?? true,
      billingFreq: json['billingFreq'] as String? ?? 'Immediate',
      campaignInApp: json['campaignInApp'] as bool? ?? true,
      campaignEmail: json['campaignEmail'] as bool? ?? false,
      attendanceInApp: json['attendanceInApp'] as bool? ?? true,
      attendanceEmail: json['attendanceEmail'] as bool? ?? false,
      announceInApp: json['announceInApp'] as bool? ?? true,
      announceEmail: json['announceEmail'] as bool? ?? true,
      channelEmail: json['channelEmail'] as bool? ?? true,
      channelPush: json['channelPush'] as bool? ?? true,
      channelSMS: json['channelSMS'] as bool? ?? false,
      dndEnabled: json['dndEnabled'] as bool? ?? false,
      dndStart: json['dndStart'] as String? ?? '22:00',
      dndEnd: json['dndEnd'] as String? ?? '07:00',
    );
  }
}

class NotificationPreferencesNotifier
    extends StateNotifier<AsyncValue<NotificationPreferences>> {
  final String schoolId;
  final DatabaseService _db = DatabaseService();

  NotificationPreferencesNotifier(this.schoolId)
      : super(const AsyncValue.loading()) {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final results = await _db.db.getAll(
        'SELECT notification_prefs FROM schools WHERE id = ?',
        [schoolId],
      );

      if (results.isEmpty) {
        state = AsyncValue.data(NotificationPreferences());
        return;
      }

      final prefsJson = results.first['notification_prefs'] as String? ?? '';
      if (prefsJson.isEmpty) {
        state = AsyncValue.data(NotificationPreferences());
        return;
      }

      try {
        final decoded = jsonDecode(prefsJson) as Map<String, dynamic>;
        state = AsyncValue.data(NotificationPreferences.fromJson(decoded));
      } catch (_) {
        state = AsyncValue.data(NotificationPreferences());
      }
    } catch (e, st) {
      debugPrint('⚠️ Error loading notification preferences: $e');
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> savePreferences(NotificationPreferences prefs) async {
    try {
      final prefsJson = jsonEncode(prefs.toJson());

      // Try to update notification_prefs column if it exists
      try {
        await _db.db.execute(
          'UPDATE schools SET notification_prefs = ? WHERE id = ?',
          [prefsJson, schoolId],
        );
      } catch (_) {
        // Column doesn't exist, use local_security_config as fallback
        await _db.db.execute(
          '''INSERT OR REPLACE INTO local_security_config (key, value, updated_at)
             VALUES (?, ?, datetime('now'))''',
          ['notification_prefs_$schoolId', prefsJson],
        );
      }

      state = AsyncValue.data(prefs);
    } catch (e, st) {
      debugPrint('⚠️ Error saving notification preferences: $e');
      state = AsyncValue.error(e, st);
    }
  }
}

final notificationPreferencesProvider = StateNotifierProvider.family<
    NotificationPreferencesNotifier,
    AsyncValue<NotificationPreferences>,
    String>((ref, schoolId) {
  return NotificationPreferencesNotifier(schoolId);
});
