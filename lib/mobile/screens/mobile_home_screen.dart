import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../widgets/dashboard/mobile_dashboard_widgets.dart';
import '../../pc/widgets/dashboard/stat_cards.dart'; // Reuse AlertBadge
import '../../pc/widgets/dashboard/revenue_chart.dart'; // Reuse the Chart Widget

class MobileHomeScreen extends StatefulWidget {
  const MobileHomeScreen({super.key});

  @override
  State<MobileHomeScreen> createState() => _MobileHomeScreenState();
}

class _MobileHomeScreenState extends State<MobileHomeScreen> {
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      
      // 1. APP BAR
      appBar: AppBar(
        backgroundColor: AppColors.backgroundBlack,
        elevation: 0,
        title: Row(
          children: [
            const CircleAvatar(
              backgroundColor: AppColors.surfaceGrey,
              radius: 18,
              backgroundImage: AssetImage('assets/avatar_placeholder.png'), // Ensure you have this or remove
              child: Icon(Icons.person, size: 20, color: Colors.white54), // Fallback
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Hello, Jane", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                Text("Finance Admin", style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.5))),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {}, 
            icon: const Icon(Icons.search, color: Colors.white)
          ),
          Stack(
            children: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none, color: Colors.white)),
              Positioned(
                right: 12,
                top: 12,
                child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.errorRed, shape: BoxShape.circle)),
              )
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),

      // 2. BODY
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // A. HEADER TEXT
            const Text("Dashboard", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            // B. KPI CARDS CAROUSEL
            SizedBox(
              height: 170,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  const MobileStatCard(
                    title: "Outstanding",
                    value: "\$12,450",
                    icon: Icons.receipt_long,
                    iconColor: AppColors.errorRed,
                    iconBgColor: Color(0x22CF6679),
                    isAlert: true,
                    footer: AlertBadge(text: "Action Needed", subText: "45 Accounts"),
                  ),
                  MobileStatCard(
                    title: "Fundraising",
                    value: "65%",
                    icon: Icons.volunteer_activism,
                    iconColor: const Color(0xFFA855F7),
                    iconBgColor: const Color(0x22A855F7),
                    footer: LinearProgressIndicator(value: 0.65, color: const Color(0xFFA855F7), backgroundColor: Colors.white10, borderRadius: BorderRadius.circular(2)),
                  ),
                  const MobileStatCard(
                    title: "Attendance",
                    value: "94%",
                    icon: Icons.check_circle,
                    iconColor: AppColors.successGreen,
                    iconBgColor: Color(0x2200C853),
                    footer: Text("+2.4% vs last week", style: TextStyle(color: Colors.white38, fontSize: 11)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // C. QUICK ACTIONS GRID
            const Text("Quick Actions", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.6,
              children: [
                MobileQuickAction(icon: Icons.add_card, label: "Record\nPayment", isPrimary: true, onTap: () {}),
                MobileQuickAction(icon: Icons.receipt, label: "Generate\nInvoice", onTap: () {}),
                MobileQuickAction(icon: Icons.people_outline, label: "Manage\nStudents", onTap: () {}),
                MobileQuickAction(icon: Icons.bar_chart, label: "View\nReports", onTap: () {}),
              ],
            ),

            const SizedBox(height: 24),

            // D. REVENUE CHART
            const Text("Revenue Trends", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const SizedBox(
              height: 300, 
              child: RevenueChart(), // Reusing the PC chart logic
            ),

            const SizedBox(height: 24),

            // E. RECENT PAYMENTS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Recent Transactions", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                TextButton(onPressed: () {}, child: const Text("View All", style: TextStyle(fontSize: 12))),
              ],
            ),
            const MobileTransactionTile(name: "Alex Morgan", date: "Today, 10:30 AM", amount: "\$1,200", isPaid: true),
            const MobileTransactionTile(name: "Sarah Connor", date: "Yesterday, 4:15 PM", amount: "\$150", isPaid: true),
            const MobileTransactionTile(name: "John Wick", date: "Oct 23, 2025", amount: "\$85", isPaid: false),
            
            // Bottom Padding for scrolling
            const SizedBox(height: 80),
          ],
        ),
      ),

      // 3. BOTTOM NAVIGATION
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white10)),
        ),
        child: BottomNavigationBar(
          backgroundColor: AppColors.surfaceGrey, // Darker nav bar
          currentIndex: _navIndex,
          onTap: (index) => setState(() => _navIndex = index),
          selectedItemColor: AppColors.primaryBlue,
          unselectedItemColor: Colors.white38,
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: "Transact"),
            BottomNavigationBarItem(icon: Icon(Icons.school_outlined), label: "Students"),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
          ],
        ),
      ),
    );
  }
}