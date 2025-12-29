import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class TransactionsKpiCards extends StatelessWidget {
  const TransactionsKpiCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildCard(
          title: "TOTAL INCOME",
          value: "\$124,500",
          icon: Icons.trending_up,
          color: AppColors.successGreen,
        ),
        const SizedBox(width: 24),
        _buildCard(
          title: "TOTAL EXPENSES",
          value: "\$42,100",
          icon: Icons.trending_down,
          color: AppColors.errorRed,
        ),
        const SizedBox(width: 24),
        _buildCard(
          title: "PENDING",
          value: "\$8,350",
          icon: Icons.pending_actions,
          color: AppColors.primaryBlue,
        ),
        const SizedBox(width: 24),
        _buildCard(
          title: "DONATIONS",
          value: "\$15,200",
          icon: Icons.volunteer_activism,
          color: AppColors.accentPurple,
        ),
      ],
    );
  }

  Widget _buildCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
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
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textWhite54,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}