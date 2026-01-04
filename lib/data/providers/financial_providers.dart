import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/invoice_service.dart';
import '../services/transaction_service.dart';
import '../services/financial_reports_service.dart';

// ========== SERVICE PROVIDERS ==========

/// Invoice Service provider
final invoiceServiceProvider = Provider<InvoiceService>((ref) {
  final supabase = Supabase.instance.client;
  return InvoiceService(supabase: supabase);
});

/// Transaction Service provider
final transactionServiceProvider = Provider<TransactionService>((ref) {
  final supabase = Supabase.instance.client;
  return TransactionService(supabase: supabase);
});

/// Financial Reports Service provider
final financialReportsServiceProvider =
    Provider<FinancialReportsService>((ref) {
  final supabase = Supabase.instance.client;
  return FinancialReportsService(supabase: supabase);
});

// ========== INVOICE PROVIDERS ==========

/// Get next invoice number for a school
final nextInvoiceNumberProvider =
    FutureProvider.family<String, String>((ref, schoolId) async {
  final invoiceService = ref.watch(invoiceServiceProvider);
  return invoiceService.getNextInvoiceNumber(schoolId);
});

/// Get all invoices for a school
final schoolInvoicesProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>(
        (ref, schoolId) async {
  final invoiceService = ref.watch(invoiceServiceProvider);
  return invoiceService.getInvoicesForSchool(schoolId: schoolId);
});

/// Get outstanding invoices for a student
final studentOutstandingInvoicesProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>(
        (ref, studentId) async {
  final invoiceService = ref.watch(invoiceServiceProvider);
  return invoiceService.getOutstandingInvoices(studentId);
});

/// Get invoice statistics for school dashboard
final invoiceStatisticsProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, schoolId) async {
  final invoiceService = ref.watch(invoiceServiceProvider);
  return invoiceService.getInvoiceStatistics(schoolId);
});

/// Get invoices by date range
final invoicesByDateRangeProvider = FutureProvider.family<
    List<Map<String, dynamic>>,
    ({String schoolId, DateTime startDate, DateTime endDate})>(
  (ref, params) async {
    final invoiceService = ref.watch(invoiceServiceProvider);
    return invoiceService.getInvoicesByDateRange(
      schoolId: params.schoolId,
      startDate: params.startDate,
      endDate: params.endDate,
    );
  },
);

// ========== PAYMENT & ALLOCATION PROVIDERS ==========

/// Get outstanding bills with balance for a student
final outstandingBillsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>(
        (ref, studentId) async {
  final transactionService = ref.watch(transactionServiceProvider);
  return transactionService.getOutstandingBillsWithBalance(studentId);
});

/// Get payment allocations for a payment
final paymentAllocationsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>(
        (ref, paymentId) async {
  final transactionService = ref.watch(transactionServiceProvider);
  return transactionService.getPaymentAllocations(paymentId);
});

/// Get bill payment summary
final billPaymentSummaryProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, billId) async {
  final transactionService = ref.watch(transactionServiceProvider);
  return transactionService.getBillPaymentSummary(billId);
});

/// Get payment history for a student
final paymentHistoryProvider = FutureProvider.family<List<Map<String, dynamic>>,
    ({String studentId, DateTime? startDate, DateTime? endDate})>(
  (ref, params) async {
    final transactionService = ref.watch(transactionServiceProvider);
    return transactionService.getPaymentHistory(
      studentId: params.studentId,
      startDate: params.startDate,
      endDate: params.endDate,
    );
  },
);

/// Get refund history for a student
final refundHistoryProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>(
        (ref, studentId) async {
  final transactionService = ref.watch(transactionServiceProvider);
  return transactionService.getRefundHistory(studentId);
});

/// Get transaction summary for school
final transactionSummaryProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, schoolId) async {
  final transactionService = ref.watch(transactionServiceProvider);
  return transactionService.getTransactionSummary(schoolId);
});

// ========== FINANCIAL REPORTS PROVIDERS ==========

/// Get financial summary (dashboard)
final financialSummaryProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, schoolId) async {
  final reportsService = ref.watch(financialReportsServiceProvider);
  return reportsService.getFinancialSummary(schoolId);
});

/// Get enrollment trends
final enrollmentTrendsProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, schoolId) async {
  final reportsService = ref.watch(financialReportsServiceProvider);
  return reportsService.getEnrollmentTrends(schoolId);
});

/// Get custom report
final customReportProvider = FutureProvider.family<
    Map<String, dynamic>,
    ({
      String schoolId,
      ReportCategory category,
      DateTimeRange dateRange,
      String? gradeLevel,
      String? studentId,
    })>(
  (ref, params) async {
    final reportsService = ref.watch(financialReportsServiceProvider);
    return reportsService.generateCustomReport(
      schoolId: params.schoolId,
      category: params.category,
      dateRange: params.dateRange,
      gradeLevel: params.gradeLevel,
      studentId: params.studentId,
    );
  },
);

/// Get financial audit log
final financialAuditLogProvider = FutureProvider.family<
    List<Map<String, dynamic>>,
    ({
      String schoolId,
      DateTime? startDate,
      DateTime? endDate,
      String? actionType,
    })>(
  (ref, params) async {
    final reportsService = ref.watch(financialReportsServiceProvider);
    return reportsService.getFinancialAuditLog(
      schoolId: params.schoolId,
      startDate: params.startDate,
      endDate: params.endDate,
      actionType: params.actionType,
    );
  },
);

