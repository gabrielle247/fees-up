import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/router.dart';
import 'constants/app_theme.dart';
import 'core/init/app_initializer.dart';
import 'data/services/app_logger.dart';

void main() async {
  await AppInitializer.init();

  // No need to initialize Drift - it's handled by the AppDatabase singleton
  AppLogger.success('App initialized successfully.');

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
