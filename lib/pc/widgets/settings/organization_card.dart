import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class OrganizationCard extends StatelessWidget {
  const OrganizationCard({super.key});

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
              const Text("Organization", style: TextStyle(color: AppColors.textWhite, fontSize: 16, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: Colors.purple.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                child: const Icon(Icons.business, color: Colors.purple, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text("Public details.", style: TextStyle(color: AppColors.textWhite54, fontSize: 12)),
          
          const SizedBox(height: 24),
          
          _buildInput("School Name", "Springfield International Academy"),
          const SizedBox(height: 16),
          _buildInput("Address", "742 Evergreen Terrace\nSpringfield, IL 62704", maxLines: 3),
          const SizedBox(height: 16),
          _buildInput("Contact Email", "finance@springfield.edu"),
        ],
      ),
    );
  }

  Widget _buildInput(String label, String value, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textWhite70, fontSize: 13)),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: value,
          maxLines: maxLines,
          style: const TextStyle(color: AppColors.textWhite),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.backgroundBlack,
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.divider)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.divider)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primaryBlue)),
          ),
        ),
      ],
    );
  }
}