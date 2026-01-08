import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../services/isar_service.dart';
import '../models/access.dart';
import '../models/saas.dart';

/// Provides the initialized Isar instance.
/// Throws an error if IsarService hasn't been initialized yet.
final isarInstanceProvider = Provider<Future<Isar>>((ref) async {
  return IsarService().db;
});

/// Provides the current School.
final currentSchoolProvider = FutureProvider<School?>((ref) async {
  final isar = await ref.watch(isarInstanceProvider);
  return await isar.schools.where().findFirst();
});

/// Provides the current School ID.
/// TODO: In a real app with auth, this would come from the user's profile or session.
/// For now, we return a fixed ID or derive it from the first available school.
final currentSchoolIdProvider = FutureProvider<String>((ref) async {
  final school = await ref.watch(currentSchoolProvider.future);
  if (school != null) {
    return school.id;
  }

  // Fallback constant for development if DB is empty
  return 'school_default_id';
});

/// Provides the current User Profile.
final currentUserProfileProvider = FutureProvider<Profile?>((ref) async {
  final isar = await ref.watch(isarInstanceProvider);
  // In a real app, filter by the logged-in user's UID.
  // Here we just take the first one or null.
  return await isar.profiles.where().findFirst();
});
