import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

class PersonalInfoForm extends StatelessWidget {
  const PersonalInfoForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Personal Information", style: TextStyle(color: AppColors.textWhite, fontSize: 16, fontWeight: FontWeight.bold)),
              Icon(Icons.badge, color: AppColors.textWhite.withValues(alpha: 0.2), size: 20),
            ],
          ),
          const SizedBox(height: 4),
          const Text("Update your personal details and contact info here.", style: TextStyle(color: AppColors.textWhite54, fontSize: 13)),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(child: _buildInput("First Name", "Jane", Icons.person_outline)),
              const SizedBox(width: 24),
              Expanded(child: _buildInput("Last Name", "Doe", Icons.person_outline)),
            ],
          ),
          const SizedBox(height: 24),
          
          _buildInput("Email Address", "jane.doe@schooladmin.edu", Icons.email_outlined),
          const SizedBox(height: 24),
          
          _buildInput("Phone Number", "+1 (555) 123-4567", Icons.phone_outlined),
          const SizedBox(height: 24),

          const Text("Bio / Role Description", style: TextStyle(color: AppColors.textWhite70, fontSize: 13)),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: "Responsible for overseeing all financial operations, including student billing, expense tracking, and ledger reconciliation.",
            maxLines: 4,
            style: const TextStyle(color: AppColors.textWhite),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.backgroundBlack,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.divider)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.divider)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primaryBlue)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textWhite70, fontSize: 13)),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: value,
          style: const TextStyle(color: AppColors.textWhite),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.backgroundBlack,
            prefixIcon: Icon(icon, color: AppColors.textWhite38, size: 18),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.divider)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.divider)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primaryBlue)),
          ),
        ),
      ],
    );
  }
}