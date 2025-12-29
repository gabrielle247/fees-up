import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

class AnnouncementKpiCards extends StatelessWidget {
  const AnnouncementKpiCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildCard(
          "Critical Alerts", "3", 
          Icons.priority_high, AppColors.errorRed, 
          AppColors.errorRedBg
        ),
        const SizedBox(width: 24),
        _buildCard(
          "Unread Notices", "12", 
          Icons.mark_email_unread, AppColors.primaryBlue, 
          AppColors.primaryBlueBg
        ),
        const SizedBox(width: 24),
        _buildCard(
          "Total This Month", "48", 
          Icons.check_circle, AppColors.successGreen, 
          AppColors.successGreenBg
        ),
      ],
    );
  }

  Widget _buildCard(String title, String count, IconData icon, Color color, Color bg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceGrey,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppColors.textWhite70, fontSize: 13)),
                Text(count, style: const TextStyle(color: AppColors.textWhite, fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}