import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../view_models/dashboard_view_model.dart';
import '../view_models/notification_view_model.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Border style matching your other cards
    final borderSide = BorderSide(
      color: colorScheme.tertiary.withValues(alpha: 0.3),
      width: 1,
    );

    // Helper to refresh dashboard when returning from a page
    void refreshDashboard() {
      if (context.mounted) {
        Provider.of<DashboardViewModel>(context, listen: false).loadDashboard();
      }
    }

    return Drawer(
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(0),
          bottomRight: Radius.circular(0),
        ),
      ),
      child: Column(
        children: [
          // ──────────────────────────────────────────────
          // 1. CUSTOM HEADER
          // ──────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border(bottom: borderSide),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.school_rounded,
                    size: 32,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Fees Up",
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Admin Console",
                  style: textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ),

          // ──────────────────────────────────────────────
          // 2. MENU ITEMS
          // ──────────────────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                _DrawerTile(
                  icon: Icons.dashboard_rounded,
                  title: "Dashboard",
                  onTap: () {
                    context.pop(); // Close drawer
                  },
                  // We assume we are on dashboard if opening drawer, usually.
                  // You can pass a 'currentRoute' param if you want strict highlighting.
                  isActive: false,
                ),

                const SizedBox(height: 8),

                _DrawerTile(
                  icon: Icons.person_add_alt_1_rounded,
                  title: "Register Student",
                  onTap: () async {
                    context.pop(); // Close drawer
                    await context.push('/addStudent');
                    refreshDashboard();
                  },
                ),

                const SizedBox(height: 8),

                _DrawerTile(
                  icon: Icons.search_rounded,
                  title: "Search / Ledger",
                  onTap: () async {
                    context.pop();
                    await context.push('/search');
                    refreshDashboard();
                  },
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Divider(color: Colors.white10),
                ),

                // ✅ NOTIFICATIONS TILE
                Consumer<NotificationViewModel>(
                  builder: (context, notifVM, child) {
                    return _DrawerTile(
                      icon: notifVM.hasNotifications
                          ? Icons.notifications_active_rounded
                          : Icons.notifications_rounded,
                      title: "Notifications",

                      // BADGE LOGIC
                      trailing: notifVM.hasNotifications
                          ? Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Colors.redAccent,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${notifVM.unreadCount}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : null,

                      // ⬇️ THIS IS THE FIX
                      onTap: () async {
                        // 1. Close Drawer
                        context.pop();

                        // 2. Navigate to the dedicated Notifications Page
                        // (Instead of /evaluation, we go to /notifications)
                        await context.push('/notifications');

                        // 3. Refresh Dashboard count when returning
                        // (In case they marked items as read)
                        refreshDashboard();

                        // Also ensure the VM refreshes its count
                        if (context.mounted) {
                          notifVM.loadNotifications();
                        }
                      },

                      isActive: notifVM.hasNotifications,
                    );
                  },
                ),

                const SizedBox(height: 8),

                _DrawerTile(
                  icon: Icons.analytics_outlined,
                  title: "Monthly Evaluation",
                  onTap: () async {
                    context.pop();
                    await context.push('/evaluation', extra: 0);
                    refreshDashboard();
                  },
                ),

                const SizedBox(height: 8),

                // Export Reports (Uses Subtitle)
                _DrawerTile(
                  icon: Icons.picture_as_pdf_outlined,
                  title: "Export Reports",
                  subtitle: "Coming Soon", // ✅ Used here
                  onTap: () {
                    context.pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("PDF Export coming in next update."),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // ──────────────────────────────────────────────
          // 3. FOOTER
          // ──────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(border: Border(top: borderSide)),
            child: Column(
              children: [
                _DrawerTile(
                  icon: Icons.settings_outlined,
                  title: "Settings",
                  onTap: () {
                    context.pop(); // Close drawer
                    context.push('/profile'); // Navigate
                  },
                ),
                const SizedBox(height: 12),
                const Center(
                  child: Text(
                    "v1.0.0 • Production Build",
                    style: TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- HELPER WIDGET FOR TILES ---
class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool isActive;
  final Widget? trailing;

  const _DrawerTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.isActive = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: isActive
              ? BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.3),
                  ),
                )
              : null,
          child: Row(
            children: [
              Icon(
                icon,
                size: 22,
                color: isActive ? colorScheme.primary : Colors.grey,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: isActive
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: isActive
                            ? colorScheme.onSurface
                            : Colors.grey.shade300,
                        fontSize: 14,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: TextStyle(
                          color: colorScheme.primary.withValues(alpha: 0.6),
                          fontSize: 10,
                        ),
                      ),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}
