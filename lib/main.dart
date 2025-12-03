import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:fees_up/core/services/database_service.dart';
import 'package:fees_up/core/routes/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.linux || 
      defaultTargetPlatform == TargetPlatform.windows || 
      defaultTargetPlatform == TargetPlatform.macOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  await Supabase.initialize(
    url: 'https://hcxvsygvihhdkkyynqzw.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhjeHZzeWd2aWhoZGtreXlucXp3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI5MTA3OTEsImV4cCI6MjA3ODQ4Njc5MX0.Tn1vzaNWHW9bV6FchGU_du-HQ9QDDXphxWJL1cM75qY',
  );

  // Initialize Local DB
  final db = DatabaseService();
  await db.database; 

  runApp(
    const ProviderScope(
      child: FeesUpApp(),
    ),
  );
}

class FeesUpApp extends ConsumerWidget {
  const FeesUpApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Fees Up',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Poppins',
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xff121b22),
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
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.transparent,
        ),
      ),
      routerConfig: router,
    );
  }
}
