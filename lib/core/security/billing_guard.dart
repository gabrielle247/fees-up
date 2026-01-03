import 'package:supabase_flutter/supabase_flutter.dart';
import '../errors/billing_exceptions.dart';

class BillingGuard {
  final SupabaseClient _supabase;

  BillingGuard(this._supabase);

  /// Executes a billing operation ONLY if the school is active.
  /// Wraps the logic in a mandatory check.
  Future<T> run<T>({
    required String schoolId,
    required Future<T> Function() action,
  }) async {
    // 1. Check Status
    await _enforceActiveStatus(schoolId);

    // 2. Execute Action (only if check passes)
    return await action();
  }

  Future<void> _enforceActiveStatus(String schoolId) async {
    try {
      // Fetch both flags: 'is_suspended' (Global) and 'billing_suspended' (Feature)
      final response = await _supabase
          .from('schools')
          .select('is_suspended, billing_suspended')
          .eq('id', schoolId)
          .single();

      final bool isGlobalSuspended = response['is_suspended'] as bool? ?? false;
      final String? billingStatus =
          response['billing_suspended'] as String?; // Handle String type

      if (isGlobalSuspended) {
        throw BillingSuspendedException(
            'School Account is Globally Suspended.');
      }

      // Strict check: if it is 'active', it means the SUSPENSION is active.
      if (billingStatus == 'active') {
        throw BillingSuspendedException('Billing Privileges are Suspended.');
      }
    } catch (e) {
      if (e is BillingSuspendedException) rethrow;
      // If we can't verify status (network error), we fail safe (BLOCK IT).
      throw BillingSuspendedException(
          'Security Check Failed: Unable to verify school status.');
    }
  }
}
