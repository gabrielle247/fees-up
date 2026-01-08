import 'package:logging/logging.dart';
import 'package:flutter/foundation.dart';

/// Production-grade logger wrapping `package:logging`.
class AppLogger {
  static const String _loggerName = 'FeesUp';
  static final Logger _logger = Logger(_loggerName);

  /// Initializes the logging system.
  /// Should be called at app startup.
  static void init() {
    Logger.root.level = Level.ALL; // Capture all logs, filter in listener if needed
    Logger.root.onRecord.listen((record) {
      final timestamp = record.time.toIso8601String();
      final level = record.level.name;
      final message = record.message;
      final error = record.error;
      final stackTrace = record.stackTrace;

      final formattedMessage = '$timestamp [${record.loggerName}] $level: $message';

      if (record.level >= Level.SEVERE) {
        // debugPrint uses the platform's native logging (e.g. Android Logcat, iOS Console, Browser Console)
        // It also throttles output on Android to prevent dropped logs.
        debugPrint(formattedMessage);
        if (error != null) debugPrint('  ➜ Error: $error');
        if (stackTrace != null) debugPrint('  ➜ StackTrace:\n$stackTrace');
      } else {
        // Use debugPrint for all logs to ensure they appear in the console across platforms
        debugPrint(formattedMessage);
      }
    });
  }

  static void info(String message) => _logger.info(message);

  // 'success' is not a standard log level, mapping to INFO with a prefix
  static void success(String message) => _logger.info('✅ SUCCESS: $message');

  static void warning(String message) => _logger.warning(message);

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.severe(message, error, stackTrace);
  }
}
