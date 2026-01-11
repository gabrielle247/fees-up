import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

// -----------------------------------------------------------------------------
// IMPORTS
// -----------------------------------------------------------------------------
import 'app.dart';
// import 'package:fees_up/data/constants/init_backend.dart'; // Commented out for placebo mode

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ---------------------------------------------------------------------------
  // LOGGING SETUP
  // ---------------------------------------------------------------------------
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    debugPrint('${record.level.name}: ${record.time}: ${record.message}');
  });

  // ---------------------------------------------------------------------------
  // BACKEND INITIALIZATION (PLACEBO MODE: OFF)
  // ---------------------------------------------------------------------------
  // await BackendInitializer().initialize();

  // ---------------------------------------------------------------------------
  // RUN APP
  // ---------------------------------------------------------------------------
  // Wrapped in ProviderScope because FeesUpApp is a ConsumerWidget
  runApp(
    const ProviderScope(
      child: FeesUpApp(),
    ),
  );
}