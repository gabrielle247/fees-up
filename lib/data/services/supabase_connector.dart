import 'package:powersync/powersync.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConnector extends PowerSyncBackendConnector {
  final SupabaseClient db;

  SupabaseConnector(this.db);

  @override
  Future<PowerSyncCredentials?> fetchCredentials() async {
    // 1. Get current session
    final session = db.auth.currentSession;
    if (session == null) {
      return null;
    }

    // 2. Fetch credentials using the Environment Variable from Makefile
    // passed via --dart-define=POWERSYNC_ENDPOINT_URL=...
    const endpoint = String.fromEnvironment('POWERSYNC_ENDPOINT_URL');

    if (endpoint.isEmpty) {
      throw Exception('POWERSYNC_ENDPOINT_URL not set in --dart-define');
    }

    final token = session.accessToken;
    final userId = session.user.id;

    return PowerSyncCredentials(
      endpoint: endpoint,
      token: token,
      userId: userId,
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

        // Map PowerSync CRUD to Supabase
        if (op.op == UpdateType.put) {
          await db.from(table).upsert({...data!, 'id': id});
        } else if (op.op == UpdateType.patch) {
          await db.from(table).update(data!).eq('id', id);
        } else if (op.op == UpdateType.delete) {
          await db.from(table).delete().eq('id', id);
        }
      }
      await transaction.complete();
    } catch (e) {
      // Error handling: if it's a permanent error, we might need to complete() it 
      // to unblock the queue, but for connectivity issues, we leave it.
      print('Sync Upload Error: $e'); 
    }
  }
}