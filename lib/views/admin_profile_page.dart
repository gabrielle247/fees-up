// lib/views/admin_profile_page.dart

import 'package:fees_up/services/database_service.dart';
import 'package:fees_up/utils/edit_admin_dialog_util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../view_models/admin_profile_view_model.dart';
import '../view_models/dashboard_view_model.dart';

class AdminProfilePage extends StatelessWidget {
  const AdminProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // Ensure the VM is loaded every time the page is accessed
      create: (_) => AdminProfileViewModel()..loadProfileData(),
      child: const _AdminProfileView(),
    );
  }
}

class _AdminProfileView extends StatelessWidget {
  const _AdminProfileView();

  // Helper method restored
  void _showTodoSnack(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$feature is coming in the next update! 📊"),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminProfileViewModel>();
    final colorScheme = Theme.of(context).colorScheme;

    // --- Dynamic Avatar/Image Logic ---
    final String initial = vm.schoolName.isNotEmpty
        ? vm.schoolName.substring(0, 1).toUpperCase()
        : '?';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // ──────────────────────────────────────────────
          // 1. BIG HEADER (SLIVER) - Updated to show Avatar
          // ──────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: colorScheme.surface,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      colorScheme.primary.withAlpha(51),
                      colorScheme.surface,
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    // 🛑 UPDATED AVATAR DISPLAY
                    CircleAvatar(
                      // Fallback if no URL is saved in DB
                      radius: 40,
                      backgroundColor: colorScheme.primary,
                      child: Text(
                        initial,
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // ... (Text fields remain the same) ...
                    Text(
                      vm.adminName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      vm.schoolName,
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurface.withAlpha(153),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ──────────────────────────────────────────────
          // 2. LIFETIME STATS (No change)
          // ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _StatCard(
                    title: "Total Revenue",
                    value: vm.isLoading ? "..." : vm.lifetimeRevenueStr,
                    icon: Icons.account_balance_wallet_rounded,
                    color: Colors.greenAccent,
                  ),
                  const SizedBox(width: 16),
                  _StatCard(
                    title: "Total Students",
                    value: vm.isLoading ? "..." : vm.totalStudentsStr,
                    icon: Icons.groups_rounded,
                    color: Colors.orangeAccent,
                  ),
                ],
              ),
            ),
          ),

          // ──────────────────────────────────────────────
          // 3. SETTINGS & ANALYTICS LIST
          // ──────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const _SectionHeader("Detailed Analytics"),

                _SettingsTile(
                  icon: Icons.bar_chart_rounded,
                  title: "Revenue Reports",
                  subtitle: "Monthly income breakdown",
                  onTap: () => context.push('/revenueReports'),
                ),

                _SettingsTile(
                  icon: Icons.trending_up_rounded,
                  title: "Student Growth",
                  subtitle: "Enrollment trends over time",
                  onTap: () => context.push('/studentGrowth'),
                ),

                const SizedBox(height: 24),

                // --- GENERAL SETTINGS ---
                const _SectionHeader("General"),
                _SettingsTile(
                  icon: Icons.edit_rounded,
                  title: "Edit School Details",
                  subtitle: "Change name and contact info",
                  onTap: () {
                    // 🛑 CHANGE THIS LOGIC
                    // context.push('/profile/edit');

                    // 🛑 TO THIS: Show as a centered dialog
                    showDialog(
                      context: context,
                      builder: (context) => const EditAdminDialogUtil(),
                    ).then((result) {
                      if (result == true && context.mounted) {
                        // Reload dashboard/profile data if changes were saved (result == true)
                        Provider.of<AdminProfileViewModel>(
                          context,
                          listen: false,
                        ).loadProfileData();
                      }
                    });
                  },
                ),
                _SettingsTile(
                  icon: Icons.lock_outline_rounded,
                  title: "Security",
                  subtitle: "Change App PIN / Password",
                  onTap: () => _showTodoSnack(context, "Security Settings"),
                ),

                const SizedBox(height: 24),

                // --- DATA MANAGEMENT (No Change) ---
                const _SectionHeader("Data Management"),
                _SettingsTile(
                  icon: Icons.download_rounded,
                  title: "Backup Data",
                  subtitle: "Export JSON to google",
                  onTap: () async {
                    //await vm.loadProfileData();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Coming Soon! 📤")),
                      );
                    }
                  },
                ),

                // DANGER ZONE (No Change)
                _SettingsTile(
                  icon: Icons.delete_forever_rounded,
                  title: "Wipe All Data",
                  subtitle: "Reset app to factory settings",
                  isDanger: true,
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Critical Action"),
                        content: const Text(
                          "This will permanently delete ALL students, bills, and payments.\n\nThis cannot be undone.",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: const Text("Wipe Everything"),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      // 🛑 DIRECT DB ACCESS: Wipes tables immediately
                      await DatabaseService().wipeAllBusinessData();

                      if (context.mounted) {
                        // Refresh Dashboard VM to reflect empty state
                        Provider.of<DashboardViewModel>(
                          context,
                          listen: false,
                        ).loadDashboard();

                        // Refresh Profile VM to update stats to 0
                        Provider.of<AdminProfileViewModel>(
                          context,
                          listen: false,
                        ).loadProfileData();

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("System wiped successfully."),
                          ),
                        );
                      }
                    }
                  },
                ),

                const SizedBox(height: 40),
                Center(
                  child: Text(
                    "Fees Up v1.0.0",
                    style: TextStyle(
                      color: Colors.grey.withAlpha(128),
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// --- HELPER WIDGETS ---

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            // 30% opacity
            color: scheme.tertiary.withAlpha(76),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                // 60% opacity
                color: scheme.onSurface.withAlpha(153),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDanger;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = isDanger ? Colors.redAccent : scheme.onSurface;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDanger
              ? Colors.red.withAlpha(76) // 30% opacity
              : scheme.tertiary.withAlpha(51), // 20% opacity
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDanger
                ? Colors.red.withAlpha(25) // 10% opacity
                : scheme.primary.withAlpha(25), // 10% opacity
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isDanger ? Colors.red : scheme.primary,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: color,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: scheme.onSurface.withAlpha(128), // 50% opacity
            fontSize: 12,
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: Colors.grey,
        ),
      ),
    );
  }
}
