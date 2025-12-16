import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
// Ensure 'uuid' is in pubspec.yaml

import '../services/database_service.dart';

/// Service responsible for two-way synchronization between Local SQLite and Supabase.
///
/// FEATURES:
/// 1. Smart Sync (Incremental): Pushes queue, Pulls updates.
/// 2. Force Push (Nuclear): Uploads ALL local data to server (Backup/Restore).
/// 3. Offline First: Checks connectivity before attempting operations.
/// 4. Data Repair: Automatically fixes timestamp formats (Int -> ISO String).
class SyncDataService {
  // Singleton
  static final SyncDataService instance = SyncDataService._internal();
  SyncDataService._internal();

  final _supabase = Supabase.instance.client;
  bool _isSyncing = false;

  // --- CONFIGURATION ---

  // Order is CRITICAL. Parents must sync before Children to satisfy Foreign Keys.
  // 1. Schools & Users (The Foundation)
  // 2. Terms & Settings (Configuration)
  // 3. Teachers & Classes (Structure)
  // 4. Students & Enrollments (Core Data)
  // 5. Financials & Operations (Transactions)
  final List<String> _tables = [
    'schools',
    'user_profiles',
    'school_terms',
    'teachers',
    'classes',
    'campaigns',
    'students',
    'enrollments',
    'bills',
    'payments',
    'expenses',
    'attendance',
    'campaign_donations',
    // 'teacher_access_tokens',  // Not in local DB
    // 'attendance_sessions',     // Not in local DB
    'student_archives',
  ];

  // Composite keys for updates/deletes
  final Map<String, List<String>> _primaryKeys = const {
    'student_archives': ['id', 'school_id'],
    'students': ['id'],
  };

  // Timestamp columns for incremental pulling
  final Map<String, String> _timestampColumn = const {
    'students': 'last_synced_at',
    'enrollments': 'enrolled_at',
  };

  List<String> _keysFor(String table) => _primaryKeys[table] ?? const ['id'];

  // ---------------------------------------------------------------------------
  // 1. PUBLIC API
  // ---------------------------------------------------------------------------

  /// Main incremental sync. Should be called on app start or "Pull to Refresh".
  Future<bool> triggerSmartSync() async {
    if (_isSyncing) {
      debugPrint("⚠️ Sync skipped: Already in progress.");
      return false;
    }

    if (!await _hasInternetConnection()) {
      debugPrint("⚠️ Sync deferred: No internet.");
      return false;
    }

    _isSyncing = true;
    debugPrint("\n--- 🔄 SMART SYNC STARTED ---");

    try {
      // Step A: Upload pending changes from Queue
      await _pushLocalChanges();

      // Step B: Download new data from Server
      await _pullRemoteChanges();

      debugPrint("--- ✅ SMART SYNC COMPLETED ---\n");
      return true;
    } catch (e, stack) {
      debugPrint("❌ SYNC ERROR: $e");
      debugPrint(stack.toString());
      return false;
    } finally {
      _isSyncing = false;
    }
  }

  // ---------------------------------------------------------------------------
  // 2. PUSH LOGIC (Queue & Bulk Seed)
  // ---------------------------------------------------------------------------

  /// Standard incremental push (reads from 'sync_queue')
  Future<void> _pushLocalChanges() async {
    final db = DatabaseService.instance;
    final pendingItems = await db.getPendingSyncOperations(limit: 50);

    if (pendingItems.isEmpty) {
      // If queue is empty, INTELLIGENTLY check if server needs data
      debugPrint("Push: No pending local changes.");
      debugPrint("Push: Checking if server data matches local...");
      await _smartSeedCheck();
      return;
    }

    debugPrint("Push: Uploading ${pendingItems.length} changes...");
    List<int> successfulIds = [];

    for (var item in pendingItems) {
      try {
        final id = item['id'] as int;
        final table = item['table_name'] as String;
        final op = item['operation'] as String;
        final payloadJson = item['payload'] as String?;

        if (payloadJson == null) continue;
        
        // Transform Payload (Fix Timestamps, Remove Local Cols)
        final rawData = jsonDecode(payloadJson) as Map<String, dynamic>;
        final data = _toServerPayload(table, rawData);

        if (op == 'insert' || op == 'INSERT') {
          // Upsert handles both new records and existing ones
          await _supabase.from(table).upsert(data).select();
        } else if (op == 'update' || op == 'UPDATE') {
          final keys = _keysFor(table);
          var query = _supabase.from(table).update(data);
          for (final k in keys) query = query.eq(k, data[k]);
          await query;
        } else if (op == 'delete' || op == 'DELETE') {
          final keys = _keysFor(table);
          var query = _supabase.from(table).delete();
          for (final k in keys) query = query.eq(k, data[k]);
          await query;
        }

        successfulIds.add(id);
      } catch (e) {
        debugPrint("⚠️ Failed to push item ${item['id']} (${item['table_name']}): $e");
        // Don't add to success list -> will retry later
      }
    }

    if (successfulIds.isNotEmpty) {
      await db.confirmSyncList(successfulIds);
      debugPrint("Push: Confirmed ${successfulIds.length} operations.");
    }
  }

