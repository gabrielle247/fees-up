import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ReportCard extends StatelessWidget {
  final String title;
  final String desc;
  final IconData icon;
  final Color color;
  final List<String> tags;
  final bool isPopular;
  final VoidCallback onTap;

  const ReportCard({
    super.key,
    required this.title,
    required this.desc,
    required this.icon,
    required this.color,
    required this.tags,
    required this.onTap,
    this.isPopular = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      hoverColor: AppColors.textWhite.withValues(alpha: 0.02),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surfaceGrey,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPopular ? AppColors.primaryBlue.withValues(alpha: 0.5) : AppColors.divider,
            width: isPopular ? 1.5 : 1
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                if (isPopular)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text("Most Popular", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(color: AppColors.textWhite, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(desc, style: const TextStyle(color: AppColors.textWhite54, fontSize: 12, height: 1.5), maxLines: 3, overflow: TextOverflow.ellipsis),
            const Spacer(),
            const Divider(color: AppColors.divider),
            const SizedBox(height: 8),
            Row(
              children: [
                ...tags.map((t) => Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(t, style: const TextStyle(color: AppColors.textWhite38, fontSize: 10, fontWeight: FontWeight.w500)),
                )),
                const Spacer(),
                const Icon(Icons.arrow_forward, color: AppColors.textWhite38, size: 16),
              ],
            )
          ],
        ),
      ),
    );
  }
}