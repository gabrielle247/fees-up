import 'package:flutter/foundation.dart';
import '../services/local_storage_service.dart';
import '../models/finance.dart';

class LoggingPaymentsViewModel extends ChangeNotifier {
  final LocalStorageService _storage = LocalStorageService();

  String studentId = '';
  double amount = 0.0;
  String allocationType = 'automatic';

  List<Bill> _allBills = [];
  List<Bill> _unpaidBills = [];
  List<Bill> _ledgerItems = [];
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  List<Bill> get unpaidBills => _unpaidBills;
  List<Bill> get ledgerItems => _ledgerItems;

  double get totalOutstandingDebt {
    return _unpaidBills.fold(0.0, (sum, bill) => sum + bill.outstandingBalance);
  }

  double get remainingCreditAfterDebt {
    double remainder = amount - totalOutstandingDebt;
    return remainder > 0 ? remainder : 0.0;
  }

  void setStudentId(String id) {
    studentId = id;
    if (studentId.isNotEmpty) {
      loadData();
    }
  }

  void updateAmount(double value) {
    amount = value;
    notifyListeners();
  }

  Future<void> loadData() async {
    if (studentId.isEmpty) return;
    _isLoading = true;
    notifyListeners();

    try {
      await _storage.checkAndEnsureMonthlyBill(studentId);
      _allBills = await _storage.getBillsForStudent(studentId);
      _unpaidBills = _allBills
          .where((b) => b.status != BillStatus.paid)
          .toList();
      _ledgerItems = List.from(_allBills.reversed);
    } catch (e) {
      debugPrint("Error loading payment data: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> logPayment() async {
    if (amount <= 0 || studentId.isEmpty) return false;
    _isLoading = true;
    notifyListeners();

    // In LoggingPaymentsViewModel.dart -> logPayment()
    debugPrint(
      "🚀 logPayment() called. studentId: $studentId, amount: $amount",
    );

    try {
      await _storage.processLumpSumPayment(studentId, amount);
      amount = 0.0;
      await loadData();
      return true;
    } catch (e) {
      debugPrint("Error processing payment: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String getStatusLabel(Bill bill) {
    switch (bill.status) {
      case BillStatus.paid:
        return "Paid";
      case BillStatus.overdue:
        return "Overdue";
      case BillStatus.partial:
        return "Partial";
      case BillStatus.unpaid:
        return "Unpaid";
    }
  }
}
