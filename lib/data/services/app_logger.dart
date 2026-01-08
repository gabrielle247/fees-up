import 'dart:io';

/// Production-grade logger (pure Dart, no platform dependencies)
class AppLogger {
  static const String _tag = '[FeesUp]';

  static void info(String message) => _log('ℹ️ INFO', message);
  static void success(String message) => _log('✅ SUCCESS', message);
  static void warning(String message) => _log('⚠️ WARNING', message);
  static void error(String message, [Object? error]) {
    _log('❌ ERROR', message);
    if (error != null) _log('  ➜ Details', error.toString());
  }

  static void _log(String level, String message) {
    final timestamp = DateTime.now().toIso8601String();
    // Use stderr to avoid mixing with app output
    stderr.writeln('$timestamp $_tag $level: $message');
  }
}