/// Compare financial performance between periods
final comparePeriodsProvider = FutureProvider.family<
    Map<String, dynamic>,
    ({
      String schoolId,
      DateTimeRange period1,
      DateTimeRange period2,
    })>(
  (ref, params) async {
    final reportsService = ref.watch(financialReportsServiceProvider);
    return reportsService.comparePerformancePeriods(
      schoolId: params.schoolId,
      period1: params.period1,
      period2: params.period2,
    );
  },
);

/// Forecast cash flow
final cashFlowForecastProvider = FutureProvider.family<Map<String, dynamic>,
    ({String schoolId, int forecastDays})>(
  (ref, params) async {
    final reportsService = ref.watch(financialReportsServiceProvider);
    return reportsService.forecastCashFlow(
      schoolId: params.schoolId,
      forecastDays: params.forecastDays,
    );
  },
);

// ========== STATE NOTIFIERS ==========

/// State for invoice creation dialog
class InvoiceCreationState {
  final String studentId;
  final String title;
  final double amount;
  final DateTime dueDate;
  final String invoiceStatus; // 'draft', 'sent'
  final bool isLoading;
  final String? error;

  InvoiceCreationState({
    required this.studentId,
    required this.title,
    required this.amount,
    required this.dueDate,
    this.invoiceStatus = 'draft',
    this.isLoading = false,
    this.error,
  });

  InvoiceCreationState copyWith({
    String? studentId,
    String? title,
    double? amount,
    DateTime? dueDate,
    String? invoiceStatus,
    bool? isLoading,
    String? error,
  }) {
    return InvoiceCreationState(
      studentId: studentId ?? this.studentId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      invoiceStatus: invoiceStatus ?? this.invoiceStatus,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// Notifier for invoice creation
class InvoiceCreationNotifier extends StateNotifier<InvoiceCreationState> {
  final InvoiceService invoiceService;

  InvoiceCreationNotifier({required this.invoiceService})
      : super(
          InvoiceCreationState(
            studentId: '',
            title: '',
            amount: 0.0,
            dueDate: DateTime.now().add(const Duration(days: 7)),
          ),
        );

  void updateStudentId(String studentId) {
    state = state.copyWith(studentId: studentId);
  }

  void updateTitle(String title) {
    state = state.copyWith(title: title);
  }

  void updateAmount(double amount) {
    state = state.copyWith(amount: amount);
  }

  void updateDueDate(DateTime date) {
    state = state.copyWith(dueDate: date);
  }

  void updateStatus(String status) {
    state = state.copyWith(invoiceStatus: status);
  }

  Future<void> submitInvoice(String schoolId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      if (state.studentId.isEmpty || state.title.isEmpty || state.amount <= 0) {
        throw Exception('Please fill all required fields');
      }

      // Get current user ID from Supabase
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      await invoiceService.createAdhocInvoice(
        schoolId: schoolId,
        studentId: state.studentId,
        title: state.title,
        amount: state.amount,
        dueDate: state.dueDate,
        status: state.invoiceStatus,
        userId: user.id,
      );

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  void reset() {
    state = InvoiceCreationState(
      studentId: '',
      title: '',
      amount: 0.0,
      dueDate: DateTime.now().add(const Duration(days: 7)),
    );
  }
}

/// Invoice creation state notifier provider
final invoiceCreationProvider =
    StateNotifierProvider<InvoiceCreationNotifier, InvoiceCreationState>(
  (ref) {
    final invoiceService = ref.watch(invoiceServiceProvider);
    return InvoiceCreationNotifier(invoiceService: invoiceService);
  },
);

// ========== REPORT STATE PROVIDERS ==========

/// Selected date range for reports
final reportDateRangeProvider = StateProvider<DateTimeRange>((ref) {
  return DateTimeRange.thisMonth();
});

/// Selected report category
final reportCategoryProvider = StateProvider<ReportCategory>((ref) {
  return ReportCategory.tuitionCollection;
});

/// Selected grade filter for reports
final reportGradeFilterProvider = StateProvider<String?>((ref) {
  return null;
});

/// Currently displayed report data
final currentReportProvider = FutureProvider<Map<String, dynamic>>((ref) {
  final schoolId = ref.watch(selectedSchoolIdProvider);
  final category = ref.watch(reportCategoryProvider);
  final dateRange = ref.watch(reportDateRangeProvider);
  final gradeFilter = ref.watch(reportGradeFilterProvider);
  final reportsService = ref.watch(financialReportsServiceProvider);

  if (schoolId == null) {
    return Future.error('No school selected');
  }

  return reportsService.generateCustomReport(
    schoolId: schoolId,
    category: category,
    dateRange: dateRange,
    gradeLevel: gradeFilter,
  );
});

// ========== UTILITY PROVIDERS ==========

/// Selected school ID (from app state)
final selectedSchoolIdProvider = StateProvider<String?>((ref) {
  // TODO: Connect to auth/school selection provider
  return null;
});

/// Get recent transactions for school
final schoolTransactionsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>(
        (ref, schoolId) async {
  final transactionService = ref.watch(transactionServiceProvider);
  return transactionService.getSchoolTransactions(schoolId);
});

/// Format currency for display
final currencyFormatterProvider = Provider<String Function(double)>((ref) {
  return (amount) {
    return NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(amount);
  };
});

/// Format date for display
final dateFormatterProvider = Provider<String Function(DateTime)>((ref) {
  return (date) {
    return DateFormat('MMM dd, yyyy').format(date);
  };
});
