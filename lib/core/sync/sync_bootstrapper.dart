import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:fees_up/data/providers/sync_providers.dart';
import 'package:fees_up/data/providers/realtime_providers.dart';

class SyncBootstrapper extends ConsumerStatefulWidget {
  const SyncBootstrapper({super.key, required this.child});

  final Widget? child;

  @override
  ConsumerState<SyncBootstrapper> createState() => _SyncBootstrapperState();
}

class _SyncBootstrapperState extends ConsumerState<SyncBootstrapper> {
  StreamSubscription<AuthState>? _sub;
  bool _syncInProgress = false;

  Future<void> _runSync() async {
    if (_syncInProgress) return;
    _syncInProgress = true;
    try {
      await ref.read(syncServiceProvider).syncAll();
    } finally {
      _syncInProgress = false;
    }
  }

  @override
  void initState() {
    super.initState();
    final supabase = Supabase.instance.client;
    // Kick off a sync if we already have a session at startup
    if (supabase.auth.currentSession != null) {
      // Schedule after first frame to avoid build-phase work
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _runSync();
        // Start realtime after initial sync
        await ref.read(realtimeSyncServiceProvider).start();
      });
    }
    _sub = supabase.auth.onAuthStateChange.listen((evt) {
      if (evt.event == AuthChangeEvent.signedIn ||
          evt.event == AuthChangeEvent.initialSession) {
        _runSync().then((_) => ref.read(realtimeSyncServiceProvider).start());
      } else if (evt.event == AuthChangeEvent.signedOut) {
        ref.read(realtimeSyncServiceProvider).stop();
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child ?? const SizedBox.shrink();
}
