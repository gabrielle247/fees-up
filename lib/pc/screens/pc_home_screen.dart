import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/dashboard/sidebar.dart';
import '../widgets/dashboard/stat_cards.dart';
import '../widgets/dashboard/revenue_chart.dart';

class PCHomeScreen extends StatelessWidget {
  const PCHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      body: Row(
        children: [
          // 1. LEFT SIDEBAR
          const DashboardSidebar(),

          // 2. MAIN CONTENT AREA
          Expanded(
            child: Column(
              children: [
                // A. TOP BAR
                _buildTopBar(),

                // B. SCROLLABLE DASHBOARD CONTENT
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // HEADER: Overview
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Overview", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                                Text("Financial status and daily operations at a glance.", style: TextStyle(color: Colors.white54)),
                              ],
                            ),
                            Row(
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.download_rounded, size: 18),
                                  label: const Text("Export Ledger"),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    side: const BorderSide(color: Colors.white24),
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.add_card_rounded, size: 18),
                                  label: const Text("Record Payment"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryBlue,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // C. KPI CARDS ROW
                        const SizedBox(
                          height: 180,
                          child: Row(
                            children: [
                              StatCard(
                                title: "Outstanding Bills",
                                value: "\$12,450",
                                icon: Icons.receipt_long,
                                iconColor: AppColors.errorRed,
                                iconBgColor: Color(0x22CF6679),
                                isAlert: true,
                                footer: AlertBadge(text: "Needs Attention", subText: "45 active accounts"),
                              ),
                              StatCard(
                                title: "Fundraising Goal",
                                value: "65%",
                                icon: Icons.volunteer_activism,
                                iconColor: Color(0xFFA855F7), // Purple
                                iconBgColor: Color(0x22A855F7),
                                footer: LinearProgressIndicator(value: 0.65, color: Color(0xFFA855F7), backgroundColor: Colors.white10),
                              ),
                              StatCard(
                                title: "Daily Attendance",
                                value: "94%",
                                icon: Icons.check_circle,
                                iconColor: AppColors.successGreen,
                                iconBgColor: Color(0x2200C853),
                                footer: Text("+2.4% compared to last week", style: TextStyle(color: Colors.white38, fontSize: 11)),
                              ),
                              StatCard(
                                title: "Active Students",
                                value: "850",
                                icon: Icons.school,
                                iconColor: AppColors.primaryBlue,
                                iconBgColor: Color(0x222962FF),
                                footer: Text("Total Capacity: 1,000", style: TextStyle(color: Colors.white38, fontSize: 11)),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // D. MIDDLE SECTION: Chart + Quick Actions
                        SizedBox(
                          height: 320,
                          child: Row(
                            children: [
                              // CHART (Takes 2/3 width)
                              const Expanded(flex: 2, child: RevenueChart()),
                              const SizedBox(width: 24),
                              // QUICK ACTIONS (Takes 1/3 width)
                              Expanded(flex: 1, child: _buildQuickActionsGrid()),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // E. BOTTOM SECTION: Recent Payments Table
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Recent Payments", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                  TextButton(onPressed: (){}, child: const Text("View All Transactions")),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildPaymentRow("Alex Morgan", "Oct 24, 2025", "Tuition Fee - Term 2", "\$1,200.00", true),
                              const Divider(color: Colors.white10),
                              _buildPaymentRow("Sarah Connor", "Oct 24, 2025", "Bus Levy", "\$150.00", true),
                              const Divider(color: Colors.white10),
                              _buildPaymentRow("John Wick", "Oct 23, 2025", "Uniform", "\$85.00", false),
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
        ],
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildTopBar() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        children: [
          const Text("Financial Dashboard", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const Spacer(),
          // Search Bar
          Container(
            width: 300,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
            child: const Row(
              children: [
                Icon(Icons.search, color: Colors.white38, size: 20),
                SizedBox(width: 8),
                Text("Search payments, invoices...", style: TextStyle(color: Colors.white38, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(width: 24),
          const Icon(Icons.notifications_outlined, color: Colors.white70),
          const SizedBox(width: 16),
          const Icon(Icons.help_outline, color: Colors.white70),
          const SizedBox(width: 24),
          const VerticalDivider(color: Colors.white10, indent: 15, endIndent: 15),
          const SizedBox(width: 16),
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("Jane Doe", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              Text("Finance Admin", style: TextStyle(color: Colors.white54, fontSize: 11)),
            ],
          ),
          const SizedBox(width: 12),
          const CircleAvatar(backgroundColor: Colors.white24, child: Text("JD", style: TextStyle(color: Colors.white, fontSize: 12))),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF15181E), // Slightly darker for contrast
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Financial Quick Actions", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.3,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildActionBtn(Icons.add_card, "Record\nPayment", AppColors.primaryBlue.withOpacity(0.2), AppColors.primaryBlue),
                _buildActionBtn(Icons.receipt, "Generate\nInvoice", Colors.white10, Colors.white),
                _buildActionBtn(Icons.account_balance_wallet, "Manage\nExpenses", Colors.white10, Colors.white),
                _buildActionBtn(Icons.bar_chart, "Financial\nReports", Colors.white10, Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn(IconData icon, String label, Color bg, Color iconColor) {
    return Container(
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
          Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 12)),
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
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text(date, style: const TextStyle(color: Colors.white38, fontSize: 12)),
              ],
            ),
          ),
          Expanded(flex: 3, child: Text(desc, style: const TextStyle(color: Colors.white70))),
          Expanded(flex: 1, child: Text(amount, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isPaid ? AppColors.successGreen.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
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