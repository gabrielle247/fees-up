import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

// Logic & Models
import '../view_models/dashboard_view_model.dart';
import '../models/student.dart';

// Utils
import '../utils/student_card.dart';
import '../utils/sized_box_normal.dart';

class EvaluationPage extends StatelessWidget {
  final int initialTabIndex; // 0 = Paid, 1 = Overdue

  const EvaluationPage({super.key, this.initialTabIndex = 0});

  @override
  Widget build(BuildContext context) {
    final currentMonth = DateFormat('MMMM yyyy').format(DateTime.now());
    final colorScheme = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: 2,
      initialIndex: initialTabIndex,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Column(
            children: [
              const Text("Monthly Evaluation", style: TextStyle(fontSize: 16)),
              Text(
                currentMonth,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurface.withAlpha(60),
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.pop(true), // Return 'true' to trigger refresh
          ),
          bottom: TabBar(
            indicatorColor: colorScheme.primary,
            labelColor: colorScheme.primary,
            unselectedLabelColor: Colors.grey,
            indicatorWeight: 3,
            tabs: const [
              Tab(text: "Fully Paid"),
              Tab(text: "Overdue / Unpaid"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            // Tab 1: Paid
            _StudentListSection(isPaidList: true),
            
            // Tab 2: Overdue
            _StudentListSection(isPaidList: false),
          ],
        ),
      ),
    );
  }
}

class _StudentListSection extends StatelessWidget {
  final bool isPaidList;

  const _StudentListSection({required this.isPaidList});

  @override
  Widget build(BuildContext context) {
    // We listen to the DashboardViewModel because it already calculated these lists
    final vm = context.watch<DashboardViewModel>();
    
    final List<Student> students = isPaidList 
        ? vm.paidStudentsCurrentMonth 
        : vm.unpaidStudentsCurrentMonth;

    final emptyMessage = isPaidList 
        ? "No payments received yet this month." 
        : "Outstanding job! No overdue students.";

    final emptyIcon = isPaidList 
        ? Icons.attach_money_outlined 
        : Icons.check_circle_outline_rounded;

    if (students.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(emptyIcon, size: 64, color: Colors.grey.withAlpha(30)),
            const SizedBoxNormal(16, 0),
            Text(
              emptyMessage,
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];
        
        // Determine status text/color based on the list type
        final statusText = isPaidList ? "Paid" : "Overdue";
        final statusKey = isPaidList ? "paid" : "overdue";

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: StudentCard(
            student.studentName,
            statusText,
            statusKey,
            () async {
               // 1. Navigate to Ledger
               await context.push(
                  '/studentLedger',
                  extra: {
                    'studentId': student.studentId,
                    'studentName': student.studentName,
                    'enrolledSubjects': student.subjects,
                  },
                );
                
                // 2. Refresh Data on Return (In case they paid while inside Ledger)
                if (context.mounted) {
                  vm.loadDashboard();
                }
            },
          ),
        );
      },
    );
  }
}