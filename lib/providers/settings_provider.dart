import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../services/settings_db_service.dart';

// --- State Model ---
class AppSettingsState {
  final bool biometricEnabled;
  final bool notificationsEnabled;
  final bool darkMode;
  final String language;

  AppSettingsState({
    this.biometricEnabled = false,
    this.notificationsEnabled = true,
    this.darkMode = true,
    this.language = 'English (US)',
  });

  AppSettingsState copyWith({
    bool? biometricEnabled,
    bool? notificationsEnabled,
    bool? darkMode,
    String? language,
  }) {
    return AppSettingsState(
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      darkMode: darkMode ?? this.darkMode,
      language: language ?? this.language,
    );
  }
}

// --- Notifier ---
class SettingsController extends StateNotifier<AsyncValue<AppSettingsState>> {
  final SettingsDatabaseService _db;

  SettingsController(this._db) : super(const AsyncValue.loading()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final bio = await _db.getSetting('biometric_enabled', defaultValue: false);
      final notif = await _db.getSetting('notifications_enabled', defaultValue: true);
      final dark = await _db.getSetting('dark_mode', defaultValue: true);
      final lang = await _db.getSetting('language', defaultValue: 'English (US)');

      state = AsyncValue.data(AppSettingsState(
        biometricEnabled: bio,
        notificationsEnabled: notif,
        darkMode: dark,
        language: lang,
      ));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggleBiometric(bool value) async {
    await _db.setSetting('biometric_enabled', value);
    // Optimistic update
    state = state.whenData((s) => s.copyWith(biometricEnabled: value));
  }

  Future<void> toggleNotifications(bool value) async {
    await _db.setSetting('notifications_enabled', value);
    state = state.whenData((s) => s.copyWith(notificationsEnabled: value));
  }

  Future<void> toggleDarkMode(bool value) async {
    await _db.setSetting('dark_mode', value);
    state = state.whenData((s) => s.copyWith(darkMode: value));
  }
}

// --- Provider Definition ---
final settingsProvider = StateNotifierProvider<SettingsController, AsyncValue<AppSettingsState>>((ref) {
  return SettingsController(SettingsDatabaseService.instance);
});