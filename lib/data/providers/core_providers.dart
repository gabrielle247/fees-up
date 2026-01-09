import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fees_up/data/database/drift_database.dart';

/// Provides the Drift database instance
final driftDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

/// Provides the current school ID from the first school in the database
final currentSchoolIdProvider = FutureProvider<String>((ref) async {
  final db = ref.watch(driftDatabaseProvider);
  final schools = await db.select(db.schools).get();
  if (schools.isEmpty) throw Exception('No school found');
  return schools.first.id;
});