  /// THE "NUCLEAR" OPTION.
  /// Ignores the sync queue and uploads EVERY row in the local database to Supabase.
  /// Use this if the server is empty or data is missing.
  Future<void> forcePushAll() async {
    if (_isSyncing) return;
    _isSyncing = true;
    debugPrint("\n🚨 --- FORCE PUSH STARTED (ALL LOCAL DATA -> SERVER) --- 🚨");

    try {
      // 1. Connectivity Check
      if (!await _hasInternetConnection()) {
        throw Exception("No Internet Connection. Cannot Force Push.");
      }

      final db = DatabaseService.instance;

      // 2. Safety Check: Is the School ID valid?
      // Supabase will reject non-UUIDs (e.g. "SCH_123").
      final schoolRows = await db.query('schools', limit: 1);
      if (schoolRows.isNotEmpty) {
        final schoolId = schoolRows.first['id'].toString();
        if (!Uuid.isValidUUID(fromString: schoolId)) {
          debugPrint("❌ FATAL ERROR: Local School ID '$schoolId' is not a valid UUID.");
          debugPrint("👉 ACTION REQUIRED: Run 'alignAndForcePush(SUPABASE_UUID)' first.");
          return;
        }
      }

      // 3. Reset Flag & Upload
      await db.setMetadata('full_seed_done', ''); // Clear "done" marker
      await _seedServerIfNeeded(force: true);

      debugPrint("🚨 --- FORCE PUSH COMPLETED --- 🚨\n");
    } catch (e, stack) {
      debugPrint("❌ FORCE PUSH CRASHED: $e");
      debugPrint(stack.toString());
    } finally {
      _isSyncing = false;
    }
  }

  /// Bulk Upload Logic (Iterates tables and upserts chunks)
  /// SMART SEED CHECK: Compares local vs server data counts and triggers seed if needed
  Future<void> _smartSeedCheck() async {
    final db = DatabaseService.instance;
    
    // Check critical tables for data discrepancies
    final criticalTables = ['schools', 'students', 'bills', 'payments', 'classes'];
    bool needsSeeding = false;
    Map<String, bool> tablesToSkip = {};
    
    for (final table in criticalTables) {
      try {
        final localCount = (await db.query(table)).length;
        final serverCount = await _getServerRowCount(table);
        
        debugPrint("   📊 $table: Local=$localCount, Server=$serverCount");
        
        // If we have local data but server is empty or has less, we need to seed
        if (localCount > 0 && serverCount < localCount) {
          debugPrint("   ⚠️ Server missing ${localCount - serverCount} rows in $table");
          needsSeeding = true;
          tablesToSkip[table] = false; // Include this table
        } else if (serverCount >= localCount && localCount > 0) {
          debugPrint("   ✅ $table already synced");
          tablesToSkip[table] = true; // Skip this table
        }
      } catch (e) {
        debugPrint("   ❌ Failed to compare $table: $e");
      }
    }
    
    if (needsSeeding) {
      debugPrint("🔄 Server data is incomplete. Triggering selective seed...");
      await _selectiveSeed(tablesToSkip);
    } else {
      debugPrint("✅ Server data is up to date.");
    }
  }

