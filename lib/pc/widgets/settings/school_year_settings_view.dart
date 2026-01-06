import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/providers/school_year_generator_provider.dart';
import '../../../../data/providers/dashboard_provider.dart';
import 'school_year_registry_card.dart';
import 'year_configuration_card.dart';

class SchoolYearSettingsView extends ConsumerStatefulWidget {
  const SchoolYearSettingsView({super.key});

  @override
  ConsumerState<SchoolYearSettingsView> createState() =>
      _SchoolYearSettingsViewState();
}

class _SchoolYearSettingsViewState
    extends ConsumerState<SchoolYearSettingsView> {
  // State to track which year is currently being edited
  String? _editingYearId = "2024-2025";
  bool _hasSeeded = false;

  @override
  void initState() {
    super.initState();
    // Trigger one-time seeding on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _seedYearsIfNeeded();
    });
  }

  /// Runs the year seeder for the current school (one-time)
  Future<void> _seedYearsIfNeeded() async {
    if (_hasSeeded) return;

    final dashboardAsync = ref.read(dashboardDataProvider);
    dashboardAsync.whenData((data) {
      if (data.schoolId.isNotEmpty) {
        setState(() => _hasSeeded = true);
        // Trigger the seeder provider (it's idempotent)
        ref.read(schoolYearSeederProvider(data.schoolId));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboardAsync = ref.watch(dashboardDataProvider);

    return dashboardAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(
        child: Text(
          'Error loading dashboard: $err',
          style: const TextStyle(color: AppColors.errorRed),
        ),
      ),
      data: (dashboard) {
        final schoolId = dashboard.schoolId;
        if (schoolId.isEmpty) {
          return const Center(
            child: Text(
              '⚠️ No school context found',
              style: TextStyle(color: AppColors.textWhite54),
            ),
          );
        }

        final seederAsync = ref.watch(schoolYearSeederProvider(schoolId));

        // Show seeding progress overlay
        if (seederAsync.isLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  '📅 Generating 15 years of academic calendar...',
                  style: TextStyle(color: AppColors.textWhite70),
                ),
                SizedBox(height: 8),
                Text(
                  'This is a one-time operation.',
                  style: TextStyle(color: AppColors.textWhite38, fontSize: 12),
                ),
              ],
            ),
          );
        }

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
      },
    );
  }
}
