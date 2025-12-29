import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

enum QuickActionType {
  recordPayment,
  addExpense,
  registerStudent,
  createCampaign,
}

class QuickActionItem {
  final String label;
  final IconData icon;
  final Color color;
  final QuickActionType type;

  const QuickActionItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.type,
  });
}

class QuickActionsGrid extends StatelessWidget {
  final Function(QuickActionType) onActionSelected;

  const QuickActionsGrid({
    super.key,
    required this.onActionSelected,
  });

  // --- CONFIGURATION ---
  final List<QuickActionItem> _actions = const [
    QuickActionItem(
      label: "Record Payment",
      icon: Icons.attach_money,
      color: AppColors.successGreen,
      type: QuickActionType.recordPayment,
    ),
    QuickActionItem(
      label: "Add Expense",
      icon: Icons.receipt_long,
      color: AppColors.errorRed,
      type: QuickActionType.addExpense,
    ),
    QuickActionItem(
      label: "New Student",
      icon: Icons.person_add,
      color: AppColors.primaryBlueLight,
      type: QuickActionType.registerStudent,
    ),
    QuickActionItem(
      label: "New Campaign",
      icon: Icons.campaign,
      color: AppColors.accentPurple,
      type: QuickActionType.createCampaign,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // This Container fills the Zone (400px height)
    return Container(
      padding: const EdgeInsets.all(24), 
      decoration: BoxDecoration(
        color: AppColors.surfaceGrey,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Quick Actions",
            style: TextStyle(
              color: AppColors.textWhite,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // Use Spacers to distribute buttons evenly within the 400px fixed height
          // This avoids stretching the buttons themselves.
          Expanded(
            child: Row(
              children: [
                Expanded(child: _buildActionCard(_actions[0])),
                const SizedBox(width: 16),
                Expanded(child: _buildActionCard(_actions[1])),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              children: [
                Expanded(child: _buildActionCard(_actions[2])),
                const SizedBox(width: 16),
                Expanded(child: _buildActionCard(_actions[3])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(QuickActionItem action) {
    // Material wraps the InkWell for the ripple effect
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onActionSelected(action.type),
        borderRadius: BorderRadius.circular(12),
        hoverColor: AppColors.textWhite.withValues(alpha: 0.04),
        child: Container(
          width: double.infinity, // Fill width of the grid cell
          // Note: No fixed height here; the 'Expanded' in the parent layout handles height allocation
          // but because there are only 2 rows in 400px (minus text/padding), 
          // they will naturally be about 130px tall, which is a good aspect ratio.
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.textWhite.withValues(alpha: 0.06)),
            color: AppColors.textWhite.withValues(alpha: 0.02),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: action.color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(action.icon, color: action.color, size: 24),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  action.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textWhite70,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}