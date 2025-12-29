import 'package:fees_up/pc/widgets/logout_dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';

class DashboardSidebar extends StatefulWidget {
  const DashboardSidebar({super.key});

  @override
  State<DashboardSidebar> createState() => _DashboardSidebarState();
}

class _DashboardSidebarState extends State<DashboardSidebar> {
  
  /// Calculates the active index based on the current URI.
  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    
    if (location.startsWith('/transactions')) return 1;
    if (location.startsWith('/invoices')) return 2;
    if (location.startsWith('/students')) return 3;
    if (location.startsWith('/reports')) return 4;
    if (location.startsWith('/announcements')) return 5;
    
    // Bottom items return -1 to ensure the main list isn't highlighted
    if (location.startsWith('/profile')) return -1; 
    if (location.startsWith('/settings')) return -1;

    // Default to Overview
    if (location == '/' || location.startsWith('/overview')) return 0;
    
    return -1; 
  }

  final List<Map<String, dynamic>> _menuItems = [
    {'icon': Icons.grid_view_rounded, 'label': 'Overview', 'route': '/'},
    {'icon': Icons.receipt_long_rounded, 'label': 'Transactions', 'route': '/transactions'},
    {'icon': Icons.description_outlined, 'label': 'Invoices', 'route': '/invoices'},
    {'icon': Icons.school_outlined, 'label': 'Students', 'route': '/students'},
    {'icon': Icons.bar_chart_rounded, 'label': 'Reports', 'route': '/reports'},
    {'icon': Icons.campaign_outlined, 'label': 'Announcements', 'route': '/announcements'},
  ];

  @override
  Widget build(BuildContext context) {
    final int selectedIndex = _calculateSelectedIndex(context);
    final String location = GoRouterState.of(context).uri.toString();
    
    final bool isSettingsSelected = location.startsWith('/settings');
    final bool isProfileSelected = location.startsWith('/profile');

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
                      style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                    ),
                  ],
                )
              ],
            ),
          ),

          const SizedBox(height: 10),

          // 2. MAIN NAVIGATION
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _menuItems.length,
              itemBuilder: (context, index) {
                final item = _menuItems[index];
                return _SidebarItem(
                  icon: item['icon'],
                  label: item['label'],
                  isSelected: selectedIndex == index,
                  onTap: () => context.go(item['route']),
                );
              },
            ),
          ),

          // 3. BOTTOM ACTIONS (PREFERENCES GROUP)
          const Divider(color: Colors.white10, indent: 20, endIndent: 20),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Group Label
                Padding(
                  padding: const EdgeInsets.only(left: 12, bottom: 12, top: 4),
                  child: Text(
                    "PREFERENCES",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                
                // Profile Item
                _SidebarItem(
                  icon: Icons.person_outline_rounded,
                  label: "Profile",
                  isSelected: isProfileSelected,
                  onTap: () => context.go('/profile'),
                ),
                const SizedBox(height: 4),

                // Settings Item
                _SidebarItem(
                  icon: Icons.settings_outlined,
                  label: "Settings",
                  isSelected: isSettingsSelected,
                  onTap: () => context.go('/settings'),
                ),
                const SizedBox(height: 4),

                // Log Out Item
                _SidebarItem(
                  icon: Icons.logout_rounded,
                  label: "Log Out",
                  isSelected: false,
                  isDestructive: true,
                  onTap: () {
                    showDialog(
                      context: context,
                      barrierColor: Colors.black.withOpacity(0.7),
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
}

class _SidebarItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isDestructive;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    this.isDestructive = false,
    required this.onTap,
  });

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final Color bgColor = widget.isSelected
        ? AppColors.primaryBlue
        : (_isHovered ? Colors.white.withOpacity(0.05) : Colors.transparent);

    final Color textColor = widget.isDestructive
        ? AppColors.errorRed
        : (widget.isSelected ? Colors.white : Colors.white70);

    final Color iconColor = widget.isDestructive
        ? AppColors.errorRed
        : (widget.isSelected ? Colors.white : Colors.white54);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(widget.icon, size: 20, color: iconColor),
              const SizedBox(width: 12),
              Text(
                widget.label,
                style: TextStyle(
                  color: textColor,
                  fontWeight: widget.isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}