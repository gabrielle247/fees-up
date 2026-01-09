import 'package:fees_up/constants/app_colors.dart';
import 'package:fees_up/data/providers/dashboard_providers.dart';
import 'package:fees_up/data/providers/school_providers.dart';
import 'package:fees_up/data/providers/student_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LearnersScreen extends ConsumerWidget {
  const LearnersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSchoolAsync = ref.watch(currentSchoolProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundBlack,
        title: const Text('Learners',
            style: TextStyle(color: AppColors.textWhite)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textWhite),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.successGreen,
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.add, color: AppColors.textWhite, size: 20),
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: currentSchoolAsync.when(
        data: (school) {
          if (school == null) {
            return const Center(child: Text("No School Selected"));
          }
          final studentsAsync = ref.watch(studentsProvider(school.id));

          return studentsAsync.when(
            data: (students) {
              if (students.isEmpty) {
                return const Center(
                    child: Text('No learners found',
                        style: TextStyle(color: Colors.grey)));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: students.length,
                itemBuilder: (context, index) {
                  final student = students[index];
                  final balanceAsync =
                      ref.watch(studentBalanceProvider(student.id));

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceGrey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: _getAvatarColor(index),
                          child: Text(
                            student.firstName[0] + student.lastName[0],
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${student.firstName} ${student.lastName}'
                                    .trim(),
                                style: const TextStyle(
                                  color: AppColors.textWhite,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: student.status == 'ACTIVE'
                                          ? AppColors.successGreen
                                          : Colors.grey,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    student.status,
                                    style: const TextStyle(
                                        color: AppColors.textGrey,
                                        fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Student Balance
                        balanceAsync.when(
                          data: (balance) {
                            final isOwing = balance > 0;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  isOwing
                                      ? '-\$${(balance / 100).toStringAsFixed(0)}'
                                      : '\$${(balance.abs() / 100).toStringAsFixed(0)}',
                                  style: TextStyle(
                                    color: isOwing
                                        ? AppColors.errorRed
                                        : AppColors.successGreen,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  isOwing ? "OWING" : "CREDIT",
                                  style: TextStyle(
                                    color: AppColors.textGrey
                                        .withValues(alpha: 0.5),
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            );
                          },
                          loading: () => Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.textGrey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "...",
                                style: TextStyle(
                                  color:
                                      AppColors.textGrey.withValues(alpha: 0.5),
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                          error: (_, __) => Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                "--",
                                style: TextStyle(
                                  color: AppColors.textGrey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                "ERROR",
                                style: TextStyle(
                                  color:
                                      AppColors.textGrey.withValues(alpha: 0.5),
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          );
        },
        loading: () => const SizedBox(),
        error: (e, s) => Text('Error: $e'),
      ),
    );
  }

  Color _getAvatarColor(int index) {
    final colors = [
      Colors.teal,
      Colors.blue,
      Colors.pink,
      Colors.orange,
      Colors.purple,
    ];
    return colors[index % colors.length];
  }
}
