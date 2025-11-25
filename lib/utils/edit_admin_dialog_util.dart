// lib/utils/edit_admin_dialog_util.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/sized_box_normal.dart';
import '../view_models/edit_admin_profile_view_model.dart';

class EditAdminDialogUtil extends StatelessWidget {
  const EditAdminDialogUtil({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EditAdminProfileViewModel()..loadProfileData(),
      child: const _EditAdminProfileForm(),
    );
  }
}

class _EditAdminProfileForm extends StatefulWidget {
  const _EditAdminProfileForm();

  @override
  State<_EditAdminProfileForm> createState() => _EditAdminProfileFormState();
}

class _EditAdminProfileFormState extends State<_EditAdminProfileForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _schoolController = TextEditingController();

  late EditAdminProfileViewModel _vm;
  late VoidCallback _listener;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _vm = context.read<EditAdminProfileViewModel>();
      _listener = () {
        if (!_vm.isLoading) {
          _nameController.text = _vm.currentFullName;
          _schoolController.text = _vm.currentSchoolName;
          _vm.removeListener(_listener);
        }
      };

      if (!_vm.isLoading) {
        _nameController.text = _vm.currentFullName;
        _schoolController.text = _vm.currentSchoolName;
      } else {
        _vm.addListener(_listener);
      }
    });
  }

  @override
  void dispose() {
    if (mounted) {
      try {
        context.read<EditAdminProfileViewModel>().removeListener(_listener);
      } catch (_) {}
    }
    _nameController.dispose();
    _schoolController.dispose();
    super.dispose();
  }

  // --- Core Save Logic ---
  Future<void> _saveChanges(EditAdminProfileViewModel vm) async {
    if (!_formKey.currentState!.validate()) return;

    final success = await vm.saveTextChanges(
      newFullName: _nameController.text.trim(),
      newSchoolName: _schoolController.text.trim(),
      // Avatar URL is ignored/null in offline mode
      newAvatarUrl: null,
    );

    if (mounted) {
      if (success) {
        Navigator.of(context).pop(true); // Return true to trigger reload
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('School details updated.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save changes.')),
        );
      }
    }
  }

  // 🛑 CHANGED: Placeholder for future update
  void _handleAvatarClick() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Custom avatars coming in the next update! 🎨"),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EditAdminProfileViewModel>();
    final colorScheme = Theme.of(context).colorScheme;

    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

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
                // Header (Offline Mode)
                _buildHeader(colorScheme, vm),

                const Divider(height: 32),

                _buildLabel("Full Name (Admin)"),
                TextFormField(
                  controller: _nameController,
                  style: TextStyle(color: colorScheme.onSurface),
                  decoration: _inputDecoration(
                    colorScheme,
                    Icons.person_outline,
                  ),
                  validator: (val) => val!.isEmpty ? "Name required" : null,
                ),

                const SizedBoxNormal(16, 0),

                _buildLabel("School Name"),
                TextFormField(
                  controller: _schoolController,
                  style: TextStyle(color: colorScheme.onSurface),
                  decoration: _inputDecoration(
                    colorScheme,
                    Icons.business_outlined,
                  ),
                  validator: (val) =>
                      val!.isEmpty ? "School Name required" : null,
                ),

                const SizedBoxNormal(24, 0),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: vm.isSaving ? null : () => _saveChanges(vm),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: vm.isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              "Save Changes",
                              style: TextStyle(color: Colors.white),
                            ),
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

  // --- UI Helpers ---

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0, left: 4.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          color: Colors.grey,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(ColorScheme colors, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, size: 20, color: Colors.grey),
      filled: true,
      fillColor: colors.tertiary.withAlpha(76),
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

  Widget _buildHeader(ColorScheme colorScheme, EditAdminProfileViewModel vm) {
    // 🛑 OFFLINE LOGIC: Use Initials Only
    final String initial = vm.currentSchoolName.isNotEmpty
        ? vm.currentSchoolName.substring(0, 1).toUpperCase()
        : 'G';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              // Avatar
              CircleAvatar(
                radius: 30,
                backgroundColor: colorScheme.primary.withAlpha(51),
                child: Text(
                  initial,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ),
              // "Coming Soon" Button
              Positioned(
                child: InkWell(
                  onTap: _handleAvatarClick,
                  child: CircleAvatar(
                    radius: 12,
                    backgroundColor: colorScheme.primary,
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 16),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Edit Details",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                "Editing: ${vm.currentFullName}",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),

        IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ],
    );
  }
}
