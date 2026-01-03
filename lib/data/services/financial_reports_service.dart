import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 🔒 SECURE Financial Reports Service
/// Generates comprehensive financial reports with export capabilities
/// Respects billing suspension status in all calculations
class FinancialReportsService {
  final SupabaseClient supabase;

  FinancialReportsService({required this.supabase});

  // ========== REPORT BUILDING ==========

  /// ✅ SECURE: Generate custom financial report
  /// Supports multiple report types with filtering
  Future<Map<String, dynamic>> generateCustomReport({
    required String schoolId,
    required ReportCategory category,
    required DateTimeRange dateRange,
    String? gradeLevel,
    String? studentId,
  }) async {
    try {
      switch (category) {
        case ReportCategory.tuitionCollection:
          return await _generateTuitionCollectionReport(
            schoolId: schoolId,
            dateRange: dateRange,
            gradeLevel: gradeLevel,
          );

        case ReportCategory.outstandingBalances:
          return await _generateOutstandingBalancesReport(
            schoolId: schoolId,
            gradeLevel: gradeLevel,
          );

        case ReportCategory.expenseAnalysis:
          return await _generateExpenseAnalysisReport(
            schoolId: schoolId,
            dateRange: dateRange,
          );

        case ReportCategory.paymentMethodBreakdown:
          return await _generatePaymentMethodReport(
            schoolId: schoolId,
            dateRange: dateRange,
          );

        case ReportCategory.studentLedger:
          return await _generateStudentLedgerReport(
            studentId: studentId ?? '',
            dateRange: dateRange,
          );

        case ReportCategory.cashFlow:
          return await _generateCashFlowReport(
            schoolId: schoolId,
            dateRange: dateRange,
          );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Tuition Collection Report
  /// Shows collected vs outstanding amounts with trend analysis
  Future<Map<String, dynamic>> _generateTuitionCollectionReport({
    required String schoolId,
    required DateTimeRange dateRange,
    String? gradeLevel,
  }) async {
    try {
      final response = await supabase.rpc('get_tuition_collection_report',
          params: {
            'p_school_id': schoolId,
            'p_start_date': dateRange.start.toIso8601String(),
            'p_end_date': dateRange.end.toIso8601String(),
            'p_grade_level': gradeLevel,
          });

      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Outstanding Balances Report
  /// Lists students with balances owed, sorted by amount
  Future<Map<String, dynamic>> _generateOutstandingBalancesReport({
    required String schoolId,
    String? gradeLevel,
  }) async {
    try {
      final response = await supabase.rpc('get_outstanding_balances_report',
          params: {
            'p_school_id': schoolId,
            'p_grade_level': gradeLevel,
          });

      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Expense Analysis Report
  /// Breaks down expenses by category with variance analysis
  Future<Map<String, dynamic>> _generateExpenseAnalysisReport({
    required String schoolId,
    required DateTimeRange dateRange,
  }) async {
    try {
      final response = await supabase.rpc('get_expense_analysis_report',
          params: {
            'p_school_id': schoolId,
            'p_start_date': dateRange.start.toIso8601String(),
            'p_end_date': dateRange.end.toIso8601String(),
          });

      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Payment Method Breakdown Report
  /// Shows payment volumes by method (Cash, Bank Transfer, etc.)
  Future<Map<String, dynamic>> _generatePaymentMethodReport({
    required String schoolId,
    required DateTimeRange dateRange,
  }) async {
    try {
      final response = await supabase.rpc('get_payment_method_report',
          params: {
            'p_school_id': schoolId,
            'p_start_date': dateRange.start.toIso8601String(),
            'p_end_date': dateRange.end.toIso8601String(),
          });

      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Student Ledger Report
  /// Complete transaction history for a single student
  Future<Map<String, dynamic>> _generateStudentLedgerReport({
    required String studentId,
    required DateTimeRange dateRange,
  }) async {
    try {
      final response = await supabase.rpc('get_student_ledger_report', params: {
        'p_student_id': studentId,
        'p_start_date': dateRange.start.toIso8601String(),
        'p_end_date': dateRange.end.toIso8601String(),
      });

      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Cash Flow Report
  /// Shows daily/weekly/monthly cash movements
  Future<Map<String, dynamic>> _generateCashFlowReport({
    required String schoolId,
    required DateTimeRange dateRange,
  }) async {
    try {
      final response = await supabase.rpc('get_cash_flow_report', params: {
        'p_school_id': schoolId,
        'p_start_date': dateRange.start.toIso8601String(),
        'p_end_date': dateRange.end.toIso8601String(),
      });

      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  // ========== FINANCIAL SUMMARY (Dashboard) ==========

  /// Get financial dashboard summary
  /// KPIs: Total collected, Outstanding, Collection rate, Expenses, Net position
  Future<Map<String, dynamic>> getFinancialSummary(String schoolId) async {
    try {
      final response = await supabase.rpc('get_financial_summary', params: {
        'target_school_id': schoolId,
      });

      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Get enrollment trends
  /// Shows student count trends over time (for projection calculations)
  Future<Map<String, dynamic>> getEnrollmentTrends(String schoolId) async {
    try {
      final response = await supabase.rpc('get_enrollment_trends', params: {
        'target_school_id': schoolId,
      });

      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  // ========== COMPARATIVE ANALYSIS ==========

  /// Compare financial performance across periods
  /// Useful for period-over-period analysis (YoY, QoQ, MoM)
  Future<Map<String, dynamic>> comparePerformancePeriods({
    required String schoolId,
    required DateTimeRange period1,
    required DateTimeRange period2,
  }) async {
    try {
      final response = await supabase.rpc('compare_periods', params: {
        'p_school_id': schoolId,
        'p_period1_start': period1.start.toIso8601String(),
        'p_period1_end': period1.end.toIso8601String(),
        'p_period2_start': period2.start.toIso8601String(),
        'p_period2_end': period2.end.toIso8601String(),
      });

      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Forecast future cash position based on historical data
  Future<Map<String, dynamic>> forecastCashFlow({
    required String schoolId,
    required int forecastDays,
  }) async {
    try {
      final response = await supabase.rpc('forecast_cash_flow', params: {
        'p_school_id': schoolId,
        'p_forecast_days': forecastDays,
      });

      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  // ========== EXPORT FUNCTIONALITY ==========

  /// ✅ NEW: Export report to CSV format
  /// Returns CSV string ready for file download
  String exportReportToCSV({
    required String reportName,
    required List<Map<String, dynamic>> data,
    List<String>? columnOrder,
  }) {
    if (data.isEmpty) {
      return 'No data available';
    }

    // Determine columns from first row or use specified order
    final columns = columnOrder ?? data.first.keys.toList();

    // Build CSV header
    final csv = StringBuffer();
    csv.writeln(columns.join(','));

    // Build CSV rows
    for (final row in data) {
      final values = columns.map((col) {
        final value = row[col];
        if (value == null) return '';

        // Escape quotes and wrap in quotes if contains comma
        final strValue = value.toString();
        if (strValue.contains(',') || strValue.contains('"')) {
          return '"${strValue.replaceAll('"', '""')}"';
        }
        return strValue;
      });

      csv.writeln(values.join(','));
    }

    return csv.toString();
  }

  /// ✅ NEW: Export report to JSON format
  /// Returns JSON string with metadata
  String exportReportToJSON({
    required String reportName,
    required Map<String, dynamic> reportData,
    String? description,
  }) {
    final export = {
      'metadata': {
        'reportName': reportName,
        'generatedAt': DateTime.now().toIso8601String(),
        'description': description,
      },
      'data': reportData,
    };

    // Simple JSON serialization
    return _jsonEncode(export);
  }

  /// Helper: Simple JSON encoding (Dart's jsonEncode alternative)
  String _jsonEncode(dynamic value) {
    if (value == null) return 'null';
    if (value is bool) return value.toString();
    if (value is num) return value.toString();
    if (value is String) return '"${value.replaceAll('"', '\\"')}"';
    if (value is List) {
      return '[${value.map(_jsonEncode).join(', ')}]';
    }
    if (value is Map) {
      final pairs = value.entries
          .map((e) => '"${e.key}": ${_jsonEncode(e.value)}')
          .join(', ');
      return '{$pairs}';
    }
    return value.toString();
  }

  // ========== AUDIT & COMPLIANCE ==========

  /// Get audit log for financial transactions
  /// Admin-only access to track all financial changes
  Future<List<Map<String, dynamic>>> getFinancialAuditLog({
    required String schoolId,
    DateTime? startDate,
    DateTime? endDate,
    String? actionType, // 'invoice_created', 'payment_recorded', 'refund_processed'
  }) async {
    try {
      final query = supabase
          .from('financial_audit_log')
          .select(
              'id, action_type, user_id, amount, reference_id, created_at, details');

      var filtered = query.eq('school_id', schoolId);

      // Apply all optional filters inline without reassignment
      final response = await (startDate != null && endDate != null && actionType != null
          ? filtered
              .gte('created_at', startDate.toIso8601String())
              .lte('created_at', endDate.toIso8601String())
              .eq('action_type', actionType)
              .order('created_at', ascending: false)
          : startDate != null && endDate != null
              ? filtered
                  .gte('created_at', startDate.toIso8601String())
                  .lte('created_at', endDate.toIso8601String())
                  .order('created_at', ascending: false)
          : startDate != null && actionType != null
              ? filtered
                  .gte('created_at', startDate.toIso8601String())
                  .eq('action_type', actionType)
                  .order('created_at', ascending: false)
              : endDate != null && actionType != null
                  ? filtered
                      .lte('created_at', endDate.toIso8601String())
                      .eq('action_type', actionType)
                      .order('created_at', ascending: false)
              : startDate != null
                  ? filtered
                      .gte('created_at', startDate.toIso8601String())
                      .order('created_at', ascending: false)
                  : endDate != null
                      ? filtered
                          .lte('created_at', endDate.toIso8601String())
                          .order('created_at', ascending: false)
                      : actionType != null
                          ? filtered
                              .eq('action_type', actionType)
                              .order('created_at', ascending: false)
                          : filtered.order('created_at', ascending: false));

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Validate financial consistency across all records
  /// Checks for discrepancies in bill vs payment totals
  Future<Map<String, dynamic>> validateFinancialConsistency(
      String schoolId) async {
    try {
      final response =
          await supabase.rpc('validate_financial_consistency', params: {
        'p_school_id': schoolId,
      });

      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }
}

// ========== ENUMS & TYPES ==========

enum ReportCategory {
  tuitionCollection,
  outstandingBalances,
  expenseAnalysis,
  paymentMethodBreakdown,
  studentLedger,
  cashFlow,
}

enum ReportFormat {
  pdf,
  csv,
  json,
  xlsx, // Excel format (if library available)
}

extension ReportCategoryDisplay on ReportCategory {
  String get displayName {
    switch (this) {
      case ReportCategory.tuitionCollection:
        return 'Tuition Collection Report';
      case ReportCategory.outstandingBalances:
        return 'Outstanding Balances Report';
      case ReportCategory.expenseAnalysis:
        return 'Expense Analysis Report';
      case ReportCategory.paymentMethodBreakdown:
        return 'Payment Method Breakdown';
      case ReportCategory.studentLedger:
        return 'Student Ledger';
      case ReportCategory.cashFlow:
        return 'Cash Flow Report';
    }
  }
}

/// Date range helper for reports
class DateTimeRange {
  final DateTime start;
  final DateTime end;

  DateTimeRange({
    required this.start,
    required this.end,
  });

  factory DateTimeRange.thisMonth() {
    final now = DateTime.now();
    return DateTimeRange(
      start: DateTime(now.year, now.month, 1),
      end: DateTime(now.year, now.month + 1, 1).subtract(const Duration(days: 1)),
    );
  }

  factory DateTimeRange.lastMonth() {
    final now = DateTime.now();
    final previousMonth = now.month == 1 ? 12 : now.month - 1;
    final previousYear = now.month == 1 ? now.year - 1 : now.year;
    return DateTimeRange(
      start: DateTime(previousYear, previousMonth, 1),
      end: DateTime(previousYear, previousMonth + 1, 1)
          .subtract(const Duration(days: 1)),
    );
  }

  factory DateTimeRange.thisYear() {
    final now = DateTime.now();
    return DateTimeRange(
      start: DateTime(now.year, 1, 1),
      end: DateTime(now.year, 12, 31),
    );
  }

  factory DateTimeRange.custom({
    required DateTime start,
    required DateTime end,
  }) {
    return DateTimeRange(start: start, end: end);
  }

  String get displayName {
    if (start.year == end.year && start.month == end.month) {
      return DateFormat('MMMM yyyy').format(start);
    }
    return '${DateFormat('MMM yyyy').format(start)} - ${DateFormat('MMM yyyy').format(end)}';
  }
}
