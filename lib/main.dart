import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:local_auth/local_auth.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Services
import 'package:fees_up/services/database_service.dart';

// Brick Repository
import 'package:fees_up/brick/repository/brick_repository.dart';

// Providers
import 'package:fees_up/providers/auth_provider.dart';

// Pages
import 'package:fees_up/pages/auth_page.dart';
import 'package:fees_up/pages/home_screen.dart';

// 1. Global Navigator Key
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Load Env
  await dotenv.load(fileName: 'assets/keys.env');
  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

  if (supabaseUrl == null || supabaseAnonKey == null) {
    throw Exception('Missing Supabase keys in assets/keys.env');
  }

  // 3. Desktop DB Support
  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.macOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // 4. Initialize Services
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  await DatabaseService.instance.database; // Open DB

  // 5. Initialize Brick Repository with encryption
  try {
    await BrickRepository.instance.initialize();
    debugPrint('Brick offline-first repository initialized');
  } catch (e) {
    debugPrint('Failed to initialize Brick repository: $e');
    // Continue without Brick if initialization fails
  }

  runApp(const ProviderScope(child: FeesUpApp()));
}

class FeesUpApp extends ConsumerWidget {
  const FeesUpApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ----------------------------------------------------------------------
    // GLOBAL AUTH LISTENER (Now works because authStateChangesProvider is imported)
    // ----------------------------------------------------------------------
    ref.listen<AsyncValue<AuthState>>(
      authStateChangesProvider,
      (previous, next) {
        next.whenData((authState) {
          if (authState.event == AuthChangeEvent.signedOut) {
            // Force navigation to AuthPage on sign out and clear history
            navigatorKey.currentState?.pushNamedAndRemoveUntil(
              AuthPage.routeName,
              (route) => false,
            );
          }
        });
      },
    );

    final theme = ThemeData(
      brightness: Brightness.dark,
      fontFamily: 'Poppins',
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xff121b22),
      colorScheme: ColorScheme.dark(
        primary: const Color(0xff3498db),
        surface: const Color(0xff1c2a35),
        onSurface: Colors.white,
        error: const Color(0xffff4c4c),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
    );

    // Watch the controller to decide INITIAL screen
    final authStateAsync = ref.watch(authControllerProvider);

    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Fees Up',
      debugShowCheckedModeBanner: false,
      theme: theme,
      routes: {
        AuthPage.routeName: (context) => const AuthPage(),
        HomeScreen.routeName: (context) => const HomeScreen(),
      },
      home: authStateAsync.when(
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (e, s) => Scaffold(
          body: Center(child: Text("Startup Error: $e")),
        ),
        data: (isAuthenticated) {
          if (isAuthenticated) {
            // Logged In -> Use Biometric Guard
            return const BiometricGuard(child: HomeScreen());
          } else {
            // Not Logged In -> Auth Page
            return const AuthPage();
          }
        },
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// BIOMETRIC GUARD (Locks on App Resume/Switch)
// -----------------------------------------------------------------------------
class BiometricGuard extends StatefulWidget {
  final Widget child;
  const BiometricGuard({super.key, required this.child});

  @override
  State<BiometricGuard> createState() => _BiometricGuardState();
}

class _BiometricGuardState extends State<BiometricGuard> with WidgetsBindingObserver {
  final LocalAuthentication auth = LocalAuthentication();
  bool _isAuthenticated = false;
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkBiometrics();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // 🔒 Detect App Lifecycle to Lock on Resume
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      // App went to background -> Lock immediately
      if (mounted) setState(() => _isAuthenticated = false);
    } else if (state == AppLifecycleState.resumed && !_isAuthenticated) {
      // App came to foreground -> Prompt Auth
      _checkBiometrics();
    }
  }

  Future<void> _checkBiometrics() async {
    if (_isAuthenticating) return;
    setState(() => _isAuthenticating = true);

    try {
      final canCheckBiometrics = await auth.canCheckBiometrics;
      final isDeviceSupported = await auth.isDeviceSupported();

      if (!canCheckBiometrics || !isDeviceSupported) {
        // Fallback for devices without hardware
        if (mounted) {
          setState(() {
            _isAuthenticated = true;
            _isAuthenticating = false;
          });
        }
        return;
      }

      final authenticated = await auth.authenticate(
        localizedReason: 'Please authenticate to access Fees Up',
        authMessages: const [],
      );

      if (mounted) {
        setState(() {
          _isAuthenticated = authenticated;
          _isAuthenticating = false;
        });
      }

      if (!authenticated) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted && !_isAuthenticated) {
          _checkBiometrics();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAuthenticated = true;
          _isAuthenticating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAuthenticated) {
      return Scaffold(
        backgroundColor: const Color(0xff121b22),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.fingerprint, size: 80, color: Color(0xff3498db)),
              const SizedBox(height: 24),
              const Text(
                'Authentication Required',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (_isAuthenticating)
                const CircularProgressIndicator()
              else
                ElevatedButton.icon(
                  onPressed: _checkBiometrics,
                  icon: const Icon(Icons.lock_open),
                  label: const Text('Authenticate'),
                ),
            ],
          ),
        ),
      );
    }

    return widget.child;
  }
}