// lib/pages/register_student_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/database_service.dart';
import '../utils/subject_selection_modal.dart';

class RegisterStudentPage extends StatefulWidget {
  const RegisterStudentPage({super.key});
  static const String routeName = '/register_student';

  @override
  State<RegisterStudentPage> createState() => _RegisterStudentPageState();
}

class _RegisterStudentPageState extends State<RegisterStudentPage> {
  final _formKey = GlobalKey<FormState>();
  
  // -- Controllers --
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _feeController = TextEditingController();
  final _initialPayController = TextEditingController();

  // -- State --
  String _selectedGrade = 'FORM 1';
  String _billingType = 'monthly'; 
  final bool _isActive = true;
  bool _isSaving = false;
  List<String> _selectedSubjects = [];

  // Dates
  DateTime _registrationDate = DateTime.now();
  // Default next billing to 1 month from now (adjusted for safe days)
  late DateTime _nextBillingDate;

  // Grade Options
  final List<String> _grades = [
    'ECD A', 'ECD B', 
    'GRADE 1', 'GRADE 2', 'GRADE 3', 'GRADE 4', 'GRADE 5', 'GRADE 6', 'GRADE 7',
    'FORM 1', 'FORM 2', 'FORM 3', 'FORM 4', 'LOWER 6', 'UPPER 6'
  ];

  @override
  void initState() {
    super.initState();
    // Initialize next billing date to next month, ensuring day <= 28
    final now = DateTime.now();
    int safeDay = now.day > 28 ? 1 : now.day;
    int nextMonth = now.month == 12 ? 1 : now.month + 1;
    int nextYear = now.month == 12 ? now.year + 1 : now.year;
    _nextBillingDate = DateTime(nextYear, nextMonth, safeDay);
  }

  // --- Logic: Date Pickers ---

