import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// -----------------------------------------------------------------------------
// IMPORTS
// -----------------------------------------------------------------------------
import 'package:fees_up/data/constants/app_colors.dart';
import 'package:fees_up/data/constants/app_routes.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. WELCOME HEADER
            const Text(
              'Good morning, Principal',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'Oakridge Elementary School',
              style: TextStyle(
                color: AppColors.textGrey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),

            // 2. PRIMARY ACTION BUTTON
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () => context.push('${AppRoutes.students}/${AppRoutes.addStudent}'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.person_add, color: Colors.white),
                label: const Text(
                  'Add New Student',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 3. FINANCIAL OVERVIEW CARD
            _buildFinancialOverview(),
            const SizedBox(height: 24),

            // 4. STATS GRID
            const Text(
              'Enrollment Stats',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildStatCard('Total Students', '1,240', '+4.2%', Icons.people_outline)),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard('Active Invoices', '86', 'Due this week', Icons.description_outlined, isGrowth: false)),
              ],
            ),
            const SizedBox(height: 32),

            // 5. RECENT PAYMENTS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Payments',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('${AppRoutes.finance}/transactions'),
                  child: const Text('View All', style: TextStyle(color: AppColors.primaryBlue)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildPaymentList(),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // WIDGET BUILDERS
  // ---------------------------------------------------------------------------

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.backgroundBlack,
      elevation: 0,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppColors.primaryBlue,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.school, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          const Text(
            'Fees Up',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          onPressed: () {},
        ),
        const Padding(
          padding: EdgeInsets.only(right: 16.0, left: 8.0),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.surfaceLightGrey,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=principal'), // Mock avatar
          ),
        ),
      ],
    );
  }

  Widget _buildFinancialOverview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceDarkGrey,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceLightGrey.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Academic Year 2024/25',
                style: TextStyle(color: AppColors.textGrey, fontSize: 12),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.greenAccent.withAlpha(30),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'ON TRACK',
                  style: TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Financial Overview',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('COLLECTED', style: TextStyle(color: AppColors.textGrey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    SizedBox(height: 6),
                    Text('\$145,200', style: TextStyle(color: AppColors.primaryBlue, fontSize: 22, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Container(width: 1, height: 40, color: AppColors.surfaceLightGrey),
              const SizedBox(width: 24),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('OWED', style: TextStyle(color: AppColors.textGrey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    SizedBox(height: 6),
                    Text('\$32,800', style: TextStyle(color: Colors.redAccent, fontSize: 22, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String subtext, IconData icon, {bool isGrowth = true}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDarkGrey,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryBlue, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            subtext,
            style: TextStyle(
              color: isGrowth ? Colors.greenAccent : AppColors.textGrey,
              fontSize: 12,
              fontWeight: isGrowth ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentList() {
    // Mock Data
    final payments = [
      {'name': 'Sarah Jenkins', 'grade': 'Grade 4', 'time': '2 mins ago', 'amount': 450.00},
      {'name': 'Marcus Chen', 'grade': 'Grade 2', 'time': '1 hour ago', 'amount': 1200.00},
      {'name': 'Elena Rodriguez', 'grade': 'Grade 6', 'time': '4 hours ago', 'amount': 850.00},
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: payments.length,
      separatorBuilder: (ctx, i) => const SizedBox(height: 12),
      itemBuilder: (ctx, i) {
        final p = payments[i];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceDarkGrey,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.withAlpha(30),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.attach_money, color: Colors.greenAccent, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p['name'] as String,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${p['grade']} • ${p['time']}',
                      style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Text(
                '+\$${(p['amount'] as double).toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        );
      },
    );
  }
}