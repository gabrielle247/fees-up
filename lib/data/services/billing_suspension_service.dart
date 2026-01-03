/// ============================================================================
/// BILLING SUSPENSION SERVICE - CORE SUSPENSION LOGIC
/// ============================================================================
///
/// This service handles all billing suspension operations including:
/// - Suspending billing (globally or scoped)
/// - Resuming billing with backbill calculations
/// - Checking suspension status
/// - Audit logging
/// - Scope filtering (students, grades, fee types)
///
/// Author: Nyasha Gabriel / Batch Tech
/// Date: January 3, 2026
/// Status: Production-Ready
library billing_suspension_service;

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

// ============================================================================
// ENUMS & TYPES
// ============================================================================

enum SuspensionStatus {
  active('active', 'Active'),
  completed('completed', 'Completed'),
  cancelled('cancelled', 'Cancelled');

  final String code;
  final String display;
  const SuspensionStatus(this.code, this.display);

  static SuspensionStatus fromCode(String code) =>
      SuspensionStatus.values.firstWhere(
        (e) => e.code == code,
        orElse: () => SuspensionStatus.active,
      );
}

enum SuspensionScopeType {
  global('global', 'All Students'),
  students('students', 'Specific Students'),
  grades('grades', 'Grade Levels'),
  feeTypes('fee_types', 'Fee Types');

  final String code;
  final String display;
  const SuspensionScopeType(this.code, this.display);

  static SuspensionScopeType fromCode(String code) =>
      SuspensionScopeType.values.firstWhere(
        (e) => e.code == code,
        orElse: () => SuspensionScopeType.global,
      );
}

enum AuditAction {
  suspend('suspend', 'Billing Suspended'),
  resume('resume', 'Billing Resumed'),
  backbill('backbill', 'Backbilling Applied'),
  configChange('config_change', 'Configuration Changed'),
  switchProcessing('switch_processing', 'Plan Switch Processed'),
  adjustment('adjustment', 'Manual Adjustment'),
  correction('manual_correction', 'Manual Correction');

  final String code;
  final String display;
  const AuditAction(this.code, this.display);

  static AuditAction fromCode(String code) =>
      AuditAction.values.firstWhere(
        (e) => e.code == code,
        orElse: () => AuditAction.suspend,
      );
}

// ============================================================================
// DATA MODELS
// ============================================================================

class BillingSuppressionScope {
  final SuspensionScopeType type;
  final List<String> values; // student IDs, grade names, or fee type codes

  BillingSuppressionScope({
    required this.type,
    this.values = const [],
  });

  bool appliesTo({
    String? studentId,
    String? gradeLevel,
    String? feeType,
  }) {
    switch (type) {
      case SuspensionScopeType.global:
        return true; // Applies to everything
      case SuspensionScopeType.students:
        return studentId != null && values.contains(studentId);
      case SuspensionScopeType.grades:
        return gradeLevel != null && values.contains(gradeLevel);
      case SuspensionScopeType.feeTypes:
        return feeType != null && values.contains(feeType);
    }
  }

  Map<String, dynamic> toJson() => {
        'type': type.code,
        'values': values,
      };

  factory BillingSuppressionScope.fromJson(Map<String, dynamic> json) =>
      BillingSuppressionScope(
        type: SuspensionScopeType.fromCode(json['type'] as String),
        values: List<String>.from(json['values'] as List? ?? []),
      );
}

// ============================================================================
// NOTE ON CLIENT-SIDE MODELS
// ============================================================================
// 
// SuspensionPeriod and BillingAuditEntry models are INTENTIONALLY EXCLUDED
// from this file per SECURE_BILLING_ENGINE_ARCHITECTURE.md
// 
// These tables contain critical financial state and must NEVER be:
// - Synced via PowerSync
// - Accessed directly from client code
// - Stored in local model classes
// 
// Access these tables ONLY via:
// 1. RPC functions (server-side validation)
// 2. Realtime subscriptions (online-only)
// 3. Read-only REST queries (admin portal)
// 
// All client-side business logic must work with suspension STATUS (boolean),
// not suspension PERIODS (full data). See BillingSuppressionStatusData class
// below for UI-safe data structures.
// ============================================================================

