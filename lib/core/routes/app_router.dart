import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/layout/responsive_layout.dart';
import '../../mobile/screens/auth/mobile_signup_screen.dart';
import '../../pc/screens/auth/pc_signup_screen.dart';
import '../../mobile/screens/mobile_home_screen.dart';
import '../../pc/screens/pc_home_screen.dart';
import '../../pc/widgets/dashboard/sidebar.dart'; // <--- IMPORT THE SIDEBAR
import '../../data/providers/auth_provider.dart';

class AppRouter {
  static final routerProvider = Provider<GoRouter>((ref) {
    final authState = ref.watch(authStateProvider);

    return GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: true,
      
      redirect: (context, state) {
        final isLoggedIn = authState.value?.session != null;
        final isLoggingIn = state.uri.toString() == '/login';
        final isSigningUp = state.uri.toString() == '/signup';

        if (!isLoggedIn && !isLoggingIn && !isSigningUp) return '/login';
        if (isLoggedIn && (isLoggingIn || isSigningUp)) return '/';
        return null;
      },

      routes: [
        GoRoute(
          path: '/',
          name: 'home',
          builder: (context, state) => const ResponsiveLayout(
            mobileScaffold: MobileHomeScreen(),
            pcScaffold: PCHomeScreen(),
          ),
        ),
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const ResponsiveLayout(
            mobileScaffold: MobileSignupScreen(),
            pcScaffold: PCSignupScreen(),
          ),
        ),
        GoRoute(
          path: '/signup',
          name: 'signup',
          builder: (context, state) => const ResponsiveLayout(
            mobileScaffold: MobileSignupScreen(),
            pcScaffold: PCSignupScreen(),
          ),
        ),

        // --- MOCK ROUTES ---
        GoRoute(path: '/transactions', builder: (context, state) => const _MockScreen(title: "Transactions")),
        GoRoute(path: '/invoices', builder: (context, state) => const _MockScreen(title: "Invoices")),
        GoRoute(path: '/students', builder: (context, state) => const _MockScreen(title: "Students Management")),
        GoRoute(path: '/reports', builder: (context, state) => const _MockScreen(title: "Reports")),
        GoRoute(path: '/announcements', builder: (context, state) => const _MockScreen(title: "Announcements")),
        GoRoute(path: '/settings', builder: (context, state) => const _MockScreen(title: "Settings")),
        GoRoute(path: '/profile', builder: (context, state) => const _MockScreen(title: "Profile")),
      ],
    );
  });
}

class _MockScreen extends StatelessWidget {
  final String title;
  const _MockScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      // Mobile: Simple Scaffold
      mobileScaffold: Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Center(child: Text("$title Coming Soon", style: const TextStyle(fontSize: 20))),
        bottomNavigationBar: BottomNavigationBar(
           // Just a visual placeholder for mobile nav consistency in mocks
           currentIndex: 0,
           items: const [
             BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: "Home"),
             BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: "Transact"),
             BottomNavigationBarItem(icon: Icon(Icons.school_outlined), label: "Students"),
           ], 
        ),
      ),
      
      // PC: Real Sidebar + Content Area
      pcScaffold: Scaffold(
        body: Row(
          children: [
            // FIX: Use the ACTUAL Sidebar widget here
            const DashboardSidebar(),
            
            // Content
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("$title Screen (PC)", style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    const Text("This module is under construction.", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}