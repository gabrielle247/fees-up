import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../services/admin_service.dart';
import '../services/database_service.dart';

/// Admin Service Provider (School Admin Operations)
/// 
/// Provides high-level admin operations with school context
final adminServiceProvider = Provider<AdminService>((ref) {
  final dbService = ref.watch(databaseServiceProvider);
  return AdminService(dbService);
});

/// Database Service Provider (Singleton)
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService.instance;
});

/// Current School Admin Context
final adminContextProvider =
    StateNotifierProvider<AdminContextNotifier, AdminContext>((ref) {
  return AdminContextNotifier();
});

class AdminContext {
  final String? schoolId;
  final String? userId;
  final bool isInitialized;

  AdminContext({
    this.schoolId,
    this.userId,
    this.isInitialized = false,
  });

  AdminContext copyWith({
    String? schoolId,
    String? userId,
    bool? isInitialized,
  }) {
    return AdminContext(
      schoolId: schoolId ?? this.schoolId,
      userId: userId ?? this.userId,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

class AdminContextNotifier extends StateNotifier<AdminContext> {
  AdminContextNotifier() : super(AdminContext());

  void initializeContext({
    required String schoolId,
    required String userId,
  }) {
    state = AdminContext(
      schoolId: schoolId,
      userId: userId,
      isInitialized: true,
    );
  }

  void clearContext() {
    state = AdminContext();
  }
}

/// Teacher Access Codes Stream
final accessCodesProvider = FutureProvider<List<Map<String, Object?>>>((ref) async {
  final adminService = ref.watch(adminServiceProvider);
  final context = ref.watch(adminContextProvider);

  if (!context.isInitialized) {
    return [];
  }

  return await adminService.getActiveAccessCodes();
});

/// School Dashboard Data
final schoolDashboardProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final adminService = ref.watch(adminServiceProvider);
  final context = ref.watch(adminContextProvider);

  if (!context.isInitialized) {
    return {};
  }

  return await adminService.getSchoolDashboard();
});

/// Students with Financials
final studentsWithFinancialsProvider =
    FutureProvider<List<dynamic>>((ref) async {
  final adminService = ref.watch(adminServiceProvider);
  final context = ref.watch(adminContextProvider);

  if (!context.isInitialized) {
    return [];
  }

  return await adminService.getStudentsWithFinancials();
});

/// School Campaigns
final schoolCampaignsProvider = FutureProvider<List<Map<String, Object?>>>((ref) async {
  final adminService = ref.watch(adminServiceProvider);
  final context = ref.watch(adminContextProvider);

  if (!context.isInitialized) {
    return [];
  }

  return await adminService.getSchoolCampaigns();
});

/// Attendance Sessions
final attendanceSessionsProvider = FutureProvider<List<Map<String, Object?>>>((ref) async {
  final adminService = ref.watch(adminServiceProvider);
  final context = ref.watch(adminContextProvider);

  if (!context.isInitialized) {
    return [];
  }

  return await adminService.getSchoolAttendanceSessions();
});

/// Permission Audit Log
final permissionAuditProvider = FutureProvider<List<Map<String, Object?>>>((ref) async {
  final adminService = ref.watch(adminServiceProvider);
  final context = ref.watch(adminContextProvider);

  if (!context.isInitialized) {
    return [];
  }

  return await adminService.getPermissionAuditLog();
});

/// Attendance Audit Log
final attendanceAuditProvider = FutureProvider<List<Map<String, Object?>>>((ref) async {
  final adminService = ref.watch(adminServiceProvider);
  final context = ref.watch(adminContextProvider);

  if (!context.isInitialized) {
    return [];
  }

  return await adminService.getAttendanceAuditLog();
});