/// UI-safe representation of billing suspension status
/// 
/// This class contains ONLY the information needed for billing logic:
/// - Whether billing is suspended (boolean)
/// - When it was suspended (timestamp)
/// - The reason (for UI display)
/// 
/// It does NOT contain the full suspension period record, which stays
/// server-side only per the security architecture.
class BillingSuppressionStatusData {
  final bool isSuspended;
  final DateTime? suspendedSince;
  final String? reason;
  final DateTime? resumesOn;

  const BillingSuppressionStatusData({
    required this.isSuspended,
    this.suspendedSince,
    this.reason,
    this.resumesOn,
  });

  factory BillingSuppressionStatusData.fromMap(Map<String, dynamic> map) =>
      BillingSuppressionStatusData(
        isSuspended: (map['is_suspended'] as bool?) ?? false,
        suspendedSince: map['suspended_since'] != null
            ? DateTime.parse(map['suspended_since'] as String)
            : null,
        reason: map['reason'] as String?,
        resumesOn: map['resumes_on'] != null
            ? DateTime.parse(map['resumes_on'] as String)
            : null,
      );

  factory BillingSuppressionStatusData.notSuspended() =>
      const BillingSuppressionStatusData(isSuspended: false);
}

// ============================================================================
// MAIN BILLING SUSPENSION SERVICE
// ============================================================================

class BillingSuppressionService {
  final SupabaseClient supabase;
  final String schoolId;
  final String userId;

  BillingSuppressionService({
    required this.supabase,
    required this.schoolId,
    required this.userId,
  });

  /// Suspend billing for the school
  /// 
  /// ✅ SECURE: Uses RPC function for server-side validation
  /// ✅ Prevents direct table access
  /// ✅ Enforces engine assignment requirement
  /// 
  /// Parameters:
  /// - [reason]: Required reason for suspension
  /// - [scope]: Who suspension applies to (default: global/everyone)
  /// - [customNote]: Optional additional details
  /// 
  /// Returns: true if suspension successful
  Future<bool> suspendBilling({
    required String reason,
    BillingSuppressionScope? scope,
    String? customNote,
  }) async {
    try {
      final actualScope = scope ?? _globalScope();

      // ✅ CORRECT: All mutations via RPC (server-side validation)
      final response = await supabase.rpc(
        'suspend_billing',
        params: {
          'p_school_id': schoolId,
          'p_user_id': userId,
          'p_reason': reason,
          'p_custom_note': customNote,
          'p_scope': actualScope.toJson(),
        },
      );

      return response != null;
    } on PostgrestException catch (e) {
      if (e.code == 'NOENG') {
        debugPrintError('No active billing engine assigned to school');
      } else if (e.code == 'PERMS') {
        debugPrintError('User lacks permission to suspend billing');
      }
      return false;
    } catch (e) {
      debugPrintError('Error suspending billing: $e');
      return false;
    }
  }

  /// Resume billing for the school
  /// 
  /// ✅ SECURE: Uses RPC function for server-side validation
  /// ✅ Only billing engine can resume
  /// ✅ Automatic audit logging on server
  /// 
  /// Returns: true if resume successful
  Future<bool> resumeBilling() async {
    try {
      // ✅ CORRECT: RPC call with engine validation
      final response = await supabase.rpc(
        'resume_billing',
        params: {
          'p_school_id': schoolId,
          'p_user_id': userId,
        },
      );

      return response != null;
    } on PostgrestException catch (e) {
      if (e.code == 'NOENG') {
        debugPrintError('No active billing engine assigned to school');
      } else if (e.code == 'NSUSP') {
        debugPrintError('No active suspension to resume');
      }
      return false;
    } catch (e) {
      debugPrintError('Error resuming billing: $e');
      return false;
    }
  }

  /// Check if billing is currently suspended
  /// 
  /// Returns: true if active suspension exists, false otherwise
  Future<bool> isBillingSuspended() async {
    try {
      final response = await supabase.rpc(
        'is_billing_suspended',
        params: {'p_school_id': schoolId},
      );

      return response as bool;
    } catch (e) {
      debugPrintError('Error checking billing suspension: $e');
      return false;
    }
  }

