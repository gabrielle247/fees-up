import 'package:go_router/go_router.dart';
import '../mobile/screens/dashboard_screen.dart';
import '../mobile/screens/students_screen.dart';
import '../mobile/screens/finance_screen.dart';
import '../mobile/screens/configs_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/dashboard',
  routes: [
    GoRoute(
      path: '/dashboard',
      name: 'dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/students',
      name: 'students',
      builder: (context, state) => const StudentsScreen(),
    ),
    GoRoute(
      path: '/finance',
      name: 'finance',
      builder: (context, state) => const FinanceScreen(),
    ),
    GoRoute(
      path: '/configs',
      name: 'configs',
      builder: (context, state) => const ConfigsScreen(),
    ),
  ],
);
