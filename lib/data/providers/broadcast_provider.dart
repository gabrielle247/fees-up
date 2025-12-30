import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/broadcast_model.dart';
import '../../../../data/services/broadcast_service.dart';
import '../../../../data/providers/school_provider.dart';
import '../../../../data/providers/auth_provider.dart';

// ==============================================================================
// 1. DATA FEED: HYBRID (CACHE + LIVE STREAM)
// ==============================================================================
final broadcastFeedProvider = StreamProvider.autoDispose<List<Broadcast>>((ref) async* {
  final service = ref.watch(broadcastServiceProvider);
  final schoolId = ref.watch(activeSchoolIdProvider);

  // Guard: If we don't know the school, we can't fetch messages.
  if (schoolId == null) {
    yield [];
    return;
  }

  // STEP A: YIELD CACHE (Instant Visuals)
  // This allows the UI to render "last known good data" immediately
  // while the websocket handshake is happening.
  final cached = await service.loadCachedBroadcasts();
  if (cached.isNotEmpty) {
    yield cached;
  }

  // STEP B: CONNECT TO LIVE STREAM
  // Once connected, this replaces the cache with real-time data.
  // We wrap in try-catch to keep showing cache if the network fails.
  try {
    yield* service.streamBroadcasts(schoolId);
  } catch (e) {
    // If socket connection fails, keep the cached data on screen
    // but maybe re-yield it so the UI knows we are "done" trying.
    if (cached.isNotEmpty) yield cached;
  }
});

// ==============================================================================
// 2. LOGIC CONTROLLER: WRITING DATA
// ==============================================================================
final broadcastLogicProvider = Provider((ref) => BroadcastLogic(ref));

class BroadcastLogic {
  final Ref _ref;
  BroadcastLogic(this._ref);

  /// Posts a new broadcast to the currently active school.
  Future<void> post({
    required String title,
    required String body,
    String priority = 'normal',
  }) async {
    // 1. Context Resolution
    final schoolId = _ref.read(activeSchoolIdProvider);
    final user = _ref.read(currentUserProvider);

    // 2. Strict Validation (Fail Fast)
    if (schoolId == null) {
      throw Exception("Operation Failed: School ID context is missing. Try restarting the app.");
    }
    
    if (user == null || user.id.isEmpty) {
      throw Exception("Authentication Failed: User ID is missing. Please log in again.");
    }

    if (title.trim().isEmpty || body.trim().isEmpty) {
      throw Exception("Validation Error: Title and Body cannot be empty.");
    }

    // 3. Execution
    // We send the 'user.id' as the author_id. The Backend RLS will verify
    // if this user actually has permission to post for this school_id.
    await _ref.read(broadcastServiceProvider).sendBroadcast(
      schoolId: schoolId,
      authorId: user.id,
      title: title,
      body: body,
      priority: priority,
      targetRole: 'all', // Default: Everyone in the school sees this
    );
  }
}