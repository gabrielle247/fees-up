import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/saas.dart';
import '../repositories/school_repository.dart';
import 'core_providers.dart';

/// Provides the SchoolRepository instance.
final schoolRepositoryProvider = Provider<Future<SchoolRepository>>((ref) async {
  final isar = await ref.watch(isarInstanceProvider);
  return SchoolRepository(isar);
});

/// Provides the current school.
/// Returns null if no school exists (user needs to create one).
final currentSchoolProvider = FutureProvider<School?>((ref) async {
  final repo = await ref.watch(schoolRepositoryProvider);
  return repo.getCurrentSchool();
});
