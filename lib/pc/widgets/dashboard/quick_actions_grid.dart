import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  void _showPlaceholderDialog(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceGrey,
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: const Text(
          "This feature is coming soon.\nWe will replace this dialog with the actual form.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Close"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
            child: const Text("Proceed (Mock)"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF15181E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Quick Actions", 
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.3,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildActionBtn(
                  context,
                  Icons.add_card, 
                  "Record\nPayment", 
                  AppColors.primaryBlue.withOpacity(0.2), 
                  AppColors.primaryBlue,
                  () => _showPlaceholderDialog(context, "Record Payment"),
                ),
                _buildActionBtn(
                  context,
                  Icons.receipt, 
                  "Generate\nInvoice", 
                  Colors.white10, 
                  Colors.white,
                  () => _showPlaceholderDialog(context, "Generate Invoice"),
                ),
                _buildActionBtn(
                  context,
                  Icons.account_balance_wallet, 
                  "Manage\nExpenses", 
                  Colors.white10, 
                  Colors.white,
                  () => _showPlaceholderDialog(context, "Manage Expenses"),
                ),
                _buildActionBtn(
                  context,
                  Icons.bar_chart, 
                  "Financial\nReports", 
                  Colors.white10, 
                  Colors.white,
                  () => _showPlaceholderDialog(context, "View Reports"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn(
    BuildContext context,
    IconData icon, 
    String label, 
    Color bg, 
    Color iconColor, 
    VoidCallback onTap
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        hoverColor: Colors.white.withOpacity(0.05),
        child: Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: iconColor, size: 28),
              const SizedBox(height: 8),
              Text(
                label, 
                textAlign: TextAlign.center, 
                style: const TextStyle(color: Colors.white70, fontSize: 12)
              ),
            ],
          ),
        ),
      ),
    );
  }
}