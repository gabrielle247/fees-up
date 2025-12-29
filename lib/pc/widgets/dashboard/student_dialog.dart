import 'dart:math';
// ignore: unnecessary_import
import 'dart:ui'; 

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/subjects.dart';
import '../../../../data/services/database_service.dart';

class StudentDialog extends ConsumerStatefulWidget {
  final String schoolId;
  
  const StudentDialog({
    super.key, 
    required this.schoolId,
  });

  @override
  ConsumerState<StudentDialog> createState() => _StudentDialogState();
}

class _StudentDialogState extends ConsumerState<StudentDialog> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _dbService = DatabaseService();

  // -- Controllers --
  final _fullNameController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _parentContactController = TextEditingController();
  final _addressController = TextEditingController();
  final _feeController = TextEditingController();
  final _initialPayController = TextEditingController();

  // -- State --
  DateTime _dob = DateTime(2010, 1, 1);
  final DateTime _registrationDate = DateTime.now();
  String _selectedGender = 'Male';
  String _selectedGrade = 'FORM 1';
  String _billingType = 'monthly';
  List<String> _selectedSubjects = [];
  bool _isLoading = false;

  // -- Constants --
  final List<String> _genders = ['Male', 'Female'];
  final List<String> _grades = [
    'ECD A', 'ECD B', 'GRADE 1', 'GRADE 2', 'GRADE 3', 'GRADE 4',
    'GRADE 5', 'GRADE 6', 'GRADE 7', 'FORM 1', 'FORM 2', 'FORM 3',
    'FORM 4', 'LOWER 6', 'UPPER 6'
  ];

  @override
  void initState() {
    super.initState();
    _generateNewId();
  }

  void _generateNewId() {
    final random = Random();
    final idNumber = 100000000 + random.nextInt(900000000); 
    _studentIdController.text = "STU-$idNumber";
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _studentIdController.dispose();
    _parentContactController.dispose();
    _addressController.dispose();
    _feeController.dispose();
    _initialPayController.dispose();
    super.dispose();
  }

  // --- LOGIC (Preserved Exactly) ---

  Future<void> _saveStudent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final db = _dbService;
      final newStudentUuid = const Uuid().v4();
      
      // 1. Prepare ID
      String displayId = _studentIdController.text.trim();
      if (displayId.isEmpty) {
        _generateNewId();
        displayId = _studentIdController.text;
      }

      final defaultFee = double.tryParse(_feeController.text.replaceAll(',', '')) ?? 0.0;
      final initialPay = double.tryParse(_initialPayController.text.replaceAll(',', '')) ?? 0.0;

      // 2. Billing Date Logic
      String? billingDateStr;
      if (_billingType == 'monthly') {
        billingDateStr = DateFormat('yyyy-MM-dd').format(_registrationDate);
      }

      // 3. Insert Student
      final studentData = {
        'id': newStudentUuid,
        'school_id': widget.schoolId,
        'student_id': displayId,
        'full_name': _fullNameController.text.trim(),
        'grade': _selectedGrade,
        'parent_contact': _parentContactController.text.trim(),
        'address': _addressController.text.trim(),
        'date_of_birth': DateFormat('yyyy-MM-dd').format(_dob),
        'gender': _selectedGender,
        'billing_type': _billingType,
        'default_fee': defaultFee,
        'subjects': _selectedSubjects.join(','),
        'registration_date': DateTime.now().toIso8601String(),
        'billing_date': billingDateStr,
        'enrollment_date': DateTime.now().toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'is_active': 1,
        'owed_total': 0.0, 
        'paid_total': initialPay,
        'photo_consent': 0,
      };

      await db.insert('students', studentData);

      // 4. Auto-Billing
      String? generatedBillId;
      if (_billingType == 'monthly' && defaultFee > 0) {
        generatedBillId = await _attemptAutoBilling(newStudentUuid, defaultFee);
      }

      // 5. Initial Payment
      if (initialPay > 0) {
        await db.insert('payments', {
          'id': const Uuid().v4(),
          'school_id': widget.schoolId,
          'student_id': newStudentUuid,
          'bill_id': generatedBillId,
          'amount': initialPay,
          'date_paid': DateFormat('yyyy-MM-dd').format(DateTime.now()),
          'category': 'Tuition',
          'method': 'Cash', 
          'payer_name': _fullNameController.text.trim(), 
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Student registered successfully!'),
            backgroundColor: AppColors.successGreen,
          ),
        );
        Navigator.of(context).pop(); 
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.errorRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<String?> _attemptAutoBilling(String studentId, double amount) async {
    try {
      final allYears = await _dbService.db.getAll('SELECT * FROM school_years WHERE school_id = ?', [widget.schoolId]);
      Map<String, dynamic>? activeYear;
      
      for (var y in allYears) {
        final start = DateTime.parse(y['start_date']);
        final end = DateTime.parse(y['end_date']);
        if (_registrationDate.isAfter(start.subtract(const Duration(days: 1))) && 
            _registrationDate.isBefore(end.add(const Duration(days: 1)))) {
          activeYear = y;
          break;
        }
      }

      if (activeYear == null) return null;

      final months = await _dbService.db.getAll('SELECT * FROM school_year_months WHERE school_year_id = ?', [activeYear['id']]);
      Map<String, dynamic>? activeMonth;

      for (var m in months) {
        final start = DateTime.parse(m['start_date']);
        final end = DateTime.parse(m['end_date']);
        if (_registrationDate.isAfter(start.subtract(const Duration(days: 1))) && 
            _registrationDate.isBefore(end.add(const Duration(days: 1)))) {
          activeMonth = m;
          break;
        }
      }

      if (activeMonth == null) return null;

      final billId = const Uuid().v4();
      await _dbService.insert('bills', {
        'id': billId,
        'school_id': widget.schoolId,
        'student_id': studentId,
        'title': 'Tuition - ${activeMonth['name']}',
        'total_amount': amount,
        'is_paid': 0,
        'bill_type': 'monthly',
        'billing_cycle_start': activeMonth['start_date'],
        'billing_cycle_end': activeMonth['end_date'],
        'month_year': activeMonth['name'],
        'school_year_id': activeYear['id'],
        'month_index': activeMonth['month_index'],
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      return billId;
    } catch (e) {
      debugPrint("Auto-billing failed (silent): $e");
      return null;
    }
  }

  // --- SUB-DIALOGS ---

  void _openSubjectSelector() {
    showDialog(
      context: context,
      builder: (context) {
        final allSubjects = ZimsecSubject.allNames;
        List<String> tempSelected = List.from(_selectedSubjects);
        String searchQuery = "";
        
        return StatefulBuilder(
          builder: (context, setState) {
            final filteredSubjects = allSubjects.where((s) => s.toLowerCase().contains(searchQuery.toLowerCase())).toList();

            return AlertDialog(
              backgroundColor: AppColors.surfaceGrey,
              title: const Text("Select Subjects", style: TextStyle(color: AppColors.textWhite)),
              content: SizedBox(
                width: 400,
                height: 500,
                child: Column(
                  children: [
                    TextField(
                      onChanged: (val) => setState(() => searchQuery = val),
                      style: const TextStyle(color: AppColors.textWhite),
                      decoration: InputDecoration(
                        hintText: "Search subjects...",
                        hintStyle: const TextStyle(color: AppColors.textWhite38),
                        prefixIcon: const Icon(Icons.search, color: AppColors.textWhite54),
                        filled: true,
                        fillColor: Colors.black12,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredSubjects.length,
                        itemBuilder: (context, index) {
                          final subject = filteredSubjects[index];
                          final isSelected = tempSelected.contains(subject);
                          return CheckboxListTile(
                            title: Text(subject, style: const TextStyle(color: AppColors.textWhite70)),
                            value: isSelected,
                            activeColor: AppColors.primaryBlue,
                            checkColor: AppColors.textWhite,
                            contentPadding: EdgeInsets.zero,
                            onChanged: (val) {
                              setState(() {
                                if (val == true) {
                                  tempSelected.add(subject);
                                } else {
                                  tempSelected.remove(subject);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel", style: TextStyle(color: AppColors.textGrey)),
                ),
                ElevatedButton(
                  onPressed: () {
                    this.setState(() => _selectedSubjects = tempSelected);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
                  child: const Text("Confirm", style: TextStyle(color: AppColors.textWhite)),
                ),
              ],
            );
          }
        );
      },
    );
  }

  // --- UI BUILD ---

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        width: 1100,
        height: 800,
        decoration: BoxDecoration(
          color: AppColors.backgroundBlack,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.surfaceLightGrey),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 20, offset: const Offset(0, 10))
          ],
        ),
        child: Column(
          children: [
            // --- HEADER ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.2), 
                      borderRadius: BorderRadius.circular(8)
                    ),
                    child: const Icon(Icons.person_add, color: AppColors.primaryBlue),
                  ),
                  const SizedBox(width: 16),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Register Student", style: TextStyle(color: AppColors.textWhite, fontSize: 18, fontWeight: FontWeight.bold)),
                      Text("Add new student details to the database", style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: AppColors.textGrey),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.divider),

            // --- MAIN CONTENT ---
            Expanded(
              child: Row(
                children: [
                  // --- LEFT: FORM (Flex 5) ---
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Form(
                        key: _formKey,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("STUDENT DETAILS", style: TextStyle(color: AppColors.textGrey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                              const SizedBox(height: 24),

                              _buildLabel("Full Name", AppColors.textWhite),
                              _buildTextField(
                                controller: _fullNameController,
                                hint: "e.g. Gabriel",
                                prefixIcon: Icons.person_outline,
                              ),
                              const SizedBox(height: 16),

                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildLabel("Student ID", AppColors.textWhite),
                                        _buildTextField(
                                          controller: _studentIdController,
                                          hint: "STU-...",
                                          suffixIcon: Icons.refresh,
                                          onSuffixTap: _generateNewId,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildLabel("Grade", AppColors.textWhite),
                                        _buildDropdown(
                                          value: _selectedGrade,
                                          items: _grades,
                                          onChanged: (v) => setState(() => _selectedGrade = v!),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildLabel("Date of Birth", AppColors.textWhite),
                                        _buildDatePicker(context, _dob, (d) => setState(() => _dob = d)),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildLabel("Gender", AppColors.textWhite),
                                        _buildDropdown(
                                          value: _selectedGender,
                                          items: _genders,
                                          onChanged: (v) => setState(() => _selectedGender = v!),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              const Text("CONTACT & FINANCIAL", style: TextStyle(color: AppColors.textGrey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                              const SizedBox(height: 24),

                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildLabel("Parent Contact", AppColors.textWhite),
                                        _buildTextField(
                                          controller: _parentContactController,
                                          hint: "+263 7...",
                                          prefixIcon: Icons.phone_outlined,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildLabel("Billing Type", AppColors.textWhite),
                                        Container(
                                          height: 52, // Match input height
                                          decoration: BoxDecoration(
                                            color: AppColors.surfaceGrey,
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: AppColors.surfaceLightGrey),
                                          ),
                                          padding: const EdgeInsets.all(4),
                                          child: Row(
                                            children: ['monthly', 'termly'].map((type) {
                                              final isSelected = _billingType == type;
                                              return Expanded(
                                                child: GestureDetector(
                                                  onTap: () => setState(() => _billingType = type),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: isSelected ? AppColors.primaryBlue : Colors.transparent,
                                                      borderRadius: BorderRadius.circular(6),
                                                    ),
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      type.toUpperCase(),
                                                      style: TextStyle(
                                                        fontSize: 12, 
                                                        fontWeight: FontWeight.bold, 
                                                        color: isSelected ? AppColors.textWhite : AppColors.textGrey
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              _buildLabel("Address", AppColors.textWhite),
                              _buildTextField(
                                controller: _addressController,
                                hint: "Street address...",
                                prefixIcon: Icons.location_on_outlined,
                              ),
                              const SizedBox(height: 16),

                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildLabel("Tuition Fee", AppColors.textWhite),
                                        _buildTextField(
                                          controller: _feeController,
                                          hint: "0.00",
                                          prefix: "\$ ",
                                          isNumber: true,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildLabel("Initial Payment", AppColors.textWhite),
                                        _buildTextField(
                                          controller: _initialPayController,
                                          hint: "0.00",
                                          prefix: "\$ ",
                                          isNumber: true,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              _buildLabel("Subjects", AppColors.textWhite),
                              InkWell(
                                onTap: _openSubjectSelector,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceGrey,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppColors.surfaceLightGrey),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _selectedSubjects.isEmpty ? "Select Subjects..." : "${_selectedSubjects.length} subjects selected",
                                        style: TextStyle(color: _selectedSubjects.isEmpty ? AppColors.textWhite54 : AppColors.textWhite),
                                      ),
                                      const Icon(Icons.arrow_drop_down, color: AppColors.textWhite54),
                                    ],
                                  ),
                                ),
                              ),
                              if (_selectedSubjects.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: _selectedSubjects.take(5).map((s) => Chip(
                                    label: Text(s, style: const TextStyle(fontSize: 10, color: AppColors.textWhite)),
                                    backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.2),
                                    padding: EdgeInsets.zero,
                                    side: BorderSide.none,
                                  )).toList(),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const VerticalDivider(width: 1, color: AppColors.divider),

                  // --- RIGHT: LIST (Flex 4) ---
                  Expanded(
                    flex: 4,
                    child: Container(
                      color: AppColors.surfaceDarkGrey, 
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("RECENTLY ADDED", style: TextStyle(color: AppColors.textGrey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                              StreamBuilder<List<Map<String, dynamic>>>(
                                stream: _dbService.watchStudents(widget.schoolId), 
                                builder: (context, snapshot) {
                                  final count = snapshot.data?.length ?? 0;
                                  return Text("$count Total", style: const TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold));
                                }
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Expanded(
                            child: StreamBuilder<List<Map<String, dynamic>>>(
                              stream: _dbService.db.watch('SELECT * FROM students WHERE school_id = ? ORDER BY created_at DESC', parameters: [widget.schoolId]),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                                final students = snapshot.data ?? [];
                                if (students.isEmpty) return const Center(child: Text("No students yet.", style: TextStyle(color: AppColors.textGrey)));

                                return ListView.separated(
                                  itemCount: students.length,
                                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final s = students[index];
                                    final name = s['full_name'] ?? 'Unknown';
                                    final id = s['student_id'] ?? 'N/A';
                                    final grade = s['grade'] ?? 'N/A';
                                    
                                    return Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceGrey, 
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                                      ),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
                                            child: Text(
                                              name.isNotEmpty ? name[0].toUpperCase() : '?',
                                              style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(name, style: const TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold)),
                                                const SizedBox(height: 2),
                                                Text("$id • $grade", style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const Divider(height: 1, color: AppColors.divider),

            // --- FOOTER ---
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("Cancel", style: TextStyle(color: AppColors.textWhite70)),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _saveStudent,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      foregroundColor: AppColors.textWhite,
                    ),
                    icon: _isLoading 
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textWhite)) 
                      : const Icon(Icons.check, size: 18),
                    label: Text(_isLoading ? "Saving..." : "Save Student", style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildLabel(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: TextStyle(color: color.withValues(alpha: 0.9), fontSize: 14, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    String? prefix, IconData? prefixIcon, IconData? suffixIcon, VoidCallback? onSuffixTap,
    bool isNumber = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
      style: const TextStyle(color: AppColors.textWhite),
      decoration: InputDecoration(
        filled: true, 
        fillColor: AppColors.surfaceGrey, 
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.textWhite.withValues(alpha: 0.3)),
        prefixText: prefix, prefixStyle: const TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppColors.textWhite54, size: 20) : null,
        suffixIcon: suffixIcon != null 
          ? GestureDetector(onTap: onSuffixTap, child: Icon(suffixIcon, color: AppColors.textWhite54, size: 20)) 
          : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.surfaceLightGrey)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.surfaceLightGrey)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildDropdown({
    required String value, required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceGrey, borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.surfaceLightGrey),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: AppColors.surfaceGrey, 
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textWhite54),
          isExpanded: true, 
          style: const TextStyle(color: AppColors.textWhite),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context, DateTime initial, Function(DateTime) onPicked) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: initial,
          firstDate: DateTime(1990),
          lastDate: DateTime(2030),
          builder: (context, child) => Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: const ColorScheme.dark(
                primary: AppColors.primaryBlue, 
                onPrimary: AppColors.textWhite, 
                surface: AppColors.surfaceGrey
              ),
            ),
            child: child!,
          ),
        );
        if (picked != null) onPicked(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceGrey, borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.surfaceLightGrey),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(DateFormat('MMM dd, yyyy').format(initial), style: const TextStyle(color: AppColors.textWhite)),
            const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.textWhite54),
          ],
        ),
      ),
    );
  }
}