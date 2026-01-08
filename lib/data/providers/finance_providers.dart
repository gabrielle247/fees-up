import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fees_up/data/models/finance.dart';
import 'dashboard_providers.dart';
import 'core_providers.dart';

/// Provides the full ledger for the Finance Screen
final ledgerProvider = FutureProvider<List<LedgerEntry>>((ref) async {
  final schoolId = await ref.watch(currentSchoolIdProvider.future);
  final repo = await ref.watch(financeRepositoryProvider);
  return repo.getLedgerEntries(schoolId);
});
