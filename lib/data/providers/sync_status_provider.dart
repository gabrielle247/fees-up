import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fees_up/data/state/sync_state.dart';
import 'package:fees_up/data/providers/sync_providers.dart';

final syncStatusProvider = StateNotifierProvider<SyncStatusNotifier, SyncState>(
    (ref) => SyncStatusNotifier(ref));

class SyncStatusNotifier extends StateNotifier<SyncState> {
  SyncStatusNotifier(this._ref) : super(SyncState.initial);

  final Ref _ref;

  Future<void> runFullSync() async {
    if (state.inProgress) return;
    state = state.copyWith(inProgress: true, lastError: null);
    try {
      await _ref.read(syncServiceProvider).syncAll();
      state = state.copyWith(
        inProgress: false,
        lastSuccessAt: DateTime.now(),
        lastError: null,
      );
    } catch (e) {
      state = state.copyWith(inProgress: false, lastError: e.toString());
      rethrow;
    }
  }
}
