import 'dart:math';
import 'package:fees_up/data/models/subjects.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../../data/services/database_service.dart';

class StudentDialog extends StatefulWidget {
  final String schoolId;
  
  const StudentDialog({
    super.key, 
    required this.schoolId,
  });

  @override
  State<StudentDialog> createState() => _StudentDialogState();
}

class _StudentDialogState extends State<StudentDialog> {
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
  DateTime _registrationDate = DateTime.now(); // Acts as Billing Start Date
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

  // --- SAVE LOGIC ---
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

      // 2. Logic for Billing Date
      // Only monthly students get a specific start date here. Termly relies on term IDs later.
      String? billingDateStr;
      if (_billingType == 'monthly') {
        billingDateStr = DateFormat('yyyy-MM-dd').format(_registrationDate);
      } else {
        billingDateStr = null; // Empty for term students
      }

      // 3. Insert Student Record
      final studentData = {
        'id': newStudentUuid,
        'school_id': widget.schoolId,
        'student_id': displayId,
        'full_name': _fullNameController.text.trim(),
        'grade': _selectedGrade, // Precise Grade
        'parent_contact': _parentContactController.text.trim(),
        'address': _addressController.text.trim(),
        'date_of_birth': DateFormat('yyyy-MM-dd').format(_dob),
        'gender': _selectedGender,
        'billing_type': _billingType,
        'default_fee': defaultFee,
        'subjects': _selectedSubjects.join(','),
        
        // Dates & Status
        'registration_date': DateTime.now().toIso8601String(),
        'billing_date': billingDateStr, // Crucial logic applied here
        'enrollment_date': DateTime.now().toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'is_active': 1,
        'owed_total': 0.0, 
        'paid_total': initialPay,
        'photo_consent': 0,
      };

      await db.insert('students', studentData);

      // 4. Attempt Auto-Billing (If Monthy & Fee > 0)
      String? generatedBillId;
      if (_billingType == 'monthly' && defaultFee > 0) {
        generatedBillId = await _attemptAutoBilling(newStudentUuid, defaultFee);
      }

