import 'package:fees_up/services/validators.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../view_models/register_student_view_model.dart';
import '../models/subjects.dart'; 
import '../utils/sized_box_normal.dart';
import '../utils/subject_chip_select.dart';// ✅ Import Validators

class RegisterStudentPage extends StatelessWidget {
  const RegisterStudentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegisterStudentViewModel(),
      child: const _RegisterStudentForm(),
    );
  }
}

class _RegisterStudentForm extends StatefulWidget {
  const _RegisterStudentForm();

  @override
  State<_RegisterStudentForm> createState() => _RegisterStudentFormState();
}

class _RegisterStudentFormState extends State<_RegisterStudentForm> {
  // ✅ 1. Create Form Key
  final _formKey = GlobalKey<FormState>();

  Future<void> _showLoadingDialog(BuildContext context) {
     // ... (Keep your existing loading dialog code) ...
     return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => const Center(child: CircularProgressIndicator()), // Simplified for brevity
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RegisterStudentViewModel>();
    final colorScheme = Theme.of(context).colorScheme;

    // Define Input Decoration Style once to reuse
    InputDecoration getDecor(String hint, IconData icon) {
      return InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14.0),
        prefixIcon: Icon(icon, size: 20, color: Colors.grey),
        filled: true,
        fillColor: colorScheme.surface,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: colorScheme.tertiary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: colorScheme.secondary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: colorScheme.error),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Form( // ✅ 2. Wrap in Form
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ... Header ...
                   Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.person_add_alt),
                    const Expanded(
                      child: Text("Register Student", textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                    ),
                    GestureDetector(onTap: () => context.pop(), child: const Icon(Icons.close_rounded)),
                  ],
                ),
                const SizedBox(height: 24.0),

                  // NAME
                  const Text("Student Info", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8.0),
                  TextFormField( // ✅ Changed to TextFormField
                    decoration: getDecor("Enter student's full name", Icons.person),
                    style: TextStyle(color: colorScheme.onSurface),
                    onChanged: vm.updateStudentName,
                    validator: Validators.validateName, // ✅ Added Validator
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),

                  const SizedBoxNormal(12, 0),

                  // PHONE
                  TextFormField(
                    keyboardType: TextInputType.phone,
                    decoration: getDecor("Enter parent contact", Icons.phone),
                    style: TextStyle(color: colorScheme.onSurface),
                    onChanged: vm.updateParentContact,
                    validator: Validators.validatePhone, // ✅ Added Validator
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),

                  const SizedBox(height: 24.0),

                  // SUBJECTS
                  const Text("Select Subjects", style: TextStyle(fontSize: 14, color: Colors.grey)),
                  const SizedBox(height: 8.0),
                  SubjectChipSelect(
                    allSubjects: ZimsecSubject.allNames,
                    selectedSubjects: vm.selectedSubjects,
                    onSelectionChanged: vm.updateSelectedSubjects,
                  ),

                  const SizedBox(height: 24.0),

                  // FEE
                  TextFormField(
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: getDecor("Monthly Fee", Icons.request_quote_outlined),
                    style: TextStyle(color: colorScheme.onSurface),
                    onChanged: vm.updateNegotiatedFee,
                    validator: Validators.validateMoney, // ✅ Added Validator
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),

                  const SizedBoxNormal(12, 0),

                  // INITIAL PAYMENT
                  TextFormField(
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: getDecor("Initial Payment (Can be 0)", Icons.attach_money),
                    style: TextStyle(color: colorScheme.onSurface),
                    onChanged: vm.updateInitialPayment,
                    // Custom validator: Can be 0, but must be a valid number
                    validator: (val) {
                      if (val == null || val.isEmpty) return null; // Allow empty (means 0)
                      if (double.tryParse(val) == null) return "Invalid number";
                      if (double.parse(val) < 0) return "Cannot be negative";
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),

                  const SizedBox(height: 32.0),

                  // SUBMIT
                  ElevatedButton(
                    onPressed: () async {
                      // ✅ 3. Validate Trigger
                      if (!_formKey.currentState!.validate()) {
                        // Form has errors, do not proceed
                        return;
                      }
                      
                      // Additional Check for Logic (e.g., Subjects selected?)
                      if (vm.selectedSubjects.isEmpty) {
                         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select at least one subject.")));
                         return;
                      }

                      // Proceed with Logic
                      _showLoadingDialog(context);

                      final newStudentId = await vm.registerStudent();

                      if (context.mounted) Navigator.of(context).pop(); // Close Dialog

                      if (newStudentId != null && context.mounted) {
                        context.pushReplacement('/studentLedger', extra: {
                          'studentId': newStudentId,
                          'studentName': vm.studentName,
                          'enrolledSubjects': vm.selectedSubjects,
                        });
                      } else if (context.mounted) {
                         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error saving data.")));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Register Student"),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}