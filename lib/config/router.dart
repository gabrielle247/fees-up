import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../mobile/screens/configs_screen.dart';
import '../mobile/screens/dashboard_screen.dart';
import '../mobile/screens/finance_screen.dart';
import '../mobile/screens/login_screen.dart';
import '../mobile/screens/students_screen.dart';
import '../mobile/widgets/app_shell.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

GoRouter buildRouter() {
  final supabase = Supabase.instance.client;

  return GoRouter(
    initialLocation: '/auth',
    refreshListenable: GoRouterRefreshStream(
      supabase.auth.onAuthStateChange,
    ),
    redirect: (context, state) {
      final loggedIn = supabase.auth.currentSession != null;
      final loggingIn = state.uri.path == '/auth';

      if (!loggedIn) {
        return loggingIn ? null : '/auth';
      }

      if (loggingIn) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) => const LoginScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                name: 'dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/students',
                name: 'students',
                builder: (context, state) => const StudentsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/finance',
                name: 'finance',
                builder: (context, state) => const FinanceScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/configs',
                name: 'configs',
                builder: (context, state) => const ConfigsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
