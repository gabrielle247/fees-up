import 'package:flutter/foundation.dart';

import '../models/student_full.dart';
import 'database_service.dart';

/// ============================================================================
/// ADMIN SERVICE (School Admin Operations)
/// ============================================================================
/// Provides high-level operations for school admins to manage:
/// - Teacher access tokens (delegating attendance/campaign duties)
/// - Attendance sessions (marking attendance via delegated admins)
/// - Campaigns (creating campaigns with teacher permission)
/// - Bulk operations and reporting
///
/// This is the main admin-only interface for managing school operations.
/// ============================================================================

class AdminService {
  final DatabaseService _db;
  String? _currentSchoolId;
  String? _currentUserId;

  AdminService(this._db);

  /// Initialize admin context
  void initializeContext({required String schoolId, required String userId}) {
    _currentSchoolId = schoolId;
    _currentUserId = userId;
  }

  /// Verify current admin context
  void _ensureContext() {
    if (_currentSchoolId == null || _currentUserId == null) {
      throw Exception('Admin context not initialized');
    }
  }

  // ===========================================================================
  // TEACHER ACCESS TOKEN MANAGEMENT
  // ===========================================================================

  /// Generate a one-time access code for a teacher
  ///
  /// Usage:
  /// ```
  /// final code = await adminService.generateTeacherAccessCode(
  ///   teacherId: 'teacher-123',
  ///   permissionType: 'attendance', // or 'campaigns' or 'both'
  ///   expiresIn: Duration(hours: 2),
  /// );
  /// // Share code with student_admin via SMS/Email
  /// ```
  Future<String> generateTeacherAccessCode({
    required String teacherId,
    required String permissionType,
    Duration expiresIn = const Duration(hours: 4),
  }) async {
    _ensureContext();

    final code = await _db.createTeacherAccessToken(
      schoolId: _currentSchoolId!,
      teacherId: teacherId,
      permissionType: permissionType,
      expiresIn: expiresIn,
    );

    if (kDebugMode) {
      print('✓ Generated access code: $code for teacher: $teacherId');
    }

    return code;
  }

  /// Get all active access codes for school
  Future<List<Map<String, Object?>>> getActiveAccessCodes() async {
    _ensureContext();
    return await _db.getUnusedAccessTokens(_currentSchoolId!);
  }

  /// Revoke/invalidate an access code (mark as used)
  Future<void> revokeAccessCode(String tokenId) async {
    await _db.markAccessTokenAsUsed(tokenId);
    if (kDebugMode) print('✓ Access code revoked');
  }

  // ===========================================================================
  // ATTENDANCE SESSION MANAGEMENT
  // ===========================================================================

  /// Create an attendance session with a valid access code
  ///
  /// Usage:
  /// ```
  /// final sessionId = await adminService.createAttendanceSession(
  ///   accessCode: 'ABC123',
  ///   classId: 'class-456',
  ///   teacherId: 'teacher-789',
  ///   sessionDate: DateTime.now(),
  /// );
  /// ```
  Future<String> createAttendanceSession({
    required String accessCode,
    required String classId,
    required String teacherId,
    required DateTime sessionDate,
  }) async {
    _ensureContext();

    // Validate access code
    final token = await _db.getAccessTokenByCode(accessCode);
    if (token == null) throw Exception('Invalid access code');
    if (token['is_used'] == 1) throw Exception('Access code already used');

    final expiresAt = DateTime.parse(token['expires_at'] as String);
    if (DateTime.now().isAfter(expiresAt)) throw Exception('Access code expired');

    if (token['permission_type'] != 'attendance' && token['permission_type'] != 'both') {
      throw Exception('This code does not permit attendance marking');
    }

    // Create session
    final sessionId = await _db.createAttendanceSession(
      schoolId: _currentSchoolId!,
      classId: classId,
      teacherId: teacherId,
      studentAdminId: _currentUserId!,
      accessTokenId: token['id'] as String,
      sessionDate: sessionDate,
    );

    if (kDebugMode) {
      print('✓ Attendance session created: $sessionId');
    }

    return sessionId;
  }

