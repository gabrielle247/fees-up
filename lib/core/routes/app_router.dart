import 'package:fees_up/mobile/screens/auth/mobile_signup_screen.dart';
import 'package:fees_up/mobile/screens/mobile_home_screen.dart';
import 'package:fees_up/pc/screens/auth/pc_signup_screen.dart';
import 'package:fees_up/pc/screens/pc_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/layout/responsive_layout.dart';
import '../../data/providers/auth_provider.dart';

class AppRouter {
  static final routerProvider = Provider<GoRouter>((ref) {
    // Watch the auth state to trigger redirects
    final authState = ref.watch(authStateProvider);

    return GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: true,
      
      // Redirect Logic: Check if user is logged in
      redirect: (context, state) {
        final isLoggedIn = authState.value?.session != null;
        final isLoggingIn = state.uri.toString() == '/login';
        final isSigningUp = state.uri.toString() == '/signup';

        // If not logged in and not on login/signup page, go to login
        if (!isLoggedIn && !isLoggingIn && !isSigningUp) {
          return '/login';
        }

        // If logged in and on login page, go home
        if (isLoggedIn && (isLoggingIn || isSigningUp)) {
          return '/';
        }

        return null; // No redirect needed
      },

      routes: [
        // Home Route (Protected)
        GoRoute(
          path: '/',
          name: 'home',
          builder: (context, state) {
            return const ResponsiveLayout(
              mobileScaffold: MobileHomeScreen(), // Replace with MobileHomeScreen later
              pcScaffold: PCHomeScreen(), // Replace with PCHomeScreen later
            );
          },
        ),
        
        // Login Route
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) {
            return const ResponsiveLayout(
              mobileScaffold: MobileSignupScreen(),
              pcScaffold: PCSignupScreen(),
            );
          },
        ),

        // Signup Route (Placeholder for now)
        GoRoute(
          path: '/signup',
          name: 'signup',
          builder: (context, state) {
            return Scaffold(
              appBar: AppBar(title: const Text("Sign Up")),
              body: const Center(child: Text("Sign Up Screen Coming Next")),
            );
          },
        ),
      ],
    );
  });
}