import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dashboard_provider.dart';
import '../repositories/users_repository.dart';

final usersRepositoryProvider = Provider((ref) => UsersRepository());

// Live list of users for the current school
final schoolUsersProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final dashboard = await ref.watch(dashboardDataProvider.future);
  final repo = ref.watch(usersRepositoryProvider);
  
  if (dashboard.schoolId.isEmpty) return [];
  
  return repo.getSchoolUsers(dashboard.schoolId);
});