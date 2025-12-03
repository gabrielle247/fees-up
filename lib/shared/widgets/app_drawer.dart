import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ⚠️ ASSUMED RIVERPOD CONTROLLERS (Adjust imports/names as needed)
import '../../features/view_models/dashboard_controller.dart'; 

// Placeholder for your Notification Controller (must be a Riverpod provider)
// Define your actual Notification State and Controller classes outside the drawer
//final notificationControllerProvider = StateNotifierProvider<NotificationController, NotificationState>((ref) => NotificationController());

// class NotificationState {
// }

// class NotificationController {
// } 
// --- END ASSUMED RIVERPOD CONTROLLERS ---

final SupabaseClient _supabase = Supabase.instance.client;

// -----------------------------------------------------------------------------
// ⚙️ WIDGET DEFINITION (ConsumerWidget for Riverpod)
// -----------------------------------------------------------------------------

class AppDrawer extends ConsumerWidget {
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
            onPressed: () {
              Navigator.of(ctx).pop(true); // User confirms
            },
            child: const Text("Logout", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    // 3. Process the confirmation
    if (confirm == true) {
      try {
        await _supabase.auth.signOut();
        
        // 4. Navigate to the Login Page and clear the entire stack
        if (context.mounted) {
          context.go('/login'); 
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Successfully logged out.")),
          );
        }
      } catch (e) {
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
  Widget build(BuildContext context, WidgetRef ref) { // 🔑 WidgetRef for Riverpod access
    final colorScheme = Theme.of(context).colorScheme;

    // Define border side
    final borderSide = BorderSide(
      color: colorScheme.tertiary.withAlpha(77),
      width: 1,
    );

    // Helper to refresh dashboard using Riverpod
    void refreshDashboard() {
        // Reads the controller notifier to call its refresh method
        ref.read(dashboardControllerProvider.notifier).refresh(); 
    }
    
    // Watch the notification provider for badge logic
    // This assumes your notification controller exposes a state with hasNotifications/unreadCount
    // final notifState = ref.watch(notificationControllerProvider); 
    // final bool hasNotifications = notifState.hasNotifications;
    // final int unreadCount = notifState.unreadCount;


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
            height: 120, 
            width: double.infinity,
            padding: const EdgeInsets.only(top: 40, left: 16),
            alignment: Alignment.centerLeft,
            child: Text(
              "FeesUp Admin",
              style: TextStyle(
                color: colorScheme.primary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // ──────────────────────────────────────────────
          // 2. MENU ITEMS
          // ──────────────────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                // Dashboard
                _DrawerTile(
                  icon: Icons.dashboard_rounded,
                  title: "Dashboard",
                  onTap: () {
                    context.pop(); // Close drawer
                    // Navigating to '/' is redundant if already on dashboard, but safe.
                    context.go('/');
                  },
                  isActive: true, // Assuming this is the active route
                ),

                const SizedBox(height: 8),

                // Register Student
                _DrawerTile(
                  icon: Icons.person_add_alt_1_rounded,
                  title: "Register Student",
                  onTap: () async {
                    context.pop(); // Close drawer
                    // ⚠️ Use the defined router path
                    await context.push('/students/add');
                    refreshDashboard();
                  },
                ),

                const SizedBox(height: 8),

                // Search
                _DrawerTile(
                  icon: Icons.search_rounded,
                  title: "Search / Ledger",
                  onTap: () async {
                    context.pop();
                    // ⚠️ Use the defined router path
                    await context.push('/search');
                  },
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Divider(color: Colors.white10),
                ),

                // // ✅ NOTIFICATIONS TILE (Uses Riverpod state)
                // _DrawerTile(
                //       icon: hasNotifications
                //           ? Icons.notifications_active_rounded
                //           : Icons.notifications_rounded,
                //       title: "Notifications",

                //       // BADGE LOGIC
                //       trailing: hasNotifications
                //           ? Container(
                //               padding: const EdgeInsets.all(6),
                //               decoration: const BoxDecoration(
                //                 color: Colors.redAccent,
                //                 shape: BoxShape.circle,
                //               ),
                //               child: Text(
                //                 '$unreadCount',
                //                 style: const TextStyle(
                //                   color: Colors.white,
                //                   fontSize: 12,
                //                   fontWeight: FontWeight.bold,
                //                 ),
                //               ),
                //             )
                //           : null,

                //       onTap: () async {
                //         context.pop();
                //         await context.push('/notifications');

                //         // Ensure the VM refreshes its count when returning
                //         ref.read(notificationControllerProvider.notifier).loadNotifications();
                //       },

                //       isActive: hasNotifications,
                //     ),

                // const SizedBox(height: 8),

                // Monthly Evaluation
                _DrawerTile(
                  icon: Icons.analytics_outlined,
                  title: "Monthly Evaluation",
                  onTap: () async {
                    context.pop();
                    // Assumed valid route
                    await context.push('/evaluation', extra: 0); 
                    refreshDashboard();
                  },
                ),

                const SizedBox(height: 8),

                // Export Reports (Uses Subtitle)
                _DrawerTile(
                  icon: Icons.picture_as_pdf_outlined,
                  title: "Export Reports",
                  subtitle: "Coming Soon",
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
                    context.pop();
                    context.push('/profile');
                  },
                ),
                
                const SizedBox(height: 8),
                
                // 🛑 LOG OUT TILE 🛑
                _DrawerTile(
                  icon: Icons.logout_rounded,
                  title: "Log Out",
                  onTap: () => _showLogoutDialog(context),
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

// -----------------------------------------------------------------------------
// 🧩 HELPER WIDGET FOR DRAWER TILES
// -----------------------------------------------------------------------------
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
    // ignore: unused_element_parameter
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
                  // Note: colorScheme.primary.withValues(alpha: 0.15) changed to standard opacity
                  color: colorScheme.primary.withOpacity(0.15), 
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.primary.withOpacity(0.3),
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
                          // colorScheme.primary.withValues(alpha: 0.6) changed to standard opacity
                          color: colorScheme.primary.withOpacity(0.6), 
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