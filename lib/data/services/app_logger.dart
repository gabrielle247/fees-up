import 'package:logging/logging.dart';
import 'dart:io';

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
        stderr.writeln(formattedMessage);
        if (error != null) stderr.writeln('  ➜ Error: $error');
        if (stackTrace != null) stderr.writeln('  ➜ StackTrace:\n$stackTrace');
      } else {
        // Use stdout for non-error logs
        stdout.writeln(formattedMessage);
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
