import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

// View Models & Widgets
import '../view_models/student_ledger_view_model.dart';
import '../utils/data_table_util.dart'; // Ensure this accepts List<MonthlySummaryEntry>
import '../utils/profile_card.dart';
import '../utils/sized_box_normal.dart';

class StudentLedgerPage extends StatelessWidget {
  final String studentId;
  final String studentName;
  final List<String> enrolledSubjects;

  const StudentLedgerPage({
    super.key,
    required this.studentId,
    required this.studentName,
    required this.enrolledSubjects,
  });

  @override
  Widget build(BuildContext context) {
    // 1. PROVIDER INJECTION
    // We create the VM here and immediately load the data.
    return ChangeNotifierProvider(
      create: (_) => StudentLedgerViewModel(studentId)..loadTransactions(),
      child: _StudentLedgerContent(
        studentName: studentName,
        studentId: studentId,
        enrolledSubjects: enrolledSubjects,
      ),
    );
  }
}

class _StudentLedgerContent extends StatelessWidget {
  final String studentName;
  final String studentId;
  final List<String> enrolledSubjects;

  const _StudentLedgerContent({
    required this.studentName,
    required this.studentId,
    required this.enrolledSubjects,
  });

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<StudentLedgerViewModel>();
    final colorScheme = Theme.of(context).colorScheme;

    // Style Definitions
    var primaryBackground = BoxDecoration(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(8.0),
      border: Border.all(
        color: colorScheme.tertiary.withAlpha(20), // Safe alternative to withValues
        width: 1.0,
      ),
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(true),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text("Student Summary"),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: IconButton(
              onPressed: () {
                // TODO: Implement PDF Export or Share logic
              },
              icon: const Icon(Icons.share_outlined),
            ),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ---------------------------------------------------------
            // 1. PROFILE SECTION
            // ---------------------------------------------------------
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: primaryBackground,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const ProfileCard(32.0),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              studentName,
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontSize: 20.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              "Student ID: $studentId",
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Subject Chips
                  if (enrolledSubjects.isNotEmpty)
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: enrolledSubjects.map((subject) {
                        return Chip(
                          label: Text(
                            subject,
                            style: TextStyle(
                              fontSize: 11,
                              color: colorScheme.onPrimary,
                            ),
                          ),
                          backgroundColor: colorScheme.primary,
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),

            const SizedBoxNormal(16, 0),

            // ---------------------------------------------------------
            // 2. FINANCIAL SUMMARY CARD
            // ---------------------------------------------------------
            Container(
              decoration: primaryBackground,
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 20.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Outstanding Balance:",
                    style: TextStyle(color: Colors.white70, fontSize: 16.0),
                  ),
                  Text(
                    vm.totalOutstandingFormatted, // ✅ UPDATED GETTER
                    style: TextStyle(
                      color: colorScheme.error,
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBoxNormal(16, 0),

            // ---------------------------------------------------------
            // 3. TRANSACTIONS TABLE
            // ---------------------------------------------------------
            Expanded(
              child: Container(
                decoration: primaryBackground,
                child: vm.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : vm.monthlySummaries.isEmpty
                        ? const Center(
                            child: Text("No billing history found.",
                                style: TextStyle(color: Colors.grey)))
                        : SingleChildScrollView(
                            // Assumes DataTableUtil is updated to handle List<MonthlySummaryEntry>
                            child: DataTableUtil(entries: vm.monthlySummaries),
                          ),
              ),
            ),

            const SizedBoxNormal(16, 0),

            // ---------------------------------------------------------
            // 4. ACTION BUTTONS
            // ---------------------------------------------------------
            Row(
              children: [
                // Add Charge Button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Manual Charges coming soon."),
                      ));
                    },
                    icon: Icon(
                      Icons.add_circle_outline,
                      color: colorScheme.primary,
                    ),
                    label: Text(
                      "Add Charge",
                      style: TextStyle(color: colorScheme.primary),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary.withAlpha(10),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Log Payment Button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      // 1. Navigate to Payment Page
                      await context.push(
                        "/loggingPayments",
                        extra: studentId,
                      );

                      // 2. Refresh Ledger when they return
                      // We check mounted to ensure the widget still exists
                      if (context.mounted) {
                        vm.loadTransactions();
                      }
                    },
                    icon: Icon(
                      Icons.receipt_long,
                      color: colorScheme.onPrimary,
                    ),
                    label: Text(
                      "Log Payment",
                      style: TextStyle(color: colorScheme.onPrimary),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
