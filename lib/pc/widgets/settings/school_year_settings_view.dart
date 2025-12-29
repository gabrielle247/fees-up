import 'package:flutter/material.dart';
// ignore: unused_import
import '../../../../core/constants/app_colors.dart';
import 'school_year_registry_card.dart';
import 'year_configuration_card.dart';

class SchoolYearSettingsView extends StatefulWidget {
  const SchoolYearSettingsView({super.key});

  @override
  State<SchoolYearSettingsView> createState() => _SchoolYearSettingsViewState();
}

class _SchoolYearSettingsViewState extends State<SchoolYearSettingsView> {
  // State to track which year is currently being edited
  String? _editingYearId = "2024-2025"; 

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Registry Table (Top Card)
        SchoolYearRegistryCard(
          onEdit: (yearId) {
            setState(() => _editingYearId = yearId);
          },
          activeEditingId: _editingYearId,
        ),
        
        const SizedBox(height: 32),

        // 2. Active Configuration (Bottom Card)
        // Only shows if a year is selected for editing
        if (_editingYearId != null)
          YearConfigurationCard(yearId: _editingYearId!),
      ],
    );
  }
}