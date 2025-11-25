// lib/services/smart_sync_manager.dart (FINAL FIXED VERSION)

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart'; 
import 'package:fees_up/services/local_storage_service.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'offline_sync_service.dart';
// Needed for Sqflite.firstIntValue

// 🛑 FIXED: Renamed to lowerCamelCase
enum SyncIntent {
  fullReconcile,
  checkDataState, 
  autoDebounce,    
}

class SmartSyncManager {
  static final SmartSyncManager _instance = SmartSyncManager._internal();
  factory SmartSyncManager() => _instance;
  SmartSyncManager._internal();

  final OfflineSyncService _syncService = OfflineSyncService();
  final LocalStorageService _localStorage = LocalStorageService(); 
  bool _isSyncing = false;
  Timer? _debounceTimer;

  // ⚙️ CONFIGURATION
  static const int _autoSyncIntervalMinutes = 15;
  static const int _debounceSeconds = 5; 

  /// 🧠 INTELLIGENCE 1: The Public Trigger (Debounced Save)
  void triggerDataChange() {
    debugPrint("🧠 SmartSync: Change detected. Debouncing sync...");
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    _debounceTimer = Timer(const Duration(seconds: _debounceSeconds), () {
      _attemptSmartSync(source: 'AUTO_DEBOUNCE', intent: SyncIntent.autoDebounce);
    });
  }

  /// 🧠 INTELLIGENCE 2: Manual Refresh / Force Sync
  Future<void> forceSync() async {
    // Clear last success stamp to force pulls to ignore delta time
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('last_full_sync_timestamp'); 
    
    await _attemptSmartSync(source: 'MANUAL_FORCE', intent: SyncIntent.fullReconcile, ignoreThrottle: true);
  }
  
  /// 🧠 INTELLIGENCE 3: Initial Load / Dashboard Check
  Future<void> initialLoadSync() async {
    await _attemptSmartSync(source: 'INITIAL_LOAD', intent: SyncIntent.checkDataState);
  }

  /// 🧠 INTELLIGENCE 4: The Engine (Determines WHAT to sync)
  Future<void> _attemptSmartSync({
    required String source,
    required SyncIntent intent,
    bool ignoreThrottle = false,
  }) async {
    if (_isSyncing) {
      debugPrint("🧠 SmartSync: Sync already in progress. Skipping.");
      return;
    }

    // 1. Check Connectivity (Fixed check using List type)
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.none)) { // 🛑 FIXED: Type check
      debugPrint("🧠 SmartSync: No internet. Sync queued for later.");
      return;
    }

    // 2. Check Throttle
    if (!ignoreThrottle) {
      final prefs = await SharedPreferences.getInstance();
      final lastSyncStr = prefs.getString('last_smart_sync_success');
      if (lastSyncStr != null) {
        final lastSync = DateTime.parse(lastSyncStr);
        final difference = DateTime.now().difference(lastSync).inMinutes;
        if (difference < _autoSyncIntervalMinutes) {
          debugPrint("🧠 SmartSync: Throttled. Last sync was $difference mins ago.");
          return;
        }
      }
    }

    _isSyncing = true;
    debugPrint("🚀 STARTING SYNC ($source, Intent: ${intent.name})...");

    try {
      await _syncService.pushLocalChanges();
      
      // 3. PULL: Centralized decision based on intent
      if (intent == SyncIntent.fullReconcile) {
        // Manual Refresh: Run full pull on ALL tables
        await _syncService.runFullSync(); 
        
      } else if (intent == SyncIntent.checkDataState) {
        // Initial Load: Check local integrity before deciding what to pull
        final localStudentCount = await _localStorage.getStudentCount(); // 🛑 Now defined
        
        if (localStudentCount == 0) {
          debugPrint("⚡ INTEL: Local Student count is zero. Forcing Full Pull.");
          await _syncService.runFullSync(); 
        } else {
          debugPrint("⚡ INTEL: Local data found. Running Delta Sync only.");
          // 🛑 Now defined and executable
          await _syncService.runDeltaSync(); 
        }
      } else {
          // AUTO_DEBOUNCE: Run standard delta sync for minimal bandwidth usage
          await _syncService.runDeltaSync(); 
      }

      // Save success time
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'last_smart_sync_success',
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      debugPrint("❌ SmartSync Failed: $e");
    } finally {
      _isSyncing = false;
    }
  }
}
