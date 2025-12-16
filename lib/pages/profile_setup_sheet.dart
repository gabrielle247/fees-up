import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/profile_provider.dart';

class ProfileSetupSheet extends ConsumerStatefulWidget {
  final String? initialFullName;
  final String? initialSchoolName;

  const ProfileSetupSheet({super.key, this.initialFullName, this.initialSchoolName});

  @override
  ConsumerState<ProfileSetupSheet> createState() => _ProfileSetupSheetState();
}

class _ProfileSetupSheetState extends ConsumerState<ProfileSetupSheet> {
  late final TextEditingController _fullNameCtrl;
  late final TextEditingController _schoolNameCtrl;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fullNameCtrl = TextEditingController(text: widget.initialFullName ?? '');
    _schoolNameCtrl = TextEditingController(text: widget.initialSchoolName ?? '');
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _schoolNameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final saving = ref.watch(profileSetupControllerProvider);
    final isLoading = saving.isLoading;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Complete your profile',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: isLoading ? null : () => Navigator.of(context).maybePop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'We could not find your profile details. Please provide them to continue.',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fullNameCtrl,
                enabled: !isLoading,
                decoration: const InputDecoration(
                  labelText: 'Full name',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if ((v ?? '').trim().isEmpty) return 'Full name is required';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _schoolNameCtrl,
                enabled: !isLoading,
                decoration: const InputDecoration(
                  labelText: 'School name',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if ((v ?? '').trim().isEmpty) return 'School name is required';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (!_formKey.currentState!.validate()) return;
                          final fullName = _fullNameCtrl.text.trim();
                          final schoolName = _schoolNameCtrl.text.trim();
                          await ref.read(profileSetupControllerProvider.notifier).save(
                                fullName: fullName,
                                schoolName: schoolName,
                              );
                          if (mounted) Navigator.of(context).maybePop();
                        },
                  icon: isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_alt),
                  label: Text(isLoading ? 'Saving…' : 'Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> showProfileSetupSheet(BuildContext context, WidgetRef ref) async {
  final maybeProfile = await ref.read(userProfileProvider.future);
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: ProfileSetupSheet(
        initialFullName: maybeProfile?.fullName,
        initialSchoolName: null,
      ),
    ),
  );
}
