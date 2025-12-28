import 'dart:async';

import 'package:fees_up/mobile/screens/mobile_home_screen.dart';
import 'package:fees_up/shared/layout/responsive_layout.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// --- IMPORTS FOR LAYOUTS ---
import '../../mobile/screens/auth/mobile_signup_screen.dart';
import '../../pc/screens/auth/pc_signup_screen.dart';
import '../../pc/screens/pc_home_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    
    // 1. LISTEN TO AUTH CHANGES
    refreshListenable: GoRouterRefreshStream(Supabase.instance.client.auth.onAuthStateChange),
    
    // 2. REDIRECT LOGIC
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final isAuthRoute = state.uri.toString() == '/login' || state.uri.toString() == '/signup';

      // CASE A: User is NOT logged in
      if (session == null) {
        return isAuthRoute ? null : '/login';
      }

      // CASE B: User IS logged in
      if (isAuthRoute) {
        return '/';
      }

      return null;
    },

    routes: [
      // --- HOME ROUTE (Responsive) ---
      GoRoute(
        path: '/',
        builder: (context, state) => const ResponsiveLayout(
          mobileScaffold: MobileHomeScreen(),
          pcScaffold: PCHomeScreen(),
        ),
      ),

      // --- LOGIN ROUTE (Responsive) ---
      GoRoute(
        path: '/login',
        builder: (context, state) => const ResponsiveLayout(
          mobileScaffold: MobileAuthScreen(initialIsLogin: true),
          pcScaffold: PCSignupScreen(initialIsLogin: true,), // Shows centered card on PC
        ),
      ),

      // --- SIGNUP ROUTE (Responsive) ---
      GoRoute(
        path: '/signup',
        builder: (context, state) => const ResponsiveLayout(
          mobileScaffold: MobileAuthScreen(initialIsLogin: false),
          pcScaffold: PCSignupScreen(initialIsLogin: false), // Shows centered card on PC
        ),
      ),
    ],
  );
});

class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}