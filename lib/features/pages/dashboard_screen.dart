import 'package:fees_up/features/view_models/dashboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

// --- CUSTOM WIDGETS ---
import 'package:fees_up/shared/widgets/student_card.dart';
import 'package:fees_up/shared/widgets/evaluation_card.dart';
import 'package:fees_up/shared/widgets/empty_list_widget.dart';
import 'package:fees_up/shared/widgets/app_drawer.dart'; // ✅ Imported AppDrawer


class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(dashboardControllerProvider);
    final controller = ref.read(dashboardControllerProvider.notifier); // Access methods
    final colorScheme = Theme.of(context).colorScheme;
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    const double kLayoutPadding = 16.0;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        SystemNavigator.pop();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        drawer: const AppDrawer(), // ✅ Enabled the AppDrawer
        
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.push("/students/add"),
          child: const Icon(Icons.add_rounded, size: 28),
        ),

        body: RefreshIndicator(
          onRefresh: () async => controller.refresh(),
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
                    onPressed: () {
                      Scaffold.of(context).openDrawer(); // ✅ Enabled opening the drawer
                    },
                  ),
                ),
                title: const Text("Dashboard"),
                centerTitle: true,
                actions: [
                  IconButton(
                    onPressed: () => context.push('/notifications'),
                    icon: const Icon(Icons.notifications_none_rounded, size: 28),
                  ),
                  const SizedBox(width: kLayoutPadding),
                ],
              ),

              // 2. HEADER CONTENT
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(kLayoutPadding),
                  child: asyncState.when(
                    loading: () => const SizedBox(height: 150, child: Center(child: CircularProgressIndicator())),
                    error: (err, _) => Text("Error loading metrics: $err"),
                    data: (state) => Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        EvaluationCard(
                          "Current Month Payments",
                          currencyFormat.format(state.totalCollectedThisMonth),
                          colorScheme.secondary,
                        ),
                        const SizedBox(height: kLayoutPadding),
                        EvaluationCard(
                          "Overdue Payments",
                          currencyFormat.format(state.totalOverdue),
                          colorScheme.error,
                        ),
                        const SizedBox(height: kLayoutPadding),
                        _buildSearchBar(colorScheme),
                      ],
                    ),
                  ),
                ),
              ),

              // 3. STUDENT LIST
              asyncState.when(
                loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
                error: (err, _) => const SliverToBoxAdapter(child: SizedBox.shrink()),
                data: (state) {
                  if (state.students.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Padding(
                        padding: const EdgeInsets.all(kLayoutPadding),
                        child: EmptyListWidget(
                          () => context.push("/students/add"),
                          "No students yet",
                          "Tap the '+' button to register your first\nstudent",
                          Icons.people_alt_outlined,
                          "+ Register student",
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: kLayoutPadding),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final student = state.students[index];
                        // Ask Controller for status, don't calculate here
                        final isOverdue = controller.isStudentOverdue(student.id); 

                        return Padding(
                          padding: const EdgeInsets.only(bottom: kLayoutPadding),
                          child: StudentCard(
                            student.fullName,
                            isOverdue ? "Overdue" : "Paid",
                            isOverdue ? "overdue" : "paid",
                            () {
                              // Navigate to Ledger with arguments
                              context.push('/students/ledger', extra: student);
                            },
                            onLongPress: () {
                              // Show Edit Dialog
                              // showDialog(...)
                            },
                          ),
                        );
                      }, childCount: state.students.length),
                    ),
                  );
                },
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(ColorScheme colorScheme) {
    // Note: colorScheme.tertiary.withValues(alpha: 0.3) fixed to standard opacity
    return GestureDetector(
      onTap: () => context.push('/search'),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: colorScheme.tertiary.withAlpha(100)),
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
    );
  }
}