import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class SidebarItemWidget extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isDestructive;
  final VoidCallback onTap;

  const SidebarItemWidget({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    this.isDestructive = false,
    required this.onTap,
  });

  @override
  State<SidebarItemWidget> createState() => _SidebarItemWidgetState();
}

class _SidebarItemWidgetState extends State<SidebarItemWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final Color bgColor = widget.isSelected
        ? AppColors.primaryBlue
        : (_isHovered ? Colors.white.withValues(alpha: 0.05) : Colors.transparent);

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
