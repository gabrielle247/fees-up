import 'package:flutter/material.dart';

/// Define your action types here to make it easy to switch between them
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
  /// The parent widget will provide the logic for what happens on tap
  final Function(QuickActionType) onActionSelected;

  const QuickActionsGrid({
    super.key,
    required this.onActionSelected,
  });

  // -----------------------------------------------------------
  // CONFIGURATION: Add new buttons here
  // -----------------------------------------------------------
  final List<QuickActionItem> _actions = const [
    QuickActionItem(
      label: "Record Payment",
      icon: Icons.attach_money,
      color: Color(0xFF4ADE80), // Green
      type: QuickActionType.recordPayment,
    ),
    QuickActionItem(
      label: "Add Expense",
      icon: Icons.receipt_long,
      color: Color(0xFFF87171), // Red
      type: QuickActionType.addExpense,
    ),
    QuickActionItem(
      label: "New Student",
      icon: Icons.person_add,
      color: Color(0xFF60A5FA), // Blue
      type: QuickActionType.registerStudent,
    ),
    QuickActionItem(
      label: "New Campaign",
      icon: Icons.campaign,
      color: Color(0xFFA78BFA), // Purple
      type: QuickActionType.createCampaign,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    const surfaceColor = Color(0xFF1F2227); // Matching PaymentDialog
    const borderColor = Colors.white10;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Quick Actions",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5, // Wider buttons
              ),
              itemCount: _actions.length,
              itemBuilder: (context, index) {
                return _buildActionCard(_actions[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(QuickActionItem action) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onActionSelected(action.type),
        borderRadius: BorderRadius.circular(12),
        hoverColor: Colors.white.withAlpha(10),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withAlpha(15)),
            color: Colors.white.withAlpha(5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: action.color.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: Icon(action.icon, color: action.color, size: 22),
              ),
              const SizedBox(height: 10),
              Text(
                action.label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}