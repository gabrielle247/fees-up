import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/all_models.dart';
import '../constants/app_strings.dart';

/// ============================================================================
/// OPERATION PLACEBO: THE SIMULATION ENGINE
/// ============================================================================
/// This ViewModel acts as the "Brain" for the UI prototyping phase.
/// It mocks the behavior of PowerSync, Supabase, and Repositories.
/// 
/// FEATURES:
/// 1. Generates consistent, relational mock data (School -> Students -> Finance).
/// 2. Simulates network latency for realistic UI loading states.
/// 3. Performs dynamic calculations (Total Revenue = Sum of Payments).
/// 4. Allows "Write" operations (Add Student, Pay) that update the UI state.
/// ============================================================================

class PlaceboViewModel extends ChangeNotifier {
  // ===========================================================================
  // 1. STATE VARIABLES
  // ===========================================================================
  
  bool _isLoading = false;
  String? _error;
  
  // -- Identity --
  School? _currentSchool;
  AcademicYear? _activeYear;
  Term? _currentTerm;
  
  // -- Registers --
  List<Student> _students = [];
  List<FeeStructure> _feeStructures = [];
  final List<Invoice> _invoices = [];
  List<Payment> _payments = [];
  List<LedgerEntry> _recentActivity = [];

  // -- Dashboard Stats (Calculated) --
  double _totalCollected = 0.0;
  double _totalOutstanding = 0.0;
  int _activeStudentCount = 0;

  // ===========================================================================
  // 2. GETTERS
  // ===========================================================================
  
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  School? get currentSchool => _currentSchool;
  AcademicYear? get activeYear => _activeYear;
  Term? get currentTerm => _currentTerm;
  
  List<Student> get students => _students;
  List<FeeStructure> get feeStructures => _feeStructures;
  List<Invoice> get invoices => _invoices;
  List<Payment> get payments => _payments;
  List<LedgerEntry> get recentActivity => _recentActivity;
  
  // Computed Stats
  double get totalCollected => _totalCollected;
  double get totalOutstanding => _totalOutstanding;
  int get activeStudentCount => _activeStudentCount;
  String get financialHealthScore {
    if (_totalOutstanding == 0) return "100%";
    final ratio = _totalCollected / (_totalCollected + _totalOutstanding);
    return "${(ratio * 100).toStringAsFixed(1)}%";
  }

  // ===========================================================================
  // 3. INITIALIZATION & DATA GENERATION
  // ===========================================================================

  PlaceboViewModel() {
    _initSimulation();
  }

  Future<void> _initSimulation() async {
    _setLoading(true);
    
    try {
      // Simulate "Booting" delay
      await Future.delayed(const Duration(milliseconds: 1200));

      _generateSchoolContext();
      _generateStudents(25); // Generate 25 students
      _generateFinanceData(); // Generate Invoices/Payments for them
      _recalculateTotals();

      debugPrint('${AppStrings.successPrefix} Placebo Simulation Initialized');
    } catch (e, stack) {
      debugPrint('${AppStrings.error}: $e\n$stack');
      _error = "Failed to start simulation: $e";
    } finally {
      _setLoading(false);
    }
  }

  // ===========================================================================
  // 4. INTERACTIVE ACTIONS (THE CONTROLLER)
  // ===========================================================================

  /// Simulates adding a new student
  Future<void> addNewStudent(Student student) async {
    _setLoading(true);
    await Future.delayed(const Duration(milliseconds: 800)); // Fake Network
    
    try {
      _students.insert(0, student); // Add to top
      _activeStudentCount++;
      _recalculateTotals();
      debugPrint("Added Student: ${student.firstName}");
    } catch (e) {
      _error = "Could not save student";
    } finally {
      _setLoading(false);
    }
  }

