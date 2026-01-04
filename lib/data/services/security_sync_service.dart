import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'database_service.dart';

/// 🔄 SECURITY SYNC SERVICE (The "Pull Once" Protocol)
/// Responsibilities:
/// 1. Fetch critical security rules from Supabase (Cloud).
/// 2. Save them to Local Storage (SQLite) immediately.
/// 3. Never let the UI wait for this. It runs in the background.
class SecuritySyncService {
  static final SecuritySyncService _instance = SecuritySyncService._internal();
  factory SecuritySyncService() => _instance;
  SecuritySyncService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  final DatabaseService _db = DatabaseService();

  /// Call this in main.dart after DatabaseService.initialize()
  /// and DeviceAuthorityService.initialize()
  /// 
  /// This runs in the background and does NOT block the UI.
  Future<void> pullSecurityRules(String schoolId, String deviceId) async {
    try {
      debugPrint("🔄 Pull Once: Fetching security rules for $schoolId...");

      // 1. Fetch School Status (Is suspended?)
      final schoolResponse = await _supabase
          .from('schools')
          .select('is_suspended, subscription_status')
          .eq('id', schoolId)
          .maybeSingle();

      // 2. Fetch Device Authority (Is this the billing engine?)
      final deviceResponse = await _supabase
          .from('billing_engine_registry')
          .select('is_active')
          .eq('school_id', schoolId)
          .eq('device_id', deviceId)
          .maybeSingle();

      // 3. WRITE TO LOCAL DB (The "Cached" Truth)
      final bool isSuspended = schoolResponse?['is_suspended'] ?? false;
      final bool isBillingEngine = deviceResponse?['is_active'] ?? false;

      // Update Local School Record
      await _db.db.execute(
        'UPDATE schools SET is_suspended = ? WHERE id = ?',
        [isSuspended ? 1 : 0, schoolId],
      );

      // Upsert into local_security_config table
      // Using INSERT OR REPLACE for each key-value pair
      await _db.db.execute(
        'INSERT OR REPLACE INTO local_security_config (key, value, updated_at) VALUES (?, ?, ?)',
        ['is_suspended', isSuspended ? 'true' : 'false', DateTime.now().toIso8601String()],
      );

      await _db.db.execute(
        'INSERT OR REPLACE INTO local_security_config (key, value, updated_at) VALUES (?, ?, ?)',
        ['is_billing_engine', isBillingEngine ? 'true' : 'false', DateTime.now().toIso8601String()],
      );

      debugPrint("✅ Pull Once: Security rules updated locally. Suspended: $isSuspended, Engine: $isBillingEngine");

    } catch (e) {
      debugPrint("⚠️ Pull Once Failed (Offline?): Using existing local rules. Error: $e");
      // We DO NOT crash. We allow the app to run on old rules.
    }
  }

  /// Optional: Force re-pull of security rules (call if needed)
  Future<void> refreshSecurityRules(String schoolId, String deviceId) async {
    await pullSecurityRules(schoolId, deviceId);
  }
}
