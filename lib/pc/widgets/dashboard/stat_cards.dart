import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color? iconBgColor;
  final Widget? footer;
  final bool isAlert; // For the "Outstanding Bills" red border style

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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceGrey,
          borderRadius: BorderRadius.circular(16),
          // If alert, show the left red border indicator
          border: isAlert 
              ? const Border(left: BorderSide(color: AppColors.errorRed, width: 4))
              : Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Header: Title + Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconBgColor ?? Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 18, color: iconColor),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Value
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Footer Content (Progress bar, alert badge, etc)
            if (footer != null) footer!,
          ],
        ),
      ),
    );
  }
}

// Helper for the "Needs Attention" badge
class AlertBadge extends StatelessWidget {
  final String text;
  final String subText;

  const AlertBadge({super.key, required this.text, required this.subText});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.errorRed.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
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
        Text(subText, style: const TextStyle(color: Colors.white38, fontSize: 11)),
      ],
    );
  }
}