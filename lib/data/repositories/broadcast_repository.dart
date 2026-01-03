import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/broadcast_model.dart';

class BroadcastRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// STREAM 1: Real-time School Broadcasts (Online-Only)
  /// Note: Supabase stream filters are limited to 'eq'. 
  /// Exclusion logic for 'hq_internal' is handled in the map.
  Stream<List<Broadcast>> watchSchoolBroadcasts(String schoolId) {
    return _supabase
        .from('broadcasts')
        .stream(primaryKey: ['id'])
        .eq('school_id', schoolId)
        .order('created_at')
        .map((rows) => rows
            .map((row) => Broadcast.fromRow(row))
            .where((b) => b.targetRole != 'hq_internal')
            .toList());
  }

  /// STREAM 2: Real-time Internal HQ Broadcasts (Online-Only)
  Stream<List<Broadcast>> watchInternalHQBroadcasts() {
    return _supabase
        .from('broadcasts')
        .stream(primaryKey: ['id'])
        .eq('target_role', 'hq_internal')
        .order('created_at')
        .map((rows) => rows.map((row) => Broadcast.fromRow(row)).toList());
  }

  /// Post Update (Direct to Supabase)
  Future<void> postBroadcast({
    required Map<String, dynamic> data,
  }) async {
    try {
      await _supabase.from('broadcasts').insert(data);
    } catch (e) {
      throw Exception('Greyway.Co Realtime Failure: $e');
    }
  }
}