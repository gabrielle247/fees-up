import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sqflite/sqflite.dart';
import 'package:fees_up/services/database_service.dart';

class SyncRepository {
  final DatabaseService _dbService = DatabaseService();
  final SupabaseClient _supabase = Supabase.instance.client;

  // Keys for tracking sync state
  static const String _kLastSync = 'last_smart_sync_success';
  bool _isSyncing = false;

  // ---------------------------------------------------------------------------
  // 1. SMART SYNC ENTRY POINT
  // ---------------------------------------------------------------------------
  Future<void> runSmartSync({bool force = false}) async {
    if (_isSyncing) return;
    
    // Check Connectivity
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) {
      debugPrint("📴 Offline: Sync skipped.");
      return;
    }

    // Check Authentication
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      debugPrint("🔒 Not logged in: Sync skipped.");
      return;
    }

    _isSyncing = true;
    try {
      debugPrint("🔄 STARTING SMART SYNC...");

      // A. Push Local Changes (Upstream)
      await _pushLocalChanges(userId);

      // B. Pull Server Changes (Downstream)
      await _pullRemoteChanges(userId, force: force);

      // C. Update Success Timestamp
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kLastSync, DateTime.now().toIso8601String());
      
      debugPrint("✅ SMART SYNC COMPLETE.");
    } catch (e) {
      debugPrint("❌ SYNC FAILED: $e");
    } finally {
      _isSyncing = false;
    }
  }

  // ---------------------------------------------------------------------------
  // 2. PUSH ENGINE (Upstream)
  // ---------------------------------------------------------------------------
  Future<void> _pushLocalChanges(String userId) async {
    final db = await _dbService.database;
    
    // Get pending changes from our Sync Queue
    final pending = await db.query('local_sync_queue');
    if (pending.isEmpty) return;

    debugPrint("⬆️ Pushing ${pending.length} local changes...");

    for (final task in pending) {
      final id = task['id'] as int;
      final table = task['table_name'] as String;
      final recordId = task['record_id'] as String;
      final action = task['action'] as String;

      try {
        if (action == 'DELETE') {
          await _supabase.from(table).delete().eq('id', recordId);
        } else {
          // For INSERT/UPDATE, fetch the actual data row
          final rows = await db.query(table, where: (table == 'students') ? 'id = ?' : 'id = ?', whereArgs: [recordId]);
          
          if (rows.isNotEmpty) {
            final data = Map<String, dynamic>.from(rows.first);
            
            // Clean up data for Supabase (Snake Case conversion needed here if inconsistent)
            data['admin_uid'] = userId; 
            data['updated_at'] = DateTime.now().toIso8601String();

            await _supabase.from(table).upsert(data);
          }
        }

        // Remove from queue on success
        await db.delete('local_sync_queue', where: 'id = ?', whereArgs: [id]);
      
      } catch (e) {
        debugPrint("⚠️ Failed to push task #$id ($table): $e");
      }
    }
  }

  // ---------------------------------------------------------------------------
  // 3. PULL ENGINE (Downstream - Delta Sync)
  // ---------------------------------------------------------------------------
  Future<void> _pullRemoteChanges(String userId, {bool force = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final lastSyncTime = prefs.getString(_kLastSync);
    
    // If we have never synced, or 'force' is true, pull everything.
    // Otherwise, filter by 'updated_at' > lastSyncTime
    final isFullSync = force || lastSyncTime == null;

    await Future.wait([
      _syncTable('students', userId, lastSyncTime, isFullSync),
      _syncTable('bills', userId, lastSyncTime, isFullSync),
      _syncTable('payments', userId, lastSyncTime, isFullSync),
    ]);
  }

  Future<void> _syncTable(String table, String userId, String? lastSync, bool isFullSync) async {
    try {
      var query = _supabase.from(table).select().eq('admin_uid', userId);

      if (!isFullSync && lastSync != null) {
        query = query.gt('updated_at', lastSync);
      }

      final List<dynamic> data = await query;
      if (data.isEmpty) return;

      debugPrint("⬇️ Pulled ${data.length} updates for $table");

      final db = await _dbService.database;
      final batch = db.batch();

      for (final row in data) {
        // Here we insert/update logic.
        // Important: We should NOT trigger the 'local_sync_queue' for incoming data!
        // The DatabaseService insert method triggers conflict replacement automatically.
        batch.insert(table, row, conflictAlgorithm: ConflictAlgorithm.replace);
      }
      await batch.commit(noResult: true);

    } catch (e) {
      debugPrint("❌ Pull Error ($table): $e");
    }
  }
}