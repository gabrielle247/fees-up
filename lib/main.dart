import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/theme/app_theme.dart';
import 'core/routes/app_router.dart';
import 'data/services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Load Keys from Environment (Makefile)
  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    // Graceful fallback for UI dev if keys aren't present (optional)
    debugPrint("⚠️ WARNING: Supabase Keys missing. Run with 'make run'.");
  } else {
    // 2. Initialize Supabase
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  // 3. Initialize Database Engine (PowerSync)
  // We wrap this in a try-catch to ensure the app still launches even if DB fails initially
  try {
    final dbService = DatabaseService();
    await dbService.initialize();
  } catch (e) {
    debugPrint("❌ Database Init Failed: $e");
  }

  // 4. Run App wrapped in ProviderScope (Crucial for Riverpod)
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
    // We watch the routerProvider from app_router.dart
    final router = ref.watch(AppRouter.routerProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Fees Up',
      theme: AppTheme.darkTheme,
      
      // Router Configuration
      routerConfig: router,
    );
  }
}