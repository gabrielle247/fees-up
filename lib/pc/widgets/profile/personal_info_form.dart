import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../data/providers/dashboard_provider.dart';

class PersonalInfoForm extends ConsumerWidget {
  const PersonalInfoForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardDataProvider);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: dashboardAsync.when(
        data: (data) => _buildFormContent(context, data.userName, data.schoolName),
        loading: () => _buildFormContent(context, "", ""),
        error: (err, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: AppColors.warningOrange, size: 48),
              const SizedBox(height: 12),
              Text("Failed to load profile: $err", style: const TextStyle(color: AppColors.textWhite70)),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => ref.invalidate(dashboardDataProvider),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text("Retry"),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormContent(BuildContext context, String fullName, String schoolName) {
    // Split name into first/last
    final nameParts = fullName.trim().split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts[0] : "";
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : "";

    return Column(
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
            Expanded(child: _buildInput("First Name", firstName.isEmpty ? "Not set" : firstName, Icons.person_outline)),
            const SizedBox(width: 24),
            Expanded(child: _buildInput("Last Name", lastName.isEmpty ? "Not set" : lastName, Icons.person_outline)),
          ],
        ),
        const SizedBox(height: 24),
        
        _buildInput("School", schoolName.isEmpty ? "Not set" : schoolName, Icons.school_outlined),
        const SizedBox(height: 24),
        
        _buildInput("Role", "Administrator", Icons.work_outline),
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