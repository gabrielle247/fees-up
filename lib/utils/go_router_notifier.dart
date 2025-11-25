// lib/utils/go_router_notifier.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Adapts a Stream<Session?> to the Listenable required by GoRouter.
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<Session?> _subscription;

  GoRouterRefreshStream(Stream<Session?> stream) {
    // We only care about session state changes, not the actual session data.
    // The key is to call notifyListeners() when the stream emits a value.
    _subscription = stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}