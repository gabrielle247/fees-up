import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:window_manager/window_manager.dart';

import '../../data/services/app_logger.dart';
import '../config/app_config.dart';

class AppInitializer {
  /// Initializes all core services required for the app to start.
  static Future<void> init() async {
    // 0. Initialize Logger first to capture startup logs
    AppLogger.init();

    final stopwatch = Stopwatch()..start();
    AppLogger.info('Starting application initialization...');
    _logConfiguration();

    try {
      // 1. Flutter Binding
      WidgetsFlutterBinding.ensureInitialized();

      // 2. Window Manager (Desktop only)
      // Use kIsWeb and defaultTargetPlatform to avoid dart:io dependency
      final isDesktop = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.windows ||
         defaultTargetPlatform == TargetPlatform.linux ||
         defaultTargetPlatform == TargetPlatform.macOS);

      if (isDesktop) {
        await windowManager.ensureInitialized();
        WindowOptions windowOptions = const WindowOptions(
          size: Size(1280, 720),
          center: true,
          backgroundColor: Colors.transparent,
          skipTaskbar: false,
          titleBarStyle: TitleBarStyle.normal,
        );
        await windowManager.waitUntilReadyToShow(windowOptions, () async {
          await windowManager.show();
          await windowManager.focus();
        });
      }

      // 3. Supabase
      if (AppConfig.supabaseUrl.isEmpty || AppConfig.supabaseUrl.contains('your-project')) {
         AppLogger.warning('Supabase is not configured. Skipping initialization.');
      } else {
        await Supabase.initialize(
          url: AppConfig.supabaseUrl,
          anonKey: AppConfig.supabaseAnonKey,
        );
        AppLogger.success('Supabase initialized successfully');
      }

      AppLogger.success('Initialization completed in ${stopwatch.elapsedMilliseconds}ms');
    } catch (e, stackTrace) {
      AppLogger.error('Initialization failed', e, stackTrace);
      // Re-throw to prevent app from starting in a broken state
      Error.throwWithStackTrace(e, stackTrace);
    }
  }

  static void _logConfiguration() {
    AppLogger.info('Environment: ${AppConfig.environment}');
    AppLogger.info('Supabase URL: ${AppConfig.supabaseUrl.isNotEmpty ? "Set" : "Not Set"}');
    AppLogger.info('PowerSync URL: ${AppConfig.powerSyncUrl.isNotEmpty ? "Set" : "Not Set"}');
  }
}
