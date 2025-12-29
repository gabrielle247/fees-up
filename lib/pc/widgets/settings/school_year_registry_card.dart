import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class SchoolYearRegistryCard extends StatelessWidget {
  final Function(String) onEdit;
  final String? activeEditingId;

  const SchoolYearRegistryCard({
    super.key,
    required this.onEdit,
    this.activeEditingId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("School Year Registry", style: TextStyle(color: AppColors.textWhite, fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text("Define academic years, active periods, and archives.", style: TextStyle(color: AppColors.textWhite54, fontSize: 13)),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text("Add New Year"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),

          // Column Headers
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                _headerCol("ACADEMIC YEAR", 3),
                _headerCol("DESCRIPTION", 4),
                _headerCol("DATE RANGE", 3),
                _headerCol("STATUS", 2),
                const Spacer(), // Actions space
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),

          // Rows (Mock Data)
          _buildRow(
            id: "2023-2024",
            label: "2023 - 2024",
            desc: "Standard Curriculum",
            dates: "Sep 2023 - Jun 2024",
            status: "Active",
            statusColor: AppColors.successGreen,
          ),
          const Divider(height: 1, color: AppColors.divider),
          
          _buildRow(
            id: "2024-2025",
            label: "2024 - 2025",
            desc: "Standard Academic Year",
            dates: "Sep 2024 - Jun 2025",
            status: "Draft",
            statusColor: AppColors.textWhite54,
            isEditable: true, // Shows the pencil icon next to name
          ),
        ],
      ),
    );
  }

  Widget _headerCol(String text, int flex) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: const TextStyle(color: AppColors.textWhite38, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8),
      ),
    );
  }

  Widget _buildRow({
    required String id,
    required String label,
    required String desc,
    required String dates,
    required String status,
    required Color statusColor,
    bool isEditable = false,
  }) {
    final bool isEditing = activeEditingId == id;

    return Container(
      color: isEditing ? AppColors.primaryBlue.withValues(alpha: 0.05) : null,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      child: Row(
        children: [
          // Year
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Text(label, style: const TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.w600, fontSize: 13)),
                if (isEditable) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.edit, size: 12, color: AppColors.primaryBlue),
                ]
              ],
            ),
          ),
          // Description
          Expanded(flex: 4, child: Text(desc, style: const TextStyle(color: AppColors.textWhite54, fontSize: 13))),
          // Dates
          Expanded(flex: 3, child: Text(dates, style: const TextStyle(color: AppColors.textWhite54, fontSize: 13))),
          // Status
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(status, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          // Action Button
          TextButton(
            onPressed: () => onEdit(id),
            child: Text(
              isEditing ? "Editing" : "Edit",
              style: TextStyle(
                color: isEditing ? AppColors.primaryBlue : AppColors.textWhite54,
                fontWeight: isEditing ? FontWeight.bold : FontWeight.normal
              ),
            ),
          ),
        ],
      ),
    );
  }
}