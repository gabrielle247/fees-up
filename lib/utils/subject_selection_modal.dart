import 'package:flutter/material.dart';
import '../models/subjects.dart'; // Ensure this points to your ZimsecSubject file

class SubjectSelectionModal extends StatefulWidget {
  final List<String> selectedSubjects;
  final ValueChanged<List<String>> onConfirmed;

  const SubjectSelectionModal({
    super.key,
    required this.selectedSubjects,
    required this.onConfirmed,
  });

  @override
  State<SubjectSelectionModal> createState() => _SubjectSelectionModalState();
}

class _SubjectSelectionModalState extends State<SubjectSelectionModal> {
  late List<String> _tempSelected;
  String _searchQuery = '';

  // CORE / POPULAR Subjects in Zimbabwe
  final List<String> _coreSubjects = [
    'Mathematics',
    'English Language',
    'Combined Science',
    'Shona',
    'Ndebele',
    'Heritage Studies',
    'Agriculture',
    'Computer Science',
    'Geography'
  ];

  @override
  void initState() {
    super.initState();
    _tempSelected = List.from(widget.selectedSubjects);
  }

  @override
  Widget build(BuildContext context) {
    final allSubjects = ZimsecSubject.allNames;
    
    // Filter logic
    final filteredSubjects = allSubjects.where((s) {
      return s.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    // Split into Core and Others for display
    final coreMatches = filteredSubjects.where((s) => _coreSubjects.contains(s)).toList();
    final otherMatches = filteredSubjects.where((s) => !_coreSubjects.contains(s)).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle Bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey.withAlpha(77),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Select Subjects",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  widget.onConfirmed(_tempSelected);
                  Navigator.pop(context);
                },
                child: const Text("Done"),
              )
            ],
          ),
          
          const SizedBox(height: 10),

          // Search Bar
          TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: "Search subjects...",
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(77),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            ),
          ),

          const SizedBox(height: 16),

          // List
          Expanded(
            child: ListView(
              children: [
                if (_searchQuery.isEmpty && coreMatches.isNotEmpty) ...[
                  _buildSectionHeader("CORE / POPULAR"),
                  ...coreMatches.map(_buildCheckboxTile),
                  const Divider(height: 32),
                  _buildSectionHeader("ALL SUBJECTS"),
                ],
                ...otherMatches.map(_buildCheckboxTile),
                
                if (coreMatches.isEmpty && otherMatches.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Center(child: Text("No subjects found")),
                  )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildCheckboxTile(String subject) {
    final isSelected = _tempSelected.contains(subject);
    return CheckboxListTile(
      value: isSelected,
      title: Text(subject),
      activeColor: Theme.of(context).colorScheme.primary,
      contentPadding: EdgeInsets.zero,
      onChanged: (bool? value) {
        setState(() {
          if (value == true) {
            _tempSelected.add(subject);
          } else {
            _tempSelected.remove(subject);
          }
        });
      },
    );
  }
}