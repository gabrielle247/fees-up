import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/drift_database.dart';
import '../repositories/school_repository.dart';
import 'core_providers.dart';

/// Provides the SchoolRepository instance.
final schoolRepositoryProvider = Provider<SchoolRepository>((ref) {
  final db = ref.watch(driftDatabaseProvider);
  return SchoolRepository(db);
});

/// Provides the current school.
/// Returns null if no school exists (user needs to create one).
final currentSchoolProvider = FutureProvider<School?>((ref) async {
  final repo = ref.watch(schoolRepositoryProvider);
  return repo.getCurrentSchool();
});
