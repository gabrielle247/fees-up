import 'package:fees_up/data/providers/core_providers.dart';
import 'package:fees_up/data/services/realtime_sync_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final realtimeSyncServiceProvider = Provider<RealtimeSyncService>((ref) {
  final db = ref.watch(driftDatabaseProvider);
  final supabase = Supabase.instance.client;
  return RealtimeSyncService(db: db, supabase: supabase);
});
