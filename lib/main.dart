import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/router.dart';
import 'constants/app_theme.dart';
import 'core/init/app_initializer.dart';

void main() async {
  await AppInitializer.init();
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
