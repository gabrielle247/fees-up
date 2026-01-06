/// Year Configuration Providers
/// Manages all Riverpod state for year configuration.
/// Widgets use these providers instead of accessing the database directly.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/year_configuration_repository.dart';
import '../repositories/year_configuration_repository_impl.dart';
import '../services/database_service.dart';
import '../providers/school_year_seeder.dart';

/// Provides the YearConfigurationRepository instance
final yearConfigurationRepositoryProvider = Provider((ref) {
  return YearConfigurationRepositoryImpl(
    db: DatabaseService(),
    seeder: SchoolYearSeeder(),
  );
});

/// Loads year data (with terms and months) - used once on widget load
final loadYearProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>?, (String, String)>((ref, params) async {
  final (yearId, schoolId) = params;
  final repository = ref.watch(yearConfigurationRepositoryProvider);
  return repository.loadYear(yearId, schoolId);
});

/// Watches year changes in real-time
final watchYearProvider = StreamProvider.autoDispose
    .family<Map<String, dynamic>?, (String, String)>((ref, params) {
  final (yearId, schoolId) = params;
  final repository = ref.watch(yearConfigurationRepositoryProvider);
  return repository.watchYear(yearId, schoolId);
});

/// Watches months for a year in real-time
final watchMonthsProvider = StreamProvider.autoDispose
    .family<List<Map<String, dynamic>>, (String, String)>((ref, params) {
  final (yearId, schoolId) = params;
  final repository = ref.watch(yearConfigurationRepositoryProvider);
  return repository.watchMonths(yearId, schoolId);
});

/// Save year data - called by widget when user clicks Save
class SaveYearNotifier extends StateNotifier<AsyncValue<void>> {
  SaveYearNotifier(this._repository) : super(const AsyncValue.data(null));

  final YearConfigurationRepository _repository;

  Future<void> saveYear({
    required String yearId,
    required String schoolId,
    required String yearLabel,
    required String startDate,
    required String endDate,
    required String description,
    required bool active,
    required List<Map<String, dynamic>> terms,
    required List<String> removedTermIds,
    required List<Map<String, dynamic>> months,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repository.saveYear(
        yearId: yearId,
        schoolId: schoolId,
        yearLabel: yearLabel,
        startDate: startDate,
        endDate: endDate,
        description: description,
        active: active,
        terms: terms,
        removedTermIds: removedTermIds,
        months: months,
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final saveYearProvider =
    StateNotifierProvider.autoDispose<SaveYearNotifier, AsyncValue<void>>(
  (ref) {
    final repository = ref.watch(yearConfigurationRepositoryProvider);
    return SaveYearNotifier(repository);
  },
);
