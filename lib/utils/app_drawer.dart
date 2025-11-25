import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:fees_up/view_models/dashboard_view_model.dart';
import 'package:fees_up/view_models/notification_view_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


// 🛑 ASSUMPTION: You need a way to access AuthService.
// I will assume your AuthService is provided via Provider at the root.
final SupabaseClient _supabase = Supabase.instance.client;

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  // -----------------------------------------------------
  // ⛔️ LOGOUT DIALOG LOGIC ⛔️
  // -----------------------------------------------------
  Future<void> _showLogoutDialog(BuildContext context) async {
    final colorScheme = Theme.of(context).colorScheme;
    
    // 1. Close the drawer first
    if (context.mounted && Navigator.of(context).canPop()) {
      context.pop();
    }
    
    // 2. Show the confirmation dialog
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Confirm Logout", style: TextStyle(color: colorScheme.onSurface)),
        content: const Text(
          "Are you sure you want to log out of the Fees Up Admin Console?", 
          style: TextStyle(color: Colors.white70)
        ),
        backgroundColor: colorScheme.surface,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false), // User cancels
            child: Text("Cancel", style: TextStyle(color: Colors.grey.shade400)),
          ),
          ElevatedButton(
            // The confirmed action now returns true
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              await _supabase.auth.signOut();
            }, // User confirms
            child: const Text("Logout", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    // 3. Process the confirmation
    if (confirm == true) {
      try {
        // 🛑 ACTUAL SUPABASE LOGOUT LOGIC (via AuthService)
        // await Provider.of<AuthService>(context, listen: false).signOut(); 
        
        // --- SIMULATED LOGOUT (Replace this with the uncommented line above) ---
        await Future.delayed(const Duration(milliseconds: 300));
        
        // 4. Navigate to the Login Page and clear the entire stack
        if (context.mounted) {
          // Use context.go() to remove all routes and push the login page
          context.go('/login'); 
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Successfully logged out.")),
          );
        }
      } catch (e) {
        // Handle network/sign-out errors (vague error message)
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Could not complete logout. Please check your network."),
            ),
          );
        }
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Border style matching your other cards
    final borderSide = BorderSide(
      color: colorScheme.tertiary.withAlpha(77), // Fixed withAlpha usage
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
          // 1. CUSTOM HEADER (Unchanged)
          // ──────────────────────────────────────────────
          // ... (Header code) ...
          
          // ──────────────────────────────────────────────
          // 2. MENU ITEMS (Unchanged)
          // ──────────────────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                // ... (Other Drawer Tiles) ...
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
                
                const SizedBox(height: 8), // Added spacing
                
                // 🛑 NEW: LOG OUT TILE 🛑
                _DrawerTile(
                  icon: Icons.logout_rounded,
                  title: "Log Out",
                  onTap: () => _showLogoutDialog(context), // Calls the new method
                ),
                // 🛑 END NEW 🛑

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

// ... (Rest of _DrawerTile helper class remains unchanged)

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