  /// Check if billing is currently suspended for this school
  /// 
  /// ✅ SECURE: Uses RPC function for server-side check
  /// ✅ Does not expose suspension period details
  /// ✅ Returns status only, not sensitive period data
  /// 
  /// Returns: true if active suspension exists
  Future<bool> getActiveSuspensions() async {
    try {
      final response = await supabase.rpc(
        'is_billing_suspended',
        params: {'p_school_id': schoolId},
      );

      return (response as bool?) ?? false;
    } catch (e) {
      debugPrintError('Error checking active suspensions: $e');
      return false;
    }
  }

  /// Check if billing applies to a specific student
  /// 
  /// ✅ SECURE: Uses RPC function with scope checking
  /// ✅ Server performs all filtering logic
  /// 
  /// Parameters:
  /// - [studentId]: Student to check
  /// - [gradeLevel]: Grade level of student (optional)
  /// - [feeType]: Fee type being billed (optional)
  /// 
  /// Returns: false if billing is suspended for this student, true otherwise
  Future<bool> isBillingAppliedToStudent({
    required String studentId,
    String? gradeLevel,
    String? feeType,
  }) async {
    try {
      // Use RPC to check if billing applies to this specific student
      final response = await supabase.rpc(
        'is_billing_applied_to_student',
        params: {
          'p_school_id': schoolId,
          'p_student_id': studentId,
          'p_grade_level': gradeLevel,
          'p_fee_type': feeType,
        },
      );

      return (response as bool?) ?? true; // Default to billing enabled on error
    } catch (e) {
      debugPrintError('Error checking student billing status: $e');
      return true; // Default to billing enabled on error
    }
  }

  /// Get suspension summary for UI display
  /// 
  /// ✅ SECURE: Returns status only, via RPC
  /// ✅ Does not expose detailed suspension period data
  /// 
  /// Returns: Formatted map with suspension status
  Future<Map<String, dynamic>> getSuspensionSummary() async {
    try {
      final isSuspended = await getActiveSuspensions();

      return {
        'is_suspended': isSuspended,
        'status_text': isSuspended ? 'Billing is suspended' : 'Billing is active',
      };
    } catch (e) {
      debugPrintError('Error getting suspension summary: $e');
      return {'is_suspended': false};
    }
  }

  /// Calculate days suspended for backbilling purposes
  /// 
  /// ✅ SECURE: Uses RPC function for calculation
  /// ✅ Server maintains accuracy of calculations
  /// 
  /// Returns: Number of days suspended
  Future<int> calculateSuspensionDays() async {
    try {
      final response = await supabase.rpc(
        'calculate_suspension_days',
        params: {'p_school_id': schoolId},
      );

      return (response as int?) ?? 0;
    } catch (e) {
      debugPrintError('Error calculating suspension days: $e');
      return 0;
    }
  }

  /// Get audit log for school (admin/read-only access)
  /// 
  /// ✅ SECURE: Uses RPC function for audit log retrieval
  /// ✅ Server enforces admin-only access via RLS
  /// ✅ Returns raw maps - no client-side models for sensitive data
  /// 
  /// Returns: List of audit entries as maps
  Future<List<Map<String, dynamic>>> getAuditLog({
    int limit = 50,
    String? filterAction,
  }) async {
    try {
      final response = await supabase.rpc(
        'get_billing_audit_log',
        params: {
          'p_school_id': schoolId,
          'p_limit': limit,
          'p_action_filter': filterAction,
        },
      );

      return List<Map<String, dynamic>>.from(response as List? ?? []);
    } catch (e) {
      debugPrintError('Error fetching audit log: $e');
      return [];
    }
  }

  // ========================================================================
  // PRIVATE HELPERS
  // ========================================================================

  BillingSuppressionScope _globalScope() => BillingSuppressionScope(
        type: SuspensionScopeType.global,
        values: [],
      );

  // NOTE: Audit logging is handled automatically by server-side triggers
  // All suspension operations are logged automatically when RPC functions
  // are executed. No client-side logging action is needed.
}

// ============================================================================
// DEBUG HELPER FUNCTION
// ============================================================================

void debugPrintError(String message) {
  if (kDebugMode) {
    debugPrint('[BILLING ERROR] $message');
  }
}
