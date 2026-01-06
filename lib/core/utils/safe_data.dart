import 'package:flutter/foundation.dart';

/// 🛡️ SafeData: Universal type-safe data parsing
/// Solves Critical Issues #2 (Type Casting), #7 (Date Parsing), #12 (Sanitization)
///
/// Usage:
/// ```dart
/// final amount = SafeData.parseDouble(student['owed_total']);
/// final isActive = SafeData.parseInt(student['is_active']) == 1;
/// final dob = SafeData.parseDate(student['date_of_birth']);
/// final name = SafeData.sanitize(_nameController.text);
/// ```
class SafeData {
  // ============================================================
  // NUMERIC PARSING (Solves Issue #2: Unsafe Type Casting)
  // ============================================================

  /// Parse any value to double safely
  /// Handles: null, int, double, String
  /// Returns default value (0.0) if parsing fails
  static double parseDouble(dynamic value, [double defaultValue = 0.0]) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? defaultValue;
    }
    debugPrint(
        '⚠️ SafeData.parseDouble: Cannot parse $value (${value.runtimeType})');
    return defaultValue;
  }

  /// Parse any value to int safely
  /// Handles: null, int, double (truncates), String
  /// Returns default value (0) if parsing fails
  static int parseInt(dynamic value, [int defaultValue = 0]) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? defaultValue;
    }
    debugPrint(
        '⚠️ SafeData.parseInt: Cannot parse $value (${value.runtimeType})');
    return defaultValue;
  }

  /// Parse boolean safely from int (database field)
  /// 0 = false, 1 = true
  static bool parseBool(dynamic value, [bool defaultValue = false]) {
    final intVal = parseInt(value, defaultValue ? 1 : 0);
    return intVal == 1;
  }

  // ============================================================
  // DATE PARSING (Solves Issue #7: DateTime Crashes)
  // ============================================================

  /// Parse any value to DateTime safely
  /// Handles: null, String (ISO 8601), DateTime
  /// Returns fallback DateTime (or current time) if parsing fails
  ///
  /// Example:
  /// ```dart
  /// final dob = SafeData.parseDate(student['date_of_birth'],
  ///   fallback: DateTime(2010));
  /// ```
  static DateTime parseDate(dynamic value, {DateTime? fallback}) {
    final defaultDate = fallback ?? DateTime.now();

    if (value == null) {
      debugPrint('⚠️ SafeData.parseDate: Null value, using default');
      return defaultDate;
    }

    if (value is DateTime) return value;

    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        debugPrint('⚠️ SafeData.parseDate: Invalid format "$value" - $e');
        return defaultDate;
      }
    }

    debugPrint(
        '⚠️ SafeData.parseDate: Cannot parse $value (${value.runtimeType})');
    return defaultDate;
  }

  /// Format DateTime for database storage (ISO 8601)
  static String formatDate(DateTime date) => date.toIso8601String();

  /// Format DateTime for display (human-readable)
  static String formatDateDisplay(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // ============================================================
  // STRING SANITIZATION (Solves Issue #12: Input Validation)
  // ============================================================

  /// Sanitize string input to prevent SQL injection, XSS, and data corruption
  /// Removes dangerous characters and normalizes whitespace
  /// Safe for database storage and display
  ///
  /// Removes: < > " ' ; % ( ) & +
  /// Normalizes: Multiple spaces → single space
  ///
  /// Example:
  /// ```dart
  /// final cleanName = SafeData.sanitize(_nameController.text);
  /// ```
  static String sanitize(String input) {
    if (input.isEmpty) return '';

    return input
        .trim()
        // Remove HTML/SQL injection characters
        .replaceAll(RegExp('[<>"\'%;()&+]'), '')
        // Normalize whitespace (multiple spaces → single space)
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Validate email format
  static bool isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email);
  }

  /// Validate phone format (basic: numbers, +, -, space only)
  static bool isValidPhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^\d+\-\s]'), '');
    return cleaned.length >= 5;
  }

  /// Validate name (at least 2 characters, no leading/trailing spaces)
  static bool isValidName(String name) {
    return name.trim().length >= 2 &&
        !name.startsWith(' ') &&
        !name.endsWith(' ');
  }

  // ============================================================
  // COLLECTION HELPERS
  // ============================================================

  /// Safely get a value from a map with type checking
  /// Example:
  /// ```dart
  /// final student = SafeData.safeGet<String>(data, 'full_name', 'Unknown');
  /// ```
  static T safeGet<T>(Map<String, dynamic> map, String key, T defaultValue) {
    try {
      final value = map[key];
      if (value == null) return defaultValue;
      if (value is T) return value;
      // Attempt type conversion
      return defaultValue;
    } catch (e) {
      debugPrint('⚠️ SafeData.safeGet: Error accessing $key - $e');
      return defaultValue;
    }
  }

  /// Check if a list index is safe to access
  static bool isValidIndex(List list, int index) {
    return list.isNotEmpty && index >= 0 && index < list.length;
  }

  /// Safely get first element from a list
  static T? safeFirst<T>(List<T>? list) {
    return (list != null && list.isNotEmpty) ? list.first : null;
  }

  /// Safely get last element from a list
  static T? safeLast<T>(List<T>? list) {
    return (list != null && list.isNotEmpty) ? list.last : null;
  }
}