  /// SELECTIVE SEED: Only uploads tables that need syncing (skip tables already synced)
  Future<void> _selectiveSeed(Map<String, bool> tablesToSkip) async {
    final db = DatabaseService.instance;

    debugPrint("⏳ Selective Uploading (Skipping synced tables)...");

    for (final table in _tables) {
      try {
        // Skip if this table is already synced
        if (tablesToSkip[table] == true) {
          debugPrint("   ⏭️ Skipping $table (Already synced)");
          continue;
        }

        // 1. Get ALL local data
        final rows = await db.query(table);
        if (rows.isEmpty) {
          debugPrint("   • Skipping $table (Empty locally)");
          continue;
        }

        // 2. Prepare Payload: Now INCLUDES owed_total, subjects, etc.
        final payload = rows
            .map((r) => _toServerPayload(table, Map<String, dynamic>.from(r)))
            .toList();

        // 3. Upload in Chunks (Supabase limit safety)
        const chunkSize = 50;
        for (var i = 0; i < payload.length; i += chunkSize) {
          final end = (i + chunkSize < payload.length) ? i + chunkSize : payload.length;
          final chunk = payload.sublist(i, end);

          try {
            await _supabase.from(table).upsert(chunk).select();
          } catch (e) {
            debugPrint("   ❌ ERROR on $table (Rows $i-$end): $e");
            // Don't abort - continue with other tables
          }
        }
        debugPrint("   ✅ Uploaded ${payload.length} rows to $table");
        
      } catch (e) {
        debugPrint("   ⚠️ General Error on $table: $e");
        // Continue with next table
      }
    }

    await db.setMetadata('full_seed_done', DateTime.now().toUtc().toIso8601String());
    debugPrint("✅ Selective Upload Complete.");
  }

  Future<void> _seedServerIfNeeded({bool force = false}) async {
    final db = DatabaseService.instance;

    if (!force) {
      final marker = await db.getMetadata('full_seed_done');
      if (marker != null && marker.isNotEmpty) {
        debugPrint("Seed marker found. Skipping. (Use force=true to override)");
        return;
      }
    }

    debugPrint("⏳ Bulk Uploading Tables...");

    for (final table in _tables) {
      try {
        // 1. Get ALL local data
        final rows = await db.query(table);
        if (rows.isEmpty) {
          debugPrint("   • Skipping $table (Empty locally)");
          continue;
        }

        // 2. Prepare Payload: Now INCLUDES owed_total, subjects, etc.
        final payload = rows
            .map((r) => _toServerPayload(table, Map<String, dynamic>.from(r)))
            .toList();

        // 3. Upload in Chunks (Supabase limit safety)
        const chunkSize = 50;
        for (var i = 0; i < payload.length; i += chunkSize) {
          final end = (i + chunkSize < payload.length) ? i + chunkSize : payload.length;
          final chunk = payload.sublist(i, end);

          try {
            await _supabase.from(table).upsert(chunk).select();
          } catch (e) {
            debugPrint("   ❌ ERROR on $table (Rows $i-$end): $e");
            
            // CRITICAL: If foundational tables fail, abort to prevent bad state.
            if (table == 'schools' || table == 'user_profiles') {
               throw Exception("Core table '$table' failed. Aborting sync.");
            }
          }
        }
        debugPrint("   ✅ Uploaded ${payload.length} rows to $table");
        
      } catch (e) {
        debugPrint("   ⚠️ General Error on $table: $e");
        if (table == 'schools') rethrow;
      }
    }

    await db.setMetadata('full_seed_done', DateTime.now().toUtc().toIso8601String());
    debugPrint("✅ Bulk Upload Logic Complete.");
  }

  // ---------------------------------------------------------------------------
  // 4. PAYLOAD SANITIZER (Updated for Inclusivity)
  // ---------------------------------------------------------------------------

  /// Prepares a local SQLite row for Supabase.
  /// NOW INCLUDES fields like 'owed_total', 'subjects', 'billing_date', 'bill_type' 
  /// that were previously stripped but should be synced.
  Map<String, dynamic> _toServerPayload(String table, Map<String, dynamic> data) {
    final copy = Map<String, dynamic>.from(data);

    // --- STRIP ONLY ARTIFACTS ---
    // We allow 'owed_total', 'subjects', 'billing_date', 'bill_type' etc. to pass through now.
    // We only remove things that are logically impossible to insert (e.g. JOIN results).
    const perTableStrip = {
      'user_profiles': ['school_name', 'last_synced_at'], // JOINED from schools + local metadata
      'classes': ['teacher_name'],      // JOINED from teachers
      'enrollments': ['id'],            // Let server decide or keep? Keep if you generated UUID.
      'students': ['last_synced_at'],   // Local sync metadata
      'bills': ['cycle_interval'],      // Local-only column not on server
      'payments': ['method'],           // Local-only column not on server
    };

    final strip = perTableStrip[table] ?? const <String>[];
    for (final k in strip) {
      copy.remove(k);
    }
    
    // Always strip sync meta-data
    copy.remove('is_synced');
    copy.remove('tries');
    // NOTE: We keep 'admin_uid' now, assuming you added it to Supabase.

    // --- FIX TIMESTAMPS (Int -> String) ---
    const timeKeys = {
      'created_at', 'updated_at', 'confirmed_at', 'used_at',
      'session_date', 'date', 'date_paid', 'date_incurred',
      'archived_at', 'enrolled_at', 'start_date', 'end_date',
      'billing_cycle_start', 'billing_cycle_end', 'registration_date',
      'due_date', 'expires_at'
    };

    for (final key in timeKeys) {
      if (copy.containsKey(key)) {
        copy[key] = _asIsoString(copy[key]);
      }
    }

    return copy;
  }

