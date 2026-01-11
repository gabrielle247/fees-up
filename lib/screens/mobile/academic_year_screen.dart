// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

// -----------------------------------------------------------------------------
// IMPORTS (Replace with your actual paths)
// -----------------------------------------------------------------------------
import 'package:fees_up/data/constants/app_colors.dart';

class AcademicSetupScreen extends StatefulWidget {
  const AcademicSetupScreen({super.key});

  @override
  State<AcademicSetupScreen> createState() => _AcademicSetupScreenState();
}

class _AcademicSetupScreenState extends State<AcademicSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final bool _isLoading = false;

  // ---------------------------------------------------------------------------
  // MOCK DATA (Placeholders for PowerSync)
  // ---------------------------------------------------------------------------
  final List<Map<String, dynamic>> _years = [
    {
      'id': '1',
      'name': '2025 Academic Year',
      'start_date': DateTime(2025, 1, 1),
      'end_date': DateTime(2025, 12, 31),
      'is_active': true,
      'is_locked': false,
      'terms': [
        {
          'id': 't1',
          'name': 'Term 1',
          'start': DateTime(2025, 1, 10),
          'end': DateTime(2025, 4, 5),
          'is_current': false
        },
        {
          'id': 't2',
          'name': 'Term 2',
          'start': DateTime(2025, 5, 5),
          'end': DateTime(2025, 8, 5),
          'is_current': true
        },
      ]
    },
    {
      'id': '2',
      'name': '2024 Academic Year',
      'start_date': DateTime(2024, 1, 1),
      'end_date': DateTime(2024, 12, 31),
      'is_active': false,
      'is_locked': true, // Historical data locked
      'terms': []
    }
  ];

  // ---------------------------------------------------------------------------
  // ACTIONS
  // ---------------------------------------------------------------------------
  Future<void> _handleAddYear() async {
    // Placeholder: Show dialog, then save to DB
    await showDialog(
      context: context,
      builder: (ctx) => _AddYearDialog(
        onSave: (name, start, end) {
          setState(() {
            _years.insert(0, {
              'id': DateTime.now().toIso8601String(),
              'name': name,
              'start_date': start,
              'end_date': end,
              'is_active': false,
              'is_locked': false,
              'terms': [],
            });
          });
        },
      ),
    );
  }

  Future<void> _handleAddTerm(String yearId) async {
    // Placeholder: Show dialog, then save to DB
    await showDialog(
      context: context,
      builder: (ctx) => _AddTermDialog(
        onSave: (name, start, end) {
          setState(() {
            final yearIndex = _years.indexWhere((y) => y['id'] == yearId);
            if (yearIndex != -1) {
              (_years[yearIndex]['terms'] as List).add({
                'id': DateTime.now().toIso8601String(),
                'name': name,
                'start': start,
                'end': end,
                'is_current': false,
              });
            }
          });
        },
      ),
    );
  }

  void _toggleActiveYear(String id) {
    // Logic to ensure only one year is active at a time
    setState(() {
      for (var year in _years) {
        year['is_active'] = (year['id'] == id);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Active Academic Year Updated')),
    );
  }

  // ---------------------------------------------------------------------------
  // UI BUILDER
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceDarkGrey,
        title: const Text('Academic Setup', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _handleAddYear,
        backgroundColor: AppColors.primaryBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Year', style: TextStyle(color: Colors.white)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _years.length,
              separatorBuilder: (ctx, index) => const SizedBox(height: 16),
              itemBuilder: (ctx, index) {
                final year = _years[index];
                return _buildYearCard(year);
              },
            ),
    );
  }

  Widget _buildYearCard(Map<String, dynamic> year) {
    final bool isActive = year['is_active'];
    final bool isLocked = year['is_locked'];
    final List terms = year['terms'];
    final dateFormat = DateFormat('MMM d, yyyy');

    return Card(
      color: AppColors.surfaceDarkGrey,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: isActive ? AppColors.primaryBlue : Colors.transparent,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: isActive,
          iconColor: AppColors.textGrey,
          collapsedIconColor: AppColors.textGrey,
          title: Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: isActive ? AppColors.primaryBlue : AppColors.textGrey,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      year['name'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${dateFormat.format(year['start_date'])} - ${dateFormat.format(year['end_date'])}',
                      style: const TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (isActive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withAlpha(50),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.primaryBlue),
                  ),
                  child: const Text(
                    'ACTIVE',
                    style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          children: [
            const Divider(color: AppColors.surfaceLightGrey, height: 1),
            // Actions Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: isLocked ? null : () => _handleAddTerm(year['id']),
                    icon: Icon(Icons.add, size: 16, color: isLocked ? Colors.grey : AppColors.primaryBlue),
                    label: Text(
                      'Add Term',
                      style: TextStyle(color: isLocked ? Colors.grey : AppColors.primaryBlue),
                    ),
                  ),
                  if (!isActive && !isLocked)
                    TextButton(
                      onPressed: () => _toggleActiveYear(year['id']),
                      child: const Text(
                        'Set as Active',
                        style: TextStyle(color: Colors.greenAccent),
                      ),
                    ),
                ],
              ),
            ),
            // Terms List
            if (terms.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'No terms added yet.',
                  style: TextStyle(color: AppColors.textGrey, fontStyle: FontStyle.italic),
                ),
              )
            else
              ...terms.map((term) => _buildTermItem(term)),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildTermItem(Map<String, dynamic> term) {
    final dateFormat = DateFormat('MMM d');
    final bool isCurrent = term['is_current'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundBlack,
        borderRadius: BorderRadius.circular(8),
        border: isCurrent 
            ? Border.all(color: Colors.greenAccent.withAlpha(100)) 
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    term['name'],
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  if (isCurrent) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.circle, color: Colors.greenAccent, size: 8),
                  ]
                ],
              ),
              Text(
                '${dateFormat.format(term['start'])} - ${dateFormat.format(term['end'])}',
                style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
              ),
            ],
          ),
          // Placeholder for term actions menu
          const Icon(Icons.more_vert, color: AppColors.textGrey, size: 18),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// HELPER DIALOGS
