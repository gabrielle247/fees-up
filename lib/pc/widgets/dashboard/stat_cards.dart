import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color? iconBgColor;
  final Widget? footer;
  final bool isAlert;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor = Colors.white,
    this.iconBgColor,
    this.footer,
    this.isAlert = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        // FIX: Reduced padding from 20 to 16 to save vertical space (4px saved top + 4px bottom = 8px total)
        padding: const EdgeInsets.all(16), 
        decoration: BoxDecoration(
          color: AppColors.surfaceGrey,
          borderRadius: BorderRadius.circular(16),
          border: isAlert 
              ? const Border(left: BorderSide(color: AppColors.errorRed, width: 4))
              : Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    title.toUpperCase(),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconBgColor ?? Colors.white.withAlpha(12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 18, color: iconColor),
                ),
              ],
            ),
            
            const SizedBox(height: 8), // Reduced gap slightly
            
            // Value
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28, // Kept large font
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            const SizedBox(height: 8), // Reduced gap slightly
            
            // Footer
            if (footer != null) 
              SizedBox(
                height: 24, 
                child: footer!,
              ),
          ],
        ),
      ),
    );
  }
}

class AlertBadge extends StatelessWidget {
  final String text;
  final String subText;

  const AlertBadge({super.key, required this.text, required this.subText});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.errorRed.withAlpha(25),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded, size: 14, color: AppColors.errorRed),
              const SizedBox(width: 4),
              Text(
                text,
                style: const TextStyle(color: AppColors.errorRed, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            subText,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
        ),
      ],
    );
  }
}