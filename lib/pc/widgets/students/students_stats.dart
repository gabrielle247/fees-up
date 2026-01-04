import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/providers/students_provider.dart';

class StudentsStats extends ConsumerWidget {
  final String schoolId;
  const StudentsStats({super.key, required this.schoolId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Uses provider for real-time stats
    final studentsAsync = ref.watch(studentsProvider(schoolId));

    return studentsAsync.when(
      loading: () => const SizedBox(
        height: 140,
        child: Center(
            child: CircularProgressIndicator(color: AppColors.primaryBlue)),
      ),
      error: (error, stack) => SizedBox(
        height: 140,
        child: Center(
            child: Text("Error: $error",
                style: const TextStyle(color: AppColors.errorRed))),
      ),
      data: (students) {
        // 1. Calculate Stats
        final total = students.length;
        final active =
            students.where((s) => (s['is_active'] as int?) == 1).length;

        // Example logic: "New Enrollments" = students created this month
        final now = DateTime.now();
        final newEnrollments = students.where((s) {
          if (s['created_at'] == null) return false;
          final created =
              DateTime.tryParse(s['created_at'].toString()) ?? DateTime(2000);
          return created.month == now.month && created.year == now.year;
        }).length;

        // Example logic: "Unpaid" = owed_total > 0
        final unpaidCount = students.where((s) {
          final owed = (s['owed_total'] as num?)?.toDouble() ?? 0.0;
          return owed > 0;
        }).length;

        return SizedBox(
          height: 140,
          child: Row(
            children: [
              // 1. Total Students
              Expanded(
                child: _StatCard(
                  title: "Total Students",
                  value: total.toString(),
                  subtext: "$active Active Users",
                  icon: Icons.people,
                  iconColor: AppColors.primaryBlue,
                  showProgress: true,
                  progressVal: total > 0 ? (active / total) : 0,
                ),
              ),
              const SizedBox(width: 16),

              // 2. New Enrollments
              Expanded(
                child: _StatCard(
                  title: "New Enrollments",
                  value: newEnrollments.toString(),
                  subtext: "+$newEnrollments this month",
                  subtextColor: AppColors.successGreen,
                  icon: Icons.person_add,
                  iconColor: AppColors.successGreen,
                ),
              ),
              const SizedBox(width: 16),

              // 3. Attendance Rate (Mocked for now as we don't have attendance stream here)
              const Expanded(
                child: _StatCard(
                  title: "Attendance Rate",
                  value: "94%",
                  subtext: "Avg. daily attendance",
                  icon: Icons.event_available,
                  iconColor: AppColors.accentPurple,
                ),
              ),
              const SizedBox(width: 16),

              // 4. Unpaid Fees (Red Alert Style)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      color: AppColors.surfaceGrey,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.errorRed.withValues(alpha: 0.5)),
                      gradient: LinearGradient(
                        colors: [
                          AppColors.surfaceGrey,
                          AppColors.errorRed.withValues(alpha: 0.05)
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      )),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("UNPAID FEES",
                              style: TextStyle(
                                  color: AppColors.textGrey,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold)),
                          Icon(Icons.warning_amber_rounded,
                              color: AppColors.errorRed, size: 20),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(unpaidCount.toString(),
                              style: const TextStyle(
                                  color: AppColors.textWhite,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          const Text("Action required",
                              style: TextStyle(
                                  color: AppColors.errorRed,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtext;
  final Color? subtextColor;
  final IconData icon;
  final Color iconColor;
  final bool showProgress;
  final double progressVal;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtext,
    this.subtextColor,
    required this.icon,
    required this.iconColor,
    this.showProgress = false,
    this.progressVal = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title.toUpperCase(),
                  style: const TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 11,
                      fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: const TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (showProgress)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: progressVal,
                        backgroundColor: AppColors.backgroundBlack,
                        color: iconColor,
                        minHeight: 4,
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                ),
              Text(subtext,
                  style: TextStyle(
                      color: subtextColor ?? AppColors.textWhite38,
                      fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}
