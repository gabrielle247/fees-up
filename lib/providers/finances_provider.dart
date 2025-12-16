import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../services/database_service.dart';

// -----------------------------------------------------------------------------
// UI DATA MODELS
// -----------------------------------------------------------------------------

/// Holds the aggregated data for the Finances Page
class FinancesPageData {
  final double totalRevenueYtd;
  final double totalOutstanding;
  final int openInvoicesCount;
  final List<AttentionItem> attentionList;
  final List<TransactionItem> recentTransactions;

  FinancesPageData({
    required this.totalRevenueYtd,
    required this.totalOutstanding,
    required this.openInvoicesCount,
    required this.attentionList,
    required this.recentTransactions,
  });

  factory FinancesPageData.initial() {
    return FinancesPageData(
      totalRevenueYtd: 0.0,
      totalOutstanding: 0.0,
      openInvoicesCount: 0,
      attentionList: [],
      recentTransactions: [],
    );
  }
}

/// Represents a student in the "Attention Needed" section
class AttentionItem {
  final String studentId;
  final String name;
  final double amountOwed;
  final String overdueText; // e.g., "Overdue 30+ Days"
  final String status; // e.g., "Unpaid" or "Partial"

  AttentionItem({
    required this.studentId,
    required this.name,
    required this.amountOwed,
    required this.overdueText,
    required this.status,
  });
}

/// Represents an item in "Recent Payments"
class TransactionItem {
  final String title;
  final String subtitle;
  final double amount;
  final DateTime date;
  final bool isIncome;

  TransactionItem({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.date,
    this.isIncome = true,
  });
}

// -----------------------------------------------------------------------------
// PROVIDER LOGIC
// -----------------------------------------------------------------------------

final financesProvider = FutureProvider.autoDispose<FinancesPageData>((ref) async {
  final db = DatabaseService.instance;
  
  // 1. Fetch Hydrated Data
  // We utilize the existing hydration logic to get all students, bills, and payments.
  final students = await db.getAllStudentsWithFinancials(includeInactive: true);

  double revenueSum = 0.0;
  double outstandingSum = 0.0;
  int openInvoiceCount = 0;
  
  List<AttentionItem> attentionItems = [];
  List<TransactionItem> transactions = [];

  final now = DateTime.now();
  final currentYear = now.year;

  // 2. Aggregate Data
  for (final student in students) {
    // A. Revenue (YTD)
    // Filter payments made in the current year
    final ytdPayments = student.payments.where((p) {
      if (p.datePaid == null) return false;
      return p.datePaid!.year == currentYear;
    });
    
    for (final p in ytdPayments) {
      revenueSum += p.amount;
    }

    // B. Outstanding & Open Invoices
    outstandingSum += student.owed;
    
    // Count bills that are not closed (paid_amount < total_amount)
    final openBills = student.bills.where((b) => !b.isClosed).toList();
    openInvoiceCount += openBills.length;

    // C. Build Attention List (Logic: If they owe money, find oldest open bill)
    if (student.owed > 1.0) { // Threshold to ignore tiny floating point errors
      String timeText = "Overdue";
      
      // Find oldest open bill date
      DateTime? oldestDate;
      if (openBills.isNotEmpty) {
        // Sort bills by creation date
        openBills.sort((a, b) => (a.createdAt ?? now).compareTo(b.createdAt ?? now));
        oldestDate = openBills.first.createdAt;
      }

      if (oldestDate != null) {
        final days = now.difference(oldestDate).inDays;
        if (days > 30) {
          timeText = "Overdue 30+ Days";
        } else if (days > 7) {
          timeText = "Overdue 7+ Days";
        } else {
          timeText = "Due Recently";
        }
      }

      attentionItems.add(AttentionItem(
        studentId: student.student.id,
        name: student.student.fullName ?? 'Unknown',
        amountOwed: student.owed,
        overdueText: timeText,
        status: student.owed >= (openBills.fold(0.0, (p,b) => p + b.totalAmount)) 
            ? 'Unpaid' 
            : 'Partial',
      ));
    }

    // D. Collect Transactions for "Recent List"
    for (final p in student.payments) {
      transactions.add(TransactionItem(
        title: "Payment Received",
        subtitle: "${student.student.fullName} • ${DateFormat('MMM d').format(p.datePaid ?? now)}",
        amount: p.amount,
        date: p.datePaid ?? now,
      ));
    }
  }

  // 3. Finalize Lists

  // Sort Attention list by amount owed (descending)
  attentionItems.sort((a, b) => b.amountOwed.compareTo(a.amountOwed));
  // Limit to top 5 for the view
  if (attentionItems.length > 5) attentionItems = attentionItems.sublist(0, 5);

  // Sort Transactions by date (descending)
  transactions.sort((a, b) => b.date.compareTo(a.date));
  // Limit to top 10
  if (transactions.length > 10) transactions = transactions.sublist(0, 10);

  return FinancesPageData(
    totalRevenueYtd: revenueSum,
    totalOutstanding: outstandingSum,
    openInvoicesCount: openInvoiceCount,
    attentionList: attentionItems,
    recentTransactions: transactions,
  );
});