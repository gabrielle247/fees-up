// ignore_for_file: unused_field
import 'package:fees_up/data/constants/__zimsec_data.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fees_up/data/constants/app_colors.dart';
import 'package:fees_up/data/constants/app_strings.dart';

// =============================================================================
// 2. SCREEN IMPLEMENTATION
// =============================================================================
class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // --- Controllers ---
  // Personal
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _nationalIdController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  
  // Guardian
  final TextEditingController _guardianNameController = TextEditingController();
  final TextEditingController _guardianPhoneController = TextEditingController();
  final TextEditingController _guardianEmailController = TextEditingController();

  // Finance
  final TextEditingController _amountPaidController = TextEditingController();

  // --- State Variables ---
  String _gender = AppStrings.optMale;
  String _studentType = AppStrings.optDay;
  DateTime? _selectedDob;
  DateTime _admissionDate = DateTime.now();
  
  String _guardianRelationship = AppStrings.optFather;
  String? _selectedFeeStructureId;
  
  // Subjects Logic
  List<String> _selectedSubjects = [];

  // MOCK Data for Fee Structures (Replace with DB fetch)
  final List<Map<String, String>> _feeStructures = [
    {"id": "fs_01", "name": "Form 1 - Day Scholar"},
    {"id": "fs_02", "name": "Form 1 - Boarding"},
    {"id": "fs_03", "name": "Form 2 - Day Scholar"},
    {"id": "fs_04", "name": "A Level - Science"},
  ];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _nationalIdController.dispose();
    _dobController.dispose();
    _guardianNameController.dispose();
    _guardianPhoneController.dispose();
    _guardianEmailController.dispose();
    _amountPaidController.dispose();
    super.dispose();
  }

  // --- Date Pickers ---
  Future<void> _pickDate({required bool isDob}) async {
    final now = DateTime.now();
    final initial = isDob ? DateTime(2010) : now;
    final first = DateTime(1990);
    final last = DateTime(2030);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primaryBlue,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isDob) {
          _selectedDob = picked;
          _dobController.text = "${picked.day}/${picked.month}/${picked.year}";
        } else {
          _admissionDate = picked;
        }
      });
    }
  }

  // --- Subject Selector Dialog ---
  void _openSubjectSelector() async {
    final List<String>? result = await showDialog(
      context: context,
      builder: (ctx) => _SubjectSelectionDialog(
        initialSelection: _selectedSubjects,
      ),
    );

    if (result != null) {
      setState(() => _selectedSubjects = result);
    }
  }

  // --- Save Logic ---
  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // 1. Serialize Subjects to JSON
      //final String subjectsJson = jsonEncode(_selectedSubjects);

      // 2. Construct Student Object (Using your Model structure)
      // Note: This is where you would call your Repository
      /*
      final newStudent = Student(
        id: const Uuid().v4(),
        schoolId: "current_school_id", // Get from Auth Provider
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        nationalId: _nationalIdController.text.trim().isEmpty ? null : _nationalIdController.text.trim(),
        dob: _selectedDob,
        gender: _gender,
        status: "ACTIVE", // Default
        enrollmentDate: DateTime.now(),
        studentType: _studentType,
        admissionDate: _admissionDate,
        subjects: subjectsJson, // <--- JSON Stored Here
        
        guardianName: _guardianNameController.text.trim(),
        guardianPhone: _guardianPhoneController.text.trim(),
        guardianEmail: _guardianEmailController.text.trim(),
        guardianRelationship: _guardianRelationship,
        
        feesOwed: 0.0, // Calculated later based on Fee Structure - Amount Paid
        isArchived: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // 3. Handle Initial Payment (If Amount > 0)
      if (_amountPaidController.text.isNotEmpty) {
         // Create Payment Record
      }
      */

      await Future.delayed(const Duration(seconds: 2)); // Simulate Network

      if (mounted) {
        context.pop(); // Go back to list
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Student Registered Successfully")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.pageTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ================= PERSONAL INFO =================
                      _buildSectionHeader(context, AppStrings.secPersonal, Icons.person_outline),
                      
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _firstNameController,
                              label: AppStrings.lblFirstName,
                              required: true,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _lastNameController,
                              label: AppStrings.lblLastName,
                              required: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      _buildTextField(
                        controller: _nationalIdController,
                        label: AppStrings.lblNationalId,
                        icon: Icons.badge_outlined,
                      ),
                      const SizedBox(height: 16),

                      // DOB & Gender Row
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _pickDate(isDob: true),
                              child: AbsorbPointer(
                                child: _buildTextField(
                                  controller: _dobController,
                                  label: AppStrings.lblDob,
                                  hint: AppStrings.hintDob,
                                  icon: Icons.calendar_today_outlined,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      _buildLabel(context, AppStrings.lblGender),
                      _buildSegmentedControl(
                        values: [AppStrings.optMale, AppStrings.optFemale],
                        selectedValue: _gender,
                        onChanged: (val) => setState(() => _gender = val),
                      ),

                      const SizedBox(height: 32),

                      // ================= ACADEMIC INFO =================
                      _buildSectionHeader(context, AppStrings.secAcademic, Icons.school_outlined),

                      _buildLabel(context, AppStrings.lblStudentType),
                      _buildSegmentedControl(
                        values: [AppStrings.optDay, AppStrings.optBoarding],
                        selectedValue: _studentType,
                        onChanged: (val) => setState(() => _studentType = val),
                      ),
                      const SizedBox(height: 16),

                      // Subjects Selector
                      _buildLabel(context, AppStrings.lblSubjects),
                      GestureDetector(
                        onTap: _openSubjectSelector,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.cardTheme.color,
                            border: Border.all(color: theme.dividerColor),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.menu_book_outlined, color: theme.primaryColor),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _selectedSubjects.isEmpty
                                      ? AppStrings.hintSubjects
                                      : "${_selectedSubjects.length} subjects selected",
                                  style: _selectedSubjects.isEmpty 
                                      ? textTheme.bodyMedium?.copyWith(color: theme.hintColor)
                                      : textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Icon(Icons.arrow_forward_ios, size: 14, color: theme.hintColor),
                            ],
                          ),
                        ),
                      ),
                      if (_selectedSubjects.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _selectedSubjects.map((s) => Chip(
                            label: Text(s, style: const TextStyle(fontSize: 12)),
                            backgroundColor: AppColors.primaryBlue.withAlpha(20),
                            side: BorderSide.none,
                            onDeleted: () {
                              setState(() => _selectedSubjects.remove(s));
                            },
                          )).toList(),
                        ),
                      ],

                      const SizedBox(height: 32),

                      // ================= FINANCIALS =================
                      _buildSectionHeader(context, AppStrings.secFinance, Icons.monetization_on_outlined),

                      _buildLabel(context, AppStrings.lblFeeStruct),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: theme.cardTheme.color,
                          border: Border.all(color: theme.dividerColor),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedFeeStructureId,
                            hint: const Text(AppStrings.hintFeeStruct),
                            isExpanded: true,
                            items: _feeStructures.map((fs) {
                              return DropdownMenuItem(
                                value: fs['id'],
                                child: Text(fs['name']!),
                              );
                            }).toList(),
                            onChanged: (val) => setState(() => _selectedFeeStructureId = val),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _amountPaidController,
                        label: AppStrings.lblAmountPaid,
                        hint: AppStrings.hintAmount,
                        icon: Icons.payments_outlined,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        suffixText: AppStrings.currency,
                      ),

                      const SizedBox(height: 32),

                      // ================= GUARDIAN INFO =================
                      _buildSectionHeader(context, AppStrings.secGuardian, Icons.family_restroom_outlined),

                      _buildTextField(
                        controller: _guardianNameController,
                        label: AppStrings.lblGName,
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _guardianPhoneController,
                              label: AppStrings.lblGPhone,
                              keyboardType: TextInputType.phone,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel(context, AppStrings.lblGRelation),
                                Container(
                                  height: 56, // Match text field height
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: theme.cardTheme.color,
                                    border: Border.all(color: theme.dividerColor),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _guardianRelationship,
                                      isExpanded: true,
                                      items: [
                                        AppStrings.optFather,
                                        AppStrings.optMother,
                                        AppStrings.optGuardian,
                                      ].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                                      onChanged: (v) => setState(() => _guardianRelationship = v!),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      _buildTextField(
                        controller: _guardianEmailController,
                        label: AppStrings.lblGEmail,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
            
            // --- Action Button ---
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(AppStrings.btnRegister),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helpers ---
  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primaryBlue),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }

  Widget _buildLabel(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? icon,
    bool required = false,
    TextInputType? keyboardType,
    String? suffixText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(context, required ? "$label *" : label),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: required 
              ? (v) => v == null || v.isEmpty ? AppStrings.errRequired : null
              : null,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon != null ? Icon(icon) : null,
            suffixText: suffixText,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildSegmentedControl({
    required List<String> values,
    required String selectedValue,
    required Function(String) onChanged,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: values.map((val) {
          final isSelected = selectedValue == val;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(val),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryBlue : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  val,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// =============================================================================
// 3. SUBJECT SELECTION DIALOG (Advanced)
// =============================================================================
class _SubjectSelectionDialog extends StatefulWidget {
  final List<String> initialSelection;

  const _SubjectSelectionDialog({required this.initialSelection});

  @override
  State<_SubjectSelectionDialog> createState() => _SubjectSelectionDialogState();
}

class _SubjectSelectionDialogState extends State<_SubjectSelectionDialog> {
  late List<String> _tempSelected;

  @override
  void initState() {
    super.initState();
    _tempSelected = List.from(widget.initialSelection);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AlertDialog(
      title: const Text(AppStrings.dlgSubjectTitle),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: ListView.separated(
          itemCount: ZimsecData.allSubjects.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (ctx, idx) {
            final subject = ZimsecData.allSubjects[idx];
            final isSelected = _tempSelected.contains(subject);
            
            return CheckboxListTile(
              title: Text(subject, style: theme.textTheme.bodyLarge),
              value: isSelected,
              activeColor: AppColors.primaryBlue,
              onChanged: (bool? val) {
                setState(() {
                  if (val == true) {
                    _tempSelected.add(subject);
                  } else {
                    _tempSelected.remove(subject);
                  }
                });
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(AppStrings.dlgCancel),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _tempSelected),
          child: const Text(AppStrings.dlgConfirm),
        ),
      ],
    );
  }
}