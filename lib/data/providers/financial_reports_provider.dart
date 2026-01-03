import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

/// Financial Reports Provider
/// Connects to deployed RPC functions for real-time financial data
final financialReportsProvider = Provider((ref) {
  return FinancialReportsService(Supabase.instance.client);
});

/// Invoice Statistics Stream Provider - Updates periodically
final invoiceStatsProvider =
    StreamProvider.family<Map<String, dynamic>, InvoiceStatsParams>(
        (ref, params) async* {
  final service = ref.watch(financialReportsProvider);

  // Periodic refresh every 30 seconds for real-time-like updates
  final timer = Stream.periodic(const Duration(seconds: 30));

  await for (final _ in timer) {
    try {
      final stats = await service.getInvoiceStatistics(
        schoolId: params.schoolId,
        startDate: params.startDate,
        endDate: params.endDate,
      );
      yield stats;
    } catch (e) {
      // Continue with error state or previous value
      continue;
    }
  }
});

/// Transaction Summary Stream Provider - Updates periodically
final transactionSummaryProvider =
    StreamProvider.family<Map<String, dynamic>, TransactionSummaryParams>(
        (ref, params) async* {
  final service = ref.watch(financialReportsProvider);

  // Periodic refresh every 30 seconds for real-time-like updates
  final timer = Stream.periodic(const Duration(seconds: 30));

  await for (final _ in timer) {
    try {
      final summary = await service.getTransactionSummary(
        schoolId: params.schoolId,
        startDate: params.startDate,
        endDate: params.endDate,
      );
      yield summary;
    } catch (e) {
      // Continue with error state or previous value
      continue;
    }
  }
});

/// Outstanding Bills Stream Provider - Updates periodically
final outstandingBillsProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>(
        (ref, studentId) async* {
  final service = ref.watch(financialReportsProvider);

  // Periodic refresh every 30 seconds for real-time-like updates
  final timer = Stream.periodic(const Duration(seconds: 30));

  await for (final _ in timer) {
    try {
      final bills = await service.getOutstandingBills(studentId);
      yield bills;
    } catch (e) {
      // Continue with error state or previous value
      continue;
    }
  }
});

/// Payment Allocation History Stream Provider - Updates periodically
final paymentAllocationHistoryProvider =
    StreamProvider.family<List<Map<String, dynamic>>, AllocationHistoryParams>(
        (ref, params) async* {
  final service = ref.watch(financialReportsProvider);

  // Periodic refresh every 30 seconds for real-time-like updates
  final timer = Stream.periodic(const Duration(seconds: 30));

  await for (final _ in timer) {
    try {
      final history = await service.getPaymentAllocationHistory(
        studentId: params.studentId,
        limit: params.limit,
      );
      yield history;
    } catch (e) {
      // Continue with error state or previous value
      continue;
    }
  }
});

// Parameter Classes
class InvoiceStatsParams {
  final String schoolId;
  final DateTime? startDate;
  final DateTime? endDate;

  InvoiceStatsParams({
    required this.schoolId,
    this.startDate,
    this.endDate,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InvoiceStatsParams &&
          runtimeType == other.runtimeType &&
          schoolId == other.schoolId &&
          startDate == other.startDate &&
          endDate == other.endDate;

  @override
  int get hashCode => Object.hash(schoolId, startDate, endDate);
}

class TransactionSummaryParams {
  final String schoolId;
  final DateTime? startDate;
  final DateTime? endDate;

  TransactionSummaryParams({
    required this.schoolId,
    this.startDate,
    this.endDate,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionSummaryParams &&
          runtimeType == other.runtimeType &&
          schoolId == other.schoolId &&
          startDate == other.startDate &&
          endDate == other.endDate;

  @override
  int get hashCode => Object.hash(schoolId, startDate, endDate);
}

class AllocationHistoryParams {
  final String studentId;
  final int limit;

  AllocationHistoryParams({
    required this.studentId,
    this.limit = 50,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AllocationHistoryParams &&
          runtimeType == other.runtimeType &&
          studentId == other.studentId &&
          limit == other.limit;

  @override
  int get hashCode => Object.hash(studentId, limit);
}

/// Financial Reports Service
/// Uses deployed Supabase RPC functions
class FinancialReportsService {
  final SupabaseClient _supabase;

  FinancialReportsService(this._supabase);

  /// Get invoice statistics using deployed RPC function
  Future<Map<String, dynamic>> getInvoiceStatistics({
    required String schoolId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final result = await _supabase.rpc(
        'get_invoice_statistics',
        params: {
          'p_school_id': schoolId,
          if (startDate != null)
            'p_start_date': startDate.toIso8601String().split('T')[0],
          if (endDate != null)
            'p_end_date': endDate.toIso8601String().split('T')[0],
        },
      );

      return result as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to fetch invoice statistics: $e');
    }
  }

  /// Get transaction summary using deployed RPC function
  Future<Map<String, dynamic>> getTransactionSummary({
    required String schoolId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final result = await _supabase.rpc(
        'get_transaction_summary',
        params: {
          'p_school_id': schoolId,
          if (startDate != null)
            'p_start_date': startDate.toIso8601String().split('T')[0],
          if (endDate != null)
            'p_end_date': endDate.toIso8601String().split('T')[0],
        },
      );

      return result as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to fetch transaction summary: $e');
    }
  }

  /// Get outstanding bills using deployed RPC function
  Future<List<Map<String, dynamic>>> getOutstandingBills(
      String studentId) async {
    try {
      final result = await _supabase.rpc(
        'get_outstanding_bills_with_balance',
        params: {
          'p_student_id': studentId,
        },
      );

      return List<Map<String, dynamic>>.from(result as List);
    } catch (e) {
      throw Exception('Failed to fetch outstanding bills: $e');
    }
  }

  /// Get payment allocation history using deployed RPC function
  Future<List<Map<String, dynamic>>> getPaymentAllocationHistory({
    required String studentId,
    int limit = 50,
  }) async {
    try {
      final result = await _supabase.rpc(
        'get_payment_allocation_history',
        params: {
          'p_student_id': studentId,
          'p_limit': limit,
        },
      );

      return List<Map<String, dynamic>>.from(result as List);
    } catch (e) {
      throw Exception('Failed to fetch payment history: $e');
    }
  }

  /// Get bill payment summary using deployed RPC function
  Future<Map<String, dynamic>> getBillPaymentSummary(String billId) async {
    try {
      final result = await _supabase.rpc(
        'get_bill_payment_summary',
        params: {
          'p_bill_id': billId,
        },
      );

      return result as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to fetch bill payment summary: $e');
    }
  }

  /// Generate next invoice number using deployed RPC function
  Future<String> generateNextInvoiceNumber(String schoolId) async {
    try {
      final result = await _supabase.rpc(
        'generate_next_invoice_number',
        params: {
          'p_school_id': schoolId,
        },
      );

      return result as String;
    } catch (e) {
      throw Exception('Failed to generate invoice number: $e');
    }
  }
}
