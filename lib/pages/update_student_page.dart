// lib/pages/update_student_page.dart

import 'package:fees_up/models/student_full.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/database_service.dart';
import '../utils/subject_selection_modal.dart';

class UpdateStudentPage extends StatefulWidget {
  final String studentId;
  final StudentFull? initialStudentData;

  const UpdateStudentPage({super.key, required this.studentId, this.initialStudentData});
  static const String routeName = '/update_student';

  @override
  State<UpdateStudentPage> createState() => _UpdateStudentPageState();
}

class _UpdateStudentPageState extends State<UpdateStudentPage> {
  final _formKey = GlobalKey<FormState>();
  
  // -- Controllers --
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _feeController = TextEditingController();
  
  // -- State variables --
  String _selectedGrade = 'FORM 1';
  DateTime _registrationDate = DateTime.now();
  
  // Initialize to a safe default (next month), will be overwritten by DB fetch
  DateTime _nextBillingDate = DateTime.now().add(const Duration(days: 30));
  
  String _billingType = 'monthly'; 
  bool _isActive = true;
  List<String> _selectedSubjects = [];
  bool _isSaving = false;

  // Grade Options
  final List<String> _grades = [
    'ECD A', 'ECD B',
    'GRADE 1', 'GRADE 2', 'GRADE 3', 'GRADE 4', 'GRADE 5', 'GRADE 6', 'GRADE 7',
    'FORM 1', 'FORM 2', 'FORM 3', 'FORM 4', 'LOWER 6', 'UPPER 6'
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _fetchLatestBillingDate(); // Fetch the specific billing date field
  }
  
  void _loadInitialData() {
    final s = widget.initialStudentData?.student;
    
    if (s != null) {
      _nameController.text = s.fullName ?? '';
      _contactController.text = s.parentContact ?? '';
      _feeController.text = s.defaultFee?.toStringAsFixed(2) ?? '0.00';
      
      _selectedGrade = s.grade ?? _grades.first;
      _registrationDate = s.registrationDate ?? DateTime.now();
      _billingType = s.billingType ?? 'monthly';
      _isActive = s.isActive;
      _selectedSubjects = s.subjects?.split(',').where((x) => x.isNotEmpty).toList() ?? [];
    }
  }

  // Fetch the billing_date separately in case StudentModel isn't updated yet
  Future<void> _fetchLatestBillingDate() async {
    final db = DatabaseService.instance;
    final data = await db.getStudentById(widget.studentId);
    if (data != null && data['billing_date'] != null) {
      setState(() {
        _nextBillingDate = DateTime.parse(data['billing_date'] as String);
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _feeController.dispose();
    super.dispose();
  }

  // --- Logic: Pick Registration Date ---
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _registrationDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _registrationDate = picked);
    }
  }

