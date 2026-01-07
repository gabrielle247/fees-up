import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/navigation_constants.dart';
import 'common/sidebar_item_widget.dart';
import 'logout_dialog.dart';

class DashboardSidebar extends StatefulWidget {
  const DashboardSidebar({super.key});

  @override
  State<DashboardSidebar> createState() => _DashboardSidebarState();
}

class _DashboardSidebarState extends State<DashboardSidebar> {
  
  /// Calculates the active index to highlight the correct item
  /// Returns a unique ID or index for logic if needed.
  String _getCurrentRoute(BuildContext context) {
    return GoRouterState.of(context).uri.toString();
  }

  bool _isActive(String currentRoute, String itemRoute) {
    if (itemRoute == '/' && currentRoute != '/') return false;
    return currentRoute.startsWith(itemRoute);
  }

  @override
  Widget build(BuildContext context) {
    final currentRoute = _getCurrentRoute(context);

    return Container(
      width: 260,
      color: const Color(0xFF0F1115),
      child: Column(
        children: [
          // 1. BRAND HEADER
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceGrey,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: const Icon(Icons.shield_outlined, color: AppColors.primaryBlue, size: 20),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "School Admin",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      "Financial Portal",
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                    ),
                  ],
                )
              ],
            ),
          ),

          // 2. SCROLLABLE MENU AREA
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                // --- SECTION: OPERATIONS ---
                ...NavigationConstants.operationalItems.map((item) => SidebarItemWidget(
                  icon: item.icon,
                  label: item.label,
                  isSelected: _isActive(currentRoute, item.route),
                  onTap: () => context.go(item.route),
                )),

                const SizedBox(height: 24),
                
                // --- SECTION: MESSAGING ---
                _sectionLabel("MESSAGING"),
                ...NavigationConstants.messagingItems.map((item) => SidebarItemWidget(
                  icon: item.icon,
                  label: item.label,
                  isSelected: _isActive(currentRoute, item.route),
                  onTap: () => context.go(item.route),
                )),
              ],
            ),
          ),

          // 3. BOTTOM PREFERENCES
          const Divider(color: Colors.white10, indent: 20, endIndent: 20),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionLabel("PREFERENCES"),
                
                SidebarItemWidget(
                  icon: Icons.person_outline_rounded,
                  label: "Profile",
                  isSelected: _isActive(currentRoute, '/profile'),
                  onTap: () => context.go('/profile'),
                ),
                const SizedBox(height: 4),

                SidebarItemWidget(
                  icon: Icons.settings_outlined,
                  label: "Settings",
                  isSelected: _isActive(currentRoute, '/settings'),
                  onTap: () => context.go('/settings'),
                ),
                const SizedBox(height: 4),

                SidebarItemWidget(
                  icon: Icons.logout_rounded,
                  label: "Log Out",
                  isSelected: false,
                  isDestructive: true,
                  onTap: () {
                    showDialog(
                      context: context,
                      barrierColor: Colors.black.withValues(alpha: 0.7),
                      builder: (context) => const LogoutDialog(),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 8, top: 4),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.4),
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
