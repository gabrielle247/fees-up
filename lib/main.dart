import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// -----------------------------------------------------------------------------
// 1. GLOBAL CONFIGURATION & INITIALIZATION
// -----------------------------------------------------------------------------

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --- A. Linux/Windows/macOS Database Setup ---
  if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.linux || 
      defaultTargetPlatform == TargetPlatform.windows || 
      defaultTargetPlatform == TargetPlatform.macOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // --- B. Initialize Supabase ---
  await Supabase.initialize(
    url: 'https://hcxvsygvihhdkkyynqzw.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhjeHZzeWd2aWhoZGtreXlucXp3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI5MTA3OTEsImV4cCI6MjA3ODQ4Njc5MX0.Tn1vzaNWHW9bV6FchGU_du-HQ9QDDXphxWJL1cM75qY',
  );

  // --- C. Run the App wrapped in Riverpod Scope ---
  runApp(
    const ProviderScope(
      child: FeesUpApp(),
    ),
  );
}

// -----------------------------------------------------------------------------
// 2. ROOT WIDGET
// -----------------------------------------------------------------------------

class FeesUpApp extends ConsumerWidget {
  const FeesUpApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Fees Up',
      debugShowCheckedModeBanner: false,
      
      // --- THEME CONFIGURATION ---
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Poppins',
        useMaterial3: true,
        // FIXED: scaffoldBackgroundColor belongs here, NOT inside ColorScheme
        scaffoldBackgroundColor: const Color(0xff121b22), 
        
        colorScheme: const ColorScheme.dark(
          primary: Color(0xff3498db),      
          onPrimary: Colors.white,
          secondary: Color(0xff2ecc71),    
          surface: Color(0xff1c2a35),
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

// -----------------------------------------------------------------------------
// 3. ROUTER CONFIGURATION
// -----------------------------------------------------------------------------

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const TemporaryHomeScreen(),
      ),
    ],
  );
});

// -----------------------------------------------------------------------------
// 4. TEMPORARY HOME SCREEN
// -----------------------------------------------------------------------------

class TemporaryHomeScreen extends StatelessWidget {
  const TemporaryHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Fees Up Setup")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 20),
            const Text(
              "Environment Healthy!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text("Riverpod v3 • GoRouter v17 • SQLCipher"),
            const SizedBox(height: 30),
            FilledButton.icon(
              onPressed: () {
                debugPrint("Ready to start coding!");
              },
              icon: const Icon(Icons.code),
              label: const Text("Start coding features"),
            )
          ],
        ),
      ),
    );
  }
}
