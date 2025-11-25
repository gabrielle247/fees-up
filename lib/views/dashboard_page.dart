import 'package:fees_up/services/smart_sync_manager.dart'; // 👈 Import the Brain
import 'package:fees_up/utils/app_drawer.dart';
import 'package:fees_up/view_models/notification_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:fees_up/utils/empty_list_widget.dart';
import 'package:fees_up/utils/student_card.dart';
import 'package:fees_up/view_models/dashboard_view_model.dart';
import 'package:fees_up/utils/evaluation_card.dart';
import 'package:fees_up/utils/edit_student_dialog.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final dashboardVM = Provider.of<DashboardViewModel>(
        context,
        listen: false,
      );
      final notifyVM = Provider.of<NotificationViewModel>(
        context,
        listen: false,
      );

      // 1. Load Local Data Immediately (Fast UI)
      await dashboardVM.loadDashboard();
      
      // 2. 🧠 Smart Sync: Check for server updates in background
      // We don't await this so the UI stays responsive
      SmartSyncManager().forceSync().then((_) {
        if (mounted) dashboardVM.loadDashboard(); // Refresh UI if sync brought new data
      });

      if (!mounted) return;

      if (dashboardVM.newBillsGeneratedCount > 0) {
        notifyVM.refresh();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "${dashboardVM.newBillsGeneratedCount} new monthly bills generated.",
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<DashboardViewModel>(context);
    final students = vm.students;
    final colorScheme = Theme.of(context).colorScheme;
    
    // --- LOCAL CONSTANT FOR UNIFORMITY ---
    const double kLayoutPadding = 16.0; 

    if (vm.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(vm.errorMessage!)));
      });
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: const AppDrawer(),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.push("/addStudent");
          if (context.mounted) {
            // Reload local SQL data to show the new student immediately
            Provider.of<DashboardViewModel>(
              context,
              listen: false,
            ).loadDashboard(); 
            // Note: The AddStudent screen should have called SmartSyncManager().triggerDataChange()
          }
        },
        child: const Icon(Icons.add_rounded, size: 28),
      ),

      body: RefreshIndicator(
        // 🧠 SMART REFRESH LOGIC
        onRefresh: () async {
          // 1. Force the engine to Push/Pull/Upsert
          await SmartSyncManager().forceSync();
          // 2. Reload the UI from the updated SQLite database
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
              leading: Builder(
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
                          Provider.of<DashboardViewModel>(
                            context,
                            listen: false,
                          ).loadDashboard();
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
                    // Shows only if DashboardVM knows sync is happening 
                    // (You might need to wire SmartSyncManager state to VM later for perfect sync, 
                    // but standard loading indicators work for now)
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
                          Provider.of<DashboardViewModel>(
                            context,
                            listen: false,
                          ).loadDashboard();
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
                    () => context.push("/addStudent"),
                    "No students yet",
                    "Tap the '+' button to register your first\nstudent",
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
                        () async {
                          await context.push(
                            '/studentLedger',
                            extra: {
                              'studentId': student.studentId,
                              'studentName': student.studentName,
                              'enrolledSubjects': student.subjects,
                            },
                          );
                          if (context.mounted) {
                            Provider.of<DashboardViewModel>(
                              context,
                              listen: false,
                            ).loadDashboard();
                          }
                        },
                        onLongPress: () async {
                          final result = await showDialog<bool>(
                            context: context,
                            builder: (_) => EditStudentDialog(student: student),
                          );

                          if (result == true && context.mounted) {
                            // Reload UI to show changes
                            Provider.of<DashboardViewModel>(
                              context,
                              listen: false,
                            ).loadDashboard(); 
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Student profile updated"),
                              ),
                            );
                            // Note: EditStudentDialog should trigger SmartSyncManager().triggerDataChange()
                          }
                        },
                      ),
                    );
                  }, childCount: students.length),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }

  Widget _buildEvaluationCards(DashboardViewModel vm, BuildContext context, double spacing) {
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