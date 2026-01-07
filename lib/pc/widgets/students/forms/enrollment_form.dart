import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'form_helpers.dart';

class EnrollmentForm extends StatelessWidget {
  final DateTime registrationDate;
  final DateTime enrollmentDate;
  final DateTime billingDate;
  final String selectedTerm;
  final String selectedBillingType;
  final List<String> terms;
  final List<String> billingTypes;
  final Function(DateTime) onRegistrationDateChanged;
  final Function(DateTime) onEnrollmentDateChanged;
  final Function(DateTime) onBillingDateChanged;
  final Function(String?) onTermChanged;
  final Function(String) onBillingTypeChanged;

  const EnrollmentForm({
    super.key,
    required this.registrationDate,
    required this.enrollmentDate,
    required this.billingDate,
    required this.selectedTerm,
    required this.selectedBillingType,
    required this.terms,
    required this.billingTypes,
    required this.onRegistrationDateChanged,
    required this.onEnrollmentDateChanged,
    required this.onBillingDateChanged,
    required this.onTermChanged,
    required this.onBillingTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("ENROLLMENT & BILLING",
            style: TextStyle(
                color: AppColors.textGrey,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2)),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FormHelpers.buildLabel("Registration Date", AppColors.textWhite),
                  FormHelpers.buildDatePicker(
                    context,
                    registrationDate,
                    onRegistrationDateChanged,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FormHelpers.buildLabel("Enrollment Date", AppColors.textWhite),
                  FormHelpers.buildDatePicker(
                    context,
                    enrollmentDate,
                    onEnrollmentDateChanged,
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
                  FormHelpers.buildLabel("Billing Date", AppColors.textWhite),
                  FormHelpers.buildDatePicker(
                    context,
                    billingDate,
                    onBillingDateChanged,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FormHelpers.buildLabel("Term", AppColors.textWhite),
                  FormHelpers.buildDropdown(
                    value: selectedTerm,
                    items: terms,
                    onChanged: onTermChanged,
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
                  FormHelpers.buildLabel("Billing Type", AppColors.textWhite),
                  Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceGrey,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.surfaceLightGrey),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: billingTypes.map((type) {
                        final isSelected = selectedBillingType == type;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => onBillingTypeChanged(type),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primaryBlue
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                type.toUpperCase(),
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? AppColors.textWhite
                                        : AppColors.textGrey),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
