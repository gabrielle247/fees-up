// lib/pages/home_screen.dart // Fixed import
import 'package:fees_up/pages/classes_view.dart';
import 'package:fees_up/pages/finances_page.dart';
import 'package:fees_up/pages/register_student_page.dart';
import 'package:fees_up/pages/settings_page.dart';
import 'package:fees_up/pages/student_ledger_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For SystemNavigator
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
// import 'package:flutter_riverpod/legacy.dart'; // Removed legacy if not needed, but kept if you use it elsewhere.

// --- Providers & Models ---
import '../providers/dashboard_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/student_provider.dart';
import '../models/dashboard_summary.dart';
import '../models/student_full.dart';
import '../widgets/ensure_profile_banner.dart';
import '../providers/profile_provider.dart';
import '../services/sync_data_service.dart';

// -----------------------------------------------------------
// STATE MANAGEMENT
// -----------------------------------------------------------

final selectedGradeProvider = StateProvider.autoDispose<String>((ref) => 'All');
final selectedTabIndexProvider = StateProvider.autoDispose<int>((ref) => 0);
final searchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

// -----------------------------------------------------------
// MAIN HOME SCREEN (DASHBOARD)
// -----------------------------------------------------------

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});
  static const String routeName = '/home';
  static bool _didKickoffSync = false; // ensure single kickoff per app session

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fire-and-forget sync once when the home screen first builds after login
    if (!_didKickoffSync) {
      _didKickoffSync = true;
      // Defer to next microtask to keep build cheap
      Future.microtask(() => SyncDataService.instance.triggerSmartSync());
    }

    final selectedIndex = ref.watch(selectedTabIndexProvider);

    Widget currentBody;
    
    // Switch for Navigation Tabs
    if (selectedIndex == 0) {
      currentBody = const _DashboardView();
    } else if (selectedIndex == 1) {
      currentBody = const ClassesView();
    } else if (selectedIndex == 2) {
      currentBody = const FinancesPage();
    } else {
      // Placeholder for Settings (Index 3)
      currentBody = SettingsPage();
    }

    return Scaffold(
      body: Column(
        children: [
          const EnsureProfileBanner(),
          Expanded(child: currentBody),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) {
          ref.read(selectedTabIndexProvider.notifier).state = index;
        },
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school), 
            label: 'Classes'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Finances',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------
// CORE DASHBOARD VIEW
// -----------------------------------------------------------

class _DashboardView extends ConsumerWidget {
  const _DashboardView();

  // Helper to group students by their grade/form
  Map<String, List<StudentFull>> _groupStudentsByGrade(
    List<StudentFull> filteredStudents,
  ) {
    final Map<String, List<StudentFull>> grouped = {};
    for (final s in filteredStudents) {
      final grade = s.student.grade != null && s.student.grade!.isNotEmpty
          ? s.student.grade!
          : 'Unassigned';

      if (!grouped.containsKey(grade)) {
        grouped[grade] = [];
      }
      grouped[grade]!.add(s);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Watch Data
    final summaryAsync = ref.watch(dashboardSummaryProvider);
    final studentListAsync = ref.watch(studentListStreamProvider);

    // 2. Watch Filters
    final selectedGrade = ref.watch(selectedGradeProvider);
    final searchQuery = ref.watch(searchQueryProvider).toLowerCase();

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: const Text('Fees Up Dashboard'),
          floating: true,
          pinned: true,
          actions: [
            // Logout Button (Clears session)
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: () async {
                await ref.read(authNotifierProvider.notifier).signOut();
              },
            ),
            // Quit App Button (Closes window)
            IconButton(
              icon: const Icon(Icons.power_settings_new),
              tooltip: 'Quit App',
              onPressed: () {
                SystemChannels.platform.invokeMethod('SystemNavigator.pop');
              },
            ),
            const SizedBox(width: 16),
          ],
        ),

        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          sliver: studentListAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, s) => SliverFillRemaining(
              child: Center(
                child: Text(
                  'Error: $e',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
            data: (allStudents) {
              // --- 3. FILTERING LOGIC ---
              // Filter by Search Query First
              final searchedStudents = allStudents.where((s) {
                final name = (s.student.fullName ?? '').toLowerCase();
                final id = s.student.id.toLowerCase();
                return name.contains(searchQuery) || id.contains(searchQuery);
              }).toList();

              // Group the filtered results
              final groupedStudents = _groupStudentsByGrade(searchedStudents);

              // Determine available grades based on ALL data (so chips don't disappear while searching)
              final allGradesGrouped = _groupStudentsByGrade(allStudents);
              final availableGrades = [
                'All',
                ...allGradesGrouped.keys.toList()..sort(),
              ];

              // Filter by Grade Chip
              final visibleGrades = selectedGrade == 'All'
                  ? groupedStudents.keys.toList()
                  : [selectedGrade];

              visibleGrades.sort();

              return SliverList(
                delegate: SliverChildListDelegate([
                  // -- Summary Cards (Rowed & Shrinked) --
                  _buildSummaryMetrics(context, summaryAsync),

                  const SizedBox(height: 24),

                  // -- Header & Search --
                  Text(
                    'Student Directory',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const _SearchBarAndAddButton(),
                  const SizedBox(height: 12),

                  // -- Dynamic Filter Chips --
                  _GradeFilterChips(availableGrades: availableGrades),
                  const SizedBox(height: 16),

                  // -- List Content --
                  if (searchedStudents.isEmpty)
                    const _EmptyListWidget()
                  else
                    ...visibleGrades.map((grade) {
                      final students = groupedStudents[grade] ?? [];
                      if (students.isEmpty) return const SizedBox.shrink();

                      return _GradeExpansionTile(
                        gradeTitle: grade,
                        students: students,
                      );
                    }),

                  // Add bottom padding
                  const SizedBox(height: 80),
                ]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryMetrics(
    BuildContext context,
    AsyncValue<DashboardSummary> summaryAsync,
  ) {
    return summaryAsync.when(
      loading: () => const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (summary) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Active Students
          Expanded(
            child: DashboardCard(
              title: 'Active',
              value: summary.activeStudents.toString(),
              color: Colors.blue.shade400,
              icon: Icons.person,
            ),
          ),
          const SizedBox(width: 8), // Small gap
          // Total Owed
          Expanded(
            child: DashboardCard(
              title: 'Owed',
              value: '\$${summary.totalFeesOwed.toStringAsFixed(0)}',
              color: Colors.red.shade400,
              icon: Icons.money_off,
            ),
          ),
          const SizedBox(width: 8), // Small gap
          // Total Paid
          Expanded(
            child: DashboardCard(
              title: 'Paid',
              value: '\$${summary.totalFeesPaid.toStringAsFixed(0)}',
              color: Colors.green.shade400,
              icon: Icons.check_circle,
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------
// DIRECTORY COMPONENTS
// -----------------------------------------------------------

class _SearchBarAndAddButton extends ConsumerWidget {
  const _SearchBarAndAddButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: (value) {
              ref.read(searchQueryProvider.notifier).state = value;
            },
            decoration: InputDecoration(
              hintText: 'Search by name or ID...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 10,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          height: 48,
          width: 48,
          child: FloatingActionButton(
            heroTag: 'add_student',
            elevation: 2,
            onPressed: () async {
              // Guard: Ensure a school exists before allowing registration
              final school = await ref.read(currentSchoolProvider.future);
              if (school == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please complete school setup before adding students.')),
                );
                return;
              }

              // 1. Wait for result from RegisterStudentPage
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const RegisterStudentPage(),
                ),
              );

              // 2. Refresh Data Providers
              ref.invalidate(dashboardSummaryProvider);
              ref.invalidate(studentListStreamProvider);
            },
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _GradeFilterChips extends ConsumerWidget {
  final List<String> availableGrades;
  const _GradeFilterChips({required this.availableGrades});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedGrade = ref.watch(selectedGradeProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: availableGrades.map((grade) {
          final isSelected = selectedGrade == grade;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(grade),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  ref.read(selectedGradeProvider.notifier).state = grade;
                }
              },
              selectedColor: Theme.of(context).colorScheme.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _GradeExpansionTile extends StatelessWidget {
  final String gradeTitle;
  final List<StudentFull> students;

  const _GradeExpansionTile({required this.gradeTitle, required this.students});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      color: Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest.withAlpha(50),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 12.0),
        title: Text(
          gradeTitle,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        initiallyExpanded: true,
        children: students.map((student) {
          return InkWell(
            onTap: () {
              // Navigate to Ledger
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      StudentLedgerPage(studentId: student.student.id),
                ),
              );
            },
            child: _StudentListItem(studentFull: student),
          );
        }).toList(),
      ),
    );
  }
}

class _StudentListItem extends StatelessWidget {
  final StudentFull studentFull;

  const _StudentListItem({required this.studentFull});

  @override
  Widget build(BuildContext context) {
    final student = studentFull.student;
    // Tolerance of 0.01 for floating point errors
    final isOwed = studentFull.owed > 0.01;

    final statusColor = isOwed
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.secondary;
    final statusText = isOwed ? 'Owed' : 'Paid';
    final balanceText = isOwed
        ? '-\$${studentFull.owed.toStringAsFixed(2)}'
        : '\$0.00';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: statusColor.withAlpha(51),
            child: Text(
              (student.fullName != null && student.fullName!.isNotEmpty)
                  ? student.fullName![0].toUpperCase()
                  : '?',
              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.fullName ?? 'Unknown Name',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  student.grade ?? 'No Grade',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.white54),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                balanceText,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyListWidget extends StatelessWidget {
  const _EmptyListWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          const Icon(Icons.search_off, size: 48, color: Colors.white24),
          const SizedBox(height: 12),
          Text(
            'No matching students',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Try adjusting your search or add a new student.',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.white54),
          ),
        ],
      ),
    );
  }
}

// 5. Reusable Card Widget (Compact Version)
class DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const DashboardCard({
    super.key,
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}