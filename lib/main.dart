import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/router.dart';
import 'constants/app_theme.dart';
import 'core/init/app_initializer.dart';
import 'data/services/app_logger.dart';
import 'data/services/isar_service.dart';

void main() async {
  await AppInitializer.init();

  // Initialize Isar if user is already logged in
  final user = Supabase.instance.client.auth.currentUser;
  if (user != null && user.email != null) {
    try {
      AppLogger.info('User logged in, initializing local database...');
      await IsarService().initialize(
        email: user.email!,
        uid: user.id,
      );
      AppLogger.success('Local database initialized.');
    } catch (e) {
      AppLogger.error('Failed to initialize local database', e);
      // Don't crash app, but user might see empty data
    }
  }

  runApp(const ProviderScope(child: FeesUpApp()));
}

class FeesUpApp extends StatelessWidget {
  const FeesUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Fees Up',
      theme: AppTheme.darkTheme,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
