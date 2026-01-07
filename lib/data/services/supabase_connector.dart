/// -----------------------------------------------------------------
/// GREYWAY.CO / BATCH TECH - CONFIDENTIAL
/// -----------------------------------------------------------------
/// Author:  Nyasha Gabriel
/// Date:    2025-12-31
/// Ref:     https://supabase.com/docs
///
/// This file defines a SupabaseConnector class that integrates
/// Supabase with PowerSync for data synchronization.
///
/// It implements methods to fetch authentication credentials
/// and upload data changes to the Supabase backend.
///
/// -----------------------------------------------------------------
library supabase_connector;

import 'package:flutter/material.dart';
import 'package:powersync/powersync.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConnector extends PowerSyncBackendConnector {
  final SupabaseClient db;
  bool _hasLoggedAuthWarning = false;

  SupabaseConnector(this.db);

  @override
  Future<PowerSyncCredentials?> fetchCredentials() async {
    final session = db.auth.currentSession;

    if (session == null) {
      // Log once to avoid spam, then return null
      if (!_hasLoggedAuthWarning) {
        debugPrint(
            "⚠️ PowerSync: No authenticated session. Please sign in to start sync.");
        _hasLoggedAuthWarning = true;
      }
      return null;
    }

    // Reset warning flag when session is available
    _hasLoggedAuthWarning = false;

    const endpoint = String.fromEnvironment('POWERSYNC_ENDPOINT_URL');
    if (endpoint.isEmpty) {
      throw Exception('POWERSYNC_ENDPOINT_URL not set in --dart-define');
    }

    // Validate endpoint format
    if (!endpoint.startsWith('https://') && !endpoint.startsWith('http://')) {
      throw Exception('POWERSYNC_ENDPOINT_URL must be a valid URL: $endpoint');
    }

    return PowerSyncCredentials(
      endpoint: endpoint,
      token: session.accessToken,
      userId: session.user.id,
    );
  }

  @override
  Future<void> uploadData(PowerSyncDatabase database) async {
    final transaction = await database.getNextCrudTransaction();
    if (transaction == null) return;

    try {
      for (var op in transaction.crud) {
        final table = op.table;
        final id = op.id;
        final data = op.opData;

        // "Create or Update" Logic
        if (op.op == UpdateType.put) {
          if (data == null) {
            debugPrint('⚠️ Warning: data is null for PUT operation on $table');
            continue;
          }
          // .upsert is the safest bet: it handles both new and existing records.
          // onConflict: 'id' ensures we don't get duplicate key errors.
          await db.from(table).upsert(
            {...data, 'id': id},
            onConflict: 'id',
            ignoreDuplicates: false,
          );
        } else if (op.op == UpdateType.patch) {
          if (data == null) {
            debugPrint('⚠️ Warning: data is null for PATCH operation on $table');
            continue;
          }
          await db.from(table).update(data).eq('id', id);
        } else if (op.op == UpdateType.delete) {
          await db.from(table).delete().eq('id', id);
        }
      }

      // Clear the queue once finished
      await transaction.complete();
    } on PostgrestException catch (e) {
      // 42501 = RLS Violation.
      // 23503 = Foreign Key Violation (Key is not present in table).
      // If we don't .complete() here, this one row blocks the WHOLE app sync loop.
      if (e.code == '42501' || e.code == '23503') {
        debugPrint(
            '❌ Sync Error ${e.code} on $transaction: ${e.message}. Skipping to unblock queue.');
        await transaction.complete();
      } else {
        // For network or server 500 errors, we rethrow so PowerSync retries later.
        rethrow;
      }
    } catch (e) {
      debugPrint('Sync Upload Error: $e');
      rethrow;
    }
  }
}
