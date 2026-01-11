import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// -----------------------------------------------------------------------------
// IMPORTS
// -----------------------------------------------------------------------------
import 'package:fees_up/data/constants/app_colors.dart';
import 'package:fees_up/data/constants/app_routes.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  // ---------------------------------------------------------------------------
  // MOCK DATA (Matches your screenshot)
  // ---------------------------------------------------------------------------
  final List<Map<String, dynamic>> _allStudents = [
    {
      'id': '1',
      'name': 'Jane Cooper',
      'adm': 'ADM-2023-001',
      'grade': 'Grade 4-B',
      'balance': 1200.00, // Owes money
      'image_url': null, // Placeholder for avatar
    },
    {
      'id': '2',
      'name': 'Robert Fox',
      'adm': 'ADM-2023-042',
      'grade': 'Grade 2-A',
      'balance': 450.00, // Owes money
      'image_url': null,
    },
    {
      'id': '3',
      'name': 'Esther Howard',
      'adm': 'ADM-2023-015',
      'grade': 'Grade 5-C',
      'balance': 0.00, // Fully Paid
      'image_url': null,
    },
    {
      'id': '4',
      'name': 'Cameron Williamson',
      'adm': 'ADM-2023-112',
      'grade': 'Grade 3-A',
      'balance': 920.00, // Owes money
      'image_url': null,
    },
    {
      'id': '5',
      'name': 'Leslie Alexander',
      'adm': 'ADM-2023-088',
      'grade': 'Grade 1-B',
      'balance': 150.00, // Owes money
      'image_url': null,
    },
     {
      'id': '6',
      'name': 'Jenny Wilson',
      'adm': 'ADM-2023-099',
      'grade': 'Grade 6-A',
      'balance': 0.00, // Fully Paid
      'image_url': null,
    },
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // UI BUILDER
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    // Filter Logic
    final displayList = _allStudents.where((s) {
      final name = s['name'].toString().toLowerCase();
      final adm = s['adm'].toString().toLowerCase();
      return name.contains(_searchQuery) || adm.contains(_searchQuery);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundBlack,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.white),
          onPressed: () {
            // Check if we can pop, otherwise go to dashboard
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.dashboard);
            }
          },
        ),
        title: const Text(
          'Student Directory',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune, color: Colors.white), // Filter icon
            onPressed: () {
              // TODO: Open Filter Modal
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Filter options coming soon')),
              );
            },
          ),
        ],
      ),
      floatingActionButton: SizedBox(
        height: 50,
        child: FloatingActionButton.extended(
          onPressed: () => context.push('${AppRoutes.students}/${AppRoutes.addStudent}'),
          backgroundColor: AppColors.primaryBlue,
          elevation: 4,
          icon: const Icon(Icons.person_add, color: Colors.white, size: 20),
          label: const Text(
            'Add Student',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: Column(
        children: [
          // -------------------------------------------------------------------
          // SEARCH BAR
          // -------------------------------------------------------------------
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search name or admission number...',
                hintStyle: const TextStyle(color: AppColors.textGrey),
                prefixIcon: const Icon(Icons.search, color: AppColors.textGrey),
                filled: true,
                fillColor: AppColors.surfaceDarkGrey,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
                ),
              ),
            ),
          ),

          // -------------------------------------------------------------------
          // STUDENT LIST
          // -------------------------------------------------------------------
          Expanded(
            child: displayList.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 80), // Bottom padding for FAB
                    itemCount: displayList.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final student = displayList[index];
                      return _buildStudentCard(student);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: AppColors.textGrey.withAlpha(100)),
          const SizedBox(height: 16),
          const Text(
            'No students found',
            style: TextStyle(color: AppColors.textGrey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student) {
    final double balance = student['balance'];
    final bool isPaidUp = balance <= 0;

    return InkWell(
      onTap: () {
        // Navigate to View Student Profile
        context.push('${AppRoutes.students}/view/${student['id']}');
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceDarkGrey,
          borderRadius: BorderRadius.circular(16),
          // Optional: Add subtle border to distinguish cards in dark mode
          border: Border.all(color: AppColors.surfaceLightGrey.withAlpha(20), width: 0.5),
        ),
        child: Row(
          children: [
            // AVATAR
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.primaryBlue.withAlpha(30),
              backgroundImage: student['image_url'] != null 
                  ? NetworkImage(student['image_url']) 
                  : null,
              child: student['image_url'] == null
                  ? Text(
                      _getInitials(student['name']),
                      style: const TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),

            // DETAILS
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student['name'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${student['adm']} • ${student['grade']}',
                    style: const TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // STATUS INDICATOR
                  if (isPaidUp)
                    const Text(
                      'Fully Paid',
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    )
                  else
                    RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Owes: ',
                            style: TextStyle(color: AppColors.textGrey, fontSize: 13),
                          ),
                          TextSpan(
                            text: '\$${balance.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // ARROW
            const Icon(
              Icons.chevron_right,
              color: AppColors.textGrey,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '';
    final parts = name.split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }
}