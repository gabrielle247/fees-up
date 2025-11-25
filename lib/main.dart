// lib/main.dart (Final Supabase Ready Version)

import 'package:fees_up/utils/edit_admin_dialog_util.dart';
import 'package:fees_up/views/revenue_reports_page.dart';
import 'package:fees_up/views/student_growth_page.dart';
import 'package:fees_up/widgets/biometric_guard.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// Services & Utils
import 'services/database_service.dart';
import 'services/local_storage_service.dart';

// View Models
import 'view_models/dashboard_view_model.dart';
import 'view_models/register_student_view_model.dart';
import 'view_models/student_ledger_view_model.dart';
import 'view_models/notification_view_model.dart';
import 'view_models/search_view_model.dart';

// Pages/Views
import 'views/dashboard_page.dart';
import 'views/registration_page.dart';
import 'views/student_ledger_page.dart';
import 'views/logging_payments_page.dart';
import 'views/search_page.dart';
import 'views/admin_profile_page.dart';
import 'views/evaluation_page.dart';
import 'views/notifications_page.dart';
import 'views/login_page.dart';

// Helper for GoRouter to listen to streams (re-defined here for completeness)
class StreamAuthNotifier extends ChangeNotifier {
  StreamAuthNotifier(Stream<dynamic> stream) {
    stream.listen((user) => notifyListeners());
  }
}

// --- AUTHENTICATION STATE CHECK (Supabase) ---
String? redirectLogic(BuildContext context, GoRouterState state) {
  // Use the Supabase current user state
  final isLoggedIn = Supabase.instance.client.auth.currentUser != null;
  final isLoggingIn = state.matchedLocation == '/login';

  if (!isLoggedIn && !isLoggingIn) {
    return '/login';
  }

  if (isLoggedIn && isLoggingIn) {
    return '/';
  }

  return null;
}

// 🛑 Router Builder Function
// lib/config/router_config.dart (or wherever you keep this)

GoRouter buildRouter() {
  return GoRouter(
    initialLocation: '/',
    redirect: redirectLogic,
    refreshListenable: StreamAuthNotifier(
      Supabase.instance.client.auth.onAuthStateChange.map(
        (event) => event.session,
      ),
    ),
    routes: <RouteBase>[
      GoRoute(
        path: "/",
        // 🛑 WRAP HERE: The Gatekeeper checks once, then holds the door open.
        builder: (BuildContext context, GoRouterState state) =>
            const BiometricGuard(child: DashboardPage()), 
            
        routes: <RouteBase>[
          GoRoute(
            path: "addStudent",
            builder: (context, state) => const RegisterStudentPage(),
          ),
          GoRoute(
            path: 'studentLedger',
            builder: (context, state) {
              final data = state.extra as Map<String, dynamic>;
              return ChangeNotifierProvider(
                create: (_) => StudentLedgerViewModel(data['studentId'].toString()),
                child: StudentLedgerPage(
                  studentId: data['studentId'].toString(),
                  studentName: data['studentName'] as String,
                  enrolledSubjects: List<String>.from(data['enrolledSubjects'] ?? []),
                ),
              );
            },
          ),
          GoRoute(
            path: "loggingPayments",
            builder: (context, state) {
              final studentId = state.extra as String? ?? "";
              return LoggingPaymentsPage(studentId: studentId);
            },
          ),
          GoRoute(
            path: 'evaluation',
            builder: (context, state) {
              final tabIndex = state.extra as int? ?? 0;
              return EvaluationPage(initialTabIndex: tabIndex);
            },
          ),
          GoRoute(
            path: 'search',
            builder: (context, state) => const SearchPage(),
          ),
          GoRoute(
            path: 'notifications',
            builder: (context, state) => const NotificationsPage(),
          ),
          GoRoute(
            path: 'profile',
            builder: (context, state) => const AdminProfilePage(),
            routes: <RouteBase>[
              GoRoute(
                path: 'edit',
                builder: (context, state) => const EditAdminDialogUtil(),
              ),
            ],
          ),
          GoRoute(
            path: 'revenueReports',
            builder: (context, state) => const RevenueReportsPage(),
          ),
        ],
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/studentGrowth',
        builder: (context, state) => const StudentGrowthPage(),
      ),
    ],
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. SQLite FFI setup
  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.macOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // 2. 🛑 Initialize Supabase Core (Using the confirmed keys)
  await Supabase.initialize(
    url: 'https://hcxvsygvihhdkkyynqzw.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhjeHZzeWd2aWhoZGtreXlucXp3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI5MTA3OTEsImV4cCI6MjA3ODQ4Njc5MX0.Tn1vzaNWHW9bV6FchGU_du-HQ9QDDXphxWJL1cM75qY',
  );

  // 3. Database init/migration
  final dbService = DatabaseService();
  await dbService.init();

  final prefs = await SharedPreferences.getInstance();
  final migrationKey = LocalStorageService.migrationCompleteKey;
  final isMigrationComplete = prefs.getBool(migrationKey) ?? false;

  if (!isMigrationComplete) {
    debugPrint("🚩 Running initial migration from JSON files...");
    await dbService.migrateFromJsonFiles();
  } else {
    debugPrint("🚩 Migration skipped. Flag set: true.");
  }

  // await LocalStorageService().forceQueueAllDataForSync();
  // 4. Build router AFTER Supabase is ready
  final router = buildRouter();
  // await LocalStorageService().wipeOldJsonFilesAndSetFlag();

  runApp(MyApp(router: router));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.router});
  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DashboardViewModel()),
        ChangeNotifierProvider(create: (_) => RegisterStudentViewModel()),
        ChangeNotifierProvider(create: (_) => NotificationViewModel()),
        ChangeNotifierProvider(create: (_) => SearchViewModel()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Fees Up',
        theme: ThemeData(
          colorScheme: ColorScheme.dark(
            primary: const Color(0xff3498db),
            onPrimary: const Color(0xffffffff),
            secondary: const Color(0xff2ecc71),
            onSecondary: const Color(0xffffffff),
            surface: const Color(0xff1c2a35),
            onSurface: Colors.white,
            error: const Color(0xffff4c4c),
            onError: const Color(0xffffffff),
            tertiary: Colors.blueGrey.shade800,
            onTertiary: const Color(0xffffffff),
          ),
          scaffoldBackgroundColor: const Color(0xff121b22),
          fontFamily: 'Poppins',
          useMaterial3: true,
        ),
        routerConfig: router,
      ),
    );
  }
}
