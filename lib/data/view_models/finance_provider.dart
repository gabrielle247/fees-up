import 'package:fees_up/data/models/finance_models.dart';
import 'package:fees_up/data/view_models/prodivers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'session_provider.dart';

// -----------------------------------------------------------------------------
// 1. DASHBOARD STATS PROVIDER
// -----------------------------------------------------------------------------
final financeStatsProvider = FutureProvider.autoDispose<Map<String, double>>((ref) async {
  final session = ref.watch(sessionProvider);
  if (!session.hasSchool) return {'revenue': 0.0, 'pending': 0.0};
  
  return await ref.watch(financeRepositoryProvider)
      .getDashboardStats(session.currentSchool!.id);
});

// -----------------------------------------------------------------------------
// 2. RECENT ACTIVITY PROVIDER
// -----------------------------------------------------------------------------
final recentActivityProvider = FutureProvider.autoDispose<List<LedgerEntry>>((ref) async {
  final session = ref.watch(sessionProvider);
  if (!session.hasSchool) return [];

  return await ref.watch(financeRepositoryProvider)
      .getRecentActivity(session.currentSchool!.id);
});

// -----------------------------------------------------------------------------
// 3. FINANCE CONTROLLER (Actions)
// -----------------------------------------------------------------------------
final financeControllerProvider = Provider((ref) {
  return FinanceController(ref);
});

class FinanceController {
  final Ref _ref;

  FinanceController(this._ref);

  /// Records a payment and refreshes the dashboard.
  Future<void> recordPayment({
    required String studentId,
    required double amount,
    String? method,
    String? reference,
  }) async {
    final session = _ref.read(sessionProvider);
    if (!session.hasSchool) throw Exception("No active school session");

    // Use the Service (Atomic logic)
    await _ref.read(paymentServiceProvider).recordAndAllocatePayment(
      schoolId: session.currentSchool!.id,
      studentId: studentId,
      amount: amount,
      method: method,
      reference: reference,
    );

    // Refresh UI
    _ref.invalidate(financeStatsProvider);
    _ref.invalidate(recentActivityProvider);
    // Note: You might also want to invalidate specific student providers if you have them
  }
}