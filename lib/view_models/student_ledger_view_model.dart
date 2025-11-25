import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/local_storage_service.dart';
import '../models/finance.dart'; 

class MonthlySummaryEntry {
  final String billId;
  final String description;
  final DateTime date;
  final double totalBilled;
  final double totalPaid;
  final double balance;
  final String statusLabel;
  final Color statusColor;

  MonthlySummaryEntry({
    required this.billId,
    required this.description,
    required this.date,
    required this.totalBilled,
    required this.totalPaid,
    required this.balance,
    required this.statusLabel,
    required this.statusColor,
  });
}

class StudentLedgerViewModel extends ChangeNotifier {
  final String studentId;
  final LocalStorageService _storage = LocalStorageService();

  StudentLedgerViewModel(this.studentId);

  List<MonthlySummaryEntry> _monthlySummaries = [];
  double _totalBilled = 0.0; // Now used
  double _totalPaid = 0.0;
  bool _isLoading = false;

  // --- GETTERS ---
  List<MonthlySummaryEntry> get monthlySummaries => _monthlySummaries;
  bool get isLoading => _isLoading;

  // 1. New Getter: Shows Total Lifetime Invoiced Amount
  String get totalBilledFormatted => "\$${_totalBilled.toStringAsFixed(2)}";

  // 2. Shows Total Lifetime Paid
  String get totalPaidFormatted => "\$${_totalPaid.toStringAsFixed(2)}";
  
  // 3. FIX: Uses _totalBilled for efficient calculation
  String get totalOutstandingFormatted {
    double debt = _totalBilled - _totalPaid;
    // Prevent negative zero display (optional polish)
    if (debt.abs() < 0.01) debt = 0.0; 
    return "\$${debt.toStringAsFixed(2)}";
  }

  // --- DATA LOADING ---
  Future<void> loadTransactions() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Ensure current month exists
      await _storage.checkAndEnsureMonthlyBill(studentId);

      // 2. Fetch Bills
      final bills = await _storage.getBillsForStudent(studentId);

      // 3. Calculate Global Totals
      _totalBilled = bills.fold(0.0, (sum, bill) => sum + bill.totalAmount);
      _totalPaid = bills.fold(0.0, (sum, bill) => sum + bill.paidAmount);

      // 4. Map to UI Model
      _monthlySummaries = bills.map((bill) {
        return MonthlySummaryEntry(
          billId: bill.id,
          date: bill.monthYear,
          description: DateFormat('MMMM yyyy').format(bill.monthYear),
          totalBilled: bill.totalAmount,
          totalPaid: bill.paidAmount,
          balance: bill.outstandingBalance,
          statusLabel: _getStatusText(bill),
          statusColor: _getStatusColor(bill.status),
        );
      }).toList();

      // 5. Sort Newest First
      _monthlySummaries = _monthlySummaries.reversed.toList();

    } catch (e) {
      debugPrint("Error loading ledger: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- HELPERS ---
  String _getStatusText(Bill bill) {
    switch (bill.status) {
      case BillStatus.paid:
        return "Paid";
      case BillStatus.overdue:
        return "Overdue (\$${bill.outstandingBalance.toStringAsFixed(2)})";
      case BillStatus.partial:
        return "Partial (Owes \$${bill.outstandingBalance.toStringAsFixed(2)})";
      case BillStatus.unpaid:
        return "Unpaid";
    }
  }

  Color _getStatusColor(BillStatus status) {
    switch (status) {
      case BillStatus.paid:
        return Colors.greenAccent;
      case BillStatus.overdue:
        return Colors.redAccent;
      case BillStatus.partial:
        return Colors.orangeAccent;
      case BillStatus.unpaid:
        return Colors.grey;
    }
  }
}