// -----------------------------------------------------------------------------

class _AddYearDialog extends StatefulWidget {
  final Function(String name, DateTime start, DateTime end) onSave;

  const _AddYearDialog({required this.onSave});

  @override
  State<_AddYearDialog> createState() => _AddYearDialogState();
}

class _AddYearDialogState extends State<_AddYearDialog> {
  final _nameController = TextEditingController();
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 365));

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceDarkGrey,
      title: const Text('New Academic Year', style: TextStyle(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Year Name (e.g. 2026)',
              labelStyle: TextStyle(color: AppColors.textGrey),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.textGrey)),
            ),
          ),
          const SizedBox(height: 16),
          _DateSelector(
            label: 'Start Date',
            date: _startDate,
            onTap: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: _startDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2030),
              );
              if (d != null) setState(() => _startDate = d);
            },
          ),
          const SizedBox(height: 8),
          _DateSelector(
            label: 'End Date',
            date: _endDate,
            onTap: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: _endDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2030),
              );
              if (d != null) setState(() => _endDate = d);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: AppColors.textGrey)),
        ),
        TextButton(
          onPressed: () {
            if (_nameController.text.isNotEmpty) {
              widget.onSave(_nameController.text, _startDate, _endDate);
              Navigator.pop(context);
            }
          },
          child: const Text('Create', style: TextStyle(color: AppColors.primaryBlue)),
        ),
      ],
    );
  }
}

class _AddTermDialog extends StatefulWidget {
  final Function(String name, DateTime start, DateTime end) onSave;

  const _AddTermDialog({required this.onSave});

  @override
  State<_AddTermDialog> createState() => _AddTermDialogState();
}

class _AddTermDialogState extends State<_AddTermDialog> {
  final _nameController = TextEditingController();
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 90));

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceDarkGrey,
      title: const Text('Add Term', style: TextStyle(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Term Name (e.g. Term 1)',
              labelStyle: TextStyle(color: AppColors.textGrey),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.textGrey)),
            ),
          ),
          const SizedBox(height: 16),
          _DateSelector(
            label: 'Start Date',
            date: _startDate,
            onTap: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: _startDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2030),
              );
              if (d != null) setState(() => _startDate = d);
            },
          ),
          const SizedBox(height: 8),
          _DateSelector(
            label: 'End Date',
            date: _endDate,
            onTap: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: _endDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2030),
              );
              if (d != null) setState(() => _endDate = d);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: AppColors.textGrey)),
        ),
        TextButton(
          onPressed: () {
            if (_nameController.text.isNotEmpty) {
              widget.onSave(_nameController.text, _startDate, _endDate);
              Navigator.pop(context);
            }
          },
          child: const Text('Add', style: TextStyle(color: AppColors.primaryBlue)),
        ),
      ],
    );
  }
}

class _DateSelector extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;

  const _DateSelector({required this.label, required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 16, color: AppColors.textGrey),
            const SizedBox(width: 8),
            Text('$label: ', style: const TextStyle(color: AppColors.textGrey)),
            Text(
              DateFormat('MMM d, yyyy').format(date),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}