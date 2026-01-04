// ------------------------------------------
// NOTE: Refactor this logic later
// ------------------------------------------

import 'dart:io'; // Needed for Platform
import 'package:flutter/foundation.dart'; // Needed for kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logging/logging.dart';
import 'package:window_manager/window_manager.dart'; // Make sure this is in pubspec.yaml

import 'core/theme/app_theme.dart';
import 'core/routes/app_router.dart';
import 'data/services/database_service.dart';
import 'data/services/device_authority_service.dart';
import 'data/services/security_sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 0. SILENCE LOGS
  Logger.root.level = Level.SEVERE;

  // --- DESKTOP WINDOW SETUP ---
  // Only run this on Desktop platforms
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = const WindowOptions(
      size: Size(1280, 720), // Default start size
      minimumSize: Size(1024, 768), // ⛔ REJECT small windows
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
      await windowManager.maximize(); // 🚀 Force Full Screen launch
    });
  }
  // ----------------------------

  // 1. Validate Environment Variables
  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  const powerSyncEndpoint = String.fromEnvironment('POWERSYNC_ENDPOINT_URL');

  // Fail fast if critical env vars are missing
  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    debugPrint(
        "❌ CRITICAL: SUPABASE_URL and SUPABASE_ANON_KEY required. Run with 'make run'.");
    runApp(const ProviderScope(child: GreywayApp())); // Will show error in UI
    return;
  }

  if (powerSyncEndpoint.isEmpty) {
    debugPrint(
        "❌ CRITICAL: POWERSYNC_ENDPOINT_URL required. Run with 'make run'.");
    runApp(const ProviderScope(child: GreywayApp())); // Will show error in UI
    return;
  }

  // 2. Initialize Supabase
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  // 3. Check Authentication Status
  final session = Supabase.instance.client.auth.currentSession;

  // 4. Initialize Database only if authenticated
  // If no session, app will route to auth screen and init later
  if (session != null) {
    try {
      final dbService = DatabaseService();
      await dbService.initialize();
      debugPrint("✅ Database initialized with authenticated session");

      // 5. Initialize Device Authority Service (Gets device ID)
      final authService = DeviceAuthorityService();
      await authService.initialize();
      debugPrint("✅ Device Authority Service initialized");

      // 6. 🔄 TRIGGER THE PULL ONCE (Background, non-blocking)
      final schoolId = Supabase.instance.client.auth.currentUser
          ?.userMetadata?['school_id'] as String?;
      if (schoolId != null) {
        // Fire and forget - runs in background
        SecuritySyncService()
            .pullSecurityRules(schoolId, authService.currentDeviceId);
      } else {
        debugPrint(
            "⚠️ No school_id in auth metadata. Security rules will pull on next login.");
      }
    } catch (e) {
      debugPrint("❌ Initialization Failed: $e");
    }
  } else {
    debugPrint("⚠️ No session found. Database will initialize after login.");
  }

  runApp(const ProviderScope(child: GreywayApp()));
}

class GreywayApp extends ConsumerWidget {
  const GreywayApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Fees Up',
      theme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}
