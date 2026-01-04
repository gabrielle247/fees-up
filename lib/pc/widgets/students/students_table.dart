import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/providers/students_provider.dart';

class StudentsTable extends ConsumerStatefulWidget {
  final String schoolId;
  const StudentsTable({super.key, required this.schoolId});

  @override
  ConsumerState<StudentsTable> createState() => _StudentsTableState();
}

class _StudentsTableState extends ConsumerState<StudentsTable> {
  // We can add local filter state here later (e.g. selectedGrade)

  @override
  Widget build(BuildContext context) {
    final studentsAsync = ref.watch(studentsProvider(widget.schoolId));

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          // --- 1. Filter Bar ---
          _buildFilterBar(),
          const Divider(height: 1, color: AppColors.divider),

          // --- 2. Table Headers ---
          _buildTableHeader(),
          const Divider(height: 1, color: AppColors.divider),

          // --- 3. Real Data List (Provider-Powered) ---
          studentsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(40.0),
              child: Center(
                  child:
                      CircularProgressIndicator(color: AppColors.primaryBlue)),
            ),
            error: (error, stack) => Padding(
              padding: const EdgeInsets.all(40.0),
              child: Center(
                  child: Text("Error: $error",
                      style: const TextStyle(color: AppColors.errorRed))),
            ),
            data: (students) {
              if (students.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Center(
                      child: Text("No students found. Add one to get started.",
                          style: TextStyle(color: AppColors.textGrey))),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: students.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: AppColors.divider),
                itemBuilder: (context, index) {
                  final s = students[index];
                  return _buildStudentRow(s);
                },
              );
            },
          ),

          // --- 4. Pagination Footer ---
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildDropdown("All Grades"),
          const SizedBox(width: 12),
          _buildDropdown("All Classes"),
          const SizedBox(width: 12),
          _buildDropdown("Status: Active"),
          const SizedBox(width: 12),
          _buildDropdown("Financial: All"),
          const Spacer(),
          TextButton(
            onPressed: () {},
            child: const Text("Clear Filters",
                style: TextStyle(color: AppColors.primaryBlue, fontSize: 13)),
          )
        ],
      ),
    );
  }

  Widget _buildDropdown(String label) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundBlack,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Text(label,
              style: const TextStyle(color: AppColors.textWhite, fontSize: 13)),
          const SizedBox(width: 8),
          const Icon(Icons.keyboard_arrow_down,
              color: AppColors.textWhite54, size: 16),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          _col("STUDENT NAME", 3),
          _col("ID / GRADE", 2),
          _col("PARENT CONTACT", 3),
          _col("STATUS", 2),
          _col("OWED AMOUNT", 2, alignRight: true),
          _col("ACTIONS", 1, alignRight: true),
        ],
      ),
    );
  }

  Widget _col(String text, int flex, {bool alignRight = false}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: alignRight ? TextAlign.right : TextAlign.left,
        style: const TextStyle(
            color: AppColors.textWhite38,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8),
      ),
    );
  }

  Widget _buildStudentRow(Map<String, dynamic> s) {
    final name = s['full_name'] ?? 'Unknown';
    final id = s['student_id'] ?? '---';
    final grade = s['grade'] ?? 'N/A';
    final parentName = s['emergency_contact_name'] ?? 'No Contact';
    final contact = s['parent_contact'] ?? '';
    final isActive = (s['is_active'] as int?) == 1;
    final owed = (s['owed_total'] as num?)?.toDouble() ?? 0.0;

    // Initials for Avatar
    final initials = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : "?";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          // 1. Name & Avatar
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.2),
                  child: Text(initials,
                      style: const TextStyle(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            color: AppColors.textWhite,
                            fontWeight: FontWeight.w500,
                            fontSize: 13)),
                    Text("Class $grade",
                        style: const TextStyle(
                            color: AppColors.textWhite38, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),

          // 2. ID / Grade
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("#$id",
                    style: const TextStyle(
                        color: AppColors.textWhite, fontSize: 13)),
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                      color: AppColors.surfaceLightGrey,
                      borderRadius: BorderRadius.circular(4)),
                  child: Text("Grade $grade",
                      style: const TextStyle(
                          color: AppColors.textWhite70, fontSize: 10)),
                ),
              ],
            ),
          ),

          // 3. Parent Contact
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(parentName,
                    style: const TextStyle(
                        color: AppColors.textWhite, fontSize: 13)),
                Text(contact,
                    style: const TextStyle(
                        color: AppColors.textWhite38, fontSize: 11)),
              ],
            ),
          ),

          // 4. Status
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.successGreen.withValues(alpha: 0.15)
                        : AppColors.surfaceLightGrey,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isActive ? "Active" : "Inactive",
                    style: TextStyle(
                        color: isActive
                            ? AppColors.successGreen
                            : AppColors.textGrey,
                        fontSize: 11,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          // 5. Owed Amount
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(NumberFormat.simpleCurrency().format(owed),
                    style: const TextStyle(
                        color: AppColors.textWhite,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
                Text(
                  owed > 0 ? "Overdue" : "Paid",
                  style: TextStyle(
                      color: owed > 0
                          ? AppColors.errorRed
                          : AppColors.successGreen,
                      fontSize: 11),
                ),
              ],
            ),
          ),

          // 6. Actions
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                    icon: const Icon(Icons.edit,
                        size: 16, color: AppColors.textWhite54),
                    onPressed: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Text("Showing all results",
              style: TextStyle(color: AppColors.textWhite54, fontSize: 13)),
          const SizedBox(width: 24),
          _paginationBtn("Previous", false),
          const SizedBox(width: 8),
          _paginationBtn("Next", false), // Logic can be added later
        ],
      ),
    );
  }

  Widget _paginationBtn(String label, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: active ? AppColors.primaryBlue : AppColors.backgroundBlack,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.divider),
      ),
      child: Text(label,
          style: TextStyle(
              color: active ? Colors.white : AppColors.textWhite70,
              fontSize: 12)),
    );
  }
}
