import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'form_helpers.dart';

class ContactInfoForm extends StatelessWidget {
  final TextEditingController addressController;
  final TextEditingController feeController;

  const ContactInfoForm({
    super.key,
    required this.addressController,
    required this.feeController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("CONTACT & FINANCIAL",
            style: TextStyle(
                color: AppColors.textGrey,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2)),
        const SizedBox(height: 24),
        FormHelpers.buildLabel("Address", AppColors.textWhite),
        FormHelpers.buildTextField(
          controller: addressController,
          hint: "Street address...",
          prefixIcon: Icons.location_on_outlined,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FormHelpers.buildLabel("Tuition Fee", AppColors.textWhite),
                  FormHelpers.buildTextField(
                    controller: feeController,
                    hint: "0.00",
                    prefix: "\$ ",
                    isNumber: true,
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
