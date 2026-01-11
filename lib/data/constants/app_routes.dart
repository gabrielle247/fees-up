// -----------------------------------------------------------------------------
// APP ROUTE PATHS
// Centralized source of truth for all navigation paths.
// -----------------------------------------------------------------------------

class AppRoutes {
  // Authentication & Onboarding
  static const String login = '/login';
  static const String signup = '/signup';
  static const String resetPassword = '/reset-password';
  static const String createSchool = '/create-school';
  static const String onboarding = '/onboarding';
  static const String plans = '/plans';
  static const String billing = '/billing';

  // Dashboard (Branch 0)
  static const String dashboard = '/dashboard';

  // Students (Branch 1)
  static const String students = '/students';
  static const String addStudent = 'add'; // Result: /students/add
  static const String viewStudent =
      'view/:studentId'; // Result: /students/view/123
  static const String studentLogs =
      'logs/:studentId'; // Result: /students/logs/123

  // Finance (Branch 2)
  static const String finance = '/finance';
  static const String recordPayment =
      'record-payment'; // Result: /finance/record-payment
  static const String feeStructures =
      'structures'; // Result: /finance/structures

  // Configs (Branch 3)
  static const String configs = '/configs';
  static const String academicSetup = 'academic'; // Result: /configs/academic

  // Inside AppRoutes class in app_routes.dart
  static const String transactions =
      'transactions'; // Result: /finance/transactions
}
