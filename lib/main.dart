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

  // 1. Load Keys
  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    debugPrint("⚠️ WARNING: Supabase Keys missing. Run with 'make run'.");
  } else {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  // 2. Initialize Database
  try {
    final dbService = DatabaseService();
    await dbService.initialize();
  } catch (e) {
    debugPrint("❌ Database Init Failed: $e");
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