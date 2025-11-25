import 'package:fees_up/models/subjects.dart';
import 'package:flutter/material.dart';

class SubjectChipSelect extends StatefulWidget {
  const SubjectChipSelect({
    required this.allSubjects,
    required this.selectedSubjects,
    required this.onSelectionChanged,
    super.key,
  });

  final List<String> allSubjects;
  final List<String> selectedSubjects;
  final ValueChanged<List<String>> onSelectionChanged;

  @override
  State<SubjectChipSelect> createState() => _SubjectChipSelectState();
}

class _SubjectChipSelectState extends State<SubjectChipSelect> {
  late List<String> effectiveSubjects;

  List<String> selected = [];

  List<String> get availableSubjects {
    final selectedSet = Set.from(selected);
    return effectiveSubjects.where((s) => !selectedSet.contains(s)).toList();
  }

  @override
  void initState() {
    super.initState();
    effectiveSubjects = widget.allSubjects.isEmpty
        ? ZimsecSubject.allNames
        : widget.allSubjects;
    selected = List.from(widget.selectedSubjects);
  }

  var title = const TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600);
  var subTitle = const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w300);
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Selected Subjects", style: subTitle),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: selected
              .map(
                (subject) => Chip(
                  label: Text(subject),
                  onDeleted: () => setState(() {
                    selected.remove(subject);
                    widget.onSelectionChanged(selected);
                  }),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.tertiary,
              width: 1,
            ),
          ),
          child: InkWell(
            onTap: () => _showOptions(context),
            child: const Row(
              children: [
                Expanded(
                  child: Text(
                    "Tap to select",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                Icon(Icons.arrow_drop_down, size: 24, color: Colors.grey),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("Select Subject", style: TextStyle(fontSize: 18)),
          ),
          SizedBox(
            height: 300, // or use MediaQuery to make it dynamic
            child: ListView(
              children: availableSubjects
                  .map(
                    (subject) => ListTile(
                      title: Text(subject),
                      onTap: () {
                        setState(() {
                          selected.add(subject);
                          widget.onSelectionChanged(selected);
                        });
                        Navigator.pop(ctx);
                      },
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
