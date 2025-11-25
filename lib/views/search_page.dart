import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

// Logic
import '../view_models/search_view_model.dart';
import '../view_models/dashboard_view_model.dart'; 

// Utils
import '../utils/student_card.dart';
import '../utils/edit_student_dialog.dart'; // 👈 Added Import

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SearchViewModel()..loadStudents(),
      child: const _SearchView(),
    );
  }
}

class _SearchView extends StatefulWidget {
  const _SearchView();

  @override
  State<_SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<_SearchView> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SearchViewModel>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: TextField(
          controller: _controller,
          focusNode: _focusNode,
          onChanged: vm.onSearchChanged,
          style: TextStyle(color: colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: "Search name or ID...",
            hintStyle: TextStyle(color: Colors.grey.shade600),
            border: InputBorder.none,
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      _controller.clear();
                      vm.onSearchChanged("");
                    },
                  )
                : null,
          ),
        ),
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(context, vm),
    );
  }

  Widget _buildBody(BuildContext context, SearchViewModel vm) {
    // 1. Empty State
    if (vm.results.isEmpty && vm.isQueryEmpty) {
      return const Center(
        child: Text("No students registered yet.", style: TextStyle(color: Colors.grey)),
      );
    }

    // 2. No Results
    if (vm.results.isEmpty && !vm.isQueryEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off_rounded, size: 64, color: Colors.grey.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            const Text("No matching students found", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    // 3. Results List
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: vm.results.length,
      itemBuilder: (context, index) {
        final student = vm.results[index];

        // Visual Logic
        final statusText = student.isActive ? "Active" : "Inactive";
        final statusKey = student.isActive ? "paid" : "overdue"; 

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: StudentCard(
            student.studentName,
            statusText,
            statusKey,
            // onTap: Navigate to Ledger
            () async {
              await context.push(
                '/studentLedger',
                extra: {
                  'studentId': student.studentId,
                  'studentName': student.studentName,
                  'enrolledSubjects': student.subjects,
                },
              );
              if (context.mounted) {
                Provider.of<DashboardViewModel>(context, listen: false).loadDashboard();
              }
            },
            // 🛑 NEW: Enable Editing from Search
            onLongPress: () async {
              // 1. Trigger the Global Edit Dialog
              final result = await showDialog<bool>(
                context: context,
                builder: (_) => EditStudentDialog(student: student),
              );

              if (result == true && context.mounted) {
                // 2. Refresh Global Dashboard (Background)
                Provider.of<DashboardViewModel>(context, listen: false).loadDashboard();
                
                // 3. Refresh Search Results (Foreground)
                // We reload the list from DB to get the new name/fees
                await vm.loadStudents();
                // We re-apply the search query so the user doesn't lose their place
                vm.onSearchChanged(_controller.text);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Student updated successfully")),
                );
              }
            },
          ),
        );
      },
    );
  }
}
