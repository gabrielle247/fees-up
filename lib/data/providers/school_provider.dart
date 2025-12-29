import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fees_up/data/services/database_service.dart';
import 'package:fees_up/data/services/school_service.dart';
import 'package:fees_up/data/providers/auth_provider.dart';

// 1. The Service Provider
final schoolServiceProvider = Provider<SchoolService>((ref) {
  return SchoolService(DatabaseService());
});

// 2. A Helper Provider to get the current school Map immediately
//    CRITICAL LOGIC: This uses 'getSchoolForUser' which performs the lookup:
//    Auth ID -> User Profile -> School ID -> School Record
final currentSchoolProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;

  final service = ref.watch(schoolServiceProvider);
  
  // We pass the USER ID (Auth ID) here. 
  // The service internally finds the profile linked to this user, 
  // extracts the 'school_id', and returns the School row.
  return await service.getSchoolForUser(user.id, waitForSync: true);
});

// 3. The ID Selector (REQUIRED by Expense, Student, and Billing features)
//    This extracts the actual 'school_id' from the school record we just fetched.
final activeSchoolIdProvider = Provider<String?>((ref) {
  final schoolAsync = ref.watch(currentSchoolProvider);
  
  // The 'id' inside this map is the SCHOOL ID (from the schools table), 
  // NOT the User ID.
  return schoolAsync.value?['id'] as String?;
});