      // 5. Handle Initial Payment
      if (initialPay > 0) {
        await db.insert('payments', {
          'id': const Uuid().v4(),
          'school_id': widget.schoolId,
          'student_id': newStudentUuid,
          'bill_id': generatedBillId, // Link if we generated one
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
          SnackBar(
            content: Text('${_fullNameController.text} registered successfully!'),
            backgroundColor: const Color(0xFF4ADE80),
          ),
        );
        Navigator.of(context).pop(); 
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Tries to find the active School Year & Month matching _registrationDate
  /// and creates a bill if found. Returns bill_id or null.
  Future<String?> _attemptAutoBilling(String studentId, double amount) async {
    try {
      // 1. Get Years
      // ignore: unused_local_variable
      final years = await _dbService.tryGet('SELECT * FROM school_years WHERE school_id = ?', [widget.schoolId]);
      // Note: tryGet returns one, we need list. Using getAll query pattern locally:
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

      // 2. Get Months
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

      // 3. Create Bill
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

  // --- HELPER DIALOGS ---

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
              backgroundColor: const Color(0xFF1F2227),
              title: const Text("Select Subjects", style: TextStyle(color: Colors.white)),
              content: SizedBox(
                width: 400,
                height: 500,
                child: Column(
                  children: [
                    // Search Bar
                    TextField(
                      onChanged: (val) => setState(() => searchQuery = val),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Search subjects...",
                        hintStyle: const TextStyle(color: Colors.white24),
                        prefixIcon: const Icon(Icons.search, color: Colors.white54),
                        filled: true,
                        fillColor: Colors.white.withAlpha(10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // List
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredSubjects.length,
                        itemBuilder: (context, index) {
                          final subject = filteredSubjects[index];
                          final isSelected = tempSelected.contains(subject);
                          return CheckboxListTile(
                            title: Text(subject, style: const TextStyle(color: Colors.white70)),
                            value: isSelected,
                            activeColor: const Color(0xFF3B82F6),
                            checkColor: Colors.white,
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
                  child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () {
                    this.setState(() => _selectedSubjects = tempSelected);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B82F6)),
                  child: const Text("Confirm", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF151718);
    const surfaceColor = Color(0xFF1F2227);
    const inputColor = Color(0xFF2A2D35);
    const primaryBlue = Color(0xFF3B82F6);
    const textWhite = Colors.white;
    const textGrey = Color(0xFF9CA3AF);

    final inputDecoration = BoxDecoration(
      color: inputColor,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.white.withAlpha(20)),
    );

    return Dialog(
      backgroundColor: bgColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 1100,
        height: 750,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // --- HEADER ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: primaryBlue, borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.person_add, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 16),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Register Student", style: TextStyle(color: textWhite, fontSize: 18, fontWeight: FontWeight.bold)),
                        Text("Add new student details to the school database", style: TextStyle(color: textGrey, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: textGrey),
                ),
              ],
            ),
            const Divider(color: Color(0xFF2E323A), height: 40),
            
            // --- BODY (Split View) ---
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- LEFT: FORM SECTION ---
                  Expanded(
                    flex: 4,
                    child: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(right: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _SectionLabel("STUDENT DETAILS"),
                            
                            _buildLabel("Full Name"),
                            _buildTextInput(controller: _fullNameController, hint: "e.g. Gabriel", icon: Icons.person, decoration: inputDecoration),
                            const SizedBox(height: 16),

                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildLabel("Student ID (Optional)"),
                                      _buildTextInput(
                                        controller: _studentIdController, 
                                        hint: "STU-...", 
                                        icon: Icons.badge,
                                        decoration: inputDecoration,
                                        suffix: IconButton(
                                          icon: const Icon(Icons.refresh, color: textGrey, size: 16),
                                          onPressed: _generateNewId,
                                          tooltip: "Generate New ID",
                                        )
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildLabel("Grade"), // Precise label
                                      _buildDropdown(_selectedGrade, _grades, (v) => setState(() => _selectedGrade = v!), inputDecoration),
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
                                      _buildLabel("Date of Birth"),
                                      _buildDatePicker(context, _dob, (d) => setState(() => _dob = d), inputDecoration),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildLabel("Gender"),
                                      _buildDropdown(_selectedGender, _genders, (v) => setState(() => _selectedGender = v!), inputDecoration),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            _buildLabel("Parent Contact"),
                            _buildTextInput(controller: _parentContactController, hint: "+263 7...", icon: Icons.phone, decoration: inputDecoration),
                            const SizedBox(height: 16),
                            _buildLabel("Address"),
                            _buildTextInput(controller: _addressController, hint: "123 Main St...", icon: Icons.location_on, decoration: inputDecoration),
                            
                            const SizedBox(height: 32),
                            const _SectionLabel("FINANCIAL SETUP"),

                            // Billing Type Toggle
                            Container(
                              decoration: inputDecoration,
                              padding: const EdgeInsets.all(4),
                              child: Row(
                                children: ['monthly', 'termly'].map((type) {
                                  final isSelected = _billingType == type;
                                  return Expanded(
                                    child: GestureDetector(
                                      onTap: () => setState(() => _billingType = type),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                        decoration: BoxDecoration(
                                          color: isSelected ? primaryBlue : Colors.transparent,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          type.toUpperCase(),
                                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : textGrey),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Fee & Initial Payment & Date
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildLabel("Tuition Fee"),
                                      _buildTextInput(controller: _feeController, hint: "0.00", prefix: "\$ ", isNumber: true, decoration: inputDecoration),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Only show Start Date for MONTHLY students
                                if (_billingType == 'monthly') ...[
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildLabel("Billing Start Date"),
                                        _buildDatePicker(context, _registrationDate, (d) => setState(() => _registrationDate = d), inputDecoration),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                ],
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildLabel("Initial Payment"),
                                      _buildTextInput(controller: _initialPayController, hint: "0.00", prefix: "\$ ", isNumber: true, decoration: inputDecoration),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Subject Selection
                            _buildLabel("Enrolled Subjects"),
                            InkWell(
                              onTap: _openSubjectSelector,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                decoration: inputDecoration,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _selectedSubjects.isEmpty ? "Select Subjects..." : "${_selectedSubjects.length} subjects selected",
                                        style: TextStyle(color: _selectedSubjects.isEmpty ? Colors.white24 : Colors.white),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const Icon(Icons.arrow_drop_down, color: textGrey),
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
                                  label: Text(s, style: const TextStyle(fontSize: 10, color: Colors.white)),
                                  backgroundColor: primaryBlue.withAlpha(50),
                                  padding: EdgeInsets.zero,
                                  side: BorderSide.none,
                                )).toList(),
                              ),
                            ],

                            const SizedBox(height: 40),
                            
                            // Action Buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("Cancel", style: TextStyle(color: textGrey)),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton.icon(
                                  onPressed: _isLoading ? null : _saveStudent,
                                  icon: _isLoading 
                                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                                    : const Icon(Icons.check, size: 18),
                                  label: const Text("Save Student"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryBlue,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),

                  Container(width: 1, color: const Color(0xFF2E323A), margin: const EdgeInsets.symmetric(horizontal: 32)),

                  // --- RIGHT: LIST SECTION ---
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("RECENTLY ADDED", style: TextStyle(color: textGrey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                            StreamBuilder<List<Map<String, dynamic>>>(
                              stream: _dbService.watchStudents(widget.schoolId), 
                              builder: (context, snapshot) {
                                final count = snapshot.data?.length ?? 0;
                                return Text("$count Students", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold));
                              }
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: StreamBuilder<List<Map<String, dynamic>>>(
                            stream: _dbService.db.watch('SELECT * FROM students WHERE school_id = ? ORDER BY created_at DESC', parameters: [widget.schoolId]),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                              final students = snapshot.data ?? [];
                              if (students.isEmpty) return const Center(child: Text("No students added yet", style: TextStyle(color: textGrey)));

                              return ListView.separated(
                                itemCount: students.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final s = students[index];
                                  final name = s['full_name'] ?? 'Unknown';
                                  final id = s['student_id'] ?? 'N/A';
                                  final grade = s['grade'] ?? 'N/A';

                                  return Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: surfaceColor,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.white.withAlpha(10)),
                                    ),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: primaryBlue.withAlpha(30),
                                          child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: const TextStyle(color: primaryBlue, fontWeight: FontWeight.bold)),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                                              const SizedBox(height: 2),
                                              Text("$id • $grade", style: const TextStyle(color: textGrey, fontSize: 12)),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
    );
  }

  Widget _buildTextInput({
    required TextEditingController controller, 
    required BoxDecoration decoration,
    String? hint, 
    Widget? suffix,
    IconData? icon,
    String? prefix,
    bool isNumber = false,
  }) {
    return Container(
      decoration: decoration,
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white24),
          prefixText: prefix,
          prefixStyle: const TextStyle(color: Colors.white70),
          prefixIcon: icon != null ? Icon(icon, color: Colors.white24, size: 20) : null,
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildDropdown(String value, List<String> items, Function(String?) onChanged, BoxDecoration decoration) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: decoration,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: const Color(0xFF1F2227),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white54),
          isExpanded: true,
          style: const TextStyle(color: Colors.white),
          items: items.map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context, DateTime initial, Function(DateTime) onPicked, BoxDecoration decoration) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: initial,
          firstDate: DateTime(1990),
          lastDate: DateTime(2030),
          builder: (context, child) => Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: const ColorScheme.dark(primary: Color(0xFF3B82F6), onPrimary: Colors.white, surface: Color(0xFF1F2227)),
            ),
            child: child!,
          ),
        );
        if (picked != null) onPicked(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: decoration,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(DateFormat('MMM dd, yyyy').format(initial), style: const TextStyle(color: Colors.white)),
            const Icon(Icons.calendar_today, size: 16, color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;
  const _SectionLabel(this.title);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, left: 2),
      child: Text(
        title,
        style: const TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 11),
      ),
    );
  }
}