  /// Mark attendance for multiple students
  ///
  /// Usage:
  /// ```
  /// await adminService.markBulkAttendance(
  ///   sessionId: 'sess-123',
  ///   classId: 'class-456',
  ///   attendanceDate: DateTime.now(),
  ///   attendanceData: [
  ///     {'studentId': 'STU-001', 'status': 'present'},
  ///     {'studentId': 'STU-002', 'status': 'absent', 'remarks': 'Sick'},
  ///   ],
  /// );
  /// ```
  Future<void> markBulkAttendance({
    required String sessionId,
    required String classId,
    required DateTime attendanceDate,
    required List<Map<String, dynamic>> attendanceData,
  }) async {
    _ensureContext();

    await _db.markBulkAttendance(
      sessionId: sessionId,
      classId: classId,
      attendanceDate: attendanceDate,
      attendanceRecords: attendanceData
          .map((data) => {
                ...data,
                'admin_uid': _currentUserId,
              })
          .toList(),
    );

    if (kDebugMode) {
      print('✓ Marked ${attendanceData.length} attendance records');
    }
  }

  /// Get all pending attendance sessions awaiting teacher confirmation
  Future<List<Map<String, Object?>>> getPendingAttendanceSessions(
    String teacherId,
  ) async {
    return await _db.getPendingAttendanceSessions(teacherId);
  }

  /// Get all attendance sessions for the school
  Future<List<Map<String, Object?>>> getSchoolAttendanceSessions() async {
    _ensureContext();
    return await _db.getAttendanceSessionsForSchool(_currentSchoolId!);
  }

  // ===========================================================================
  // CAMPAIGN MANAGEMENT
  // ===========================================================================

  /// Create a new campaign
  ///
  /// Usage:
  /// ```
  /// final campaignId = await adminService.createCampaign(
  ///   title: 'Sports Equipment Fund',
  ///   description: 'Collecting funds for new sports equipment',
  ///   goalAmount: 5000,
  /// );
  /// ```
  Future<String> createCampaign({
    required String title,
    String? description,
    double goalAmount = 0,
  }) async {
    _ensureContext();

    final campaignId = await _db.createCampaign({
      'school_id': _currentSchoolId,
      'title': title,
      'description': description,
      'goal_amount': goalAmount,
      'status': 'active',
      'admin_uid': _currentUserId,
    });

    if (kDebugMode) print('✓ Campaign created: $campaignId');
    return campaignId;
  }

  /// Get all campaigns for school
  Future<List<Map<String, Object?>>> getSchoolCampaigns() async {
    _ensureContext();
    return await _db.getCampaignsForSchool(_currentSchoolId!);
  }

  /// Update campaign status
  Future<void> updateCampaignStatus(String campaignId, String status) async {
    await _db.updateCampaignStatus(campaignId, status);
    if (kDebugMode) print('✓ Campaign $campaignId status updated to: $status');
  }

  // ===========================================================================
  // SCHOOL ADMIN DASHBOARD DATA
  // ===========================================================================

  /// Get comprehensive school dashboard data
  Future<Map<String, dynamic>> getSchoolDashboard() async {
    _ensureContext();

    final students = await _db.query(
      'students',
      where: 'school_id = ? AND is_active = 1',
      whereArgs: [_currentSchoolId],
    );

    final bills = await _db.query(
      'bills',
      where: 'school_id = ?',
      whereArgs: [_currentSchoolId],
    );

    final payments = await _db.query(
      'payments',
      where: 'school_id = ?',
      whereArgs: [_currentSchoolId],
    );

    final expenses = await _db.query(
      'expenses',
      where: 'school_id = ?',
      whereArgs: [_currentSchoolId],
    );

    final campaigns = await getSchoolCampaigns();
    final sessions = await getSchoolAttendanceSessions();

    // Calculate metrics
    double totalRevenue = 0;
    double totalExpenses = 0;

    for (final payment in payments) {
      totalRevenue += (payment['amount'] as num).toDouble();
    }

    for (final expense in expenses) {
      totalExpenses += (expense['amount'] as num).toDouble();
    }

    double outstandingBills = 0;
    for (final bill in bills) {
      if (bill['is_closed'] != 1) {
        outstandingBills += (bill['total_amount'] as num).toDouble() -
            (bill['paid_amount'] as num).toDouble();
      }
    }

    return {
      'studentCount': students.length,
      'totalBills': bills.length,
      'totalPayments': payments.length,
      'totalExpenses': expenses.length,
      'totalRevenue': totalRevenue,
      'totalExpensesAmount': totalExpenses,
      'outstandingBills': outstandingBills,
      'netBalance': totalRevenue - totalExpenses,
      'activeCampaigns': campaigns.where((c) => c['status'] == 'active').length,
      'pendingAttendanceSessions': sessions.where((s) => s['is_confirmed_by_teacher'] != 1).length,
    };
  }

