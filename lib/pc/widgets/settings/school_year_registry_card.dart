import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/providers/settings_provider.dart';

class SchoolYearRegistryCard extends ConsumerWidget {
  final Function(String) onEdit;
  final String? activeEditingId;

  const SchoolYearRegistryCard({
    super.key,
    required this.onEdit,
    this.activeEditingId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schoolYearsAsync = ref.watch(schoolYearsProvider);

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
                    Text("School Year Registry",
                        style: TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text("Define academic years, active periods, and archives.",
                        style: TextStyle(
                            color: AppColors.textWhite54, fontSize: 13)),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text("Add New Year"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
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

          // Rows
          if (schoolYearsAsync.isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (schoolYearsAsync.hasError)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                  child: Text(
                      'Error loading school years: ${schoolYearsAsync.error}')),
            )
          else
            ..._buildRows(schoolYearsAsync.value ?? []),
        ],
      ),
    );
  }

  List<Widget> _buildRows(List<Map<String, dynamic>> years) {
    if (years.isEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
              child: Text('No school years found',
                  style: TextStyle(color: AppColors.textWhite54))),
        )
      ];
    }

    final rows = <Widget>[];
    for (final year in years) {
      rows.add(_buildRowFromMap(year));
      rows.add(const Divider(height: 1, color: AppColors.divider));
    }
    // Remove last divider
    if (rows.isNotEmpty) rows.removeLast();
    return rows;
  }

  Widget _buildRowFromMap(Map<String, dynamic> year) {
    final id = year['id'] as String? ?? '';
    final label = year['year_label'] as String? ?? 'Unknown';
    final desc = year['description'] as String? ?? '';
    final startDate = year['start_date'] as String? ?? '';
    final endDate = year['end_date'] as String? ?? '';
    final dates = startDate.isNotEmpty && endDate.isNotEmpty
        ? '$startDate - $endDate'
        : '';
    final active = (year['active'] as int? ?? 0) == 1;
    final status = active ? 'Active' : 'Inactive';
    final statusColor = active ? AppColors.successGreen : AppColors.textWhite54;
    const isEditable = true; // Always allow editing

    return _buildRow(
      id: id,
      label: label,
      desc: desc,
      dates: dates,
      status: status,
      statusColor: statusColor,
      isEditable: isEditable,
    );
  }

  Widget _headerCol(String text, int flex) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: const TextStyle(
            color: AppColors.textWhite38,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8),
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
                Text(label,
                    style: const TextStyle(
                        color: AppColors.textWhite,
                        fontWeight: FontWeight.w600,
                        fontSize: 13)),
                if (isEditable) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.edit,
                      size: 12, color: AppColors.primaryBlue),
                ]
              ],
            ),
          ),
          // Description
          Expanded(
              flex: 4,
              child: Text(desc,
                  style: const TextStyle(
                      color: AppColors.textWhite54, fontSize: 13))),
          // Dates
          Expanded(
              flex: 3,
              child: Text(dates,
                  style: const TextStyle(
                      color: AppColors.textWhite54, fontSize: 13))),
          // Status
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(status,
                      style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
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
                  color:
                      isEditing ? AppColors.primaryBlue : AppColors.textWhite54,
                  fontWeight: isEditing ? FontWeight.bold : FontWeight.normal),
            ),
          ),
        ],
      ),
    );
  }
}
