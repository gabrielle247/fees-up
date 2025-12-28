import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logging/logging.dart'; // <--- ADD THIS IMPORT

import 'core/theme/app_theme.dart';
import 'core/routes/app_router.dart';
import 'data/services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 0. SILENCE LOGS (Production Setting)
  // This stops the infinite warning loop in the console
  Logger.root.level = Level.SEVERE; 

  // 1. Load Keys from Environment (Makefile)
  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    debugPrint("⚠️ WARNING: Supabase Keys missing. Run with 'make run'.");
  } else {
    // 2. Initialize Supabase
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  // 3. Initialize Database Engine (PowerSync)
  try {
    final dbService = DatabaseService();
    await dbService.initialize();
    // await dbService.factoryReset();
  } catch (e) {
    debugPrint("❌ Database Init Failed: $e");
  }

  // 4. Run App wrapped in ProviderScope
  runApp(
    const ProviderScope(
      child: GreywayApp(),
    ),
  );
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