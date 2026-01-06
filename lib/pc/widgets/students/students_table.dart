import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/safe_data.dart';
import '../../../../data/providers/students_provider.dart';
import 'edit_student_dialog.dart';
import 'quick_payment_dialog.dart';
import 'student_bills_dialog.dart';

class StudentsTable extends ConsumerStatefulWidget {
  final String schoolId;
  const StudentsTable({super.key, required this.schoolId});

  @override
  ConsumerState<StudentsTable> createState() => _StudentsTableState();
}

class _StudentsTableState extends ConsumerState<StudentsTable> {
  List<String> _grades = [];
  List<String> _classes = [];
  bool _classesAvailable = false;

  @override
  void initState() {
    super.initState();
    _loadGradesAndClasses();
  }

  Future<void> _loadGradesAndClasses() async {
    // Load ZIMSEC grades (fixed for Zimbabwe)
    setState(() {
      _grades = ['All Grades', ...zimsecGrades];
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredStudents =
        ref.watch(filteredStudentsProvider(widget.schoolId));

    // Watch classes to determine if filter should be enabled
    final classesAsync = ref.watch(classesProvider(widget.schoolId));

    // Update classes availability
    classesAsync.when(
      data: (classes) {
        _classes = ['All Classes', ...classes.map((c) => c['name'] as String)];
        _classesAvailable = classes.isNotEmpty;
      },
      loading: () {},
      error: (_, __) {},
    );

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
          Builder(
            builder: (context) {
              if (filteredStudents.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Center(
                      child: Text(
                          "No students found. Try adjusting your filters.",
                          style: TextStyle(color: AppColors.textGrey))),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredStudents.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: AppColors.divider),
                itemBuilder: (context, index) {
                  final s = filteredStudents[index];
                  return _buildStudentRow(s);
                },
              );
            },
          ),

          // --- 4. Pagination Footer ---
          _buildFooter(filteredStudents.length),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    final selectedGrade = ref.watch(studentGradeFilterProvider);
    final selectedClass = ref.watch(studentClassFilterProvider);
    final selectedStatus = ref.watch(studentStatusFilterProvider);
    final selectedFinancial = ref.watch(studentFinancialFilterProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Grade Filter - Always enabled
          _buildDropdownButton(
            label: selectedGrade ?? "All Grades",
            items: _grades,
            enabled: true,
            onSelected: (value) {
              ref.read(studentGradeFilterProvider.notifier).state = value;
            },
          ),
          const SizedBox(width: 12),
          // Class Filter - Disabled if no classes exist
          _buildDropdownButton(
            label: selectedClass ?? "All Classes",
            items: _classes.isEmpty ? ['All Classes'] : _classes,
            enabled: _classesAvailable,
            onSelected: _classesAvailable
                ? (value) {
                    ref.read(studentClassFilterProvider.notifier).state = value;
                  }
                : null,
          ),
          const SizedBox(width: 12),
          // Status Filter - Now includes Suspended and Banned Forever
          _buildDropdownButton(
            label: selectedStatus ?? "Status: All",
            items: studentStatusOptions,
            enabled: true,
            onSelected: (value) {
              ref.read(studentStatusFilterProvider.notifier).state = value;
            },
          ),
          const SizedBox(width: 12),
          // Financial Filter
          _buildDropdownButton(
            label: selectedFinancial ?? "Financial: All",
            items: const [
              "Financial: All",
              "Financial: Owed",
              "Financial: Paid"
            ],
            enabled: true,
            onSelected: (value) {
              ref.read(studentFinancialFilterProvider.notifier).state = value;
            },
          ),
          const Spacer(),
          TextButton(
            onPressed: () {
              ref.read(studentSearchProvider.notifier).state = '';
              ref.read(studentGradeFilterProvider.notifier).state = null;
              ref.read(studentClassFilterProvider.notifier).state = null;
              ref.read(studentStatusFilterProvider.notifier).state = null;
              ref.read(studentFinancialFilterProvider.notifier).state = null;
            },
            child: const Text("Clear Filters",
                style: TextStyle(color: AppColors.primaryBlue, fontSize: 13)),
          )
        ],
      ),
    );
  }

  Widget _buildDropdownButton(
      {required String label,
      required List<String> items,
      required bool enabled,
      required Function(String?)? onSelected}) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: PopupMenuButton<String>(
        enabled: enabled,
        onSelected: onSelected,
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.backgroundBlack,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
                color: enabled ? AppColors.divider : AppColors.textWhite38),
          ),
          child: Row(
            children: [
              Text(label,
                  style: TextStyle(
                      color:
                          enabled ? AppColors.textWhite : AppColors.textWhite54,
                      fontSize: 13)),
              const SizedBox(width: 8),
              Icon(Icons.keyboard_arrow_down,
                  color:
                      enabled ? AppColors.textWhite54 : AppColors.textWhite38,
                  size: 16),
            ],
          ),
        ),
        itemBuilder: (context) => items
            .map((item) => PopupMenuItem<String>(
                  value: item,
                  child: Text(item),
                ))
            .toList(),
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
    final isActive = SafeData.parseInt(s['is_active']) == 1;
    final isSuspended = SafeData.parseInt(s['is_suspended']) == 1;
    final owed = SafeData.parseDouble(s['owed_total'], 0.0);

    // Initials for Avatar
    final initials = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : "?";

    // Determine status display
    String statusLabel;
    Color statusColor;
    Color statusBackgroundColor;

    if (isSuspended) {
      statusLabel = "Banned Forever";
      statusColor = AppColors.errorRed;
      statusBackgroundColor = AppColors.errorRed.withValues(alpha: 0.15);
    } else if (!isActive) {
      statusLabel = "Inactive";
      statusColor = AppColors.textGrey;
      statusBackgroundColor = AppColors.surfaceLightGrey;
    } else {
      statusLabel = "Active";
      statusColor = AppColors.successGreen;
      statusBackgroundColor = AppColors.successGreen.withValues(alpha: 0.15);
    }

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
                    color: statusBackgroundColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                        color: statusColor,
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

          // 6. Actions - Quick Actions Popup Menu
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert,
                      size: 18, color: AppColors.textWhite54),
                  color: AppColors.surfaceGrey,
                  offset: const Offset(0, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: AppColors.divider),
                  ),
                  itemBuilder: (context) => [
                    const PopupMenuItem<String>(
                      value: 'view',
                      child: Row(
                        children: [
                          Icon(Icons.visibility_outlined,
                              size: 16, color: AppColors.primaryBlue),
                          SizedBox(width: 12),
                          Text('View Details',
                              style: TextStyle(color: AppColors.textWhite)),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'pay',
                      child: Row(
                        children: [
                          Icon(Icons.payment,
                              size: 16, color: AppColors.successGreen),
                          SizedBox(width: 12),
                          Text('Record Payment',
                              style: TextStyle(color: AppColors.textWhite)),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'sms',
                      child: Row(
                        children: [
                          Icon(Icons.message_outlined,
                              size: 16, color: AppColors.textWhite70),
                          SizedBox(width: 12),
                          Text('Send SMS',
                              style: TextStyle(color: AppColors.textWhite)),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined,
                              size: 16, color: AppColors.textWhite70),
                          SizedBox(width: 12),
                          Text('Edit Student',
                              style: TextStyle(color: AppColors.textWhite)),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem<String>(
                      value: 'bills',
                      child: Row(
                        children: [
                          Icon(Icons.receipt_long,
                              size: 16, color: AppColors.textWhite70),
                          SizedBox(width: 12),
                          Text('View Bills',
                              style: TextStyle(color: AppColors.textWhite)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    switch (value) {
                      case 'view':
                        // Set selected student to show details
                        ref.read(selectedStudentProvider.notifier).state = s;
                        break;
                      case 'pay':
                        // Open payment dialog
                        final owed = SafeData.parseDouble(s['owed_total'], 0.0);
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => QuickPaymentDialog(
                            schoolId: widget.schoolId,
                            studentId: s['id'] ?? '',
                            studentName: s['full_name'] ?? 'Student',
                            outstandingAmount: owed,
                          ),
                        );
                        break;
                      case 'sms':
                        // TODO: Open SMS dialog
                        // Implementation: Create SmsSendDialog widget
                        // 1. Display contact number from emergency_contact_phone
                        // 2. Allow composing message
                        // 3. Integrate with SMS provider (Twilio, AWS SNS, etc.)
                        // 4. Track sent messages in database
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('SMS feature coming soon')),
                          );
                        }
                        break;
                      case 'edit':
                        // Open edit student dialog
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => EditStudentDialog(
                            studentData: s,
                            schoolId: widget.schoolId,
                          ),
                        );
                        break;
                      case 'bills':
                        final studentId = s['student_id'] ?? s['id'] ?? '';
                        final studentName = s['full_name'] ?? 'Student';
                        showDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (_) => StudentBillsDialog(
                            studentId: studentId,
                            studentName: studentName,
                          ),
                        );
                        break;
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(int count) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text("Showing $count results",
              style:
                  const TextStyle(color: AppColors.textWhite54, fontSize: 13)),
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
