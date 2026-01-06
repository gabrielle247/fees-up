import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/staff_repository.dart';

/// Load all staff for a school
final loadStaffProvider =
    FutureProvider.autoDispose.family<List<StaffMember>, String>(
  (ref, schoolId) async {
    final repository = StaffRepositoryImpl();
    return repository.loadStaff(schoolId);
  },
);

/// Watch staff changes in real-time
final watchStaffProvider =
    StreamProvider.autoDispose.family<List<StaffMember>, String>(
  (ref, schoolId) {
    final repository = StaffRepositoryImpl();
    return repository.watchStaff(schoolId);
  },
);

/// Get staff count by role
final staffCountByRoleProvider =
    FutureProvider.autoDispose.family<Map<String, int>, String>(
  (ref, schoolId) async {
    final repository = StaffRepositoryImpl();
    return repository.getStaffCountByRole(schoolId);
  },
);
