import 'package:go_router/go_router.dart';
import '../mobile/screens/configs_screen.dart';
import '../mobile/screens/dashboard_screen.dart';
import '../mobile/screens/finance_screen.dart';
import '../mobile/screens/students_screen.dart';
import '../mobile/widgets/app_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/dashboard',
  routes: [
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
