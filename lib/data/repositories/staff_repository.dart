import 'package:flutter/foundation.dart';
import '../services/database_service.dart';

/// Staff member model
class StaffMember {
  final String id;
  final String fullName;
  final String email;
  final String role;
  final String? avatarUrl;
  final bool isActive;

  StaffMember({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.avatarUrl,
    this.isActive = true,
  });

  factory StaffMember.fromMap(Map<String, dynamic> map) {
    return StaffMember(
      id: map['id'] as String? ?? '',
      fullName: map['full_name'] as String? ?? 'Unknown',
      email: map['email'] as String? ?? '',
      role: map['role'] as String? ?? 'teacher',
      avatarUrl: map['avatar_url'] as String?,
      isActive: (map['is_banned'] as int? ?? 0) == 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'full_name': fullName,
        'email': email,
        'role': role,
        'avatar_url': avatarUrl,
        'is_banned': isActive ? 0 : 1,
      };
}

/// Interface for staff operations
abstract class IStaffRepository {
  /// Load all staff members for a school
  Future<List<StaffMember>> loadStaff(String schoolId);

  /// Watch staff changes in real-time
  Stream<List<StaffMember>> watchStaff(String schoolId);

  /// Count staff by role
  Future<Map<String, int>> getStaffCountByRole(String schoolId);
}

/// Repository implementation
class StaffRepositoryImpl implements IStaffRepository {
  final DatabaseService _db = DatabaseService();

  @override
  Future<List<StaffMember>> loadStaff(String schoolId) async {
    try {
      final results = await _db.db.getAll(
        '''SELECT 
             up.id, 
             up.full_name, 
             up.email, 
             up.role, 
             up.avatar_url, 
             up.is_banned
           FROM user_profiles up
           WHERE up.school_id = ? AND up.role IN ('super_admin', 'school_admin', 'teacher')
           ORDER BY up.role ASC, up.full_name ASC''',
        [schoolId],
      );

      return results.map((r) => StaffMember.fromMap(r)).toList();
    } catch (e) {
      debugPrint('⚠️ Error loading staff: $e');
      return [];
    }
  }

  @override
  Stream<List<StaffMember>> watchStaff(String schoolId) async* {
    try {
      // Initial load
      yield await loadStaff(schoolId);

      // Periodic polling (5-second intervals)
      while (true) {
        await Future.delayed(const Duration(seconds: 5));
        yield await loadStaff(schoolId);
      }
    } catch (e) {
      debugPrint('⚠️ Error in watchStaff: $e');
      yield [];
    }
  }

  @override
  Future<Map<String, int>> getStaffCountByRole(String schoolId) async {
    try {
      final results = await _db.db.getAll(
        '''SELECT role, COUNT(*) as count
           FROM user_profiles
           WHERE school_id = ? AND role IN ('super_admin', 'school_admin', 'teacher')
           GROUP BY role''',
        [schoolId],
      );

      final counts = <String, int>{};
      for (final row in results) {
        final role = (row['role'] as String?) ?? 'unknown';
        final count = (row['count'] as int?) ?? 0;
        counts[role] = count;
      }
      return counts;
    } catch (e) {
      debugPrint('⚠️ Error getting staff count: $e');
      return {};
    }
  }
}