  /// Simulates recording a payment
  Future<void> recordPayment({
    required String studentId, 
    required double amount, 
    required String method
  }) async {
    _setLoading(true);
    await Future.delayed(const Duration(milliseconds: 600));

    try {
      final studentIndex = _students.indexWhere((s) => s.id == studentId);
      if (studentIndex == -1) throw Exception("Student not found");

      // 1. Create Payment Record
      final payment = Payment(
        id: "pay_${_randomId()}",
        schoolId: _currentSchool!.id,
        studentId: studentId,
        amount: amount,
        method: method,
        referenceCode: "REC-${Random().nextInt(99999)}",
        receivedAt: DateTime.now().toIso8601String(),
        createdAt: DateTime.now().toIso8601String(),
      );

      // 2. Update Local State
      _payments.insert(0, payment);
      
      // 3. Update Student Balance (Mocking the trigger)
      final s = _students[studentIndex];
      final updatedStudent = Student(
        id: s.id,
        schoolId: s.schoolId,
        firstName: s.firstName,
        lastName: s.lastName,
        status: s.status,
        enrollmentDate: s.enrollmentDate,
        studentType: s.studentType,
        admissionDate: s.admissionDate,
        isArchived: s.isArchived,
        createdAt: s.createdAt,
        updatedAt: DateTime.now(),
        feesOwed: s.feesOwed - amount, // Reduce debt
        admissionNumber: s.admissionNumber,
        guardianName: s.guardianName,
        guardianPhone: s.guardianPhone,
      );
      _students[studentIndex] = updatedStudent;

      // 4. Add to Activity Log
      _recentActivity.insert(0, LedgerEntry(
        id: "led_${_randomId()}",
        schoolId: _currentSchool!.id,
        studentId: studentId,
        type: AppStrings.creditType,
        category: "TUITION_PAYMENT",
        amount: amount,
        currency: "USD",
        referenceCode: payment.referenceCode,
        description: "Payment received via $method",
        occurredAt: DateTime.now().toIso8601String(),
        createdAt: DateTime.now().toIso8601String(),
      ));

      _recalculateTotals();
      
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// Refreshes the dashboard (Pull to refresh)
  Future<void> refreshDashboard() async {
    await _initSimulation(); // Re-roll the dice
  }

  // ===========================================================================
  // 5. INTERNAL HELPERS & MOCK GENERATORS
  // ===========================================================================

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _recalculateTotals() {
    _totalCollected = _payments.fold(0.0, (sum, item) => sum + item.amount);
    _totalOutstanding = _students.fold(0.0, (sum, item) => sum + item.feesOwed);
    _activeStudentCount = _students.where((s) => s.status == 'ACTIVE').length;
    notifyListeners();
  }

  void _generateSchoolContext() {
    _currentSchool = School(
      id: "sch_001",
      name: "Harare High School",
      subdomain: "hararehigh",
      subscriptionStatus: "active",
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
      ownerId: "usr_admin",
      city: "Harare",
      country: "Zimbabwe",
    );

    _activeYear = AcademicYear(
      id: "ay_2026",
      schoolId: "sch_001",
      name: "2026 Academic Year",
      startDate: DateTime(2026, 1, 1),
      endDate: DateTime(2026, 12, 10),
      isActive: true,
      isLocked: false,
      createdAt: DateTime.now(),
    );

    _currentTerm = Term(
      id: "term_1_2026",
      schoolId: "sch_001",
      academicYearId: "ay_2026",
      name: "Term 1",
      startDate: DateTime(2026, 1, 10),
      endDate: DateTime(2026, 3, 28),
      dueDate: DateTime(2026, 1, 10),
      isCurrent: true,
      createdAt: DateTime.now(),
    );
  }

  void _generateStudents(int count) {
    final firstNames = ["Nyasha", "Tinashe", "Farai", "Kudza", "Rudo", "Simba", "Chipo", "Tendai", "Gabriel", "Michelle"];
    final lastNames = ["Moyo", "Sibanda", "Chikore", "Mutasa", "Ndlovu", "Gara", "Marufu", "Phiri", "Banda"];
    
    _students = List.generate(count, (index) {
      final isBoarder = Random().nextBool();
      return Student(
        id: "stu_$index",
        schoolId: "sch_001",
        firstName: firstNames[Random().nextInt(firstNames.length)],
        lastName: lastNames[Random().nextInt(lastNames.length)],
        status: index % 5 == 0 ? "OWING" : "ACTIVE", // Every 5th student owes money
        enrollmentDate: DateTime(2025, 1, 15),
        admissionNumber: "2025-${1000 + index}",
        guardianName: "Parent of Student $index",
        guardianPhone: "+263 77 ${Random().nextInt(999)} ${Random().nextInt(9999)}",
        studentType: isBoarder ? "BOARDER" : "DAY_SCHOLAR",
        admissionDate: DateTime(2025, 1, 10),
        isArchived: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        feesOwed: (Random().nextInt(5) * 100).toDouble(), // $0 to $500 owed
      );
    });
  }

  void _generateFinanceData() {
    _feeStructures = [
      FeeStructure(
        id: "fee_tuition",
        schoolId: "sch_001",
        academicYearId: "ay_2026",
        categoryId: "cat_tuition",
        name: "Term 1 Tuition",
        amount: 450.00,
        currency: "USD",
        createdAt: DateTime.now().toIso8601String(),
        billingType: "TERM",
        recurrence: "once",
        billableMonths: "",
        suspensions: "",
      ),
      FeeStructure(
        id: "fee_levy",
        schoolId: "sch_001",
        academicYearId: "ay_2026",
        categoryId: "cat_levy",
        name: "Building Levy",
        amount: 50.00,
        currency: "USD",
        createdAt: DateTime.now().toIso8601String(),
        billingType: "FIXED",
        recurrence: "once",
        billableMonths: "",
        suspensions: "",
      ),
    ];

    // Generate simulated payment history
    _payments = [];
    _recentActivity = [];
    
    // Create random payments for students with low balance
    for (var student in _students) {
      if (student.feesOwed < 200) {
         const amount = 450.00;
         _payments.add(Payment(
           id: "pay_${_randomId()}",
           schoolId: "sch_001",
           studentId: student.id,
           amount: amount,
           method: Random().nextBool() ? "CASH" : "ECOCASH",
           receivedAt: DateTime.now().subtract(Duration(days: Random().nextInt(30))).toIso8601String(),
           createdAt: DateTime.now().toIso8601String(),
           referenceCode: "REC-${Random().nextInt(10000)}"
         ));
         
         // Add matching ledger entry
         _recentActivity.add(LedgerEntry(
           id: "led_${_randomId()}",
           schoolId: "sch_001",
           studentId: student.id,
           type: "CREDIT",
           category: "PAYMENT",
           amount: amount,
           currency: "USD",
           description: "Term 1 Payment",
           occurredAt: DateTime.now().subtract(Duration(days: Random().nextInt(30))).toIso8601String(),
           createdAt: DateTime.now().toIso8601String(),
         ));
      }
    }
    
    // Sort activity by date (newest first)
    _recentActivity.sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
  }

  String _randomId() {
    return Random().nextInt(100000).toString();
  }
}

// ==========================================
// MOCK EXTENSIONS FOR MISSING MODEL FIELDS
// ==========================================
// Since your School model didn't have currency in the previous file, 
// I am extending it here strictly for the Placebo to avoid errors, 
// or you can add `final String currency;` to your school_models.dart.
extension SchoolPlacebo on School {
  // Mocking getter if field doesn't exist yet
  String get currency => "USD";
}