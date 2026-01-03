import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class InvoicesStats extends StatelessWidget {
  final VoidCallback onCreateInvoice;

  const InvoicesStats({
    super.key, 
    required this.onCreateInvoice,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140, // Fixed height for uniformity
      child: Row(
        children: [
          // 1. Total Invoiced
          const Expanded(
            child: _StatCard(
              title: "Total Invoiced",
              value: "\$45,231.00",
              subtext: "+12.5% from last month",
              subtextColor: AppColors.successGreen,
              icon: Icons.bar_chart,
              iconColor: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(width: 16),

          // 2. Pending Payment
          const Expanded(
            child: _StatCard(
              title: "Pending Payment",
              value: "\$12,450.00",
              subtext: "45 active invoices",
              subtextColor: AppColors.warningOrange,
              icon: Icons.pending_actions,
              iconColor: AppColors.warningOrange,
            ),
          ),
          const SizedBox(width: 16),

          // 3. Overdue
          const Expanded(
            child: _StatCard(
              title: "Overdue",
              value: "\$2,840.00",
              subtext: "Needs attention (8 students)",
              subtextColor: AppColors.errorRed,
              icon: Icons.warning_amber_rounded,
              iconColor: AppColors.errorRed,
            ),
          ),
          const SizedBox(width: 16),

          // 4. Create New Action Card
          Expanded(
            child: _CreateInvoiceCard(onTap: onCreateInvoice),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtext;
  final Color subtextColor;
  final IconData icon;
  final Color iconColor;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtext,
    required this.subtextColor,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: AppColors.textGrey, fontSize: 13)),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withAlpha(38),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(color: AppColors.textWhite, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(subtext, style: TextStyle(color: subtextColor, fontSize: 12, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}

class _CreateInvoiceCard extends StatelessWidget {
  final VoidCallback onTap;
  const _CreateInvoiceCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceDarkGrey,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider, style: BorderStyle.solid), // Dashed effect requires custom painter, using solid for now to stay clean
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: AppColors.primaryBlue, size: 24),
            ),
            const SizedBox(height: 12),
            const Text(
              "Create New Invoice",
              style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}