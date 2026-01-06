/// Year Configuration Repository
/// Handles all database operations for school years, billing months, and terms.
/// This repository is the ONLY place database writes happen for year data.
library;

abstract class YearConfigurationRepository {
  /// Load complete year data including months and terms
  Future<Map<String, dynamic>?> loadYear(
    String yearId,
    String schoolId,
  );

  /// Save year with atomic transaction
  /// Ensures year + all months save together or rollback together
  Future<void> saveYear({
    required String yearId,
    required String schoolId,
    required String yearLabel,
    required String startDate,
    required String endDate,
    required String description,
    required bool active,
    required List<Map<String, dynamic>> terms,
    required List<String> removedTermIds,
    required List<Map<String, dynamic>> months,
  });

  /// Watch year changes in real-time
  Stream<Map<String, dynamic>?> watchYear(
    String yearId,
    String schoolId,
  );

  /// Watch months for a year
  Stream<List<Map<String, dynamic>>> watchMonths(
    String yearId,
    String schoolId,
  );
}

class YearConfigurationException implements Exception {
  final String message;
  YearConfigurationException(this.message);

  @override
  String toString() => 'YearConfigurationException: $message';
}
