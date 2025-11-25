// lib/services/offline_sync_service.dart

import 'dart:convert';
import 'package:fees_up/models/admin_profile.dart';
import 'package:fees_up/services/local_storage_service.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/database_service.dart';

class OfflineSyncService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final DatabaseService _dbService = DatabaseService();

  static const String _kLastSyncStudents = 'last_delta_sync_students';
  static const String _kLastSyncPayments = 'last_delta_sync_payments';
  static const String _kLastSyncNotifs = 'last_delta_sync_notifications';
  static const String _kLastSyncBills = 'last_delta_sync_bills';
  static const String _kInitialSyncDoneKey =
      'has_successfully_pushed_initial_data';

  // ===========================================================================
  // ⚡ GRANULAR SYNC (The "Extra Method")
  // ===========================================================================

  Future<void> syncItemImmediately(String table, String recordId) async {
    debugPrint("⚡ Immediate Sync: Pushing $table ($recordId)...");
    await _processPushQueue(specificTable: table, specificRecordId: recordId);
  }

  // ===========================================================================
  // 🔼 PUSH ENGINE (Smart Upsert)
  // ===========================================================================

  Future<void> pushLocalChanges() async {
    await _processPushQueue();
  }

  Future<void> _processPushQueue({
    String? specificTable,
    String? specificRecordId,
  }) async {
    final db = await _dbService.database;

    String? where;
    List<dynamic>? args;

    if (specificTable != null && specificRecordId != null) {
      where = 'table_name = ? AND record_id = ?';
      args = [specificTable, specificRecordId];
    }

    final pendingChanges = await db.query(
      'local_sync_status',
      where: where,
      whereArgs: args,
    );
    if (pendingChanges.isEmpty) return;

    if (specificTable == null) {
      debugPrint("🚀 Batch Sync: Processing ${pendingChanges.length} items...");
    }

    Map<String, Set<String>> updatesToPush = {};
    Map<String, Set<String>> deletesToPush = {};

    for (var change in pendingChanges) {
      final table = change['table_name'] as String;
      final id = change['record_id'] as String;
      final action = change['action'] as String;

      if (action == 'DELETE') {
        deletesToPush.putIfAbsent(table, () => {}).add(id);
      } else {
        updatesToPush.putIfAbsent(table, () => {}).add(id);
      }
    }

    for (var table in updatesToPush.keys) {
      final ids = updatesToPush[table]!.toList();
      if (ids.isEmpty) continue;

      try {
        for (var i = 0; i < ids.length; i += 50) {
          final chunk = ids.sublist(
            i,
            ids.length < i + 50 ? ids.length : i + 50,
          );

          final localDataList = await db.query(
            table,
            where: (table == 'students')
                ? 'studentId IN (${List.filled(chunk.length, '?').join(',')})'
                : 'id IN (${List.filled(chunk.length, '?').join(',')})',
            whereArgs: chunk,
          );

          if (localDataList.isNotEmpty) {
            final serverPayload = localDataList
                .map((row) => _mapLocalToServer(table, row))
                .toList();

            if (table == 'students') {
              await _supabase
                  .from(table)
                  .upsert(serverPayload, onConflict: 'student_id');
            } else {
              await _supabase.from(table).upsert(serverPayload);
            }

            debugPrint(
              "⬆️ Batch Synced ${serverPayload.length} rows to $table",
            );
          }

          await db.delete(
            'local_sync_status',
            where:
                'table_name = ? AND record_id IN (${List.filled(chunk.length, '?').join(',')})',
            whereArgs: [table, ...chunk],
          );
        }
      } catch (e) {
        debugPrint("⚠️ Batch Push Error ($table): $e");
      }
    }

    for (var table in deletesToPush.keys) {
      final ids = deletesToPush[table]!.toList();
      if (ids.isEmpty) continue;

      try {
        final idListString = '(${ids.map((e) => '"$e"').join(',')})';

        await _supabase
            .from(table)
            .delete()
            .filter(
              (table == 'students') ? 'student_id' : 'id',
              'in',
              idListString,
            );

        await db.delete(
          'local_sync_status',
          where:
              'table_name = ? AND record_id IN (${List.filled(ids.length, '?').join(',')})',
          whereArgs: [table, ...ids],
        );
        debugPrint("❌ Batch Deleted ${ids.length} rows from $table");
      } catch (e) {
        debugPrint("⚠️ Delete Error ($table): $e");
      }
    }
  }

  // 🔍 MAPPING LOGIC (CRITICAL: Must send admin_uid and updated_at)
  Map<String, dynamic> _mapLocalToServer(
    String table,
    Map<String, dynamic> local,
  ) {
    final uid = _supabase.auth.currentUser?.id;
    final now = DateTime.now().toIso8601String();

    if (table == 'students') {
      return {
        'student_id': local['studentId'],
        'student_name': local['studentName'],
        'registration_date': local['registrationDate'],
        'is_active': (local['isActive'] == 1),
        'default_monthly_fee': local['defaultMonthlyFee'],
        'parent_contact': local['parentContact'],
        'frequency': local['frequency'],
        'subjects': (local['subjects'] != null)
            ? jsonDecode(local['subjects'])
            : [],
        'admin_uid': uid,
        'updated_at': now,
      };
    } else if (table == 'bills') {
      return {
        'id': local['id'],
        'student_id': local['studentId'],
        'total_amount': local['totalAmount'],
        'paid_amount': local['paidAmount'],
        'month_year': local['monthYear'],
        'due_date': local['dueDate'],
        'created_at': local['createdAt'],
        'admin_uid': uid,
        'updated_at': now,
      };
    } else if (table == 'payments') {
      return {
        'id': local['id'],
        'bill_id': local['billId'],
        'student_id': local['studentId'],
        'amount': local['amount'],
        'date_paid': local['datePaid'],
        'method': local['method'],
        'admin_uid': uid,
        'updated_at': now,
      };
    } else if (table == 'notifications') {
      return {
        'id': local['id'],
        'title': local['title'],
        'body': local['body'],
        'timestamp': local['timestamp'],
        'is_read': (local['isRead'] == 1),
        'type': local['type'],
        'admin_uid': uid,
        'updated_at': now,
      };
    }
    return local;
  }

  // ===========================================================================
  // 🔽 PULL: DELTA SYNC (Budget Friendly)
  // ===========================================================================

  Future<void> syncStudents() async {
    debugPrint("📥 syncStudents: starting (prefKey=$_kLastSyncStudents)");
    await _performDeltaSync(
      tableName: 'students',
      prefKey: _kLastSyncStudents,
      onBatchReceived: (batch) async {
        final db = await _dbService.database;
        final sqlBatch = db.batch();
        for (var item in batch) {
          sqlBatch.insert('students', {
            'studentId': item['student_id'],
            'studentName': item['student_name'],
            'registrationDate': item['registration_date'],
            'isActive': (item['is_active'] == true) ? 1 : 0,
            'defaultMonthlyFee': item['default_monthly_fee'],
            'parentContact': item['parent_contact'],
            'frequency': item['frequency'],
            'subjects': (item['subjects'] is List)
                ? jsonEncode(item['subjects'])
                : item['subjects'],
            'admin_uid': item['admin_uid'],
          }, conflictAlgorithm: ConflictAlgorithm.replace);
        }
        await sqlBatch.commit(noResult: true);
      },
    );
  }

  Future<void> syncPayments() async {
    debugPrint("📥 syncPayments: starting (prefKey=$_kLastSyncPayments)");
    await _performDeltaSync(
      tableName: 'payments',
      prefKey: _kLastSyncPayments,
      onBatchReceived: (batch) async {
        final db = await _dbService.database;
        final sqlBatch = db.batch();
        for (var item in batch) {
          sqlBatch.insert('payments', {
            'id': item['id'],
            'billId': item['bill_id'],
            'studentId': item['student_id'],
            'amount': item['amount'],
            'datePaid': item['date_paid']?.toString(),
            'method': item['method'],
            'admin_uid': item['admin_uid'],
          }, conflictAlgorithm: ConflictAlgorithm.replace);
        }
        await sqlBatch.commit(noResult: true);
      },
    );
  }

  Future<void> syncNotifications() async {
    debugPrint("📥 syncNotifications: starting (prefKey=$_kLastSyncNotifs)");
    await _performDeltaSync(
      tableName: 'notifications',
      prefKey: _kLastSyncNotifs,
      onBatchReceived: (batch) async {
        final db = await _dbService.database;
        final sqlBatch = db.batch();
        for (var item in batch) {
          sqlBatch.insert('notifications', {
            'id': item['id'],
            'title': item['title'],
            'body': item['body'],
            'timestamp': item['timestamp'],
            'isRead': (item['is_read'] == true) ? 1 : 0,
            'type': item['type'],
            'admin_uid': item['admin_uid'],
          }, conflictAlgorithm: ConflictAlgorithm.replace);
        }
        await sqlBatch.commit(noResult: true);
      },
    );
  }

  // lib/services/offline_sync_service.dart

  // 🧠 GENERIC DELTA ENGINE (Robust & Verbose)
  Future<void> _performDeltaSync({
    required String tableName,
    required String prefKey,
    required Function(List<dynamic>) onBatchReceived,
  }) async {
    final userId = _supabase.auth.currentUser?.id;

    if (userId == null) {
      debugPrint("⚠️ Delta Pull Skipped ($tableName): User not authenticated.");
      return;
    }

    final bool requiresAdminFilter =
        tableName == 'students' ||
        tableName == 'bills' ||
        tableName == 'payments' ||
        tableName == 'notifications';

    try {
      final db = await _dbService.database;
      final prefs = await SharedPreferences.getInstance();

      // NEW INTELLIGENCE: Check Local Data Count
      final localCount =
          Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM $tableName'),
          ) ??
          0;

      final lastSyncTime = prefs.getString(prefKey);

      debugPrint(
        "🔎 DeltaSync START: table=$tableName LocalCount=$localCount requiresAdminFilter=$requiresAdminFilter userId=$userId lastSync=$lastSyncTime",
      );

      // Build base query
      var query = _supabase.from(tableName).select();

      // 1. Apply RLS Filter FIRST
      if (requiresAdminFilter) {
        // FIX: Use .filter() for compatibility
        query = query.filter('admin_uid', 'eq', userId);
        debugPrint("🔎 Applied admin_uid filter on $tableName = $userId");
      }

      // 2. APPLY INTELLIGENCE: Decide whether to use the timestamp filter
      if (localCount > 0 && lastSyncTime != null) {
        // Delta pull: Apply filter only if data exists locally AND we have a timestamp.
        debugPrint(
          "🔎 Applying updated_at > $lastSyncTime for $tableName (Delta)",
        );
        query = query.filter('updated_at', 'gt', lastSyncTime);
      } else {
        // If localCount is 0 OR lastSyncTime is null, force a full pull (no filter added).
        if (localCount == 0) {
          debugPrint(
            "⚡ Forced FULL PULL for $tableName (Local table is empty).",
          );
        } else {
          debugPrint(
            "🔎 No last sync for $tableName; performing full fetch (Missing Preference).",
          );
        }
      }

      // Execute
      dynamic response;
      try {
        response = await query;
      } catch (e) {
        debugPrint(
          "⚠️ Delta query failed for $tableName with filters (adminFilter=$requiresAdminFilter, lastSync=$lastSyncTime): $e",
        );

        // Retry path: try without updated_at filter (common schema mismatch fallback)
        try {
          var retryQuery = _supabase.from(tableName).select();
          if (requiresAdminFilter) {
            retryQuery = retryQuery.filter('admin_uid', 'eq', userId);
          }
          response = await retryQuery;
          debugPrint(
            "🔁 Retry succeeded for $tableName (without updated_at filter)",
          );
        } catch (e2) {
          debugPrint("⚠️ Retry also failed for $tableName: $e2");
          response = []; // give up gracefully
        }
      }

      response ??= [];
      final count = (response is List) ? response.length : 0;
      debugPrint("📥 Delta Sync result for $tableName -> $count rows");

      if (count > 0) {
        await onBatchReceived(response);
      } else {
        debugPrint("ℹ️ No changes returned for $tableName.");
      }

      // Mark up-to-date
      await prefs.setString(prefKey, DateTime.now().toIso8601String());
      debugPrint("✅ Marked $tableName last sync time updated.");
    } catch (e) {
      debugPrint("❌ Delta Pull Failed ($tableName): $e");
    }
  }

  Future<void> syncAdminProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    debugPrint("📥 Delta Sync: Pulling Admin Profile...");
    try {
      // Build query
      var query = _supabase
          .from('admin_profile')
          .select('full_name, school_name, avatar_url, last_synced_at')
          // 🛑 FIX: Replace .eq() with .filter() for compatibility
          .filter('id', 'eq', user.id);

      final serverProfile = await query.single();

      final localProfile = AdminProfile.fromSupabaseRow(
        user.id,
        user.email,
        serverProfile,
      );

      await LocalStorageService().saveAdminProfile(localProfile);
    } catch (e) {
      if (e is PostgrestException && e.code == 'PGRST116') {
        debugPrint("Profile not found on server. Skipping pull.");
      } else {
        debugPrint("❌ Profile Sync Failed: $e");
      }
    }
  }

  Future<void> syncBills() async {
    debugPrint("📥 syncBills: starting (prefKey=$_kLastSyncBills)");
    await _performDeltaSync(
      tableName: 'bills',
      prefKey: _kLastSyncBills,
      onBatchReceived: (batch) async {
        final db = await _dbService.database;
        final sqlBatch = db.batch();

        for (var item in batch) {
          sqlBatch.insert('bills', {
            'id': item['id'],
            'studentId': item['student_id'],
            'totalAmount': item['total_amount'],
            'paidAmount': item['paid_amount'],
            'monthYear': item['month_year'],
            'dueDate': item['due_date'],
            'createdAt': item['created_at'],
            'admin_uid': item['admin_uid'],
          }, conflictAlgorithm: ConflictAlgorithm.replace);
        }

        await sqlBatch.commit(noResult: true);
      },
    );
  }

  // ===========================================================================
  // 🚀 MASTER SYNC
  // ===========================================================================
  Future<void> runFullSync() async {
    if (_supabase.auth.currentUser == null) return;

    debugPrint("🚀 STARTING SMART SYNC...");

    // 1. Smart Reconciliation (Synchronous but guarded)
    await reconcileDataState();

    // 2. Push Queue (Synchronous)
    await pushLocalChanges();

    // 3. Pull Deltas (Parallel with per-task error handling)
    await Future.wait([
      syncAdminProfile().catchError((e) {
        debugPrint("❌ Admin Profile Pull Failed: $e");
      }),
      syncStudents().catchError((e) {
        debugPrint("❌ Students Pull Failed: $e");
      }),
      syncBills().catchError((e) {
        debugPrint("❌ Bills Pull Failed: $e");
      }),
      syncPayments().catchError((e) {
        debugPrint("❌ Payments Pull Failed: $e");
      }),
      syncNotifications().catchError((e) {
        debugPrint("❌ Notifications Pull Failed: $e");
      }),
    ]);

    debugPrint("🏁 SYNC COMPLETE.");
  }

  // 🧠 RECONCILIATION (Smart Check)
  Future<void> reconcileDataState() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_kInitialSyncDoneKey) ?? false) {
      return;
    }

    try {
      final db = await _dbService.database;
      final localCount =
          Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM students'),
          ) ??
          0;

      if (localCount == 0) {
        await prefs.setBool(_kInitialSyncDoneKey, true);
        return;
      }

      int? serverCount;
      try {
        final userId = _supabase.auth.currentUser?.id;
        if (userId == null) {
          debugPrint(
            "⚠️ reconcileDataState: no authenticated user, skipping server count",
          );
          await prefs.setBool(_kInitialSyncDoneKey, true);
          return;
        }

        // 🛑 FIX: Replace .eq() with .filter() for compatibility
        final serverCountQuery = _supabase
            .from('students')
            .select()
            .filter('admin_uid', 'eq', userId);
        serverCount = (await serverCountQuery.count(CountOption.exact)) as int?;

        debugPrint(
          "🔁 reconcileDataState: serverCount(for admin $userId) = $serverCount, localCount = $localCount",
        );
      } catch (e) {
        debugPrint(
          "⚠️ reconcileDataState: failed to get server count (will not force-queue): $e",
        );
        serverCount = null;
      }

      if (serverCount != null && serverCount == 0 && localCount > 0) {
        debugPrint(
          "🚨 Empty Server Detected for this admin. Queueing local data...",
        );
        await _forceQueueAllData(db);
        await pushLocalChanges();
        await prefs.setBool(_kInitialSyncDoneKey, true);
      } else {
        await prefs.setBool(_kInitialSyncDoneKey, true);
      }
    } catch (e) {
      debugPrint("⚠️ Reconcile skipped: $e");
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_kInitialSyncDoneKey, true);
      } catch (_) {}
    }
  }

  // lib/services/offline_sync_service.dart (Changes)

  // ... (Inside the OfflineSyncService class definition) ...

  // 🛑 NEW: Wrapper for performing a delta sync of ALL core tables
  Future<void> runDeltaSync() async {
    // This executes the essential pull methods in parallel
    await Future.wait([
      syncStudents().catchError((e) {
        debugPrint("❌ Students Delta Failed: $e");
      }),
      syncBills().catchError((e) {
        debugPrint("❌ Bills Delta Failed: $e");
      }),
      syncPayments().catchError((e) {
        debugPrint("❌ Payments Delta Failed: $e");
      }),
      syncNotifications().catchError((e) {
        debugPrint("❌ Notifications Delta Failed: $e");
      }),
    ]);
  }

  Future<void> _forceQueueAllData(Database db) async {
    // ... keep existing force-queue logic (unchanged) ...
  }
}
