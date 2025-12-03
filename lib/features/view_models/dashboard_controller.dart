import 'dart:async';
import 'package:fees_up/features/payments/data/bill_repository.dart';
import 'package:fees_up/features/students/data/student_model.dart';
import 'package:fees_up/features/students/data/student_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
class DashboardState {
  final List<Student> students;
  final double totalCollectedThisMonth;
  final double totalOverdue;

  const DashboardState({
    this.students = const [],
    this.totalCollectedThisMonth = 0.0,
    this.totalOverdue = 0.0,
  });

  DashboardState copyWith({
    List<Student>? students,
    double? totalCollectedThisMonth,
    double? totalOverdue,
  }) {
    return DashboardState(
      students: students ?? this.students,
      totalCollectedThisMonth: totalCollectedThisMonth ?? this.totalCollectedThisMonth,
      totalOverdue: totalOverdue ?? this.totalOverdue,
    );
  }
}

final dashboardControllerProvider = AsyncNotifierProvider<DashboardController, DashboardState>(() {
  return DashboardController();
});

class DashboardController extends AsyncNotifier<DashboardState> {
  final StudentRepository _studentRepo = StudentRepository();
  final BillRepository _billRepo = BillRepository();

  @override
  FutureOr<DashboardState> build() async {
    return _fetchData();
  }

  Future<DashboardState> _fetchData() async {
    final students = await _studentRepo.getAllStudents();
    double overdue = 0.0;
    
    // Simple mock logic for now until Payment Repo is fully connected
    for (var student in students) {
      final unpaidBills = await _billRepo.getUnpaidBills(student.id);
      for (var bill in unpaidBills) {
        overdue += bill.outstandingBalance;
      }
    }

    return DashboardState(
      students: students,
      totalOverdue: overdue,
      totalCollectedThisMonth: 0.0, // Placeholder
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchData());
  }

  bool isStudentOverdue(String studentId) {
    // For now, we return false as default, BUT this is where you wire up the logic 
    // to check the specific student's bill status from the repo.
    // Ideally, the 'Student' model or a 'StudentDashboardView' model should hold this flag.
    return false; 
  }
}