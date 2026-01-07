import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'form_helpers.dart';

class PersonalInfoForm extends StatelessWidget {
  final TextEditingController fullNameController;
  final TextEditingController studentIdController;
  final TextEditingController medicalNotesController;
  final String selectedGrade;
  final DateTime dob;
  final String selectedGender;
  final List<String> selectedSubjects;
  final List<String> grades;
  final List<String> genders;
  final Function(String?) onGradeChanged;
  final Function(DateTime) onDobChanged;
  final Function(String?) onGenderChanged;
  final VoidCallback onSelectSubjects;

  const PersonalInfoForm({
    super.key,
    required this.fullNameController,
    required this.studentIdController,
    required this.medicalNotesController,
    required this.selectedGrade,
    required this.dob,
    required this.selectedGender,
    required this.selectedSubjects,
    required this.grades,
    required this.genders,
    required this.onGradeChanged,
    required this.onDobChanged,
    required this.onGenderChanged,
    required this.onSelectSubjects,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("STUDENT DETAILS",
            style: TextStyle(
                color: AppColors.textGrey,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2)),
        const SizedBox(height: 24),
        FormHelpers.buildLabel("Full Name", AppColors.textWhite),
        FormHelpers.buildTextField(
          controller: fullNameController,
          hint: "e.g. Gabriel",
          prefixIcon: Icons.person_outline,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FormHelpers.buildLabel("Student ID", AppColors.textWhite),
                  FormHelpers.buildTextField(
                    controller: studentIdController,
                    hint: "STU-...",
                    readOnly: true,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FormHelpers.buildLabel("Grade", AppColors.textWhite),
                  FormHelpers.buildDropdown(
                    value: selectedGrade,
                    items: grades,
                    onChanged: onGradeChanged,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FormHelpers.buildLabel("Date of Birth", AppColors.textWhite),
                  FormHelpers.buildDatePicker(
                    context,
                    dob,
                    onDobChanged,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FormHelpers.buildLabel("Gender", AppColors.textWhite),
                  FormHelpers.buildDropdown(
                    value: selectedGender,
                    items: genders,
                    onChanged: onGenderChanged,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        FormHelpers.buildLabel("Subjects", AppColors.textWhite),
        InkWell(
          onTap: onSelectSubjects,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surfaceGrey,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.surfaceLightGrey),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedSubjects.isEmpty
                      ? "Select Subjects..."
                      : "${selectedSubjects.length} subjects selected",
                  style: TextStyle(
                      color: selectedSubjects.isEmpty
                          ? AppColors.textWhite54
                          : AppColors.textWhite),
                ),
                const Icon(Icons.arrow_drop_down,
                    color: AppColors.textWhite54),
              ],
            ),
          ),
        ),
        if (selectedSubjects.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: selectedSubjects
                .take(10)
                .map((s) => Chip(
                      label: Text(s,
                          style: const TextStyle(
                              fontSize: 10, color: AppColors.textWhite)),
                      backgroundColor:
                          AppColors.primaryBlue.withValues(alpha: 0.2),
                      padding: EdgeInsets.zero,
                      side: BorderSide.none,
                    ))
                .toList(),
          ),
        ],
        const SizedBox(height: 16),
        FormHelpers.buildLabel("Medical Notes", AppColors.textWhite),
        FormHelpers.buildTextField(
          controller: medicalNotesController,
          hint: "Allergies, conditions, etc.",
          prefixIcon: Icons.medical_information_outlined,
          maxLines: 2,
        ),
      ],
    );
  }
}
