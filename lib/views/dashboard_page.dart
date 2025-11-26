// lib/views/dashboard_main_content.dart (Complete Code)

import 'package:fees_up/services/smart_sync_manager.dart'; 
import 'package:fees_up/view_models/notification_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for SystemNavigator.pop
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:fees_up/utils/responsive.dart'; 
import 'package:fees_up/view_models/desktop_dashboard_view_model.dart';
import 'package:fees_up/utils/empty_list_widget.dart';
import 'package:fees_up/utils/student_card.dart';
import 'package:fees_up/view_models/dashboard_view_model.dart';
import 'package:fees_up/utils/evaluation_card.dart';
import 'package:fees_up/utils/edit_student_dialog.dart';
import 'package:fees_up/models/student.dart'; 
import 'package:fees_up/utils/app_drawer.dart'; // Ensure this is imported

class DashboardMainContent extends StatefulWidget {
  const DashboardMainContent({super.key});

  @override
  State<DashboardMainContent> createState() => _DashboardMainContentState();
}

class _DashboardMainContentState extends State<DashboardMainContent> {
  
  // Helper to open student ledger dynamically on desktop or mobile
  void _openStudentLedger(Student student, BuildContext context) async {
    final bool isDesktop = Responsive.isDesktop(context);
    final desktopVM = isDesktop ? context.read<DesktopDashboardViewModel>() : null;
    
    if (isDesktop) {
      desktopVM?.openStudentLedger(
        studentId: student.studentId,
        studentName: student.studentName,
        subjects: student.subjects,
      );
    } else {
      await context.push(
        '/studentLedger',
        extra: {
          'studentId': student.studentId,
          'studentName': student.studentName,
          'enrolledSubjects': student.subjects,
        },
      );
      if (context.mounted) {
        Provider.of<DashboardViewModel>(context, listen: false).loadDashboard();
      }
    }
  }
  
