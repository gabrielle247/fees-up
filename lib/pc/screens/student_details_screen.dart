import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/safe_data.dart';
import '../../../../data/providers/dashboard_provider.dart';
import '../../../../data/providers/students_provider.dart';
import '../../../../data/viewmodels/student_details_viewmodel.dart';
import '../widgets/sidebar.dart';
import '../widgets/students/students_header.dart';
import '../widgets/students/edit_student_dialog.dart';
import '../widgets/students/financial_ledger_dialog.dart';

class StudentDetailsScreen extends ConsumerWidget {
  final String studentId;

  const StudentDetailsScreen({super.key, required this.studentId});

  void _showComingSoon(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label coming soon'),
        backgroundColor: AppColors.primaryBlue,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get dashboard data to retrieve schoolId
    final dashboardAsync = ref.watch(dashboardDataProvider);

    // Watch real-time student data from database via ViewModel
    final studentDataAsync = ref.watch(studentDetailProvider(studentId));

    // Access business logic
    final logic = ref.watch(studentDetailsLogicProvider);

    return dashboardAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.backgroundBlack,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryBlue),
        ),
      ),
      error: (err, _) => Scaffold(
        backgroundColor: AppColors.backgroundBlack,
        body: Center(
          child: Text('Error loading dashboard: $err',
              style: const TextStyle(color: AppColors.errorRed)),
        ),
      ),
      data: (dashboard) {
        final schoolId = dashboard.schoolId;

        return studentDataAsync.when(
          loading: () => const Scaffold(
            backgroundColor: AppColors.backgroundBlack,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primaryBlue),
            ),
          ),
          error: (err, _) => Scaffold(
            backgroundColor: AppColors.backgroundBlack,
            body: Center(
              child: Text('Error loading student: $err',
                  style: const TextStyle(color: AppColors.errorRed)),
            ),
          ),
          data: (studentData) {
            if (studentData.isEmpty) {
              return const Scaffold(
                backgroundColor: AppColors.backgroundBlack,
                body: Center(
                  child: Text('Student not found',
                      style: TextStyle(color: AppColors.textGrey)),
                ),
              );
            }

            // Extract base student data from real-time stream
            final name = studentData['full_name'] ?? 'Unknown';
            final id = studentData['student_id'] ?? '---';
            final grade = studentData['grade'] ?? 'N/A';
            final parentName =
                studentData['emergency_contact_name'] ?? 'No Contact';
            final parentContact = studentData['parent_contact'] ?? 'No contact';
            final address = studentData['address'] ?? 'Not provided';
            final dob = studentData['date_of_birth'] ?? 'Not provided';
            final gender = studentData['gender'] ?? 'Not specified';
            final enrollmentDate =
                studentData['enrollment_date'] ?? 'Not provided';
            final medicalNotes = studentData['medical_notes'] ?? 'None';
            final billingType = studentData['billing_type'] ?? 'Standard';
            final defaultFee =
                SafeData.parseDouble(studentData['default_fee'], 0.0);
            final billingDate = studentData['billing_date'] ?? 'Not provided';
            final subjects = (studentData['subjects'] as String? ?? '')
                .split(',')
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty)
                .toList();
            final termId = studentData['term_id'] ?? 'Not set';
            final photoConsent = SafeData.parseInt(
                  studentData['photo_consent'],
                ) ==
                1;
            final adminUid = studentData['admin_uid'] ?? '---';
            final createdAt = studentData['created_at'];
            final updatedAt = studentData['updated_at'];
            final lastSynced = studentData['last_synced_at'];

            // Use ViewModel logic for formatting and calculations
            final initials = logic.getInitials(name);
            final statusLabel = logic.getStatusLabel(studentData);
            final statusColor = logic.getStatusColor(studentData);
            final age = logic.calculateAge(dob);

            // Watch real-time related data from database via ViewModel
            final enrollmentsAsync = ref.watch(studentEnrollmentsProvider(id));
            final attendanceAsync = ref.watch(studentAttendanceProvider(id));
            final billsAsync = ref.watch(studentBillsProvider(id));
            final paymentsAsync = ref.watch(studentPaymentsProvider(id));

            return _buildDetailsContent(
              context,
              ref,
              logic,
              name,
              id,
              grade,
              age,
              dob,
              initials,
              parentName,
              parentContact,
              address,
              gender,
              enrollmentDate,
              medicalNotes,
              termId,
              billingType,
              defaultFee,
              billingDate,
              subjects,
              photoConsent,
              statusLabel,
              statusColor,
              enrollmentsAsync,
              attendanceAsync,
              billsAsync,
              paymentsAsync,
              schoolId,
              studentData,
              adminUid,
              createdAt,
              updatedAt,
              lastSynced,
            );
          },
        );
      },
    );
  }

  Widget _buildDetailsContent(
    BuildContext context,
    WidgetRef ref,
    StudentDetailsLogic logic,
    String name,
    String id,
    String grade,
    String age,
    String dob,
    String initials,
    String parentName,
    String parentContact,
    String address,
    String gender,
    String enrollmentDate,
    String medicalNotes,
    String termId,
    String billingType,
    double defaultFee,
    String billingDate,
    List<String> subjects,
    bool photoConsent,
    String statusLabel,
    Color statusColor,
    AsyncValue<List<Map<String, dynamic>>> enrollmentsAsync,
    AsyncValue<List<Map<String, dynamic>>> attendanceAsync,
    AsyncValue<List<Map<String, dynamic>>> billsAsync,
    AsyncValue<List<Map<String, dynamic>>> paymentsAsync,
    String schoolId,
    Map<String, dynamic> studentData,
    String adminUid,
    String? createdAt,
    String? updatedAt,
    String? lastSynced,
  ) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      body: Row(
        children: [
          // 1. Shared Sidebar (same as students_screen.dart)
          const DashboardSidebar(),

          // 2. Main Content
          Expanded(
            child: Column(
              children: [
                // A. Standardized Header with back button
                const StudentsHeader(),
                const Divider(height: 1, color: AppColors.divider),

                // B. Breadcrumb Navigation Bar
                Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: const BoxDecoration(
                    color: AppColors.backgroundBlack,
                    border:
                        Border(bottom: BorderSide(color: AppColors.divider)),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          // Clear selected student to go back to list
                          ref.read(selectedStudentProvider.notifier).state =
                              null;
                        },
                        icon: const Icon(Icons.arrow_back,
                            color: AppColors.textWhite70),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () {
                          ref.read(selectedStudentProvider.notifier).state =
                              null;
                        },
                        child: const Text(
                          "Students",
                          style: TextStyle(
                              color: AppColors.textWhite54, fontSize: 14),
                        ),
                      ),
                      const Icon(Icons.chevron_right,
                          color: AppColors.textWhite38, size: 16),
                      const SizedBox(width: 4),
                      const Text(
                        "Student Details",
                        style: TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),

                // C. Body Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Student Header Card
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceGrey,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: Row(
                            children: [
                              // Avatar with online status
                              Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 50,
                                    backgroundColor: AppColors.primaryBlue
                                        .withValues(alpha: 0.2),
                                    child: Text(
                                      initials,
                                      style: const TextStyle(
                                        color: AppColors.primaryBlue,
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 4,
                                    right: 4,
                                    child: Container(
                                      width: 16,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        color: AppColors.successGreen,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: AppColors.surfaceGrey,
                                            width: 2),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 24),
                              // Student Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: const TextStyle(
                                        color: AppColors.textWhite,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        _badge(
                                          icon: Icons.badge_outlined,
                                          text: id,
                                        ),
                                        _badge(
                                          icon: Icons.school_outlined,
                                          text: schoolId,
                                        ),
                                        _badge(
                                          text: "Grade $grade",
                                          color: AppColors.primaryBlue
                                              .withValues(alpha: 0.15),
                                          textColor: AppColors.primaryBlue,
                                        ),
                                        _badge(
                                          icon: Icons.cake_outlined,
                                          text: dob != 'Not provided'
                                              ? "$dob ($age)"
                                              : age,
                                          color: AppColors.surfaceLightGrey,
                                          textColor: AppColors.textWhite70,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Action Buttons
                              Row(
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: () =>
                                        _showComingSoon(context, 'Messaging'),
                                    icon: const Icon(Icons.email_outlined,
                                        size: 16),
                                    label: const Text("Message"),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.textWhite,
                                      side: const BorderSide(
                                          color: AppColors.divider),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  OutlinedButton.icon(
                                    onPressed: () => _showComingSoon(
                                        context, 'Printable report'),
                                    icon: const Icon(Icons.print_outlined,
                                        size: 16),
                                    label: const Text("Print Report"),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.textWhite,
                                      side: const BorderSide(
                                          color: AppColors.divider),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (_) => EditStudentDialog(
                                          studentData: studentData,
                                          schoolId: schoolId,
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.edit, size: 16),
                                    label: const Text("Edit Profile"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryBlue,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Three Column Layout with uniform height
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Column 1: Personal Info
                              Expanded(
                                child: ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(minHeight: 420),
                                  child: _buildPersonalInfoCard(
                                    gender: gender,
                                    address: address,
                                    parentName: parentName,
                                    parentContact: parentContact,
                                    medicalNotes: medicalNotes,
                                    photoConsent: photoConsent,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 24),

                              // Column 2: Academic Data (Real from DB)
                              Expanded(
                                child: ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(minHeight: 420),
                                  child: _buildAcademicDataCard(
                                    logic: logic,
                                    enrollmentsAsync: enrollmentsAsync,
                                    attendanceAsync: attendanceAsync,
                                    grade: grade,
                                    enrollmentDate: enrollmentDate,
                                    termId: termId,
                                    subjects: subjects,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 24),

                              // Column 3: Financial Status (Real from DB)
                              Expanded(
                                child: ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(minHeight: 420),
                                  child: _buildFinancialDataCard(
                                    context: context,
                                    logic: logic,
                                    studentId: id,
                                    studentName: name,
                                    studentRid:
                                        studentData['student_rid'] ?? '',
                                    billsAsync: billsAsync,
                                    paymentsAsync: paymentsAsync,
                                    statusLabel: statusLabel,
                                    statusColor: statusColor,
                                    billingType: billingType,
                                    defaultFee: defaultFee,
                                    billingDate: billingDate,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        _buildMetadataSection(
                          logic: logic,
                          adminUid: adminUid,
                          createdAt: createdAt,
                          updatedAt: updatedAt,
                          lastSynced: lastSynced,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoCard({
    required String gender,
    required String address,
    required String parentName,
    required String parentContact,
    required String medicalNotes,
    required bool photoConsent,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.person_outline,
                  color: AppColors.primaryBlue, size: 20),
              SizedBox(width: 8),
              Text(
                "Personal Info",
                style: TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoSection("GENDER", gender),
          const SizedBox(height: 16),
          _buildInfoSection("HOME ADDRESS", address),
          const SizedBox(height: 16),
          _buildInfoSection("EMERGENCY CONTACT", "$parentName\n$parentContact",
              icon: Icons.phone_outlined),
          const SizedBox(height: 16),
          _buildMedicalSection(medicalNotes, photoConsent),
        ],
      ),
    );
  }

  Widget _buildAcademicDataCard({
    required StudentDetailsLogic logic,
    required AsyncValue<List<Map<String, dynamic>>> enrollmentsAsync,
    required AsyncValue<List<Map<String, dynamic>>> attendanceAsync,
    required String grade,
    required String enrollmentDate,
    required String termId,
    required List<String> subjects,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.school_outlined,
                  color: AppColors.primaryBlue, size: 20),
              SizedBox(width: 8),
              Text(
                "Academic Data",
                style: TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Term & Enrollment
          Row(
            children: [
              Expanded(
                child: _boxedInfo(
                  title: 'CURRENT TERM',
                  value: termId,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _boxedInfo(
                  title: 'ENROLLED ON',
                  value: logic.formatDate(enrollmentDate),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Attendance
          attendanceAsync.when(
            data: (attendance) {
              final present =
                  attendance.where((a) => a['status'] == 'present').length;
              final absent =
                  attendance.where((a) => a['status'] == 'absent').length;
              final total = present + absent;
              final percent = total > 0
                  ? ((present / total) * 100).toStringAsFixed(0)
                  : '0';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Attendance",
                    style: TextStyle(
                      color: AppColors.textWhite38,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: total > 0 ? (present / total) : 0,
                            backgroundColor: AppColors.surfaceLightGrey,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.successGreen),
                            minHeight: 8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "$percent%",
                        style: const TextStyle(
                          color: AppColors.successGreen,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        "$present Days Present",
                        style: const TextStyle(
                            color: AppColors.textWhite70, fontSize: 11),
                      ),
                      const Spacer(),
                      Text(
                        "$absent Days Absent",
                        style: const TextStyle(
                            color: AppColors.textWhite54, fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(8.0),
              child: SizedBox(
                height: 20,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(AppColors.primaryBlue),
                  strokeWidth: 2,
                ),
              ),
            ),
            error: (err, _) => const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Error loading attendance",
                style: TextStyle(color: AppColors.errorRed, fontSize: 11),
              ),
            ),
          ),

          // Subjects
          const Text(
            "ENROLLED SUBJECTS",
            style: TextStyle(
              color: AppColors.textWhite38,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          if (subjects.isEmpty)
            const Text(
              "No subjects provided",
              style: TextStyle(color: AppColors.textWhite54, fontSize: 12),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: subjects
                  .map(
                    (subject) => Chip(
                      label: Text(
                        subject,
                        style: const TextStyle(
                          color: AppColors.textWhite,
                          fontSize: 11,
                        ),
                      ),
                      backgroundColor: AppColors.backgroundBlack,
                      side: const BorderSide(color: AppColors.divider),
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  )
                  .toList(),
            ),
          const SizedBox(height: 24),

          // Enrolled Classes
          const Text(
            "ENROLLED CLASSES",
            style: TextStyle(
              color: AppColors.textWhite38,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          enrollmentsAsync.when(
            data: (enrollments) {
              if (enrollments.isEmpty) {
                return const Text(
                  "No classes enrolled",
                  style: TextStyle(color: AppColors.textWhite54, fontSize: 12),
                );
              }
              return Column(
                children: enrollments
                    .map(
                      (enrollment) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: _buildClassItem(
                          enrollment['class_name'] ?? 'Unknown Class',
                          enrollment['teacher_name'] ?? 'Unassigned',
                          grade,
                          AppColors.primaryBlue,
                        ),
                      ),
                    )
                    .toList(),
              );
            },
            loading: () => const SizedBox(
              height: 20,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(AppColors.primaryBlue),
                strokeWidth: 2,
              ),
            ),
            error: (err, _) => Text(
              "Error loading classes: $err",
              style: const TextStyle(color: AppColors.errorRed, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialDataCard({
    required BuildContext context,
    required StudentDetailsLogic logic,
    required String studentId,
    required String studentName,
    required String studentRid,
    required AsyncValue<List<Map<String, dynamic>>> billsAsync,
    required AsyncValue<List<Map<String, dynamic>>> paymentsAsync,
    required String statusLabel,
    required Color statusColor,
    required String billingType,
    required double defaultFee,
    required String billingDate,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance_wallet_outlined,
                  color: AppColors.primaryBlue, size: 20),
              const SizedBox(width: 8),
              const Text(
                "Financial Data",
                style: TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => FinancialLedgerDialog(
                      studentId: studentId,
                      studentName: studentName,
                      studentRid: studentRid,
                      billsAsync: billsAsync,
                      paymentsAsync: paymentsAsync,
                    ),
                  );
                },
                child: const Text(
                  "View Ledger",
                  style: TextStyle(color: AppColors.primaryBlue, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Real financial summary from database
          billsAsync.when(
            data: (bills) {
              final totalOwed = bills
                  .where((b) => SafeData.parseInt(b['is_paid']) == 0)
                  .fold<double>(
                      0.0,
                      (sum, b) =>
                          sum + SafeData.parseDouble(b['total_amount'], 0.0));

              final totalPaid = bills
                  .where((b) => SafeData.parseInt(b['is_paid']) == 1)
                  .fold<double>(
                      0.0,
                      (sum, b) =>
                          sum + SafeData.parseDouble(b['total_amount'], 0.0));

              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "OUTSTANDING",
                              style: TextStyle(
                                color: AppColors.textWhite38,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              NumberFormat.simpleCurrency().format(totalOwed),
                              style: const TextStyle(
                                color: AppColors.errorRed,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              totalOwed > 0 ? "Due Now" : "Paid",
                              style: TextStyle(
                                color: totalOwed > 0
                                    ? AppColors.errorRed
                                    : AppColors.successGreen,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "TOTAL PAID",
                              style: TextStyle(
                                color: AppColors.textWhite38,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              NumberFormat.simpleCurrency().format(totalPaid),
                              style: const TextStyle(
                                color: AppColors.successGreen,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              "YTD",
                              style: TextStyle(
                                color: AppColors.textWhite54,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Billing configuration
                  _rowItem(label: 'Billing Type', value: billingType),
                  const SizedBox(height: 12),
                  _rowItem(
                      label: 'Default Fee', value: logic.formatCurrency(defaultFee)),
                  const SizedBox(height: 12),
                  _rowItem(label: 'Billing Date', value: billingDate),
                  const SizedBox(height: 24),

                  // Recent Bills
                  const Text(
                    "RECENT BILLS",
                    style: TextStyle(
                      color: AppColors.textWhite38,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (bills.isEmpty)
                    const Text(
                      "No bills found",
                      style:
                          TextStyle(color: AppColors.textWhite54, fontSize: 12),
                    )
                  else
                    Column(
                      children: bills.take(3).map((bill) {
                        final isPaid = SafeData.parseInt(bill['is_paid']) == 1;
                        final amount =
                            SafeData.parseDouble(bill['total_amount'], 0.0);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      bill['title'] ?? 'Bill',
                                      style: const TextStyle(
                                        color: AppColors.textWhite,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      bill['created_at'] ?? 'N/A',
                                      style: const TextStyle(
                                        color: AppColors.textWhite54,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                NumberFormat.simpleCurrency().format(amount),
                                style: TextStyle(
                                  color: isPaid
                                      ? AppColors.successGreen
                                      : AppColors.errorRed,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                isPaid
                                    ? Icons.check_circle
                                    : Icons.pending_actions,
                                size: 16,
                                color: isPaid
                                    ? AppColors.successGreen
                                    : AppColors.warningOrange,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                ],
              );
            },
            loading: () => const SizedBox(
              height: 40,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(AppColors.primaryBlue),
                strokeWidth: 2,
              ),
            ),
            error: (err, _) => const Text(
              "Error loading financial data",
              style: TextStyle(color: AppColors.errorRed, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataSection({
    required StudentDetailsLogic logic,
    required String adminUid,
    required String? createdAt,
    required String? updatedAt,
    required String? lastSynced,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.settings, size: 16, color: AppColors.textWhite54),
              SizedBox(width: 8),
              Text(
                "System Metadata",
                style: TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _metaRow(
              label: 'Admin UID',
              value: adminUid.isNotEmpty ? adminUid : '---'),
          _metaRow(label: 'Registered', value: logic.formatDate(createdAt)),
          _metaRow(label: 'Last Synced', value: logic.formatDate(lastSynced)),
          _metaRow(label: 'Updated', value: logic.formatDate(updatedAt)),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String label, String value, {IconData? icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textWhite38,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: AppColors.textWhite54),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMedicalSection(String medicalNotes, bool photoConsent) {
    final hasPeanutAllergy = medicalNotes.toLowerCase().contains('peanut') ||
        medicalNotes.toLowerCase().contains('allergy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "MEDICAL & LEGAL",
          style: TextStyle(
            color: AppColors.textWhite38,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        if (hasPeanutAllergy)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.errorRed.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
              border:
                  Border.all(color: AppColors.errorRed.withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: AppColors.errorRed, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Peanut Allergy",
                        style: TextStyle(
                          color: AppColors.errorRed,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Requires EpiPen on site.",
                        style: TextStyle(
                          color: AppColors.errorRed,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: (photoConsent ? AppColors.successGreen : AppColors.divider)
                .withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color:
                  (photoConsent ? AppColors.successGreen : AppColors.textGrey)
                      .withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                photoConsent ? Icons.check_circle : Icons.cancel,
                color:
                    photoConsent ? AppColors.successGreen : AppColors.textGrey,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  photoConsent
                      ? "Photo Consent Granted"
                      : "Photo Consent Not Granted",
                  style: TextStyle(
                    color: photoConsent
                        ? AppColors.successGreen
                        : AppColors.textGrey,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClassItem(
      String className, String teacher, String grade, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundBlack,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(Icons.menu_book, size: 16, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  className,
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  teacher,
                  style: const TextStyle(
                    color: AppColors.textWhite54,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceLightGrey,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              grade,
              style: const TextStyle(
                color: AppColors.textWhite,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _boxedInfo({required String title, required String value}) =>
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.backgroundBlack,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textWhite38,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: AppColors.textWhite,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );

  Widget _metaRow({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.textWhite54, fontSize: 11),
          ),
          Text(
            value,
            style: const TextStyle(color: AppColors.textWhite70, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _rowItem({required String label, required String value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textWhite54, fontSize: 12),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textWhite,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _badge({
    IconData? icon,
    required String text,
    Color color = AppColors.backgroundBlack,
    Color textColor = AppColors.textGrey,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: textColor.withValues(alpha: 0.9)),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
