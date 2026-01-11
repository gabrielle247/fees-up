import 'package:flutter/material.dart';
import 'package:fees_up/data/constants/app_colors.dart';

class PlaceholderCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  const PlaceholderCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceGrey,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.surfaceLightGrey),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue_20,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.primaryBlue, size: 20),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold)),
                Text(subtitle, style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
              ],
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, color: AppColors.textGrey, size: 16),
          ],
        ),
      ),
    );
  }
}