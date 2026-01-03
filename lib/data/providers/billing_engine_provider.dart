/// ============================================================================
/// BILLING ENGINE PROVIDER - RIVERPOD STATE MANAGEMENT
/// ============================================================================
library billing_engine_provider;

import 'package:fees_up/data/services/billing_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Create instance provider for BillingEngine
final billingEngineProvider = Provider.family<BillingEngine, String>((ref, schoolId) {
  return BillingEngine(schoolId: schoolId);
});

// Provider for batch billing processor
final batchBillingProcessorProvider =
    Provider.family<BatchBillingProcessor, String>((ref, schoolId) {
  final engine = ref.watch(billingEngineProvider(schoolId));
  return BatchBillingProcessor(engine: engine);
});

// Provider for tracking generated bills
final generatedBillsProvider = StateNotifierProvider.family<
    GeneratedBillsNotifier,
    List<GeneratedBill>,
    String>((ref, schoolId) {
  return GeneratedBillsNotifier(schoolId);
});

// StateNotifier for managing generated bills
class GeneratedBillsNotifier extends StateNotifier<List<GeneratedBill>> {
  final String schoolId;

  GeneratedBillsNotifier(this.schoolId) : super([]);

  void addBill(GeneratedBill bill) {
    state = [...state, bill];
  }

  void addBills(List<GeneratedBill> bills) {
    state = [...state, ...bills];
  }

  void clearBills() {
    state = [];
  }

  void removeBill(String billId) {
    state = state.where((bill) => bill.id != billId).toList();
  }

  int get totalBills => state.length;
  double get totalAmount => state.fold(0.0, (sum, bill) => sum + bill.total);
}

// Provider for billing configurations cache
final billingConfigCacheProvider = StateNotifierProvider.family<
    BillingConfigCacheNotifier,
    Map<String, BillingConfiguration>,
    String>((ref, schoolId) {
  return BillingConfigCacheNotifier(schoolId);
});

class BillingConfigCacheNotifier
    extends StateNotifier<Map<String, BillingConfiguration>> {
  final String schoolId;

  BillingConfigCacheNotifier(this.schoolId) : super({});

  void registerConfig(BillingConfiguration config) {
    state = {...state, config.id: config};
  }

  void registerConfigs(List<BillingConfiguration> configs) {
    final newState = {...state};
    for (final config in configs) {
      newState[config.id] = config;
    }
    state = newState;
  }

  BillingConfiguration? getConfig(String configId) => state[configId];

  List<BillingConfiguration> getActiveConfigs() =>
      state.values.where((config) => config.isActive).toList();
}

// Provider for billing switch history
final billingSwitchHistoryProvider = StateNotifierProvider.family<
    BillingSwitchHistoryNotifier,
    Map<String, List<BillingSwitch>>,
    String>((ref, schoolId) {
  return BillingSwitchHistoryNotifier(schoolId);
});

class BillingSwitchHistoryNotifier
    extends StateNotifier<Map<String, List<BillingSwitch>>> {
  final String schoolId;

  BillingSwitchHistoryNotifier(this.schoolId) : super({});

  void recordSwitch(String studentId, BillingSwitch billSwitch) {
    state = {
      ...state,
      studentId: [...(state[studentId] ?? []), billSwitch],
    };
  }

  List<BillingSwitch> getSwitchHistory(String studentId) =>
      state[studentId] ?? [];

  int getTotalSwitches(String studentId) => state[studentId]?.length ?? 0;
}
