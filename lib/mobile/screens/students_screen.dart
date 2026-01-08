import 'package:fees_up/constants/app_colors.dart';
import 'package:fees_up/data/models/people.dart';
import 'package:fees_up/data/providers/core_providers.dart';
import 'package:fees_up/data/providers/student_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StudentsScreen extends ConsumerStatefulWidget {
  const StudentsScreen({super.key});

  @override
  ConsumerState<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends ConsumerState<StudentsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final Map<String, bool> _expandedForms = {};

  List<Student> _getFilteredStudents(List<Student> students) {
    if (_searchQuery.isEmpty) {
      return students;
    }
    return students
        .where((student) =>
            (student.firstName.toLowerCase() + ' ' + student.lastName.toLowerCase())
                .contains(_searchQuery.toLowerCase()) ||
            student.admissionNumber.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  // Group students by form/grade
  Map<String, List<Student>> _groupStudentsByForm(List<Student> students) {
    final Map<String, List<Student>> grouped = {};
    for (var student in students) {
      // Assuming 'grade' field holds 'Form 1', 'Grade 5', etc.
      // If grade is just a number/code, we might need mapping.
      // Assuming it's a string like 'Form 1' or '1'
      final key = (student.currentGrade ?? 'Unknown').toUpperCase();

      // Vocabulary adjustments: If it's just a number 1-7, treat as Grade. 8-13 or Form.
      // Assuming stored data matches vocabulary or we map it here.

      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(student);
    }

    // Ensure keys are sorted if possible
    final sortedKeys = grouped.keys.toList()..sort();
    final Map<String, List<Student>> sortedMap = {};
    for (var key in sortedKeys) {
      sortedMap[key] = grouped[key]!;
    }

    return sortedMap;
  }

  Color _getAvatarColor(String initials) {
    final colors = [
      const Color(0xFF6366F1),
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
      const Color(0xFFF59E0B),
      const Color(0xFF10B981),
      const Color(0xFF3B82F6),
      const Color(0xFF14B8A6),
    ];
    return colors[initials.hashCode % colors.length];
  }

  void _showStudentDetails(Student student) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceGrey,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _StudentDetailsSheet(student: student),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final schoolIdAsync = ref.watch(currentSchoolIdProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      body: SafeArea(
        child: schoolIdAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue)),
          error: (e, s) => Center(child: Text('Error loading school: $e', style: const TextStyle(color: AppColors.errorRed))),
          data: (schoolId) {
            final studentsAsync = ref.watch(studentsProvider(schoolId));

            return Column(
              children: [
                // Header with back button, title, and add button
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(
                              Icons.arrow_back,
                              color: AppColors.textWhite,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Learners',
                            style: TextStyle(
                              color: AppColors.textWhite,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.successGreen,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: AppColors.textWhite,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),

                // Search and Filter bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.surfaceGrey,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) {
                              setState(() => _searchQuery = value);
                            },
                            style: const TextStyle(color: AppColors.textWhite),
                            decoration: const InputDecoration(
                              hintText: 'Search',
                              hintStyle: TextStyle(color: AppColors.textGrey),
                              prefixIcon: Icon(Icons.search,
                                  color: AppColors.textGrey),
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceGrey,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.tune,
                          color: AppColors.textGrey,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Expandable Form Sections
                Expanded(
                  child: studentsAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue)),
                    error: (e, s) => Center(child: Text('Error loading students: $e', style: const TextStyle(color: AppColors.errorRed))),
                    data: (students) {
                      if (students.isEmpty) {
                         return const Center(child: Text('No students found', style: TextStyle(color: AppColors.textGrey)));
                      }

                      final groupedStudents = _groupStudentsByForm(students);

                      // Initialize expanded state for new keys
                      for (var key in groupedStudents.keys) {
                        if (!_expandedForms.containsKey(key)) {
                          // Expand first one by default
                          _expandedForms[key] = groupedStudents.keys.first == key;
                        }
                      }

                      return SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: groupedStudents.entries.map((entry) {
                              final form = entry.key;
                              final formStudents = entry.value;
                              final filteredStudents = _getFilteredStudents(formStudents);
                              final isExpanded = _expandedForms[form] ?? false;

                              if (filteredStudents.isEmpty && _searchQuery.isNotEmpty) return const SizedBox.shrink();

                              return Column(
                                children: [
                                  // Form Header
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _expandedForms[form] = !isExpanded;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceGrey,
                                        borderRadius: BorderRadius.circular(8),
                                        border: const Border(
                                          left: BorderSide(
                                            color: AppColors.successGreen,
                                            width: 4,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                form,
                                                style: const TextStyle(
                                                  color: AppColors.textWhite,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.successGreen
                                                      .withValues(alpha: 0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  '${filteredStudents.length}',
                                                  style: const TextStyle(
                                                    color: AppColors.successGreen,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Icon(
                                            isExpanded
                                                ? Icons.expand_less
                                                : Icons.expand_more,
                                            color: AppColors.textGrey,
                                            size: 24,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Expanded Student List
                                  if (isExpanded && filteredStudents.isNotEmpty)
                                    Column(
                                      children: [
                                        const SizedBox(height: 12),
                                        ...filteredStudents.map((student) {
                                          // Placeholder for owed amount - assuming logic or field exists
                                          // Student model doesn't have 'owed' field in current view
                                          // We might need to fetch this or assume 0 for now
                                          final isOwing = false;
                                          final owedAmount = 0;
                                          final paidAmount = 0;
                                          final initials = (student.firstName.isNotEmpty ? student.firstName[0] : '') +
                                                           (student.lastName.isNotEmpty ? student.lastName[0] : '');
                                          final fullName = '${student.firstName} ${student.lastName}';

                                          return Padding(
                                            padding: const EdgeInsets.only(bottom: 12),
                                            child: GestureDetector(
                                              onTap: () => _showStudentDetails(student),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 12,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.surfaceGrey,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Row(
                                                  children: [
                                                    // Avatar
                                                    Container(
                                                      width: 48,
                                                      height: 48,
                                                      decoration: BoxDecoration(
                                                        color: _getAvatarColor(initials),
                                                        borderRadius:
                                                            BorderRadius.circular(24),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          initials,
                                                          style: const TextStyle(
                                                            color: AppColors.textWhite,
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                        ),
                                                      ),
                                                    ),

                                                    const SizedBox(width: 12),

                                                    // Name and Status
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            fullName,
                                                            style: const TextStyle(
                                                              color:
                                                                  AppColors.textWhite,
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight.w600,
                                                            ),
                                                          ),
                                                          const SizedBox(height: 4),
                                                          Row(
                                                            children: [
                                                              Container(
                                                                width: 8,
                                                                height: 8,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: AppColors
                                                                      .successGreen,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(4),
                                                                ),
                                                              ),
                                                              const SizedBox(width: 6),
                                                              Text(
                                                                student.status ?? 'ACTIVE',
                                                                style: const TextStyle(
                                                                  color: AppColors
                                                                      .textGrey,
                                                                  fontSize: 11,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),

                                                    // Financial Status (Placeholder)
                                                    /*
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment.end,
                                                      children: [
                                                        Text(
                                                          isOwing
                                                              ? '-\$${owedAmount}'
                                                              : '+\$${paidAmount}',
                                                          style: TextStyle(
                                                            color: isOwing
                                                                ? AppColors.errorRed
                                                                : AppColors
                                                                    .successGreen,
                                                            fontSize: 13,
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                        ),
                                                        const SizedBox(height: 4),
                                                        Text(
                                                          isOwing ? 'OWING' : 'PAID',
                                                          style: const TextStyle(
                                                            color: AppColors.textGrey,
                                                            fontSize: 10,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    */
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                      ],
                                    ),

                                  const SizedBox(height: 16),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// Student Details Bottom Sheet
class _StudentDetailsSheet extends StatelessWidget {
  final Student student;

  const _StudentDetailsSheet({required this.student});

  @override
  Widget build(BuildContext context) {
    final fullName = '${student.firstName} ${student.lastName}';

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fullName,
                    style: const TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    student.admissionNumber,
                    style: const TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(
                  Icons.close,
                  color: AppColors.textGrey,
                  size: 24,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Details Grid (Mocked Financials as Student model lacks them currently)
          // We could use a Provider here to fetch financials for this student
          /*
          Row(
            children: [
              Expanded(
                child: _DetailCard(
                  label: 'Outstanding',
                  value: '\$0', // Placeholder
                  valueColor: AppColors.successGreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DetailCard(
                  label: 'Paid',
                  value: '\$0', // Placeholder
                  valueColor: AppColors.successGreen,
                ),
              ),
            ],
          ),
          */

          const Text(
            'Personal Details',
            style: TextStyle(color: AppColors.textGrey, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Grade: ${student.currentGrade ?? 'N/A'}',
            style: const TextStyle(color: AppColors.textWhite),
          ),

          const SizedBox(height: 24),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.visibility, size: 18),
                  label: const Text('View'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: AppColors.textWhite,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.payment, size: 18),
                  label: const Text('Pay'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.successGreen,
                    side: const BorderSide(color: AppColors.successGreen),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Edit'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryBlueLight,
                side: const BorderSide(color: AppColors.surfaceLightGrey),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _DetailCard({
    required this.label,
    required this.value,
    this.valueColor = AppColors.textWhite,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundBlack,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textGrey,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
