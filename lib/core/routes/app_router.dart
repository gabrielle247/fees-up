import 'dart:async';

import 'package:fees_up/pc/screens/announcements_screen.dart';
import 'package:fees_up/pc/screens/invoices_screen.dart';
import 'package:fees_up/pc/screens/notifications_screen.dart'; // <--- WIRED
import 'package:fees_up/pc/screens/profile_screen.dart';
import 'package:fees_up/pc/screens/reports_screen.dart';
import 'package:fees_up/pc/screens/settings_screen.dart';
import 'package:fees_up/pc/screens/students_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// --- LAYOUT & SHARED ---
import '../../../shared/layout/responsive_layout.dart';

// --- MOBILE SCREENS ---
import '../../mobile/screens/mobile_home_screen.dart';
import '../../mobile/screens/auth/mobile_signup_screen.dart';

// --- PC SCREENS ---
import '../../pc/screens/pc_home_screen.dart';
import '../../pc/screens/auth/pc_signup_screen.dart';
import '../../pc/screens/transactions_screen.dart';

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

      if (session == null) {
        return isAuthRoute ? null : '/login';
      }

      if (isAuthRoute) {
        return '/';
      }

      return null;
    },

    routes: [
      // -----------------------------------------------------------------------
      // CORE ROUTES
      // -----------------------------------------------------------------------
      
      // 1. HOME / OVERVIEW
      GoRoute(
        path: '/',
        builder: (context, state) => const ResponsiveLayout(
          mobileScaffold: MobileHomeScreen(),
          pcScaffold: PCHomeScreen(),
        ),
      ),

      // 2. TRANSACTIONS
      GoRoute(
        path: '/transactions',
        builder: (context, state) => const ResponsiveLayout(
          mobileScaffold: Scaffold(body: Center(child: Text("Mobile Transactions"))), 
          pcScaffold: TransactionsScreen(), 
        ),
      ),

      // -----------------------------------------------------------------------
      // FEATURE ROUTES
      // -----------------------------------------------------------------------
      
      // 3. INVOICES
      GoRoute(
        path: '/invoices',
        builder: (context, state) => const InvoicesScreen(),
      ),

      // 4. STUDENTS
      GoRoute(
        path: '/students',
        builder: (context, state) => const StudentsScreen(),
      ),

      // 5. REPORTS
      GoRoute(
        path: '/reports',
        builder: (context, state) => const ReportsScreen(),
      ),

      // -----------------------------------------------------------------------
      // MESSAGING ROUTES (Broadcasts & Notifications)
      // -----------------------------------------------------------------------
      
      // 6. ANNOUNCEMENTS (Broadcasts)
      GoRoute(
        path: '/announcements',
        builder: (context, state) => const AnnouncementsScreen(),
      ),

      // 7. NOTIFICATIONS (Personal Inbox) - NEW
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),

      // -----------------------------------------------------------------------
      // PREFERENCES
      // -----------------------------------------------------------------------

      // 8. SETTINGS
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),

      // 9. PROFILE
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),

      // -----------------------------------------------------------------------
      // AUTH ROUTES
      // -----------------------------------------------------------------------
      GoRoute(
        path: '/login',
        builder: (context, state) => const ResponsiveLayout(
          mobileScaffold: MobileAuthScreen(initialIsLogin: true),
          pcScaffold: PCSignupScreen(initialIsLogin: true),
        ),
      ),

      GoRoute(
        path: '/signup',
        builder: (context, state) => const ResponsiveLayout(
          mobileScaffold: MobileAuthScreen(initialIsLogin: false),
          pcScaffold: PCSignupScreen(initialIsLogin: false),
        ),
      ),
    ],
  );
});

// --- HELPER CLASSES ---

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