import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/providers/users_provider.dart';

class AddUserDialog extends ConsumerStatefulWidget {
  final String schoolId;
  const AddUserDialog({super.key, required this.schoolId});

  @override
  ConsumerState<AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends ConsumerState<AddUserDialog> {
  final _emailController = TextEditingController();
  String _selectedRole = 'teacher';
  bool _isLoading = false;
  String? _error;

  Future<void> _submit() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      await ref.read(usersRepositoryProvider).addUserByEmail(
        email: _emailController.text.trim(),
        schoolId: widget.schoolId,
        role: _selectedRole,
      );
      
      // Refresh list and close
      // ignore: unused_result
      ref.refresh(schoolUsersProvider);
      if (mounted) Navigator.of(context).pop();
      
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surfaceGrey,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Add New User", style: TextStyle(color: AppColors.textWhite, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text("Link an existing account to your school by email.", style: TextStyle(color: AppColors.textWhite54)),
            const SizedBox(height: 24),

            // Email Input
            const Text("User Email", style: TextStyle(color: AppColors.textWhite70, fontSize: 13)),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              style: const TextStyle(color: AppColors.textWhite),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.backgroundBlack,
                hintText: "e.g. sarah.jones@school.edu",
                hintStyle: const TextStyle(color: AppColors.textWhite38),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.divider)),
              ),
            ),
            const SizedBox(height: 24),

            // Role Selection
            const Text("Assign Role", style: TextStyle(color: AppColors.textWhite70, fontSize: 13)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.backgroundBlack,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.divider),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedRole,
                  isExpanded: true,
                  dropdownColor: AppColors.surfaceGrey,
                  style: const TextStyle(color: AppColors.textWhite),
                  items: const [
                    DropdownMenuItem(value: 'teacher', child: Text("Teacher")),
                    DropdownMenuItem(value: 'school_admin', child: Text("School Admin")),
                    DropdownMenuItem(value: 'student', child: Text("Student")),
                  ],
                  onChanged: (v) => setState(() => _selectedRole = v!),
                ),
              ),
            ),

            if (_error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.errorRed.withAlpha(26), borderRadius: BorderRadius.circular(8)),
                child: Row(children: [
                  const Icon(Icons.error, color: AppColors.errorRed, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_error!, style: const TextStyle(color: AppColors.errorRed, fontSize: 12))),
                ]),
              )
            ],

            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel", style: TextStyle(color: AppColors.textWhite54)),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
                  child: Text(_isLoading ? "Linking..." : "Add User"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}