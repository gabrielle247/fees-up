import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// -----------------------------------------------------------------------------
// IMPORTS
// -----------------------------------------------------------------------------
import 'package:fees_up/data/constants/app_colors.dart';
import 'package:fees_up/data/constants/app_routes.dart';

class FinanceScreen extends StatelessWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundBlack,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {}, // Open Drawer
        ),
        title: const Text(
          'Finance Overview',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. TOP STATS ROW
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'REVENUE',
                    amount: '\$24,850',
                    subtitle: '+12.5% vs last month',
                    icon: Icons.attach_money,
                    color: Colors.greenAccent,
                    isPositive: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    title: 'PENDING',
                    amount: '\$4,210',
                    subtitle: '! 18 Unpaid invoices',
                    icon: Icons.pending_actions_outlined,
                    color: Colors.orangeAccent,
                    isPositive: false,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 2. COLLECTIONS TREND CHART
            _buildChartSection(),

            const SizedBox(height: 24),

            // 3. RECENT ACTIVITY HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Activity',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('${AppRoutes.finance}/transactions'),
                  child: const Text('See All', style: TextStyle(color: AppColors.primaryBlue)),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // 4. ACTIVITY LIST
            _buildActivityItem(
              name: 'James Wilson',
              description: 'Tuition Fee • Grade 4',
              amount: '+\$1,200',
              time: 'Today, 2:45 PM',
              isIncome: true,
            ),
            const SizedBox(height: 12),
            _buildActivityItem(
              name: 'Sarah Chen',
              description: 'Lab Fee • Grade 10',
              amount: '+\$350',
              time: 'Today, 11:20 AM',
              isIncome: true,
            ),
            const SizedBox(height: 12),
            _buildActivityItem(
              name: 'Invoice Overdue',
              description: 'Robert Smith • Grade 2',
              amount: '\$1,500',
              time: 'Due Yesterday',
              isIncome: false,
              isWarning: true,
            ),

            const SizedBox(height: 80), // Space for bottom button
          ],
        ),
      ),
      
      // 5. BOTTOM ACTION BUTTON
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () {
               // Assuming "Generate Invoice" goes to Fee Structures to select a fee to bill
               context.push('${AppRoutes.finance}/${AppRoutes.feeStructures}');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
            ),
            icon: const Icon(Icons.add_circle_outline, color: Colors.white),
            label: const Text(
              'Generate New Invoice',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HELPER WIDGETS
  // ---------------------------------------------------------------------------

  Widget _buildStatCard({
    required String title,
    required String amount,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isPositive,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDarkGrey,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceLightGrey.withAlpha(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textGrey,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: isPositive ? Colors.greenAccent : Colors.redAccent,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceDarkGrey,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceLightGrey.withAlpha(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Collections Trend',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Academic Year 2023-24',
                    style: TextStyle(color: AppColors.textGrey, fontSize: 12),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(50),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Text('Monthly', style: TextStyle(color: Colors.white, fontSize: 12)),
                    SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down, color: AppColors.textGrey, size: 16),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // CUSTOM BAR CHART VISUALIZER
          SizedBox(
            height: 150,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildBar(heightPct: 0.4, label: 'JAN'),
                _buildBar(heightPct: 0.65, label: 'FEB'),
                _buildBar(heightPct: 0.55, label: 'MAR'),
                _buildBar(heightPct: 0.85, label: 'APR', isActive: true),
                _buildBar(heightPct: 0.7, label: 'MAY'),
                _buildBar(heightPct: 0.95, label: 'JUN'),
                _buildBar(heightPct: 0.6, label: 'JUL'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar({required double heightPct, required String label, bool isActive = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 32,
          height: 120 * heightPct,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryBlue : AppColors.surfaceLightGrey.withAlpha(30),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: TextStyle(
            color: isActive ? AppColors.primaryBlue : AppColors.textGrey,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem({
    required String name,
    required String description,
    required String amount,
    required String time,
    required bool isIncome,
    bool isWarning = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDarkGrey,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceLightGrey.withAlpha(20)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: isWarning 
                ? Colors.redAccent.withAlpha(20) 
                : AppColors.primaryBlue.withAlpha(20),
            child: Icon(
              isWarning ? Icons.priority_high : Icons.person,
              color: isWarning ? Colors.redAccent : AppColors.primaryBlue,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  color: isWarning 
                      ? Colors.redAccent 
                      : (isIncome ? Colors.greenAccent : Colors.white),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                time,
                style: const TextStyle(color: AppColors.textGrey, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}