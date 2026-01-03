/// ============================================================================
/// BILLING SUSPENSION PROVIDER - RIVERPOD STATE MANAGEMENT
/// ============================================================================
/// 
/// Provides reactive state management for billing suspension operations
/// using Riverpod. Enables real-time updates to suspension status across
/// the application.
///
/// Author: Nyasha Gabriel / Batch Tech
/// Date: January 3, 2026
library billing_suspension_provider;

// ✅ CORRECT: Only export non-sensitive utility classes and enums
// ❌ DO NOT export: SuspensionPeriod, BillingAuditEntry, BillingExtension
// These tables are server-side only and must never be synced to client
export '../services/billing_suspension_service.dart'
    show
        BillingSuppressionStatusData,
        BillingSuppressionScope,
        SuspensionStatus,
        SuspensionScopeType,
        AuditAction;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/billing_suspension_service.dart';

// ============================================================================
// PROVIDERS
// ============================================================================

/// Provides instance of BillingSuppressionService scoped by school ID
final billingSuppressionServiceProvider =
    Provider.family<BillingSuppressionService, String>((ref, schoolId) {
  final supabase = Supabase.instance.client;
  final userId = supabase.auth.currentUser?.id ?? '';

  return BillingSuppressionService(
    supabase: supabase,
    schoolId: schoolId,
    userId: userId,
  );
});

/// Provides current billing suspension status (is any suspension active?)
final billingSuppressionStatusProvider =
    FutureProvider.family<bool, String>((ref, schoolId) async {
  final service = ref.watch(billingSuppressionServiceProvider(schoolId));
  return await service.isBillingSuspended();
});

/// Provides all active suspension periods for a school
/// 
/// ✅ SECURE: Returns boolean status only, not full period data
/// ✅ Server validates all suspension logic
final activeSuspensionsProvider = FutureProvider.family<bool, String>(
    (ref, schoolId) async {
  final service = ref.watch(billingSuppressionServiceProvider(schoolId));
  return await service.getActiveSuspensions();
});

/// Provides suspension summary for UI display
final suspensionSummaryProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, schoolId) async {
  final service = ref.watch(billingSuppressionServiceProvider(schoolId));
  return await service.getSuspensionSummary();
});

/// Provides audit log entries (admin/read-only)
/// 
/// ✅ SECURE: Returns raw maps, no client-side models
/// ✅ Server enforces admin-only access via RLS
final billingAuditLogProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>(
        (ref, schoolId) async {
  final service = ref.watch(billingSuppressionServiceProvider(schoolId));
  return await service.getAuditLog(limit: 100);
});

/// StateNotifier for managing suspension UI state
class SuspensionStateNotifier extends StateNotifier<SuspensionUIState> {
  final BillingSuppressionService _service;

  SuspensionStateNotifier({required BillingSuppressionService service})
      : _service = service,
        super(const SuspensionUIState());

  /// Trigger suspension
  /// 
  /// ✅ SECURE: Uses RPC call via service
  /// ✅ No direct table access
  Future<bool> suspendBilling({
    required String reason,
    BillingSuppressionScope? scope,
    String? customNote,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _service.suspendBilling(
        reason: reason,
        scope: scope,
        customNote: customNote,
      );

      state = state.copyWith(
        isLoading: false,
        isSuspended: result,
      );
      return result;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Trigger resumption
  /// 
  /// ✅ SECURE: Uses RPC call via service
  /// ✅ Server validates engine assignment
  Future<bool> resumeBilling() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _service.resumeBilling();

      state = state.copyWith(
        isLoading: false,
        isSuspended: !result, // false when resume succeeds
      );
      return result;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Refresh suspension status
  /// 
  /// ✅ SECURE: Queries current status from server via RPC
  Future<void> refreshStatus() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final isSuspended = await _service.isBillingSuspended();

      state = state.copyWith(
        isLoading: false,
        isSuspended: isSuspended,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// UI State for suspension operations
/// 
/// ✅ SECURE: Only contains suspension status, not sensitive period data
/// Sensitive data (periods, audit log) is server-side only
class SuspensionUIState {
  final bool isSuspended;
  final bool isLoading;
  final String? error;

  const SuspensionUIState({
    this.isSuspended = false,
    this.isLoading = false,
    this.error,
  });

  SuspensionUIState copyWith({
    bool? isSuspended,
    bool? isLoading,
    String? error,
  }) {
    return SuspensionUIState(
      isSuspended: isSuspended ?? this.isSuspended,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// StateNotifier provider for suspension state
final suspensionStateProvider =
    StateNotifierProvider.family<SuspensionStateNotifier, SuspensionUIState,
        String>((ref, schoolId) {
  final service = ref.watch(billingSuppressionServiceProvider(schoolId));
  return SuspensionStateNotifier(service: service);
});