  // Helper to trigger the Edit Dialog (Works the same on mobile/desktop)
  Future<void> _showEditDialog(Student student) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => EditStudentDialog(student: student),
    );

    if (result == true && context.mounted) {
      Provider.of<DashboardViewModel>(
        context,
        listen: false,
      ).loadDashboard();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Student profile updated"),
        ),
      );
    }
  }
  
  // 🛑 NEW: EXIT CONFIRMATION DIALOG 🛑
  Future<bool> _showExitConfirmationDialog(BuildContext context) async {
    final bool? exitConfirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Exit'),
          content: const Text('Are you sure you want to exit the Fees Up application?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Do not exit
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // Confirm exit
              child: const Text('Exit'),
              style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            ),
          ],
        );
      },
    );
    
    // If exit is confirmed, pop the entire Android activity stack
    if (exitConfirmed == true) {
      // NOTE: SystemNavigator.pop() is necessary to fully exit the app on Android/iOS
      // context.pop() or Navigator.of(context).pop() only pop the Flutter route stack.
      SystemNavigator.pop(animated: true);
    }
    
    // Always return false to prevent automatic popping of the current route
    // The explicit SystemNavigator.pop handles the actual exit.
    return false; 
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<DashboardViewModel>(context);
    final students = vm.students;
    final colorScheme = Theme.of(context).colorScheme;
    final bool isDesktop = Responsive.isDesktop(context);
    
    const double kLayoutPadding = 16.0;
    
    if (vm.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(vm.errorMessage!)));
      });
    }

    // 🛑 WRAPPER: Use PopScope for back button control
    return PopScope(
      canPop: false, // Prevents automatic pop
      onPopInvoked: (didPop) async {
        if (didPop) return;
        
        // Only show confirmation on mobile, desktop is handled by the overall window manager
        if (!isDesktop) {
          await _showExitConfirmationDialog(context);
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        drawer: isDesktop ? null : const AppDrawer(), // Only on mobile/narrow view

        floatingActionButton: isDesktop
            ? null
            : FloatingActionButton(
                onPressed: () async {
                  await context.push("/addStudent");
                  if (context.mounted) {
                    Provider.of<DashboardViewModel>(context, listen: false).loadDashboard();
                  }
                },
                child: const Icon(Icons.add_rounded, size: 28),
              ),

        body: RefreshIndicator(
          onRefresh: () async {
            await SmartSyncManager().forceSync();
            if (context.mounted) {
              await vm.loadDashboard();
            }
          },
          child: CustomScrollView(
            slivers: [
              // 1. APP BAR
              SliverAppBar(
                floating: true,
                pinned: false,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                elevation: 0,
                leading: isDesktop
                    ? null
                    : Builder(
                        builder: (context) => IconButton(
                          icon: const Icon(Icons.menu),
                          onPressed: () => Scaffold.of(context).openDrawer(),
                        ),
                      ),
                title: const Text("Dashboard"),
                centerTitle: true,
                actions: [
                  Consumer<NotificationViewModel>(
                    builder: (context, notifVM, child) {
                      return IconButton(
                        onPressed: () async {
                          await context.push('/notifications'); 
                          if (context.mounted) {
                            Provider.of<DashboardViewModel>(context, listen: false).loadDashboard();
                            notifVM.loadNotifications();
                          }
                        },
                        icon: Badge(
                          isLabelVisible: notifVM.hasNotifications,
                          label: Text('${notifVM.unreadCount}'),
                          backgroundColor: Colors.redAccent,
                          textColor: Colors.white,
                          smallSize: 10,
                          child: Icon(
                            notifVM.hasNotifications
                                ? Icons.notifications_active_rounded
                                : Icons.notifications_none_rounded,
                            color: notifVM.hasNotifications
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey,
                            size: 28,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: kLayoutPadding),
                ],
              ),

              // 2. HEADER CONTENT (Evaluation Cards + Search)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(kLayoutPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 🧠 VISUAL INDICATOR
                      if (vm.isSyncing) ...[
                        LinearProgressIndicator(
                          minHeight: 2,
                          backgroundColor: colorScheme.surface,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(height: 12),
                      ],

                      _buildEvaluationCards(vm, context, kLayoutPadding),

                      const SizedBox(height: kLayoutPadding),

                      // SEARCH BAR
                      GestureDetector(
                        onTap: () async {
                          await context.push('/search');
                          if (mounted) {
                            Provider.of<DashboardViewModel>(context, listen: false).loadDashboard();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(
                              color: colorScheme.tertiary.withAlpha(76),
                            ),
                            color: colorScheme.surface,
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.search, color: Colors.blueGrey.shade300),
                              const SizedBox(width: 10),
                              const Text(
                                "Search student name...",
                                style: TextStyle(color: Colors.blueGrey),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 3. STUDENT LIST (Or Empty State)
              if (vm.isLoading && !vm.isSyncing)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (students.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.all(kLayoutPadding),
                    child: EmptyListWidget(
                      isDesktop
                          ? () => context.read<DesktopDashboardViewModel>().openRegisterStudent()
                          : () => context.push("/addStudent"),
                      "No students yet",
                      "Tap the '+' button or the register button to enroll your first\nstudent",
                      Icons.people_alt_outlined,
                      "+ Register student",
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: kLayoutPadding),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final student = students[index];
                      final isOverdue = vm.isStudentOverdue(student.studentId);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: kLayoutPadding),
                        child: StudentCard(
                          student.studentName,
                          isOverdue ? "Overdue" : "Paid",
                          isOverdue ? "overdue" : "paid",
                          () => _openStudentLedger(student, context),
                          onLongPress: () => _showEditDialog(student),
                        ),
                      );
                    }, childCount: students.length),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEvaluationCards(
    DashboardViewModel vm,
    BuildContext context,
    double spacing,
  ) {
    const title1 = "Current Month Payments";
    const title2 = "Overdue Payments";
    
    void openEvaluation(int tabIndex) async {
      await context.push('/evaluation', extra: tabIndex);
      if (mounted) vm.loadDashboard();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: () => openEvaluation(0),
          child: EvaluationCard(
            title1,
            vm.totalCollectedFormatted,
            Theme.of(context).colorScheme.secondary,
          ),
        ),
        SizedBox(height: spacing),
        GestureDetector(
          onTap: () => openEvaluation(1),
          child: EvaluationCard(
            title2,
            vm.totalOverdueFormatted,
            Theme.of(context).colorScheme.error,
          ),
        ),
      ],
    );
  }
}
