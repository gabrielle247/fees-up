import 'package:supabase_flutter/supabase_flutter.dart';

class ReportsRepository {
  final SupabaseClient _client = Supabase.instance.client;

  // 1. Fetch Financial Data
  Future<Map<String, dynamic>> fetchFinancialSummary({
    required String schoolId,
    required DateTime start,
    required DateTime end,
  }) async {
    final response = await _client.rpc('get_financial_summary', params: {
      'target_school_id': schoolId,
      'start_date': start.toIso8601String(),
      'end_date': end.toIso8601String(),
    });
    return response as Map<String, dynamic>;
  }

  // 2. Fetch Outstanding Balances
  Future<List<Map<String, dynamic>>> fetchOutstandingBalances({
    required String schoolId,
    String grade = 'All Grades',
  }) async {
    final response = await _client.rpc('get_outstanding_balances', params: {
      'target_school_id': schoolId,
      'grade_filter': grade,
    });
    return List<Map<String, dynamic>>.from(response);
  }

  // 3. Fetch Enrollment Stats
  Future<Map<String, dynamic>> fetchEnrollmentTrends({
    required String schoolId,
  }) async {
    final response = await _client.rpc('get_enrollment_trends', params: {
      'target_school_id': schoolId,
    });
    return response as Map<String, dynamic>;
  }
}