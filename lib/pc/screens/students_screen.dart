import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/providers/dashboard_provider.dart';
import '../widgets/sidebar.dart';
import '../widgets/students/students_header.dart';
import '../widgets/students/students_stats.dart';
import '../widgets/students/students_table.dart';
import '../widgets/dashboard/student_dialog.dart'; // Reusing your existing dialog

class StudentsScreen extends ConsumerWidget {
  const StudentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardDataProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      body: Row(
        children: [
          // 1. Shared Sidebar
          const DashboardSidebar(),

          // 2. Main Content
          Expanded(
            child: Column(
              children: [
                // A. Standardized Header
                const StudentsHeader(),
                const Divider(height: 1, color: AppColors.divider),

                // B. Body
                Expanded(
                  child: dashboardAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue)),
                    error: (e, _) => Center(child: Text("Error: $e", style: const TextStyle(color: AppColors.errorRed))),
                    data: (data) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Page Title & Actions
                            _buildPageHeader(context, data.schoolId),
                            const SizedBox(height: 24),

                            // 2. Live KPI Cards (Passes schoolId to fetch stats)
                            StudentsStats(schoolId: data.schoolId),
                            const SizedBox(height: 32),

                            // 3. Main Data Table
                            StudentsTable(schoolId: data.schoolId),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageHeader(BuildContext context, String schoolId) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Student Directory",
              style: TextStyle(
                color: AppColors.textWhite,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              "Manage enrollment, contact details, and financial status.",
              style: TextStyle(color: AppColors.textWhite54, fontSize: 14),
            ),
          ],
        ),
        Row(
          children: [
            // Export Button
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.download, size: 16),
              label: const Text("Export List"),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textWhite,
                side: const BorderSide(color: AppColors.divider),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              ),
            ),
            const SizedBox(width: 16),
            
            // Add Student Button
            ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => StudentDialog(schoolId: schoolId),
                );
              },
              icon: const Icon(Icons.add, size: 16),
              label: const Text("Add New Student"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              ),
            ),
          ],
        ),
      ],
    );
  }
}