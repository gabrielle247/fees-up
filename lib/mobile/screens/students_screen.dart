import 'package:fees_up/constants/app_colors.dart';
import 'package:flutter/material.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final Map<String, bool> _expandedForms = {
    'FORM 1': true,
    'FORM 2': false,
    'FORM 3': false,
    'FORM 4': false,
  };

  // Mock student data grouped by form
  final Map<String, List<Map<String, dynamic>>> _studentsByForm = {
    'FORM 1': [
      {
        'id': 'STU-001',
        'name': 'John Mwangi',
        'initials': 'JM',
        'owed': 15000,
        'paid': 45000,
        'status': 'ACTIVE',
      },
      {
        'id': 'STU-002',
        'name': 'Jane Kipchoge',
        'initials': 'JK',
        'owed': 0,
        'paid': 60000,
        'status': 'ACTIVE',
      },
      {
        'id': 'STU-003',
        'name': 'Michael Ochieng',
        'initials': 'MO',
        'owed': 22000,
        'paid': 38000,
        'status': 'ACTIVE',
      },
      {
        'id': 'STU-004',
        'name': 'Sarah Wanjiru',
        'initials': 'SW',
        'owed': 8500,
        'paid': 52000,
        'status': 'ACTIVE',
      },
      {
        'id': 'STU-005',
        'name': 'David Kariuki',
        'initials': 'DK',
        'owed': 31000,
        'paid': 29000,
        'status': 'ACTIVE',
      },
      {
        'id': 'STU-006',
        'name': 'Emily Nakitare',
        'initials': 'EN',
        'owed': 5000,
        'paid': 55000,
        'status': 'ACTIVE',
      },
      {
        'id': 'STU-007',
        'name': 'Peter Kipkemboi',
        'initials': 'PK',
        'owed': 18000,
        'paid': 42000,
        'status': 'ACTIVE',
      },
    ],
    'FORM 2': [
      {
        'id': 'STU-008',
        'name': 'Alice Kamau',
        'initials': 'AK',
        'owed': 12000,
        'paid': 48000,
        'status': 'ACTIVE',
      },
      {
        'id': 'STU-009',
        'name': 'Kevin Muthuri',
        'initials': 'KM',
        'owed': 0,
        'paid': 60000,
        'status': 'ACTIVE',
      },
      {
        'id': 'STU-010',
        'name': 'Rachel Kimani',
        'initials': 'RK',
        'owed': 25000,
        'paid': 35000,
        'status': 'ACTIVE',
      },
      {
        'id': 'STU-011',
        'name': 'Thomas Kipchoge',
        'initials': 'TK',
        'owed': 0,
        'paid': 60000,
        'status': 'ACTIVE',
      },
      {
        'id': 'STU-012',
        'name': 'Grace Omondi',
        'initials': 'GO',
        'owed': 20000,
        'paid': 40000,
        'status': 'ACTIVE',
      },
      {
        'id': 'STU-013',
        'name': 'Charles Kiplagat',
        'initials': 'CK',
        'owed': 5000,
        'paid': 55000,
        'status': 'ACTIVE',
      },
      {
        'id': 'STU-014',
        'name': 'Victoria Njoroge',
        'initials': 'VN',
        'owed': 30000,
        'paid': 30000,
        'status': 'ACTIVE',
      },
      {
        'id': 'STU-015',
        'name': 'Joseph Koech',
        'initials': 'JK',
        'owed': 10000,
        'paid': 50000,
        'status': 'ACTIVE',
      },
    ],
    'FORM 3': [
      {
        'id': 'STU-016',
        'name': 'Amelia Wambui',
        'initials': 'AW',
        'owed': 0,
        'paid': 60000,
        'status': 'ACTIVE',
      },
      {
        'id': 'STU-017',
        'name': 'Brian Kipchoge',
        'initials': 'BK',
        'owed': 15000,
        'paid': 45000,
        'status': 'ACTIVE',
      },
      {
        'id': 'STU-018',
        'name': 'Catherine Mutua',
        'initials': 'CM',
        'owed': 28000,
        'paid': 32000,
        'status': 'ACTIVE',
      },
      {
        'id': 'STU-019',
        'name': 'Daniel Kipkemboi',
        'initials': 'DK',
        'owed': 0,
        'paid': 60000,
        'status': 'ACTIVE',
      },
      {
        'id': 'STU-020',
        'name': 'Eleanor Ng\'eno',
        'initials': 'EN',
        'owed': 22000,
        'paid': 38000,
        'status': 'ACTIVE',
      },
      {
        'id': 'STU-021',
        'name': 'Francis Kiplagat',
        'initials': 'FK',
        'owed': 10000,
        'paid': 50000,
        'status': 'ACTIVE',
      },
      {
        'id': 'STU-022',
        'name': 'Gloria Kiprotich',
        'initials': 'GK',
        'owed': 0,
        'paid': 60000,
        'status': 'ACTIVE',
      },
      {
        'id': 'STU-023',
        'name': 'Henry Kipkemboi',
        'initials': 'HK',
        'owed': 18000,
        'paid': 42000,
        'status': 'ACTIVE',
      },
      {
        'id': 'STU-024',
        'name': 'Iris Kipchoge',
        'initials': 'IK',
        'owed': 5000,
        'paid': 55000,
        'status': 'ACTIVE',
      },
      {
        'id': 'STU-025',
        'name': 'James Kiplagat',
        'initials': 'JL',
        'owed': 35000,
        'paid': 25000,
        'status': 'ACTIVE',
      },
      {
        'id': 'STU-026',
        'name': 'Karen Kipkemboi',
        'initials': 'KK',
        'owed': 0,
        'paid': 60000,
        'status': 'ACTIVE',
      },
      {
        'id': 'STU-027',
        'name': 'Luke Kipchoge',
        'initials': 'LK',
        'owed': 12000,
        'paid': 48000,
        'status': 'ACTIVE',
      },
      {
        'id': 'STU-028',
        'name': 'Maria Kiplagat',
        'initials': 'MK',
        'owed': 25000,
        'paid': 35000,
        'status': 'ACTIVE',
      },
      {
        'id': 'STU-029',
        'name': 'Nina Kipkemboi',
        'initials': 'NK',
        'owed': 20000,
        'paid': 40000,
        'status': 'ACTIVE',
      },
      {
        'id': 'STU-030',
        'name': 'Oliver Kipchoge',
        'initials': 'OK',
        'owed': 8000,
        'paid': 52000,
        'status': 'ACTIVE',
      },
      {
        'id': 'STU-031',
        'name': 'Paula Kiplagat',
        'initials': 'PL',
        'owed': 0,
        'paid': 60000,
        'status': 'ACTIVE',
      },
      {
        'id': 'STU-032',
        'name': 'Quinn Kipkemboi',
        'initials': 'QK',
        'owed': 30000,
        'paid': 30000,
        'status': 'ACTIVE',
      },
    ],
    'FORM 4': [
      {
        'id': 'STU-033',
        'name': 'Rachel Kipchoge',
        'initials': 'RK',
        'owed': 0,
        'paid': 60000,
        'status': 'ACTIVE',
      },
      {
        'id': 'STU-034',
        'name': 'Samuel Kiplagat',
        'initials': 'SK',
        'owed': 15000,
        'paid': 45000,
        'status': 'ACTIVE',
      },
      {
        'id': 'STU-035',
        'name': 'Tasha Kipkemboi',
        'initials': 'TK',
        'owed': 22000,
        'paid': 38000,
        'status': 'ACTIVE',
      },
    ],
  };

  List<Map<String, dynamic>> _getFilteredStudents(
      List<Map<String, dynamic>> students) {
    if (_searchQuery.isEmpty) {
      return students;
    }
    return students
        .where((student) =>
            student['name']
                .toString()
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            student['id']
                .toString()
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()))
        .toList();
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

  void _showStudentDetails(Map<String, dynamic> student) {
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
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      body: SafeArea(
        child: Column(
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
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: _studentsByForm.entries.map((entry) {
                      final form = entry.key;
                      final students = entry.value;
                      final filteredStudents = _getFilteredStudents(students);
                      final isExpanded = _expandedForms[form] ?? false;

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
                                  final isOwing = student['owed'] > 0;

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
                                                color: _getAvatarColor(
                                                    student['initials']),
                                                borderRadius:
                                                    BorderRadius.circular(24),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  student['initials'],
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
                                                    student['name'],
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
                                                      const Text(
                                                        'ACTIVE',
                                                        style: TextStyle(
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

                                            // Financial Status
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  isOwing
                                                      ? '-Ksh ${student['owed']}'
                                                      : '+Ksh ${student['paid']}',
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
              ),
            ),

            // Load more button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.textGrey),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Load more...',
                    style: TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Student Details Bottom Sheet
class _StudentDetailsSheet extends StatelessWidget {
  final Map<String, dynamic> student;

  const _StudentDetailsSheet({required this.student});

  @override
  Widget build(BuildContext context) {
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
                    student['name'],
                    style: const TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    student['id'],
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

          // Details Grid
          Row(
            children: [
              Expanded(
                child: _DetailCard(
                  label: 'Outstanding',
                  value:
                      student['owed'] > 0 ? 'Ksh ${student['owed']}' : 'Ksh 0',
                  valueColor: student['owed'] > 0
                      ? AppColors.errorRed
                      : AppColors.successGreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DetailCard(
                  label: 'Paid',
                  value: 'Ksh ${student['paid']}',
                  valueColor: AppColors.successGreen,
                ),
              ),
            ],
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
