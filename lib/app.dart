import 'package:fees_up/app_router.dart';
import 'package:fees_up/data/constants/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FeesUpApp extends ConsumerWidget {
  const FeesUpApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Fees Up',
      
      // -----------------------------------------------------------------------
      // THEME CONFIGURATION
      // -----------------------------------------------------------------------
      // Enforcing Dark Mode Strategy
      theme: AppTheme.darkTheme, 
      darkTheme: AppTheme.darkTheme, 
      themeMode: ThemeMode.dark, // Forces Dark Mode regardless of system settings

      // -----------------------------------------------------------------------
      // ROUTER
      // -----------------------------------------------------------------------
      routerConfig: appRouter,
      
      // -----------------------------------------------------------------------
      // DEBUG FLAGS
      // -----------------------------------------------------------------------
      debugShowCheckedModeBanner: false,
    );
  }
}