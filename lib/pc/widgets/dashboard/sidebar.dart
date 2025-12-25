import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';

class DashboardSidebar extends StatefulWidget {
  const DashboardSidebar({super.key});

  @override
  State<DashboardSidebar> createState() => _DashboardSidebarState();
}

class _DashboardSidebarState extends State<DashboardSidebar> {
  // Track active index for visual state
  int _selectedIndex = 0; 

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
    return Container(
      width: 260,
      color: const Color(0xFF0F1115), // Slightly darker than main background
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

          // 2. NAVIGATION ITEMS
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _menuItems.length,
              itemBuilder: (context, index) {
                final item = _menuItems[index];
                final isSelected = _selectedIndex == index;

                return _SidebarItem(
                  icon: item['icon'],
                  label: item['label'],
                  isSelected: isSelected,
                  onTap: () {
                    setState(() => _selectedIndex = index);
                    // context.go(item['route']); // Uncomment when routes exist
                  },
                );
              },
            ),
          ),

          // 3. BOTTOM ACTIONS
          const Divider(color: Colors.white10, indent: 20, endIndent: 20),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _SidebarItem(
                  icon: Icons.settings_outlined,
                  label: "Settings",
                  isSelected: false,
                  onTap: () {},
                ),
                const SizedBox(height: 8),
                _SidebarItem(
                  icon: Icons.logout_rounded,
                  label: "Log Out",
                  isSelected: false,
                  isDestructive: true,
                  onTap: () {
                    // Handle Logout Logic
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

// ANIMATED ITEM WIDGET
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
    // Determine Colors based on state
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