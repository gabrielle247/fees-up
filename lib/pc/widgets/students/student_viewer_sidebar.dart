import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/providers/students_provider.dart';
import '../../../../data/viewmodels/student_details_viewmodel.dart';

class StudentViewerSidebar extends ConsumerWidget {
  const StudentViewerSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedStudent = ref.watch(selectedStudentProvider);
    final logic = ref.watch(studentDetailsLogicProvider);

    // If no student is selected, show empty state
    if (selectedStudent == null) {
      return Container(
        width: 350,
        color: AppColors.backgroundBlack,
        decoration: const BoxDecoration(
          border: Border(left: BorderSide(color: AppColors.divider)),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.divider)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person_outline,
                      color: AppColors.primaryBlue, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    "Student Details",
                    style: TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close,
                        color: AppColors.textWhite54, size: 20),
                    onPressed: () {
                      ref.read(selectedStudentProvider.notifier).state = null;
                    },
                  ),
                ],
              ),
            ),
            // Empty State
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_search,
                        size: 64, color: AppColors.textWhite38),
                    SizedBox(height: 16),
                    Text(
                      "Select a student to view details",
                      style: TextStyle(
                        color: AppColors.textWhite54,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Student is selected, show details
    final name = selectedStudent['full_name'] ?? 'Unknown';
    final id = selectedStudent['student_id'] ?? '---';
    final grade = selectedStudent['grade'] ?? 'N/A';
    final parentName =
        selectedStudent['emergency_contact_name'] ?? 'No Contact';
    final parentContact = selectedStudent['parent_contact'] ?? 'No contact';
    final address = selectedStudent['address'] ?? 'Not provided';
    final dob = selectedStudent['date_of_birth'] ?? 'Not provided';
    final gender = selectedStudent['gender'] ?? 'Not specified';
    final enrollmentDate = selectedStudent['enrollment_date'] ?? 'Not provided';
    final medicalNotes = selectedStudent['medical_notes'] ?? 'None';
    final subjects = selectedStudent['subjects'] ?? 'Not assigned';
    final owed = (selectedStudent['owed_total'] as num?)?.toDouble() ?? 0.0;
    final paid = (selectedStudent['paid_total'] as num?)?.toDouble() ?? 0.0;

    // Use reused logic
    final initials = logic.getInitials(name);
    final statusLabel = logic.getStatusLabel(selectedStudent);
    final statusColor = logic.getStatusColor(selectedStudent);

    return Container(
      width: 350,
      color: AppColors.backgroundBlack,
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: AppColors.divider)),
      ),
      child: Column(
        children: [
          // Header with close button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.divider)),
            ),
            child: Row(
              children: [
                const Icon(Icons.person_outline,
                    color: AppColors.primaryBlue, size: 20),
                const SizedBox(width: 8),
                const Text(
                  "Student Details",
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close,
                      color: AppColors.textWhite54, size: 20),
                  onPressed: () {
                    ref.read(selectedStudentProvider.notifier).state = null;
                  },
                ),
              ],
            ),
          ),
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceGrey,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor:
                              AppColors.primaryBlue.withValues(alpha: 0.2),
                          child: Text(
                            initials,
                            style: const TextStyle(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "ID: $id",
                          style: const TextStyle(
                            color: AppColors.textWhite54,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            statusLabel,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Academic Section
                  _buildSectionTitle("Academic"),
                  _buildDetailRow("Grade/Form", grade),
                  _buildDetailRow("Subjects", subjects),
                  const SizedBox(height: 16),

                  // Personal Information
                  _buildSectionTitle("Personal Information"),
                  _buildDetailRow("Date of Birth", logic.formatDate(dob)),
                  _buildDetailRow("Gender", gender),
                  _buildDetailRow("Address", address),
                  const SizedBox(height: 16),

                  // Enrollment
                  _buildSectionTitle("Enrollment"),
                  _buildDetailRow("Enrollment Date", logic.formatDate(enrollmentDate)),
                  const SizedBox(height: 16),

                  // Parent/Guardian
                  _buildSectionTitle("Parent/Guardian"),
                  _buildDetailRow("Name", parentName),
                  _buildDetailRow("Contact", parentContact),
                  const SizedBox(height: 16),

                  // Financial Summary
                  _buildSectionTitle("Financial Summary"),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceGrey,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text(
                              "Paid",
                              style: TextStyle(
                                color: AppColors.textWhite54,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              logic.formatCurrency(paid),
                              style: const TextStyle(
                                color: AppColors.successGreen,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 1,
                          height: 30,
                          color: AppColors.divider,
                        ),
                        Column(
                          children: [
                            const Text(
                              "Owed",
                              style: TextStyle(
                                color: AppColors.textWhite54,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              logic.formatCurrency(owed),
                              style: TextStyle(
                                color: owed > 0
                                    ? AppColors.errorRed
                                    : AppColors.successGreen,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Medical Notes
                  _buildSectionTitle("Medical Notes"),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceGrey,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Text(
                      medicalNotes,
                      style: const TextStyle(
                        color: AppColors.textWhite70,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.textWhite,
          fontSize: 13,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textWhite54,
              fontSize: 12,
            ),
          ),
          const Spacer(),
          Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: AppColors.textWhite,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
