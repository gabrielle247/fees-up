// lib/utils/edit_student_dialog.dart

import 'package:flutter/material.dart';
import '../models/student.dart';
import '../models/subjects.dart'; // Ensure you have this for ZimsecSubject.allNames
import '../services/local_storage_service.dart';
import '../utils/sized_box_normal.dart';

class EditStudentDialog extends StatefulWidget {
  final Student student;

  const EditStudentDialog({super.key, required this.student});

  @override
  State<EditStudentDialog> createState() => _EditStudentDialogState();
}

class _EditStudentDialogState extends State<EditStudentDialog> {
  final LocalStorageService _storage = LocalStorageService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _contactController;
  late TextEditingController _feeController;
  
  // 🛑 NEW: State for subjects
  late List<String> _selectedSubjects;
  late bool _isActive;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.student.studentName);
    _contactController = TextEditingController(text: widget.student.parentContact);
    _feeController = TextEditingController(text: widget.student.defaultMonthlyFee.toString());
    _isActive = widget.student.isActive;
    
    // Initialize list from student data
    _selectedSubjects = List<String>.from(widget.student.subjects);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _feeController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final updatedStudent = widget.student.copyWith(
        studentName: _nameController.text.trim(),
        parentContact: _contactController.text.trim(),
        frequency: 'Monthly',
        defaultMonthlyFee: double.tryParse(_feeController.text) ?? widget.student.defaultMonthlyFee,
        isActive: _isActive,
        // 🛑 NEW: Save the updated list
        subjects: _selectedSubjects, 
      );

      // This handles the database update + sync queue logic we built earlier
      await _storage.updateStudentAndFee(updatedStudent);

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save student: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- HEADER ---
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: colorScheme.primary.withAlpha(51), // ~20%
                      child: Text(
                        widget.student.studentName.isNotEmpty 
                          ? widget.student.studentName.substring(0, 1).toUpperCase()
                          : "?",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Edit Student",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            widget.student.studentId,
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 32),

                // --- ACTIVE STATUS SWITCH ---
                Container(
                  decoration: BoxDecoration(
                    color: _isActive 
                        ? colorScheme.secondary.withAlpha(25) 
                        : colorScheme.error.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isActive ? colorScheme.secondary : colorScheme.error,
                      width: 1,
                    ),
                  ),
                  child: SwitchListTile(
                    title: Text(
                      _isActive ? "Active Student" : "Inactive (Archived)",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: _isActive ? colorScheme.secondary : colorScheme.error,
                      ),
                    ),
                    subtitle: const Text(
                      "Inactive students won't generate new monthly bills.",
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    value: _isActive,
                    activeThumbColor: colorScheme.secondary,
                    onChanged: (val) => setState(() => _isActive = val),
                  ),
                ),
                
                const SizedBoxNormal(20, 0),

                // --- EDITABLE FIELDS ---
                _buildLabel("Full Name"),
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration(colorScheme, Icons.person_outline),
                  validator: (val) => val!.isEmpty ? "Name required" : null,
                ),
                
                const SizedBoxNormal(16, 0),

                _buildLabel("Parent Contact"),
                TextFormField(
                  controller: _contactController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration(colorScheme, Icons.phone_outlined),
                ),

                const SizedBoxNormal(16, 0),

                _buildLabel("Monthly Fee (\$)"),
                TextFormField(
                  controller: _feeController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration(colorScheme, Icons.attach_money),
                  validator: (val) => val!.isEmpty ? "Fee required" : null,
                ),

                const SizedBoxNormal(16, 0),

                // --- 🛑 NEW: SUBJECT SELECTOR INTEGRATION ---
                _buildLabel("Enrolled Subjects"),
                _buildSubjectSelector(colorScheme),

                const SizedBoxNormal(24, 0),

                // --- ACTIONS ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _isSaving ? null : _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20, height: 20, 
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text("Save Changes", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------------------
  // 🎨 UI HELPERS
  // ----------------------------------------------------------------

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0, left: 4.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500),
      ),
    );
  }

  InputDecoration _inputDecoration(ColorScheme colors, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, size: 20, color: Colors.grey),
      filled: true,
      // Matching your design system (alpha ~30 for subtle BG)
      fillColor: colors.surfaceContainerHighest.withAlpha(76), 
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: colors.primary, width: 1.5),
      ),
    );
  }

  // 🛑 The Streamlined Subject Selector Widget
  Widget _buildSubjectSelector(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Trigger Button (Styled like a TextField)
        InkWell(
          onTap: () => _showSubjectPicker(context),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withAlpha(76),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.class_outlined, size: 20, color: Colors.grey),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Tap to add subjects...",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ),
                Icon(Icons.arrow_drop_down_rounded, color: Colors.grey),
              ],
            ),
          ),
        ),
        
        // 2. Selected Chips Display
        if (_selectedSubjects.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedSubjects.map((subject) {
              return Chip(
                label: Text(
                  subject, 
                  style: TextStyle(fontSize: 12, color: colorScheme.onSurface),
                ),
                backgroundColor: colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: colorScheme.tertiary.withAlpha(100)),
                ),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () {
                  setState(() {
                    _selectedSubjects.remove(subject);
                  });
                },
              );
            }).toList(),
          ),
        ]
      ],
    );
  }

  // 🛑 The Bottom Sheet Picker Logic
  void _showSubjectPicker(BuildContext context) {
    // Use allNames from your ZimsecSubject model, filtered by what's already selected
    final availableSubjects = ZimsecSubject.allNames
        .where((s) => !_selectedSubjects.contains(s))
        .toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      showDragHandle: true,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("Select Subject", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          if (availableSubjects.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32.0),
              child: Text("All available subjects selected.", style: TextStyle(color: Colors.grey)),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: availableSubjects.length,
                itemBuilder: (ctx, index) {
                  final subject = availableSubjects[index];
                  return ListTile(
                    leading: const Icon(Icons.book_outlined),
                    title: Text(subject),
                    onTap: () {
                      setState(() {
                        _selectedSubjects.add(subject);
                      });
                      Navigator.pop(ctx);
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}