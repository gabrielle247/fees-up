import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

// -----------------------------------------------------------------------------
// IMPORTS
// -----------------------------------------------------------------------------
import 'package:fees_up/data/constants/app_colors.dart';
import 'package:fees_up/data/constants/app_strings.dart';
import 'package:fees_up/data/constants/app_routes.dart';
import 'package:fees_up/screens/mobile/all_mobile_screens.dart';

// -----------------------------------------------------------------------------
// ROUTER CONFIGURATION
// -----------------------------------------------------------------------------
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: AppRoutes.login, 
  
  // ---------------------------------------------------------------------------
  // REDIRECT LOGIC
  // ---------------------------------------------------------------------------
  redirect: (context, state) {
    return null; // No redirection needed for prototype
  },

  errorBuilder: (context, state) => const Scaffold(
    backgroundColor: AppColors.backgroundBlack,
    body: Center(child: Text('Route Error', style: TextStyle(color: Colors.white))),
  ),
  
  routes: [
    // =========================================================================
    // 1. AUTH & ONBOARDING (No Bottom Nav)
    // =========================================================================
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.signup,
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: AppRoutes.resetPassword,
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: AppRoutes.createSchool,
      builder: (context, state) => const CreateSchoolScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: AppRoutes.plans,
      builder: (context, state) => const PlansScreen(),
    ),
    GoRoute(
      path: AppRoutes.billing,
      builder: (context, state) => const BillingInfoScreen(),
    ),

    // =========================================================================
    // 2. FULL SCREEN APP PAGES (Moved OUT of Shell to hide Bottom Nav)
    // =========================================================================
    
    // --- Students Branch Full Screen Pages ---
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey, // Covers the bottom nav
      path: '${AppRoutes.students}/${AppRoutes.addStudent}', // /students/add
      builder: (context, state) => const AddStudentScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '${AppRoutes.students}/view/:studentId', // /students/view/123
      builder: (context, state) {
        final id = state.pathParameters['studentId'];
        return ViewStudentScreen(studentId: id);
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '${AppRoutes.students}/logs/:studentId',
      builder: (context, state) {
         final id = state.pathParameters['studentId'];
        return StudentLoggingScreen(studentId: id);
      },
    ),

    // --- Finance Branch Full Screen Pages ---
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '${AppRoutes.finance}/${AppRoutes.recordPayment}',
      builder: (context, state) {
        final studentId = state.uri.queryParameters['studentId'];
        return RecordPaymentScreen(preselectedStudentId: studentId);
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '${AppRoutes.finance}/${AppRoutes.feeStructures}',
      builder: (context, state) => const FeeStructuresScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '${AppRoutes.finance}/transactions',
      builder: (context, state) => const TransactionHistoryScreen(),
    ),

    // --- Configs Branch Full Screen Pages ---
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '${AppRoutes.configs}/${AppRoutes.academicSetup}',
      builder: (context, state) => const AcademicSetupScreen(),
    ),


    // =========================================================================
    // 3. APP SHELL (Bottom Nav Only)
    // =========================================================================
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppShell(navigationShell: navigationShell);
      },
      branches: [
        // BRANCH 0: DASHBOARD
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.dashboard,
              builder: (context, state) => const DashboardScreen(),
            ),
          ],
        ),

        // BRANCH 1: STUDENTS (List View Only)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.students,
              builder: (context, state) => const StudentsScreen(),
            ),
          ],
        ),

        // BRANCH 2: FINANCE (Dashboard Only)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.finance,
              builder: (context, state) => const FinanceScreen(),
            ),
          ],
        ),

        // BRANCH 3: CONFIGS (Menu Only)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.configs,
              builder: (context, state) => const ConfigsScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);

// -----------------------------------------------------------------------------
// APP SHELL WIDGET
// -----------------------------------------------------------------------------
class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({required this.navigationShell, super.key});

  void _onTabSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surfaceDarkGrey,
          border: Border(
            top: BorderSide(color: AppColors.surfaceLightGrey, width: 0.5),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: GNav(
              backgroundColor: AppColors.surfaceDarkGrey,
              tabBackgroundColor: AppColors.primaryBlueLight.withAlpha(50), 
              color: AppColors.textGrey,
              activeColor: AppColors.textWhite,
              gap: 8,
              tabBorderRadius: 12,
              iconSize: 22,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              selectedIndex: navigationShell.currentIndex,
              onTabChange: _onTabSelected,
              tabs: const [
                GButton(
                  icon: Icons.dashboard_outlined,
                  text: AppStrings.dashboardTitle,
                ),
                GButton(
                  icon: Icons.people_outline,
                  text: AppStrings.studentsTitle,
                ),
                GButton(
                  icon: Icons.account_balance_wallet_outlined,
                  text: AppStrings.financeTitle,
                ),
                GButton(
                  icon: Icons.settings_outlined,
                  text: AppStrings.configsTitle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}