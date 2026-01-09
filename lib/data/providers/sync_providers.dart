import 'package:fees_up/data/providers/core_providers.dart';
import 'package:fees_up/data/services/sync_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final syncServiceProvider = Provider<SyncService>((ref) {
  final db = ref.watch(driftDatabaseProvider);
  final supabase = Supabase.instance.client;
  return SyncService(supabase: supabase, db: db);
});
