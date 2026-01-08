import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io';

import '../../data/services/app_logger.dart';
import '../config/app_config.dart';

class AppInitializer {
  /// Initializes all core services required for the app to start.
  static Future<void> init() async {
    // 0. Initialize Logger first to capture startup logs
    AppLogger.init();

    final stopwatch = Stopwatch()..start();
    AppLogger.info('Starting application initialization...');

    try {
      // 1. Flutter Binding
      WidgetsFlutterBinding.ensureInitialized();

      // 2. Window Manager (Desktop only)
      if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
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
      // Check if the URL is a placeholder to avoid crashing on startup
      if (AppConfig.supabaseUrl.contains('your-project') || AppConfig.supabaseUrl.isEmpty) {
         AppLogger.warning('Supabase is not configured (placeholder URL detected). Skipping initialization.');
         AppLogger.warning('To fix: Update SUPABASE_URL in lib/core/config/app_config.dart or use --dart-define.');
      } else {
        await Supabase.initialize(
          url: AppConfig.supabaseUrl,
          anonKey: AppConfig.supabaseAnonKey,
        );
      }

      AppLogger.success('Initialization completed in ${stopwatch.elapsedMilliseconds}ms');
    } catch (e, stackTrace) {
      AppLogger.error('Initialization failed', e, stackTrace);
      // Re-throw to prevent app from starting in a broken state
      Error.throwWithStackTrace(e, stackTrace);
    }
  }
}
