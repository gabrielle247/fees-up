import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database_service.dart';
import 'dashboard_provider.dart';

// --- MODELS ---
class GlobalSettings {
  final String themeMode;
  final bool twoFactor;
  final int sessionTimeout;
  // ... add others
  GlobalSettings({required this.themeMode, required this.twoFactor, required this.sessionTimeout});
}

class SchoolPreferences {
  final bool notifyPayment;
  final bool notifyOverdue;
  final String landingPage;
  // ... add others
  SchoolPreferences({required this.notifyPayment, required this.notifyOverdue, required this.landingPage});
}

// --- PROVIDERS ---

// 1. Fetch Global Settings (User-centric)
final globalSettingsProvider = FutureProvider<GlobalSettings>((ref) async {
  // ignore: unused_local_variable
  final db = DatabaseService();
  // In production, fetch from Supabase. For UI demo, returning mock default.
  return GlobalSettings(themeMode: 'dark', twoFactor: true, sessionTimeout: 15);
});

// 2. Fetch School Context Settings (School-centric)
final schoolPreferencesProvider = FutureProvider<SchoolPreferences>((ref) async {
  final dashboard = await ref.watch(dashboardDataProvider.future);
  if (dashboard.schoolId.isEmpty) {
    return SchoolPreferences(notifyPayment: true, notifyOverdue: true, landingPage: 'overview');
  }
  
  // Logic: Fetch FROM user_school_preferences WHERE school_id = dashboard.schoolId
  return SchoolPreferences(notifyPayment: true, notifyOverdue: false, landingPage: 'transactions');
});