  Future<void> _pickRegistrationDate() async {
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

  Future<void> _pickBillingDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _nextBillingDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      // DISABLE 29, 30, 31 to ensure consistent monthly billing cycles
      selectableDayPredicate: (DateTime val) => val.day <= 28,
    );
    if (picked != null) {
      setState(() => _nextBillingDate = picked);
    }
  }

  // --- Logic: Save Student ---
  Future<void> _registerStudent() async {
    if (!_formKey.currentState!.validate()) return;

    // 1. Get Admin UID from Supabase
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: You must be logged in to register students.')),
      );
      return;
    }

    // 1.b Enforce: Must have an existing school linked before adding students
    final db = DatabaseService.instance;
    final profile = await db.getUserProfileById(user.id);
    final schoolId = profile != null ? (profile['school_id'] as String?) : null;
    if (schoolId == null || schoolId.isEmpty) {
      if (mounted) {
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Complete Setup Required'),
            content: const Text('Please complete your school setup before adding students.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
      return;
    }

    // 1.c Enforce: Termly billing requires at least one term
    if (_billingType == 'termly') {
      final hasTerm = await db.hasAnyTermForSchool(schoolId);
      if (!hasTerm) {
        if (mounted) {
          await showDialog<void>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Add a Term First'),
              content: const Text('You must set up at least one academic term before adding termly students.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
        return;
      }
    }

    setState(() => _isSaving = true);

    try {
      final db = DatabaseService.instance;
      
      final defaultFee = double.tryParse(_feeController.text) ?? 0.0;
      final initialPay = double.tryParse(_initialPayController.text) ?? 0.0;

      // 2. Prepare Data Map
      final studentData = {
        'full_name': _nameController.text.trim(),
        'parent_contact': _contactController.text.trim(),
        'grade': _selectedGrade,
        'registration_date': _registrationDate.toIso8601String(),
        'billing_date': _nextBillingDate.toIso8601String(), // NEW FIELD
        'billing_type': _billingType,
        'default_fee': defaultFee,
        'is_active': _isActive ? 1 : 0,
        'subjects': _selectedSubjects.join(','),
        'admin_uid': user.id, // AUTH ID
        'school_id': schoolId,
      };

      // 3. Insert Student
      final studentId = await db.createStudent(
        studentData, 
        createBackdatedBills: false 
      );

      // 4. Generate the "Initial Bill" (Current Period)
      // We label this bill based on the registration date
      await db.createBillForStudent(
        studentId: studentId,
        totalAmount: defaultFee,
        billType: _billingType,
        createdAt: _registrationDate, // Bill date is Reg date
        cycleStart: _registrationDate,
        adminUid: user.id,
        monthYear: _billingType == 'monthly' 
            ? '${_registrationDate.year}-${_registrationDate.month.toString().padLeft(2,'0')}' 
            : null,
      );

      // 5. Record Initial Payment
      if (initialPay > 0) {
        final bills = await db.getStudentBills(studentId);
        if (bills.isNotEmpty) {
          final billId = bills.first['id'] as String;
          await db.recordPayment(
            billId: billId,
            studentId: studentId,
            amount: initialPay,
            datePaid: DateTime.now(),
            method: 'Cash',
            adminUid: user.id,
          );
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Student registered successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final standardBoxDecoration = BoxDecoration(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(12.0),
      border: Border.all(color: colorScheme.outlineVariant, width: 1.0),
    );

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Add Student'),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SectionHeader(title: "PERSONAL INFORMATION"),
                  
                  _buildTextField(
                    label: "Full Name",
                    controller: _nameController,
                    hint: "e.g. John Smith",
                    decoration: standardBoxDecoration,
                    validator: (v) => v!.isEmpty ? "Name required" : null,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    label: "Parent Contact",
                    controller: _contactController,
                    hint: "+263 7...",
                    icon: Icons.phone_outlined,
                    decoration: standardBoxDecoration,
                    inputType: TextInputType.phone,
                  ),

                  const SizedBox(height: 24),
                  _SectionHeader(title: "ACADEMIC"),
                  
                  // Grade Dropdown
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: standardBoxDecoration,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedGrade,
                        isExpanded: true,
                        dropdownColor: colorScheme.surfaceContainer,
                        icon: Icon(Icons.arrow_forward_ios, size: 14, color: colorScheme.onSurfaceVariant),
                        items: _grades.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                        onChanged: (v) => setState(() => _selectedGrade = v!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Subject Selector
                  GestureDetector(
                    onTap: _openSubjectPicker,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: standardBoxDecoration,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Enrolled Subjects", style: TextStyle(color: colorScheme.onSurfaceVariant)),
                              Icon(Icons.add, color: colorScheme.primary),
                            ],
                          ),
                          if (_selectedSubjects.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _selectedSubjects.map((s) => Chip(
                                label: Text(s, style: const TextStyle(fontSize: 11)),
                                backgroundColor: colorScheme.primaryContainer,
                                labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                                visualDensity: VisualDensity.compact,
                                side: BorderSide.none,
                                onDeleted: () => setState(() => _selectedSubjects.remove(s)),
                              )).toList(),
                            )
                          ]
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Registration Date Picker
                  GestureDetector(
                    onTap: _pickRegistrationDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: standardBoxDecoration,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Registration Date", style: TextStyle(color: colorScheme.onSurfaceVariant)),
                          Row(
                            children: [
                              Text(
                                DateFormat('MMM dd, yyyy').format(_registrationDate),
                                style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 8),
                              Icon(Icons.calendar_today, size: 16, color: colorScheme.primary),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  _SectionHeader(title: "FINANCIALS"),

                  // Billing Frequency
                  Container(
                    decoration: standardBoxDecoration,
                    child: Row(
                      children: ['termly', 'monthly', 'yearly'].map((type) {
                        final isSelected = _billingType == type;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _billingType = type),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: isSelected ? colorScheme.primary : Colors.transparent,
                                borderRadius: BorderRadius.circular(11),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                type.toUpperCase(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: isSelected ? Colors.white : colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Fee Amount
                  _buildTextField(
                    label: "Recurring Fee Amount",
                    controller: _feeController,
                    prefix: "\$ ",
                    inputType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: standardBoxDecoration,
                    validator: (v) => v!.isEmpty ? "Fee required" : null,
                  ),
                  const SizedBox(height: 12),

                  // Initial Pay & Next Billing Row
                  Row(
                    children: [
                      // Initial Payment
                      Expanded(
                        flex: 4,
                        child: _buildTextField(
                          label: "Initial Payment",
                          controller: _initialPayController,
                          prefix: "\$ ",
                          hint: "0.00",
                          inputType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: standardBoxDecoration,
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // Next Billing Date
                      Expanded(
                        flex: 5,
                        child: GestureDetector(
                          onTap: _pickBillingDate,
                          child: Container(
                            height: 60, // Match typical text field height
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: standardBoxDecoration,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Next Bill Date",
                                  style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        DateFormat('MMM dd, yyyy').format(_nextBillingDate),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold, 
                                          color: colorScheme.onSurface,
                                          fontSize: 13
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Icon(Icons.event_repeat, size: 16, color: colorScheme.primary),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      "* Billing dates restricted to days 1-28 to prevent cycle errors.",
                      style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant.withAlpha(128)),
                    ),
                  ),

                  const SizedBox(height: 32),
                  
                  // Save Button
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _registerStudent,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: _isSaving 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("SAVE STUDENT", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required BoxDecoration decoration,
    String? hint,
    String? prefix,
    IconData? icon,
    TextInputType inputType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: decoration,
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        validator: validator,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixText: prefix,
          suffixIcon: icon != null ? Icon(icon, color: Colors.grey, size: 20) : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          labelStyle: const TextStyle(color: Colors.grey),
          prefixStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 4),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          fontSize: 12,
        ),
      ),
    );
  }
}