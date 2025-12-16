import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/settings_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../services/auth_service.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  // --- Actions ---
  
  void _editProfile(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("TODO: Open Edit Profile Page")),
    );
  }

  void _changePassword(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("TODO: Open Change Password Flow")),
    );
  }

  Future<void> _showCompleteProfileDialog(BuildContext context, WidgetRef ref, {
    required String initialFullName,
  }) async {
    final fullNameController = TextEditingController(text: initialFullName);
    final schoolNameController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xff1c2a35),
        title: const Text('Complete Your Profile', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: fullNameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: schoolNameController,
              decoration: const InputDecoration(
                labelText: 'School Name',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == true) {
      final fullName = fullNameController.text.trim();
      final schoolName = schoolNameController.text.trim();
      if (fullName.isEmpty || schoolName.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter your name and school name.')),
        );
        return;
      }

      try {
        // Create school and user profile in Supabase under RLS
        await AuthService().completeProfileSetup(fullName: fullName, schoolName: schoolName);
        // Refresh local cached profile
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

  void _openHelpCenter(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("TODO: Open Help Center / Webview")),
    );
  }

  Future<void> _handleSignOut(BuildContext context, WidgetRef ref) async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xff1c2a35),
        title: const Text("Sign Out?", style: TextStyle(color: Colors.white)),
        content: const Text(
          "Are you sure you want to sign out? You will need to login again.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Sign Out", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(authNotifierProvider.notifier).signOut();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Watch settings state
    final settingsAsync = ref.watch(settingsProvider);
    // Watch profile state
    final profileAsync = ref.watch(userProfileProvider);
    
    // Get current user info from Supabase for the header
    final user = Supabase.instance.client.auth.currentUser;
    final email = profileAsync.when(
      data: (p) => p?.email ?? user?.email ?? 'admin@school.edu',
      loading: () => user?.email ?? 'admin@school.edu',
      error: (_, _) => user?.email ?? 'admin@school.edu',
    );
    final name = profileAsync.when(
      data: (p) => p?.fullName ?? (user?.userMetadata?['full_name'] ?? 'School Admin'),
      loading: () => user?.userMetadata?['full_name'] ?? 'School Admin',
      error: (_, _) => user?.userMetadata?['full_name'] ?? 'School Admin',
    );

    return Scaffold(
      backgroundColor: colorScheme.surface, // 0xff121b22
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: Colors.white, 
          fontSize: 20, 
          fontWeight: FontWeight.bold
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text("Error: $e", style: const TextStyle(color: Colors.red))),
        data: (settings) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // --- PROFILE HEADER ---
                Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withAlpha(20), width: 2),
                          ),
                          child: const CircleAvatar(
                            radius: 45,
                            backgroundImage: AssetImage('assets/avatar_placeholder.png'), // Ensure you have this or use Icon
                            backgroundColor: Color(0xff1c2a35),
                            child: SizedBox(),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Color(0xff3498db), // Brand Blue
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.edit, size: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 20, 
                        fontWeight: FontWeight.bold, 
                        color: Colors.white
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: TextStyle(fontSize: 14, color: Colors.white.withAlpha(150)),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _editProfile(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff3498db).withAlpha(30),
                        foregroundColor: const Color(0xff3498db),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                      ),
                      child: const Text("Edit Profile", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                // Prompt to complete profile if backend record is missing (no school_id)
                profileAsync.maybeWhen(
                  data: (p) {
                    if (p != null && (p.schoolId == null || p.schoolId!.isEmpty)) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xff2a3a46),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withAlpha(20)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Profile Incomplete',
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'We couldn\'t find your profile in the cloud. Complete setup to enable syncing.',
                              style: TextStyle(color: Colors.white.withAlpha(170)),
                            ),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: FilledButton(
                                onPressed: () => _showCompleteProfileDialog(context, ref, initialFullName: name.toString()),
                                child: const Text('Complete Now'),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                  orElse: () => const SizedBox.shrink(),
                ),

                const SizedBox(height: 32),

                // --- ACCOUNT SECTION ---
                _SectionTitle(title: "ACCOUNT"),
                _SettingsGroup(
                  children: [
                    _SettingsTile(
                      icon: Icons.lock_outline,
                      iconColor: const Color(0xff64b5f6), // Light Blue
                      title: "Change Password",
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                      onTap: () => _changePassword(context),
                    ),
                    _Divider(),
                    _SettingsTile(
                      icon: Icons.security_outlined,
                      iconColor: const Color(0xffba68c8), // Purple
                      title: "Two-Factor Authentication",
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("Enabled", style: TextStyle(color: const Color(0xff66bb6a), fontSize: 12, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                        ],
                      ),
                      onTap: () {},
                    ),
                    _Divider(),
                    _SettingsTile(
                      icon: Icons.fingerprint,
                      iconColor: const Color(0xffffb74d), // Orange
                      title: "Biometric Login",
                      trailing: Switch(
                        value: settings.biometricEnabled,
                        onChanged: (val) => ref.read(settingsProvider.notifier).toggleBiometric(val),
                        activeThumbColor: const Color(0xff3498db),
                        activeTrackColor: const Color(0xff3498db).withAlpha(100),
                        inactiveTrackColor: Colors.grey.withAlpha(50),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // --- PREFERENCES SECTION ---
                _SectionTitle(title: "PREFERENCES"),
                _SettingsGroup(
                  children: [
                    _SettingsTile(
                      icon: Icons.notifications_none_outlined,
                      iconColor: const Color(0xff4db6ac), // Teal
                      title: "Notifications",
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                      onTap: () {},
                    ),
                    _Divider(),
                    _SettingsTile(
                      icon: Icons.language,
                      iconColor: const Color(0xff7986cb), // Indigo
                      title: "Language",
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(settings.language, style: TextStyle(color: Colors.white.withAlpha(150), fontSize: 12)),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                        ],
                      ),
                      onTap: () {},
                    ),
                    _Divider(),
                    _SettingsTile(
                      icon: Icons.dark_mode_outlined,
                      iconColor: const Color(0xff90a4ae), // Grey Blue
                      title: "Dark Mode",
                      // Locked to true for this app design, but switchable in logic
                      trailing: Switch(
                        value: settings.darkMode, 
                        onChanged: (val) => ref.read(settingsProvider.notifier).toggleDarkMode(val),
                        activeThumbColor: const Color(0xff3498db),
                        activeTrackColor: const Color(0xff3498db).withAlpha(100),
                        inactiveTrackColor: Colors.grey.withAlpha(50),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // --- SUPPORT SECTION ---
                _SectionTitle(title: "SUPPORT"),
                _SettingsGroup(
                  children: [
                    _SettingsTile(
                      icon: Icons.help_outline,
                      iconColor: const Color(0xffe57373), // Red
                      title: "Help Center",
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                      onTap: () => _openHelpCenter(context),
                    ),
                    _Divider(),
                    _SettingsTile(
                      icon: Icons.chat_bubble_outline,
                      iconColor: const Color(0xffffd54f), // Yellow
                      title: "Send Feedback",
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                      onTap: () {},
                    ),
                    _Divider(),
                    _SettingsTile(
                      icon: Icons.info_outline,
                      iconColor: const Color(0xff4fc3f7), // Light Blue
                      title: "About App",
                      trailing: Text("v2.4.0", style: TextStyle(color: Colors.white.withAlpha(100), fontSize: 12)),
                      onTap: () {},
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // --- LOGOUT ---
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: () => _handleSignOut(context, ref),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xffef5350)), // Red border
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      foregroundColor: const Color(0xffef5350),
                    ),
                    icon: const Icon(Icons.logout),
                    label: const Text("Sign Out", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),

                const SizedBox(height: 20),
                Text(
                  "Secure Student Data System © 2025",
                  style: TextStyle(color: Colors.white.withAlpha(50), fontSize: 12),
                ),
                const SizedBox(height: 100), // Bottom padding for nav bar
              ],
            ),
          );
        },
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// HELPER WIDGETS
// -----------------------------------------------------------------------------

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white.withAlpha(100),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;
  const _SettingsGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xff1c2a35), // Card Surface
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(10)),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withAlpha(30),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
      ),
      trailing: trailing,
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.white.withAlpha(10),
      indent: 60, // Align with text, skipping icon
    );
  }
}