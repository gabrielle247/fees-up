import 'package:fees_up/features/pages/dashboard_screen.dart';
import 'package:fees_up/features/pages/login_screen.dart';
import 'package:fees_up/features/pages/register_student_screen.dart';
import 'package:fees_up/utils/student_codec.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// --- CORE PROVIDERS ---
// import '../providers/auth_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // Watch auth state to trigger redirects when login status changes
  // final authState = ref.watch(authStateChangesProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    extraCodec: studentCodec,
    
    // -------------------------------------------------------------------------
    // 🚦 REDIRECT LOGIC
    // -------------------------------------------------------------------------
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final isLoggedIn = session != null;
      final isLoggingIn = state.matchedLocation == '/login';

      if (!isLoggedIn && !isLoggingIn) {
        return '/login';
      }

      if (isLoggedIn && isLoggingIn) {
        return '/';
      }

      return null;
    },

    // -------------------------------------------------------------------------
    // 🗺️ ROUTE DEFINITIONS
    // -------------------------------------------------------------------------
    routes: [
      // 1. DASHBOARD (Home)
      GoRoute(
        path: '/',
        builder: (context, state) => const DashboardScreen(),
        routes: [
          // 2. REGISTER STUDENT (Nested under dashboard implies 'back' goes to dashboard)
          GoRoute(
            path: 'students/add',
            builder: (context, state) => const RegisterStudentScreen(),
          ),
          
          // 3. STUDENT LEDGER (Placeholder for future migration)
          GoRoute(
            path: 'students/ledger',
            builder: (context, state) {
              // Retrieve the student object passed via 'extra'
              // final student = state.extra as Student; 
              return const Scaffold(body: Center(child: Text("Ledger coming soon")));
            },
          ),
        ],
      ),

      // 4. LOGIN
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),

      // 5. NOTIFICATIONS (Placeholder)
      GoRoute(
        path: '/notifications',
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text("Notifications")),
          body: const Center(child: Text("No new notifications")),
        ),
      ),

      // 6. SEARCH (Placeholder)
      GoRoute(
        path: '/search',
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text("Search")),
          body: const Center(child: Text("Search feature coming soon")),
        ),
      ),
    ],
  );
});