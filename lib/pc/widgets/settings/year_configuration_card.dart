import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class YearConfigurationCard extends StatelessWidget {
  final String yearId;
  const YearConfigurationCard({super.key, required this.yearId});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundBlack, // Darker background to pop
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryBlue, width: 1.5), // Active Blue Border
      ),
      child: Column(
        children: [
          // 1. Config Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Configure: $yearId", style: const TextStyle(color: AppColors.textWhite, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text("Editing details, terms, and billing settings.", style: TextStyle(color: AppColors.textWhite54, fontSize: 13)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text("Draft", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),

          // 2. Form Body
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row 1: Label & Dates
                Row(
                  children: [
                    Expanded(child: _buildInput("Label", "2024 - 2025")),
                    const SizedBox(width: 24),
                    Expanded(child: _buildInput("Start Date", "09/01/2024", icon: Icons.calendar_today)),
                    const SizedBox(width: 24),
                    Expanded(child: _buildInput("End Date", "06/30/2025", icon: Icons.calendar_today)),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Row 2: Description
                _buildInput("Description", "Standard academic year curriculum.", helper: "Brief description for administrative reference."),
                
                const SizedBox(height: 40),
                const Divider(color: AppColors.divider),
                const SizedBox(height: 32),

                // 3. Terms Management Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.date_range, color: AppColors.textWhite70, size: 20),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Terms Management", style: TextStyle(color: AppColors.textWhite, fontSize: 14, fontWeight: FontWeight.bold)),
                            Text("Define academic terms (Semesters/Trimesters) for this year.", style: TextStyle(color: AppColors.textWhite54, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.add, size: 14),
                      label: const Text("Add Term"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textWhite,
                        side: const BorderSide(color: AppColors.divider),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Term 1
                _buildTermRow("Term Name", "Term 1", "09/01/2024", "12/20/2024"),
                const SizedBox(height: 16),
                
                // Term 2 (Empty for effect)
                _buildTermRow("Term Name", "Term 2", "", ""),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(String label, String value, {IconData? icon, String? helper}) {
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
            fillColor: AppColors.surfaceGrey,
            contentPadding: const EdgeInsets.all(16),
            suffixIcon: icon != null ? Icon(icon, color: AppColors.textWhite54, size: 18) : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.divider)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.divider)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primaryBlue)),
          ),
        ),
        if (helper != null) ...[
          const SizedBox(height: 6),
          Text(helper, style: const TextStyle(color: AppColors.textWhite38, fontSize: 11)),
        ]
      ],
    );
  }

  Widget _buildTermRow(String label, String val1, String val2, String val3) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceGrey.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(flex: 4, child: _buildSubInput("Term Name", val1)),
          const SizedBox(width: 16),
          Expanded(flex: 3, child: _buildSubInput("Start Date", val2, icon: Icons.calendar_today)),
          const SizedBox(width: 16),
          Expanded(flex: 3, child: _buildSubInput("End Date", val3, icon: Icons.calendar_today)),
          const SizedBox(width: 16),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.delete_outline, color: AppColors.textWhite54),
              tooltip: "Remove Term",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubInput(String label, String value, {IconData? icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textWhite38, fontSize: 11)),
        const SizedBox(height: 6),
        SizedBox(
          height: 40,
          child: TextFormField(
            initialValue: value,
            style: const TextStyle(color: AppColors.textWhite, fontSize: 13),
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: AppColors.backgroundBlack,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              suffixIcon: icon != null ? Icon(icon, color: AppColors.textWhite38, size: 16) : null,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.divider)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.divider)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.textWhite38)),
            ),
          ),
        ),
      ],
    );
  }
}