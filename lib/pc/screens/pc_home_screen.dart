import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../data/providers/dashboard_provider.dart';
import '../widgets/dashboard/sidebar.dart';
import '../widgets/dashboard/stat_cards.dart';
import '../widgets/dashboard/revenue_chart.dart';
import '../widgets/dashboard/quick_actions_grid.dart'; // IMPORTED

class PCHomeScreen extends ConsumerWidget {
  const PCHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardDataProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      body: Row(
        children: [
          const DashboardSidebar(),
          Expanded(
            child: dashboardAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text("Error: $err", style: const TextStyle(color: Colors.white))),
              data: (data) => Column(
                children: [
                  _buildTopBar(data.userName, data.schoolName),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // HEADER
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Overview", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                                  Text("Status for ${data.schoolName}", style: const TextStyle(color: Colors.white54)),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // KPI CARDS ROW (Equal Widths)
                          SizedBox(
                            height: 160, 
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch, 
                              children: [
                                StatCard(
                                  title: "Outstanding Bills",
                                  value: NumberFormat.simpleCurrency().format(data.outstandingBalance),
                                  icon: Icons.receipt_long,
                                  iconColor: AppColors.errorRed,
                                  iconBgColor: const Color(0x22CF6679),
                                  isAlert: data.outstandingBalance > 0,
                                  footer: const AlertBadge(text: "Updated", subText: "Just now"),
                                ),
                                const StatCard(
                                  title: "Fundraising Goal",
                                  value: "65%",
                                  icon: Icons.volunteer_activism,
                                  iconColor: Color(0xFFA855F7),
                                  iconBgColor: Color(0x22A855F7),
                                ),
                                StatCard(
                                  title: "Active Students",
                                  value: data.studentCount.toString(),
                                  icon: Icons.school,
                                  iconColor: AppColors.primaryBlue,
                                  iconBgColor: const Color(0x222962FF),
                                  footer: const Text("Enrolled", style: TextStyle(color: Colors.white38, fontSize: 11)),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // CHART & ACTIONS ROW
                          const SizedBox(
                            height: 340,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // REVENUE CHART (66% Width)
                                Expanded(flex: 2, child: RevenueChart()),
                                
                                SizedBox(width: 24),
                                
                                // QUICK ACTIONS (33% Width) - Now using external widget
                                Expanded(flex: 1, child: QuickActionsGrid()),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // RECENT PAYMENTS
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceGrey,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Recent Payments", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 16),
                                
                                if (data.recentPayments.isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.all(20.0),
                                    child: Text("No recent payments found.", style: TextStyle(color: Colors.white54)),
                                  )
                                else
                                  ...data.recentPayments.map((payment) {
                                    return Column(
                                      children: [
                                        _buildPaymentRow(
                                          payment['payer_name'] ?? 'Unknown',
                                          payment['date_paid'] != null 
                                              ? DateFormat('MMM d, yyyy').format(DateTime.parse(payment['date_paid'])) 
                                              : 'Unknown Date',
                                          payment['category'] ?? 'Fee',
                                          NumberFormat.simpleCurrency().format(payment['amount']),
                                          true,
                                        ),
                                        const Divider(color: Colors.white10),
                                      ],
                                    );
                                  }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(String userName, String schoolName) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white10))),
      child: Row(
        children: [
          const Text("Financial Dashboard", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const Spacer(),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(userName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              Text(schoolName, style: const TextStyle(color: Colors.white54, fontSize: 11)),
            ],
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            backgroundColor: Colors.white24, 
            child: Text(userName.isNotEmpty ? userName[0] : "U", style: const TextStyle(color: Colors.white, fontSize: 12))
          ),
        ],
      ),
    );
  }
  
  Widget _buildPaymentRow(String name, String date, String desc, String amount, bool isPaid) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const CircleAvatar(radius: 16, backgroundColor: Colors.white10, child: Icon(Icons.person, size: 16, color: Colors.white54)),
          const SizedBox(width: 12),
          Expanded(flex: 2, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(color: Colors.white)), Text(date, style: const TextStyle(color: Colors.white38, fontSize: 12))])),
          Expanded(flex: 3, child: Text(desc, style: const TextStyle(color: Colors.white70))),
          Expanded(flex: 1, child: Text(amount, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isPaid ? AppColors.successGreen.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              isPaid ? "Paid" : "Pending",
              style: TextStyle(color: isPaid ? AppColors.successGreen : Colors.orange, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}