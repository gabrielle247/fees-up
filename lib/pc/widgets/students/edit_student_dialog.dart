import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/safe_data.dart';
import '../../../../data/models/subjects.dart';
import '../../../../data/services/database_service.dart';
import 'forms/contact_info_form.dart';
import 'forms/enrollment_form.dart';
import 'forms/form_helpers.dart';
import 'forms/personal_info_form.dart';

class EditStudentDialog extends ConsumerStatefulWidget {
  final Map<String, dynamic> studentData;
  final String schoolId;

  const EditStudentDialog({
    super.key,
    required this.studentData,
    required this.schoolId,
  });

  @override
  ConsumerState<EditStudentDialog> createState() => _EditStudentDialogState();
}

class _EditStudentDialogState extends ConsumerState<EditStudentDialog> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _dbService = DatabaseService();

  // -- Controllers --
  late TextEditingController _fullNameController;
  late TextEditingController _studentIdController;
  late TextEditingController _parentContactController;
  late TextEditingController _emergencyContactController;
  late TextEditingController _addressController;
  late TextEditingController _feeController;
  late TextEditingController _medicalNotesController;

  // -- State --
  late DateTime _dob;
  late DateTime _registrationDate;
  late DateTime _enrollmentDate;
  late DateTime _billingDate;
  late String _selectedGender;
  late String _selectedGrade;
  late String _selectedBillingType;
  late String _selectedTerm;
  List<String> _selectedSubjects = [];
  bool _isActive = true;
  bool _photoConsent = false;
  bool _isLoading = false;

  // -- Constants --
  final List<String> _genders = ['Male', 'Female'];
  final List<String> _grades = [
    'ECD A',
    'ECD B',
    'GRADE 1',
    'GRADE 2',
    'GRADE 3',
    'GRADE 4',
    'GRADE 5',
    'GRADE 6',
    'GRADE 7',
    'FORM 1',
    'FORM 2',
    'FORM 3',
    'FORM 4',
    'LOWER 6',
    'UPPER 6'
  ];
  final List<String> _billingTypes = ['monthly', 'termly'];
  final List<String> _terms = ['Term 1', 'Term 2', 'Term 3', 'Term 4'];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _fullNameController =
        TextEditingController(text: widget.studentData['full_name'] ?? '');
    _studentIdController =
        TextEditingController(text: widget.studentData['student_id'] ?? '');
    _parentContactController =
        TextEditingController(text: widget.studentData['parent_contact'] ?? '');
    _emergencyContactController = TextEditingController(
        text: widget.studentData['emergency_contact_name'] ?? '');
    _addressController =
        TextEditingController(text: widget.studentData['address'] ?? '');
    _feeController = TextEditingController(
        text: (widget.studentData['default_fee'] ?? 0).toString());
    _medicalNotesController =
        TextEditingController(text: widget.studentData['medical_notes'] ?? '');

    // Parse subjects string into list (🛡️ Safe parsing)
    final String subjectsStr = widget.studentData['subjects'] ?? '';
    _selectedSubjects = subjectsStr.isNotEmpty
        ? subjectsStr
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList()
        : [];

    // Parse dates (🛡️ Issue #7: Safe date parsing)
    _dob = SafeData.parseDate(
      widget.studentData['date_of_birth'],
      fallback: DateTime(2010, 1, 1),
    );

    _registrationDate = SafeData.parseDate(
      widget.studentData['registration_date'],
      fallback: DateTime.now(),
    );

    _enrollmentDate = SafeData.parseDate(
      widget.studentData['enrollment_date'],
      fallback: DateTime.now(),
    );

    _billingDate = SafeData.parseDate(
      widget.studentData['billing_date'],
      fallback: DateTime.now(),
    );

    _selectedGender = widget.studentData['gender'] ?? 'Male';
    // Ensure selected grade is valid, otherwise default to FORM 1
    final rawGrade = widget.studentData['grade'];
    _selectedGrade = _grades.contains(rawGrade) ? rawGrade : 'FORM 1';

    _selectedBillingType = widget.studentData['billing_type'] ?? 'monthly';
    _selectedTerm = widget.studentData['term_id'] ?? 'Term 1';
    _isActive = SafeData.parseInt(widget.studentData['is_active']) == 1;
    _photoConsent = SafeData.parseInt(widget.studentData['photo_consent']) == 1;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _studentIdController.dispose();
    _parentContactController.dispose();
    _emergencyContactController.dispose();
    _addressController.dispose();
    _feeController.dispose();
    _medicalNotesController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final db = _dbService;
      final studentId = widget.studentData['id'];

      // 🛡️ Issue #5: Field-level validation
      final fullName = SafeData.sanitize(_fullNameController.text);
      final parentContact = SafeData.sanitize(_parentContactController.text);
      final emergencyContact =
          SafeData.sanitize(_emergencyContactController.text);
      final address = SafeData.sanitize(_addressController.text);
      final medicalNotes = SafeData.sanitize(_medicalNotesController.text);
      final defaultFee =
          SafeData.parseDouble(_feeController.text.replaceAll(',', ''), 0.0);

      // Validate critical fields
      if (fullName.isEmpty || fullName.length < 3) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Full name must be at least 3 characters'),
              backgroundColor: AppColors.errorRed,
            ),
          );
        }
        setState(() => _isLoading = false);
        return;
      }

      if (parentContact.isNotEmpty && !SafeData.isValidPhone(parentContact)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enter a valid phone number'),
              backgroundColor: AppColors.errorRed,
            ),
          );
        }
        setState(() => _isLoading = false);
        return;
      }

      // 🛡️ Issue #12: Sanitized update data (ALL schema fields)
      final updateData = {
        'full_name': fullName,
        'parent_contact': parentContact,
        'emergency_contact_name': emergencyContact,
        'address': address,
        'medical_notes': medicalNotes,
        'subjects': _selectedSubjects.join(','),
        'date_of_birth': DateFormat('yyyy-MM-dd').format(_dob),
        'registration_date': DateFormat('yyyy-MM-dd').format(_registrationDate),
        'enrollment_date': DateFormat('yyyy-MM-dd').format(_enrollmentDate),
        'billing_date': DateFormat('yyyy-MM-dd').format(_billingDate),
        'gender': _selectedGender,
        'grade': _selectedGrade,
        'billing_type': _selectedBillingType,
        'term_id': _selectedTerm,
        'default_fee': defaultFee,
        'photo_consent': _photoConsent ? 1 : 0,
        'is_active': _isActive ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await db.update('students', studentId, updateData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Student updated successfully!'),
            backgroundColor: AppColors.successGreen,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- SUB-DIALOGS (Subject Selector) ---
  void _openSubjectSelector() {
    showDialog(
      context: context,
      builder: (context) {
        final allSubjects = ZimsecSubject.allNames;
        List<String> tempSelected = List.from(_selectedSubjects);
        String searchQuery = "";

        return StatefulBuilder(builder: (context, setState) {
          final filteredSubjects = allSubjects
              .where((s) => s.toLowerCase().contains(searchQuery.toLowerCase()))
              .toList();

          return AlertDialog(
            backgroundColor: AppColors.surfaceGrey,
            title: const Text("Select Subjects",
                style: TextStyle(color: AppColors.textWhite)),
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
                      prefixIcon: const Icon(Icons.search,
                          color: AppColors.textWhite54),
                      filled: true,
                      fillColor: Colors.black12,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none),
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
                          title: Text(subject,
                              style: const TextStyle(
                                  color: AppColors.textWhite70)),
                          value: isSelected,
                          fillColor: WidgetStateProperty.all(
                            AppColors.primaryBlue,
                          ),
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
                child: const Text("Cancel",
                    style: TextStyle(color: AppColors.textGrey)),
              ),
              ElevatedButton(
                onPressed: () {
                  this.setState(() => _selectedSubjects = tempSelected);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue),
                child: const Text("Confirm",
                    style: TextStyle(color: AppColors.textWhite)),
              ),
            ],
          );
        });
      },
    );
  }

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
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.edit, color: AppColors.primaryBlue),
                  ),
                  const SizedBox(width: 16),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Edit Student Profile",
                        style: TextStyle(
                          color: AppColors.textWhite,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Update student details",
                        style: TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 13,
                        ),
                      ),
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

            // Content
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
                              PersonalInfoForm(
                                fullNameController: _fullNameController,
                                studentIdController: _studentIdController,
                                medicalNotesController: _medicalNotesController,
                                selectedGrade: _selectedGrade,
                                dob: _dob,
                                selectedGender: _selectedGender,
                                selectedSubjects: _selectedSubjects,
                                grades: _grades,
                                genders: _genders,
                                onGradeChanged: (v) =>
                                    setState(() => _selectedGrade = v!),
                                onDobChanged: (d) => setState(() => _dob = d),
                                onGenderChanged: (v) =>
                                    setState(() => _selectedGender = v!),
                                onSelectSubjects: _openSubjectSelector,
                              ),
                              const SizedBox(height: 24),
                              ContactInfoForm(
                                addressController: _addressController,
                                feeController: _feeController,
                              ),
                              const SizedBox(height: 24),
                              EnrollmentForm(
                                registrationDate: _registrationDate,
                                enrollmentDate: _enrollmentDate,
                                billingDate: _billingDate,
                                selectedTerm: _selectedTerm,
                                selectedBillingType: _selectedBillingType,
                                terms: _terms,
                                billingTypes: _billingTypes,
                                onRegistrationDateChanged: (d) =>
                                    setState(() => _registrationDate = d),
                                onEnrollmentDateChanged: (d) =>
                                    setState(() => _enrollmentDate = d),
                                onBillingDateChanged: (d) =>
                                    setState(() => _billingDate = d),
                                onTermChanged: (v) =>
                                    setState(() => _selectedTerm = v!),
                                onBillingTypeChanged: (v) =>
                                    setState(() => _selectedBillingType = v),
                              ),
                              const SizedBox(height: 24),

                              // Status & Preferences Section
                              const Text("STATUS & PREFERENCES",
                                  style: TextStyle(
                                      color: AppColors.textGrey,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2)),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: FormHelpers.buildCheckbox(
                                      label: "Active",
                                      value: _isActive,
                                      onChanged: (v) =>
                                          setState(() => _isActive = v!),
                                    ),
                                  ),
                                  const SizedBox(width: 32),
                                  Expanded(
                                    child: FormHelpers.buildCheckbox(
                                      label: "Photo Consent",
                                      value: _photoConsent,
                                      onChanged: (v) =>
                                          setState(() => _photoConsent = v!),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const VerticalDivider(width: 1, color: AppColors.divider),

                  // --- RIGHT: INFO/SUMMARY (Flex 4) ---
                  Expanded(
                    flex: 4,
                    child: Container(
                      color: AppColors.surfaceDarkGrey,
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("PROFILE SUMMARY",
                              style: TextStyle(
                                  color: AppColors.textGrey,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2)),
                          const SizedBox(height: 24),

                          // Summary Card
                          Container(
                            padding: const EdgeInsets.all(24),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceGrey,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.05)),
                            ),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 40,
                                  backgroundColor: AppColors.primaryBlue
                                      .withValues(alpha: 0.2),
                                  child: Text(
                                    _fullNameController.text.isNotEmpty
                                        ? _fullNameController.text[0]
                                            .toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryBlue),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _fullNameController.text.isNotEmpty
                                      ? _fullNameController.text
                                      : 'Student Name',
                                  style: const TextStyle(
                                      color: AppColors.textWhite,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "${_studentIdController.text} • $_selectedGrade",
                                  style: const TextStyle(
                                      color: AppColors.textGrey),
                                ),
                                const SizedBox(height: 24),
                                const Divider(color: AppColors.divider),
                                const SizedBox(height: 24),
                                _buildSummaryRow(
                                    "Status",
                                    _isActive ? "Active" : "Inactive",
                                    _isActive
                                        ? AppColors.successGreen
                                        : AppColors.errorRed),
                                const SizedBox(height: 12),
                                _buildSummaryRow(
                                    "Billing",
                                    _selectedBillingType.toUpperCase(),
                                    AppColors.textWhite),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color:
                                  AppColors.primaryBlue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: AppColors.primaryBlue
                                      .withValues(alpha: 0.3)),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.info_outline,
                                    color: AppColors.primaryBlue),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    "Student ID is read-only. Contact admin for changes.",
                                    style: TextStyle(
                                        color: AppColors.textWhite70,
                                        fontSize: 12),
                                  ),
                                ),
                              ],
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

            // Footer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: AppColors.textWhite70),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      foregroundColor: AppColors.textWhite,
                    ),
                    icon: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.textWhite,
                            ),
                          )
                        : const Icon(Icons.check, size: 18),
                    label: Text(
                      _isLoading ? "Saving..." : "Save Changes",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
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

  Widget _buildSummaryRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textGrey)),
        Text(value,
            style: TextStyle(color: valueColor, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
