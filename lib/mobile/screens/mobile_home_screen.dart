import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../data/providers/dashboard_provider.dart';
import '../widgets/dashboard/mobile_dashboard_widgets.dart';
import '../../pc/widgets/dashboard/stat_cards.dart'; 
// Removed unused import: revenue_chart.dart

class MobileHomeScreen extends ConsumerStatefulWidget {
  const MobileHomeScreen({super.key});

  @override
  ConsumerState<MobileHomeScreen> createState() => _MobileHomeScreenState();
}

class _MobileHomeScreenState extends ConsumerState<MobileHomeScreen> {
  
  // Calculate index based on current route for visual state
  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/transactions')) return 1;
    if (location.startsWith('/students')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0;
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/transactions');
        break;
      case 2:
        context.go('/students');
        break;
      case 3:
        context.go('/profile'); // We will add this mock route
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboardAsync = ref.watch(dashboardDataProvider);
    final int navIndex = _calculateSelectedIndex(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      
      body: dashboardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err", style: const TextStyle(color: Colors.white))),
        data: (data) => Scaffold( 
          backgroundColor: AppColors.backgroundBlack,
          
          appBar: AppBar(
            backgroundColor: AppColors.backgroundBlack,
            elevation: 0,
            title: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.surfaceGrey,
                  radius: 18,
                  child: Text(data.userName.isNotEmpty ? data.userName[0] : "U", style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Hello, ${data.userName.split(' ')[0]}", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text(data.schoolName, style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.5))),
                  ],
                ),
              ],
            ),
            actions: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none, color: Colors.white)),
            ],
          ),

          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Dashboard", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),

                // KPI CARDS CAROUSEL
                SizedBox(
                  height: 170,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      MobileStatCard(
                        title: "Outstanding",
                        value: NumberFormat.simpleCurrency().format(data.outstandingBalance),
                        icon: Icons.receipt_long,
                        iconColor: AppColors.errorRed,
                        iconBgColor: const Color(0x22CF6679),
                        isAlert: data.outstandingBalance > 0,
                        footer: AlertBadge(text: "Live", subText: "Updated via Sync"),
                      ),
                      MobileStatCard(
                        title: "Students",
                        value: data.studentCount.toString(),
                        icon: Icons.school,
                        iconColor: AppColors.primaryBlue,
                        iconBgColor: const Color(0x222962FF),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // RECENT PAYMENTS LIST (Real Data)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Recent Transactions", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    TextButton(onPressed: () {}, child: const Text("View All", style: TextStyle(fontSize: 12))),
                  ],
                ),
                
                if (data.recentPayments.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text("No transactions yet.", style: TextStyle(color: Colors.grey)),
                  ),

                ...data.recentPayments.map((payment) => MobileTransactionTile(
                  name: payment['payer_name'] ?? 'Unknown',
                  date: payment['date_paid'] != null 
                        ? DateFormat('MMM d, h:mm a').format(DateTime.parse(payment['date_paid'])) 
                        : '',
                  amount: NumberFormat.simpleCurrency().format(payment['amount']),
                  isPaid: true,
                )),
                
                const SizedBox(height: 80),
              ],
            ),
          ),
          
          // BOTTOM NAV
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.white10))),
            child: BottomNavigationBar(
              backgroundColor: AppColors.surfaceGrey,
              currentIndex: navIndex,
              onTap: _onItemTapped, // Triggers navigation
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
        ),
      ),
    );
  }
}