// lib/view_models/dashboard_view_model.dart (STABLE REPLACEMENT)

import 'package:fees_up/services/smart_sync_manager.dart';
import 'package:flutter/foundation.dart';
import '../services/local_storage_service.dart';
import '../models/student.dart';
import '../models/finance.dart'; 
import '../utils/dashboard_calculator.dart'; 

class DashboardViewModel extends ChangeNotifier {
  // Use SmartSyncManager for non-UI controlled syncs (Debounce/Throttle)
  final SmartSyncManager _smartSync = SmartSyncManager();
  final LocalStorageService _storage = LocalStorageService();

  // --- STATE ---
  List<Student> _students = [];
  bool _isLoading = false;
  bool _isSyncing = false; 
  String? _errorMessage;

  // --- DERIVED METRICS STATE ---
  double _totalCollectedThisMonth = 0.0;
  double _totalOverdueAllTime = 0.0;
  int _newBillsGeneratedCount = 0;
  final List<Student> _paidStudentsCurrentMonth = [];
  final List<Student> _unpaidStudentsCurrentMonth = [];
  final Map<String, BillStatus> _studentFinancialStatus = {};

  // --- GETTERS ---
  List<Student> get students => _students;
  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;
  String? get errorMessage => _errorMessage;
  int get newBillsGeneratedCount => _newBillsGeneratedCount;

  String get totalCollectedFormatted => "\$${_totalCollectedThisMonth.toStringAsFixed(2)}";
  String get totalOverdueFormatted => "\$${_totalOverdueAllTime.toStringAsFixed(2)}";
  int get totalStudents => _students.length;

  List<Student> get paidStudentsCurrentMonth => _paidStudentsCurrentMonth;
  List<Student> get unpaidStudentsCurrentMonth => _unpaidStudentsCurrentMonth;

  bool isStudentOverdue(String studentId) {
    return _studentFinancialStatus[studentId] == BillStatus.overdue;
  }

  // --- MAIN LOAD (STABLE LOGIC) ---
  Future<void> loadDashboard() async {
    _setLoading(true);
    _clearError();

    try {
      // 1. CRITICAL: Run background automation logic once.
      bool changesMade = await _storage.ensureBillsForAllStudents();
      _newBillsGeneratedCount = changesMade ? 1 : 0;

      // 2. STABILITY FIX: Trigger sync engine, which internally checks freshness/throttle.
      _smartSync.triggerDataChange(); // Call trigger, do not await.
      
      // 3. CORE ACTION: Load and calculate metrics from the local DB.
      await _fetchAndCalculateLocalData();

    } catch (e) {
      _setError("Failed to load dashboard: $e");
      debugPrint("Error loading dashboard: $e");
    } finally {
      _setLoading(false);
    }
  }

  // --- HELPER: Fetch & Calculate (No change, clean utility) ---
  Future<void> _fetchAndCalculateLocalData() async {
    final students = await _storage.getAllStudents();
    final allBills = await _storage.getAllBills();
    final allPayments = await _storage.getAllPayments();

    final metrics = calculateDashboardMetrics(
      students: students,
      allBills: allBills,
      allPayments: allPayments,
    );
    
    _students = metrics.sortedStudents;
    _totalCollectedThisMonth = metrics.totalCollectedThisMonth;
    _totalOverdueAllTime = metrics.totalOverdueAllTime;
    
    _paidStudentsCurrentMonth
      ..clear()
      ..addAll(metrics.paidStudentsCurrentMonth);
      
    _unpaidStudentsCurrentMonth
      ..clear()
      ..addAll(metrics.unpaidStudentsCurrentMonth);
      
    _studentFinancialStatus
      ..clear()
      ..addAll(metrics.studentFinancialStatus);

    notifyListeners();
  }

  // 🛑 NEW: MANUAL REFRESH (The safe version of force sync)
  Future<void> refreshData() async {
    _isSyncing = true;
    notifyListeners();

    try {
      await _smartSync.forceSync(); 
      await _fetchAndCalculateLocalData();
      
    } catch (e) {
      debugPrint("Manual refresh failed: $e");
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  // 🛑 REMOVED: _checkAndRunDailySync() logic is now centralized in SmartSyncManager.

  // --- WIPE DATA ---
  Future<void> wipeAllData() async {
    _setLoading(true);
    try {
      await _storage.wipeAllData();
      await loadDashboard(); 
    } catch (e) {
      _setError("Failed to wipe app data: $e");
      _setLoading(false);
    }
  }
  // --- STATE MUTATORS ---
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}