  // --- Logic: Pick Next Billing Date ---
  Future<void> _pickBillingDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _nextBillingDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)), // Allow retroactive fixes
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      // DISABLE 29, 30, 31 to ensure consistent monthly billing cycles
      selectableDayPredicate: (DateTime val) => val.day <= 28,
    );
    if (picked != null) {
      setState(() => _nextBillingDate = picked);
    }
  }

  // --- Logic: Select Subjects ---
  void _openSubjectPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SubjectSelectionModal(
        selectedSubjects: _selectedSubjects,
        onConfirmed: (List<String> newSelection) {
          setState(() => _selectedSubjects = newSelection);
        },
      ),
    );
  }

  // --- Logic: UPDATE Student ---
  Future<void> _updateStudent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final db = DatabaseService.instance;
      
      final defaultFee = double.tryParse(_feeController.text) ?? 0.0;

      // Data map containing fields to be updated
      final valuesToUpdate = {
        'full_name': _nameController.text.trim(),
        'parent_contact': _contactController.text.trim(),
        'grade': _selectedGrade,
        'registration_date': _registrationDate.toIso8601String(),
        'billing_date': _nextBillingDate.toIso8601String(), // Updated Billing Date
        'billing_type': _billingType,
        'default_fee': defaultFee,
        'is_active': _isActive ? 1 : 0,
        'subjects': _selectedSubjects.join(','), 
      };

      final updateCount = await db.update(
        'students', 
        valuesToUpdate, 
        'id = ?', 
        [widget.studentId]
      );

      if (mounted) {
        if (updateCount > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Student profile updated successfully')),
          );
          Navigator.pop(context, true); 
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No changes were saved.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating student: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Theme helpers
    final theme = Theme.of(context);
    
    // Styles
    final sectionHeaderStyle = TextStyle(
      fontSize: 13.0, 
      fontWeight: FontWeight.w700, 
      color: theme.colorScheme.primary, 
      letterSpacing: 1.1,
    );
    
    // Standardized Input Decoration (Outlined Box)
    final inputDecoration = BoxDecoration(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(12.0),
      border: Border.all(
        color: theme.colorScheme.outlineVariant,
        width: 1.0,
      ),
    );

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text('Edit Student: ${widget.initialStudentData?.student.fullName ?? widget.studentId}'),
        centerTitle: true,
        backgroundColor: theme.colorScheme.surface,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _updateStudent,
            child: Text(
              'SAVE',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _isSaving ? Colors.grey : theme.colorScheme.primary,
              ),
            ),
          )
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- PERSONAL INFORMATION ---
                  Text("PERSONAL INFORMATION", style: sectionHeaderStyle),
                  const SizedBox(height: 12),
                  
                  _buildInputContainer(
                    decoration: inputDecoration,
                    child: TextFormField(
                      controller: _nameController,
                      style: TextStyle(color: theme.colorScheme.onSurface),
                      decoration: _inputDecor(hint: "e.g. John Smith", label: "Full Name"),
                      validator: (v) => v == null || v.isEmpty ? 'Name is required' : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  _buildInputContainer(
                    decoration: inputDecoration,
                    child: TextFormField(
                      controller: _contactController,
                      style: TextStyle(color: theme.colorScheme.onSurface),
                      keyboardType: TextInputType.phone,
                      decoration: _inputDecor(
                        hint: "+263 77 123 4567", 
                        label: "Parent Contact",
                        icon: Icons.phone_outlined
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                  
                  // --- ACADEMIC SECTION ---
                  Text("ACADEMIC & SUBJECTS", style: sectionHeaderStyle),
                  const SizedBox(height: 12),

                  // Grade Dropdown
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: inputDecoration,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedGrade,
                        isExpanded: true,
                        dropdownColor: theme.colorScheme.surfaceContainer,
                        icon: Icon(Icons.arrow_drop_down, color: theme.colorScheme.onSurface),
                        items: _grades.map((g) => DropdownMenuItem(
                          value: g, 
                          child: Text(g, style: TextStyle(color: theme.colorScheme.onSurface))
                        )).toList(),
                        onChanged: (v) => setState(() => _selectedGrade = v!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Subject Selection Tile
                  GestureDetector(
                    onTap: _openSubjectPicker,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: inputDecoration,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Enrolled Subjects", 
                                style: TextStyle(
                                  color: theme.colorScheme.onSurfaceVariant, 
                                  fontSize: 16
                                )
                              ),
                              Icon(Icons.add_circle_outline, color: theme.colorScheme.primary),
                            ],
                          ),
                          if (_selectedSubjects.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _selectedSubjects.map((s) => Chip(
                                label: Text(s, style: TextStyle(fontSize: 12, color: theme.colorScheme.onPrimaryContainer)),
                                backgroundColor: theme.colorScheme.primaryContainer,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide.none),
                                labelPadding: const EdgeInsets.symmetric(horizontal: 2),
                                visualDensity: VisualDensity.compact,
                                onDeleted: () => setState(() => _selectedSubjects.remove(s)),
                                deleteIconColor: theme.colorScheme.onPrimaryContainer.withAlpha(128),
                              )).toList(),
                            )
                          ] else ...[
                            const SizedBox(height: 8),
                            Text("Tap to select core and elective subjects", 
                              style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(102), fontSize: 13, fontStyle: FontStyle.italic)),
                          ]
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Registration Date Picker
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: inputDecoration,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Registration Date", style: TextStyle(color: theme.colorScheme.onSurface)),
                          Row(
                            children: [
                              Text(
                                DateFormat('MMM dd, yyyy').format(_registrationDate),
                                style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                              ),
                              const SizedBox(width: 8),
                              Icon(Icons.calendar_today, size: 18, color: theme.colorScheme.onSurface.withAlpha(153)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // --- FINANCIALS ---
                  Text("FINANCIALS", style: sectionHeaderStyle),
                  const SizedBox(height: 12),

                  // Billing Frequency
                  Container(
                    decoration: inputDecoration,
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: ['termly', 'monthly', 'yearly'].map((type) {
                        final isSelected = _billingType == type;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _billingType = type),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                type.toUpperCase(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface.withAlpha(153),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      // Fee Amount
                      Expanded(
                        flex: 4,
                        child: _buildInputContainer(
                          decoration: inputDecoration,
                          child: TextFormField(
                            controller: _feeController,
                            style: TextStyle(color: theme.colorScheme.onSurface),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: _inputDecor(label: "Recurring Fee", prefix: "\$ "),
                            validator: (v) {
                              if (v != null && v.isNotEmpty && double.tryParse(v) == null) return 'Invalid';
                              return null;
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // Next Billing Date (Updateable)
                      Expanded(
                        flex: 5,
                        child: GestureDetector(
                          onTap: _pickBillingDate,
                          child: Container(
                            height: 60, // Match Text Field Height roughly
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: inputDecoration,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Next Bill Date", 
                                  style: TextStyle(fontSize: 11, color: Colors.grey)
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        DateFormat('MMM dd, yyyy').format(_nextBillingDate),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold, 
                                          color: theme.colorScheme.onSurface,
                                          fontSize: 13
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Icon(Icons.event_repeat, size: 16, color: theme.colorScheme.primary),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      "* Restricted to days 1-28 to prevent cycle errors.",
                      style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withAlpha(128)),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // --- STATUS ---
                  Text("SYSTEM STATUS", style: sectionHeaderStyle),
                  const SizedBox(height: 12),

                  Container(
                    decoration: inputDecoration,
                    child: SwitchListTile(
                      title: Text('Active Student', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w500)),
                      subtitle: Text('Currently enrolled in classes', style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(153), fontSize: 12)),
                      value: _isActive,
                      onChanged: (v) => setState(() => _isActive = v),
                      activeThumbColor: theme.colorScheme.primary,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // SAVE BUTTON
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _updateStudent,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: _isSaving 
                        ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: theme.colorScheme.onPrimary, strokeWidth: 2))
                        : const Text("SAVE CHANGES", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- UI Helpers ---
  Widget _buildInputContainer({required BoxDecoration decoration, required Widget child}) {
    return Container(decoration: decoration, child: child);
  }

  InputDecoration _inputDecor({required String label, String? hint, String? prefix, IconData? icon}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixText: prefix,
      suffixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
      border: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      labelStyle: const TextStyle(color: Colors.grey),
      hintStyle: TextStyle(color: Colors.grey.withAlpha(128)),
    );
  }
}