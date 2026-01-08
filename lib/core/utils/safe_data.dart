/// Utility class for safe data handling and null safety
class SafeData {
  static String safeString(String? value, {String fallback = ''}) {
    return value ?? fallback;
  }

  static int safeInt(int? value, {int fallback = 0}) {
    return value ?? fallback;
  }

  static double safeDouble(double? value, {double fallback = 0.0}) {
    return value ?? fallback;
  }

  static bool safeBool(bool? value, {bool fallback = false}) {
    return value ?? fallback;
  }

  static List<T> safeList<T>(List<T>? value) {
    return value ?? [];
  }
}
