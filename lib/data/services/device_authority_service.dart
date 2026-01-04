import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

import 'database_service.dart';

/// 🔒 DEVICE AUTHORITY SERVICE (Offline Enforcer)
///
/// This service reads ONLY from the Local Database.
/// It does not care if the internet is on or off.
///
/// Security rules are pulled ONCE by SecuritySyncService and stored locally.
/// This service only enforces what's already cached.
///
/// Enforces the "One Billing Engine Per School" constraint:
/// - Only one device per school can perform financial mutations
/// - All other devices are read-only for financial data
class DeviceAuthorityService {
  static final DeviceAuthorityService _instance =
      DeviceAuthorityService._internal();

  factory DeviceAuthorityService() => _instance;
  DeviceAuthorityService._internal();

  late String _deviceId;
  bool _isInitialized = false;
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final DatabaseService _db = DatabaseService();

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _deviceId = await _getDeviceId();
      _isInitialized = true;
      if (kDebugMode) {
        debugPrint("🆔 Device ID: $_deviceId");
      }
    } catch (e) {
      debugPrint("❌ Device Init Error: $e");
      _deviceId = "unknown_device";
    }
  }

  /// Get unique device identifier
  /// - Android: AndroidId
  /// - iOS: UUID from UIDevice
  /// - Desktop: Constant ID for dev stability
  /// - Web: Browser fingerprint (hostname-based)
  Future<String> _getDeviceId() async {
    // DEV BYPASS: For Windows/macOS, return constant ID
    if (kDebugMode &&
        (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.macOS)) {
      return 'dev-pc-id';
    }

    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final androidInfo = await _deviceInfo.androidInfo;
        return androidInfo.id;
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ?? 'unknown-ios';
      } else {
        return 'generic-device';
      }
    } catch (e) {
      debugPrint("❌ Error getting device ID: $e");
      return 'unknown-device-${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  /// Check if this device is the billing engine for the given school.
  /// READS LOCAL DB ONLY (no Supabase calls).
  ///
  /// Returns true if:
  /// 1. Local cache says this device is the billing engine
  /// 2. Device dev bypass is enabled
  Future<bool> isBillingEngineForSchool(String schoolId) async {
    if (!_isInitialized) await initialize();

    // 1. Dev Bypass (Keep this for speed)
    if (kDebugMode) return true;

    try {
      // 2. Read from the local config cache populated by SecuritySyncService
      final result = await _db.db.getAll(
          "SELECT value FROM local_security_config WHERE key = 'is_billing_engine' LIMIT 1");

      if (result.isNotEmpty) {
        return result.first['value'] == 'true';
      }

      // 3. Fallback: If no config found (fresh install, offline), default to SAFE mode (False)
      return false;
    } catch (e) {
      debugPrint("⚠️ Authority Check Error: $e");
      return false;
    }
  }

  /// Get the current active billing engine device for a school
  /// READS LOCAL DB ONLY
  Future<Map<String, dynamic>?> getActiveBillingEngineForSchool(
      String schoolId) async {
    try {
      if (!_isInitialized) await initialize();

      final result = await _db.db.getAll(
        'SELECT * FROM billing_engine_registry '
        'WHERE school_id = ? AND is_active = 1 '
        'LIMIT 1',
        [schoolId],
      );

      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      debugPrint("❌ Error getting active billing engine: $e");
      return null;
    }
  }

  /// Register this device as the billing engine for a school
  /// This writes to LOCAL DB immediately, then syncs to cloud via PowerSync
  Future<void> registerAsActiveBillingEngine(
    String schoolId,
    String userId,
  ) async {
    try {
      if (!_isInitialized) await initialize();

      final now = DateTime.now().toIso8601String();

      // First, deactivate any existing billing engines for this school
      await _db.db.execute(
        'UPDATE billing_engine_registry SET is_active = 0 '
        'WHERE school_id = ?',
        [schoolId],
      );

      // Then register this device as active
      final deviceName = await _getDeviceName();
      await _db.db.execute(
        'INSERT INTO billing_engine_registry (id, school_id, device_id, device_name, user_id, is_active, activated_at, last_sync_at, created_at, updated_at) '
        'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
        [
          _generateId(),
          schoolId,
          _deviceId,
          deviceName,
          userId,
          1,
          now,
          now,
          now,
          now,
        ],
      );

      // Update local security config
      await _db.db.execute(
        'INSERT OR REPLACE INTO local_security_config (key, value, updated_at) VALUES (?, ?, ?)',
        ['is_billing_engine', 'true', now],
      );

      if (kDebugMode) {
        debugPrint(
            "✅ Registered device as billing engine for school: $schoolId");
      }
    } catch (e) {
      debugPrint("❌ Error registering as billing engine: $e");
      rethrow;
    }
  }

  /// Deactivate this device as the billing engine
  /// (Used when transferring authority to another device)
  Future<void> deactivateAsBillingEngine(String schoolId) async {
    try {
      if (!_isInitialized) await initialize();

      final now = DateTime.now().toIso8601String();

      await _db.db.execute(
        'UPDATE billing_engine_registry SET is_active = 0 '
        'WHERE school_id = ? AND device_id = ?',
        [schoolId, _deviceId],
      );

      // Update local security config
      await _db.db.execute(
        'INSERT OR REPLACE INTO local_security_config (key, value, updated_at) VALUES (?, ?, ?)',
        ['is_billing_engine', 'false', now],
      );

      if (kDebugMode) {
        debugPrint(
            "✅ Deactivated device as billing engine for school: $schoolId");
      }
    } catch (e) {
      debugPrint("❌ Error deactivating billing engine: $e");
      rethrow;
    }
  }

  /// Get device name for display purposes
  Future<String> _getDeviceName() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final androidInfo = await _deviceInfo.androidInfo;
        return '${androidInfo.manufacturer} ${androidInfo.model}';
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return iosInfo.model;
      } else {
        return 'Web/Desktop Device';
      }
    } catch (e) {
      return 'Unknown Device';
    }
  }

  String _generateId() => DateTime.now().millisecondsSinceEpoch.toString();

  // Getters
  String get currentDeviceId => _deviceId;
  bool get isInitialized => _isInitialized;
}
