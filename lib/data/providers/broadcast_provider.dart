import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/broadcast_model.dart';
import '../repositories/broadcast_repository.dart';
import 'school_provider.dart';
import 'auth_provider.dart';

final broadcastRepositoryProvider = Provider((ref) => BroadcastRepository());

/// Unified Provider Names for UI Integration
final schoolBroadcastProvider = StreamProvider.autoDispose<List<Broadcast>>((ref) {
  final schoolId = ref.watch(activeSchoolIdProvider);
  if (schoolId == null) return Stream.value([]);
  return ref.watch(broadcastRepositoryProvider).watchSchoolBroadcasts(schoolId);
});

final internalHQBroadcastProvider = StreamProvider.autoDispose<List<Broadcast>>((ref) {
  return ref.watch(broadcastRepositoryProvider).watchInternalHQBroadcasts();
});

final broadcastLogicProvider = Provider((ref) => BroadcastLogic(ref));

class BroadcastLogic {
  final Ref _ref;
  BroadcastLogic(this._ref);

  Future<void> post({
    required String title,
    required String body,
    String priority = 'normal',
    bool isInternalHQ = false,
  }) async {
    final user = _ref.read(currentUserProvider);
    final schoolId = _ref.read(activeSchoolIdProvider);

    if (user == null) throw Exception("Auth Required");

    final Map<String, dynamic> data = {
      'id': const Uuid().v4(),
      'school_id': isInternalHQ ? null : schoolId,
      'author_id': user.id,
      'is_system_message': isInternalHQ ? 1 : 0,
      'target_role': isInternalHQ ? 'hq_internal' : 'all',
      'title': title,
      'body': body,
      'priority': priority,
      'created_at': DateTime.now().toIso8601String(),
    };

    await _ref.read(broadcastRepositoryProvider).postBroadcast(data: data);
  }
}