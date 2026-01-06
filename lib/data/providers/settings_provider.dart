import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database_service.dart';
import 'dashboard_provider.dart';

// --- MODELS ---
class GlobalSettings {
  final String themeMode;
  final bool twoFactor;
  final int sessionTimeout;
  // ... add others
  GlobalSettings(
      {required this.themeMode,
      required this.twoFactor,
      required this.sessionTimeout});
}

class SchoolPreferences {
  final bool notifyPayment;
  final bool notifyOverdue;
  final String landingPage;
  // ... add others
  SchoolPreferences(
      {required this.notifyPayment,
      required this.notifyOverdue,
      required this.landingPage});
}

// --- PROVIDERS ---

// 1. Fetch Global Settings (User-centric)
final globalSettingsProvider = FutureProvider<GlobalSettings>((ref) async {
  final db = DatabaseService();

  try {
    // Fetch from user_settings table or use sensible defaults
    final result = await db.db.getAll(
      'SELECT theme_mode, two_factor_enabled, session_timeout_minutes FROM user_settings LIMIT 1',
    );

    if (result.isNotEmpty) {
      final settings = result.first;
      return GlobalSettings(
        themeMode: settings['theme_mode'] ?? 'dark',
        twoFactor: (settings['two_factor_enabled'] as int?) == 1,
        sessionTimeout: settings['session_timeout_minutes'] ?? 15,
      );
    }
  } catch (e) {
    debugPrint('⚠️ Error fetching global settings: $e');
  }

  // Fallback to sensible defaults if table doesn't exist yet
  return GlobalSettings(
      themeMode: 'dark', twoFactor: false, sessionTimeout: 15);
});

// 2. Fetch School Context Settings (School-centric)
final schoolPreferencesProvider =
    FutureProvider<SchoolPreferences>((ref) async {
  final dashboard = await ref.watch(dashboardDataProvider.future);
  if (dashboard.schoolId.isEmpty) {
    return SchoolPreferences(
        notifyPayment: true, notifyOverdue: true, landingPage: 'overview');
  }

  final db = DatabaseService();

  try {
    // Fetch FROM school_preferences WHERE school_id = dashboard.schoolId
    final result = await db.db.getAll(
      'SELECT notify_payment, notify_overdue, default_landing_page FROM school_preferences WHERE school_id = ?',
      [dashboard.schoolId],
    );

    if (result.isNotEmpty) {
      final prefs = result.first;
      return SchoolPreferences(
        notifyPayment: (prefs['notify_payment'] as int?) == 1,
        notifyOverdue: (prefs['notify_overdue'] as int?) == 1,
        landingPage: prefs['default_landing_page'] ?? 'overview',
      );
    }
  } catch (e) {
    debugPrint('⚠️ Error fetching school preferences: $e');
  }

  // Fallback to sensible defaults
  return SchoolPreferences(
      notifyPayment: true, notifyOverdue: true, landingPage: 'overview');
});

// 3. Fetch School Years
final schoolYearsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final dashboard = await ref.watch(dashboardDataProvider.future);
  if (dashboard.schoolId.isEmpty) {
    return [];
  }

  final db = DatabaseService();
  return await db.db.getAll(
      'SELECT * FROM school_years WHERE school_id = ? ORDER BY start_date DESC',
      [dashboard.schoolId]);
});
