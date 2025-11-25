// lib/utils/dashboard_calculator.dart

import 'package:intl/intl.dart';

import '../models/student.dart';
import '../models/finance.dart'; 

// 1. Define a Result Class for structured return values
class DashboardMetrics {
  final List<Student> sortedStudents;
  final double totalCollectedThisMonth;
  final double totalOverdueAllTime;
  final List<Student> paidStudentsCurrentMonth;
  final List<Student> unpaidStudentsCurrentMonth;
  final Map<String, BillStatus> studentFinancialStatus;

  DashboardMetrics({
    required this.sortedStudents,
    required this.totalCollectedThisMonth,
    required this.totalOverdueAllTime,
    required this.paidStudentsCurrentMonth,
    required this.unpaidStudentsCurrentMonth,
    required this.studentFinancialStatus,
  });
}


// 2. The Pure Calculation Function
DashboardMetrics calculateDashboardMetrics({
  required List<Student> students,
  required List<Bill> allBills,
  required List<Payment> allPayments,
}) {
  // --- Setup ---
  final now = DateTime.now();
  final currentMonthKey = DateFormat('yyyy-MM').format(now);
  final endOfCurrentMonth = DateTime(now.year, now.month + 1, 0);

  double monthlyCashFlow = 0.0;
  double totalDebt = 0.0;

  final paidStudents = <Student>[];
  final unpaidStudents = <Student>[];
  final studentStatusMap = <String, BillStatus>{};

  // --- Step A: Prepare Data ---
  
  // Sort students once for display
  students.sort((a, b) => a.studentName.compareTo(b.studentName));
  final activeStudents = students.where((s) => s.isActive).toList();
  
  // Map Bills for fast lookup
  final Map<String, Bill> currentMonthBills = {};
  for (var bill in allBills) {
    if (bill.uniqueMonthKey == currentMonthKey) {
      currentMonthBills[bill.studentId] = bill;
    }
    // Initialize all active students as Paid status for simplicity, to be overwritten by overdue bills below
    if (studentStatusMap[bill.studentId] == null) {
      studentStatusMap[bill.studentId] = BillStatus.paid;
    }
  }

  // --- Step B: Categorize Students (Current Month Status) ---
  for (var student in activeStudents) {
    final bill = currentMonthBills[student.studentId];

    if (bill != null && bill.status == BillStatus.paid) {
      paidStudents.add(student);
    } else {
      unpaidStudents.add(student);
    }
  }

  // --- Step C: Calculate Cash Flow (Payments) ---
  for (final pay in allPayments) {
    final payMonthKey = DateFormat('yyyy-MM').format(pay.datePaid);
    if (payMonthKey == currentMonthKey) {
      monthlyCashFlow += pay.amount;
    }
  }

  // --- Step D: Calculate Debt (Overdue/Outstanding Status) ---
  for (final bill in allBills) {
    // Only consider bills up to the end of the current month (i.e., ignore pre-paid future bills)
    if (bill.monthYear.isAfter(endOfCurrentMonth)) {
      continue; 
    }

    if (bill.status != BillStatus.paid) {
      totalDebt += bill.outstandingBalance;
      // Mark student as overdue if they have ANY unpaid debt
      studentStatusMap[bill.studentId] = BillStatus.overdue;
    }
  }

  // --- Step E: Return Results ---
  return DashboardMetrics(
    sortedStudents: students,
    totalCollectedThisMonth: monthlyCashFlow,
    totalOverdueAllTime: totalDebt,
    paidStudentsCurrentMonth: paidStudents,
    unpaidStudentsCurrentMonth: unpaidStudents,
    studentFinancialStatus: studentStatusMap,
  );
}