  /// Get student list with aggregated financial data
  Future<List<StudentFull>> getStudentsWithFinancials() async {
    _ensureContext();

    final studentsData = await _db.query(
      'students',
      where: 'school_id = ? AND is_active = 1',
      whereArgs: [_currentSchoolId],
    );

    final List<StudentFull> students = [];

    for (final studentData in studentsData) {
      final studentId = studentData['id'] as String;
      final bills = await _db.getStudentBills(studentId);

      double paidTotal = 0;
      double owedTotal = 0;

      for (final bill in bills) {
        final paidAmount = (bill['paid_amount'] as num?)?.toDouble() ?? 0.0;
        final billAmount = (bill['total_amount'] as num?)?.toDouble() ?? 0.0;

        paidTotal += paidAmount;
        owedTotal += billAmount - paidAmount;
      }

      students.add(StudentFull(
        student: StudentModel(
          id: studentId,
          fullName: studentData['full_name'] as String?,
          grade: studentData['grade'] as String?,
          parentContact: studentData['parent_contact'] as String?,
          registrationDate: studentData['registration_date'] != null 
            ? DateTime.tryParse(studentData['registration_date'] as String)
            : null,
          billingType: studentData['billing_type'] as String? ?? 'monthly',
          defaultFee: (studentData['default_fee'] as num?)?.toDouble() ?? 0.0,
          isActive: (studentData['is_active'] as int?) == 1,
          paidTotal: paidTotal,
          owedTotal: owedTotal,
        ),
      ));
    }

    return students;
  }

  /// Get detailed student financial report
  Future<Map<String, dynamic>> getStudentFinancialReport(String studentId) async {
    final student = await _db.getStudentById(studentId);
    if (student == null) throw Exception('Student not found');

    final bills = await _db.getStudentBills(studentId);
    final payments = await _db.query(
      'payments',
      where: 'student_id = ?',
      whereArgs: [studentId],
    );

    double totalBilled = 0;
    double totalPaid = 0;

    for (final bill in bills) {
      totalBilled += (bill['total_amount'] as num?)?.toDouble() ?? 0.0;
      totalPaid += (bill['paid_amount'] as num?)?.toDouble() ?? 0.0;
    }

    return {
      'studentId': studentId,
      'studentName': student['full_name'],
      'totalBilled': totalBilled,
      'totalPaid': totalPaid,
      'outstandingBalance': totalBilled - totalPaid,
      'billCount': bills.length,
      'paymentCount': payments.length,
      'bills': bills,
      'payments': payments,
    };
  }

  // ===========================================================================
  // PERMISSION-BASED AUDIT 
  // ===========================================================================

  /// Get audit log of all delegated permissions
  Future<List<Map<String, Object?>>> getPermissionAuditLog() async {
    _ensureContext();

    return await _db.query(
      'teacher_access_tokens',
      where: 'school_id = ?',
      whereArgs: [_currentSchoolId],
      orderBy: 'created_at DESC',
    );
  }

  /// Get audit log of attendance sessions
  Future<List<Map<String, Object?>>> getAttendanceAuditLog() async {
    _ensureContext();

    final sessions = await _db.getAttendanceSessionsForSchool(_currentSchoolId!);
    
    return sessions;
  }
}