  /// Helper to convert dynamic time values to ISO8601
  String? _asIsoString(dynamic v) {
    if (v == null) return null;
    try {
      if (v is String) return v; // Already String
      if (v is int) {
        // Heuristic: If > 10 billion, it's ms. Else it might be seconds.
        // Assuming ms for Dart DateTime
        return DateTime.fromMillisecondsSinceEpoch(v).toUtc().toIso8601String();
      }
      return v.toString();
    } catch (_) {
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // 3. PULL LOGIC (Download from Cloud)
  // ---------------------------------------------------------------------------

  Future<void> _pullRemoteChanges() async {
    final db = DatabaseService.instance;
    
    final lastSyncStr = await db.getMetadata('last_remote_sync');
    final lastSync = lastSyncStr != null ? DateTime.parse(lastSyncStr) : DateTime(2000);
    final syncStartTime = DateTime.now().toUtc();

    for (final table in _tables) {
      try {
        // Determine how to filter (Incremental vs Full)
        final tsCol = _timestampColumn[table] ?? 'created_at';
        final isoDate = lastSync.toIso8601String();
        
        List<dynamic> rows = [];
        
        try {
          // Attempt incremental fetch
          rows = await _supabase.from(table).select().gt(tsCol, isoDate);
        } catch (_) {
          // Fallback: simple limit if column missing
          rows = await _supabase.from(table).select().limit(100); 
        }

        if (rows.isNotEmpty) {
          debugPrint("Pull: Received ${rows.length} updates for $table");
          for (final row in rows) {
            await _mergeRemoteData(table, row as Map<String, dynamic>);
          }
        }
      } catch (e) {
        debugPrint("⚠️ Pull Error ($table): $e");
      }
    }

    await db.setMetadata('last_remote_sync', syncStartTime.toIso8601String());
  }

  Future<void> _mergeRemoteData(String table, Map<String, dynamic> remote) async {
    final db = DatabaseService.instance;
    final keys = _keysFor(table);
    final where = keys.map((k) => '$k = ?').join(' AND ');
    final args = keys.map((k) => remote[k]).toList();

    final local = await db.query(table, where: where, whereArgs: args);

    if (local.isEmpty) {
      await db.insert(table, remote, queueForSync: false);
    } else {
      if (_shouldOverwrite(local.first, remote)) {
        await db.update(table, remote, where, args, queueForSync: false);
      }
    }
  }

  bool _shouldOverwrite(Map<String, dynamic> local, Map<String, dynamic> remote) {
    // Integrity Guard: Don't let server nullify critical fields we have locally
    const critical = ['full_name', 'amount', 'title', 'total_amount'];
    for (var k in critical) {
      if (remote.containsKey(k) && remote[k] == null && local[k] != null) {
        return false; 
      }
    }
    return true; // Default: Server wins
  }

  // ---------------------------------------------------------------------------
  // 5. UTILS
  // ---------------------------------------------------------------------------

  /// Get the count of rows in a server table (for comparison)
  Future<int> _getServerRowCount(String table) async {
    try {
      // Simple and reliable: just fetch IDs and count them
      final response = await _supabase.from(table).select('id');
      return (response as List).length;
    } catch (e) {
      debugPrint("Failed to get server count for $table: $e");
      return 0;
    }
  }

  Future<bool> _hasInternetConnection() async {
    try {
      final res = await Connectivity().checkConnectivity();
      if (res.contains(ConnectivityResult.none)) return false;
      
      // DNS Check to be sure
      final lookup = await InternetAddress.lookup('google.com');
      return lookup.isNotEmpty && lookup[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}