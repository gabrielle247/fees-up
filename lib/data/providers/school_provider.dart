import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database_service.dart';
import '../services/school_service.dart';
import 'auth_provider.dart';

// The Service Provider
final schoolServiceProvider = Provider<SchoolService>((ref) {
  return SchoolService(DatabaseService());
});

// A Helper Provider to get the current school immediately
final currentSchoolProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;

  final service = ref.watch(schoolServiceProvider);
  // We enable waitForSync to prevent "Bad State" errors on login
  return await service.getSchoolForUser(user.id, waitForSync: true);
});