import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/profile_provider.dart';
import '../services/auth_service.dart';

/// A thin banner that appears when the user's cloud profile or school data
/// is missing. Shown across top-level pages.
class EnsureProfileBanner extends ConsumerWidget {
  const EnsureProfileBanner({super.key});

  Future<void> _completeProfile(BuildContext context, WidgetRef ref, String initialName) async {
    final fullNameCtrl = TextEditingController(text: initialName);
    final schoolNameCtrl = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xff1c2a35),
        title: const Text('Complete Setup', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: fullNameCtrl,
              decoration: const InputDecoration(labelText: 'Full Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: schoolNameCtrl,
              decoration: const InputDecoration(labelText: 'School Name'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
        ],
      ),
    );

    if (confirmed == true) {
      final fn = fullNameCtrl.text.trim();
      final sn = schoolNameCtrl.text.trim();
      if (fn.isEmpty || sn.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter both full name and school name.')),
        );
        return;
      }
      try {
        await AuthService().completeProfileSetup(fullName: fn, schoolName: sn);
        await ref.read(profileRefreshProvider.notifier).refresh();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile completed successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to complete profile: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final schoolAsync = ref.watch(currentSchoolProvider);

    // Decide if banner should show: admins with no school should be prompted to create one
    final shouldShow = profileAsync.maybeWhen(
      data: (p) {
        if (p == null) return false; // not logged in / unknown
        
        // Check if user is an admin role
        final isAdmin = p.role == 'school_admin' || 
                        p.role == 'super_admin' || 
                        p.role.toLowerCase().contains('admin');
        
        // Show banner if admin has no school linked
        if (isAdmin && (p.schoolId == null || p.schoolId!.isEmpty)) {
          return true;
        }
        
        // For non-admins, only show if they somehow have incomplete profile + school
        if (!isAdmin) return false;
        
        // If admin has school, check if school data exists and is valid
        if (p.schoolId != null && p.schoolId!.isNotEmpty) {
          final s = schoolAsync.asData?.value;
          return s == null || (s.name.isEmpty);
        }
        
        return false;
      },
      orElse: () => false,
    );

    if (!shouldShow) return const SizedBox.shrink();

    final name = profileAsync.asData?.value?.fullName ?? 'School Admin';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xff2a3a46),
        border: Border(bottom: BorderSide(color: Color(0x1FFFFFFF))),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.amber),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              "We couldn't find your cloud profile/school. Complete setup to enable syncing.",
              style: TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: () => _completeProfile(context, ref, name),
            child: const Text('Complete Now'),
          )
        ],
      ),
    );
  }
}
