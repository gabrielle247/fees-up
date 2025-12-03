import 'package:fees_up/features/view_models/register_student_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/zimsec_subjects.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/subject_chip_select.dart'; // Ensure this path is correct

class RegisterStudentScreen extends ConsumerWidget {
  const RegisterStudentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register Student"),
        centerTitle: true,
      ),
      body: const _RegisterForm(),
    );
  }
}

class _RegisterForm extends ConsumerStatefulWidget {
  const _RegisterForm();

  @override
  ConsumerState<_RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends ConsumerState<_RegisterForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registerStudentControllerProvider);
    final controller = ref.read(registerStudentControllerProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- 1. PERSONAL INFO ---
            Text("Student Info", style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            
            TextFormField(
              decoration: _inputDecor("Full Name", Icons.person_outline),
              validator: Validators.validateName,
              onChanged: controller.updateName,
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              decoration: _inputDecor("Parent Contact", Icons.phone_outlined),
              keyboardType: TextInputType.phone,
              validator: Validators.validatePhone,
              onChanged: controller.updateContact,
            ),
            const SizedBox(height: 24),

            // --- 2. ACADEMIC INFO ---
            Text("Academic", style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            
            // Subject Picker
            SubjectChipSelect(
              allSubjects: ZimsecSubject.allNames,
              selectedSubjects: state.subjects,
              onSelectionChanged: controller.updateSubjects,
            ),
            const SizedBox(height: 24),

            // --- 3. BILLING CONFIG ---
            Text("Billing Configuration", style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            Row(
              children: [
                // Frequency Dropdown
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: state.frequency,
                    decoration: _inputDecor("Frequency", Icons.update),
                    items: ['Monthly', 'Termly', 'Annually']
                        .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) controller.updateFrequency(val);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                
                // Registration Date Picker
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: state.registrationDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                        selectableDayPredicate: (date) {
                          // UI BLOCKER: If Monthly, disable days > 28 visually
                          if (state.frequency == 'Monthly') {
                            return date.day <= 28;
                          }
                          return true;
                        },
                      );
                      if (picked != null) {
                        controller.updateDate(picked);
                      }
                    },
                    child: InputDecorator(
                      decoration: _inputDecor("Start Date", Icons.calendar_today),
                      child: Text(
                        DateFormat('dd MMM yyyy').format(state.registrationDate),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            if (state.frequency == 'Monthly')
              Text(
                "* Monthly students must start between 1st-28th.",
                style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
              ),

            const SizedBox(height: 16),

            TextFormField(
              decoration: _inputDecor("Agreed Fee", Icons.attach_money),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: Validators.validateMoney,
              onChanged: controller.updateFee,
            ),
            const SizedBox(height: 16),

            TextFormField(
              decoration: _inputDecor("Initial Payment (Optional)", Icons.payment),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: Validators.validateOptionalMoney,
              onChanged: controller.updateInitialPayment,
            ),

            const SizedBox(height: 32),

            // --- SUBMIT ---
            ElevatedButton(
              onPressed: state.isLoading ? null : () async {
                if (_formKey.currentState!.validate()) {
                  final success = await controller.register();
                  if (success && context.mounted) {
                    context.pop(); // Return to dashboard
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Student Registered Successfully")),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
              child: state.isLoading 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text("Complete Registration"),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecor(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
  }
}