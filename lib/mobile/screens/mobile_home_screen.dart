import 'package:fees_up/mobile/widgets/dashboard/create_school_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../data/providers/dashboard_provider.dart';
import '../../data/services/database_service.dart'; // For connectivity
import '../widgets/dashboard/mobile_dashboard_widgets.dart';
import '../../pc/widgets/dashboard/stat_cards.dart';

class MobileHomeScreen extends ConsumerStatefulWidget {
  const MobileHomeScreen({super.key});

  @override
  ConsumerState<MobileHomeScreen> createState() => _MobileHomeScreenState();
}

class _MobileHomeScreenState extends ConsumerState<MobileHomeScreen> {
  // Visual state for nav bar
  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/transactions')) return 1;
    if (location.startsWith('/students')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0;
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      context.go('/');
    } else if (index == 1) {
      context.go('/transactions');
    } else if (index == 2) {
      context.go('/students');
    } else if (index == 3) {
      context.go('/profile');
    }
  }

  void _showCreateSchoolDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Force decision
      builder: (ctx) => const CreateSchoolDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dashboardAsync = ref.watch(dashboardDataProvider);
    final int navIndex = _calculateSelectedIndex(context);

    // Check connectivity status directly from your DatabaseService/PowerSync
    final bool isConnected = DatabaseService().db.currentStatus.connected;

    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      body: dashboardAsync.when(
        // 1. LOADING STATE
        // ignore: prefer_const_constructors
        loading: () => Center(
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.primaryBlue),
              SizedBox(height: 16),
              Text("Loading School Data...",
                  style: TextStyle(color: Colors.white54))
            ],
          ),
        ),

        // 2. ERROR STATE
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline,
                    color: AppColors.errorRed, size: 40),
                const SizedBox(height: 16),
                Text("Error: $err",
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.refresh(dashboardDataProvider),
                  child: const Text("Retry"),
                )
              ],
            ),
          ),
        ),

        // 3. DATA LOADED
        data: (data) {
          // --- LOGIC: CHECK IF SCHOOL EXISTS ---
          // If schoolId is empty or name is "Loading...", we treat it as "No School Found"
          final bool hasSchool =
              data.schoolId.isNotEmpty && data.schoolName != 'Loading...';

          return Scaffold(
            backgroundColor: AppColors.backgroundBlack,

            appBar: AppBar(
              backgroundColor: AppColors.backgroundBlack,
              elevation: 0,
              title: Row(
                children: [
                  // --- PROFILE ICON WITH INTELLIGENT ON-TAP ---
                  InkWell(
                    onTap: () {
                      if (!hasSchool) {
                        // Triggers the global create dialog if school is missing
                        _showCreateSchoolDialog(context);
                      } else {
                        context.go('/profile');
                      }
                    },
                    borderRadius: BorderRadius.circular(50),
                    child: CircleAvatar(
                      backgroundColor: hasSchool
                          ? AppColors.surfaceGrey
                          : AppColors.warningOrange,
                      radius: 18,
                      child: hasSchool
                          ? Text(
                              data.userName.isNotEmpty ? data.userName[0] : "U",
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold))
                          : const Icon(Icons.priority_high,
                              size: 18,
                              color: Colors.black), // Alert Icon if no school
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          // Fallback name if loading
                          data.userName.isEmpty
                              ? "User"
                              : "Hello, ${data.userName.split(' ')[0]}",
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),

                      // Show "Syncing..." or School Name
                      Text(
                          hasSchool
                              ? data.schoolName
                              : (isConnected
                                  ? "Tap to Setup School"
                                  : "Waiting for Sync..."),
                          style: TextStyle(
                              fontSize: 10,
                              color: hasSchool
                                  ? Colors.white.withAlpha(127)
                                  : AppColors.warningOrange)),
                    ],
                  ),
                ],
              ),
              actions: [
                IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications_none,
                        color: Colors.white)),
              ],
            ),

            body: Stack(
              children: [
                // MAIN CONTENT
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Dashboard",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),

                      // KPI CARDS CAROUSEL
                      SizedBox(
                        height: 170,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            MobileStatCard(
                              title: "Outstanding",
                              value: NumberFormat.simpleCurrency()
                                  .format(data.outstandingBalance),
                              icon: Icons.receipt_long,
                              iconColor: AppColors.errorRed,
                              iconBgColor: const Color(0x22CF6679),
                              isAlert: data.outstandingBalance > 0,
                              footer: const AlertBadge(
                                  text: "Live", subText: "Updated via Sync"),
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

                      // RECENT PAYMENTS LIST
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Recent Transactions",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                          TextButton(
                              onPressed: () {},
                              child: const Text("View All",
                                  style: TextStyle(fontSize: 12))),
                        ],
                      ),

                      if (data.recentPayments.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Text("No transactions yet.",
                              style: TextStyle(color: Colors.grey)),
                        ),

                      ...data.recentPayments
                          .map((payment) => MobileTransactionTile(
                                name: payment['payer_name'] ?? 'Unknown',
                                date: payment['date_paid'] != null
                                    ? DateFormat('MMM d, h:mm a').format(
                                        DateTime.parse(payment['date_paid']))
                                    : '',
                                amount: NumberFormat.simpleCurrency()
                                    .format(payment['amount']),
                                isPaid: true,
                              )),

                      const SizedBox(height: 80),
                    ],
                  ),
                ),

                // --- GLOBAL OVERLAY: "NO SCHOOL" BLOCKER ---
                if (!hasSchool)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withAlpha(0.85 * 255 as int), // Dim background
                      child: Center(
                        child: Container(
                          margin: const EdgeInsets.all(24),
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceGrey,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // ICON: Depends on Internet Connection
                              Icon(
                                isConnected
                                    ? Icons.domain_add
                                    : Icons.cloud_off,
                                size: 48,
                                color: isConnected
                                    ? AppColors.primaryBlue
                                    : Colors.grey,
                              ),
                              const SizedBox(height: 16),

                              Text(
                                isConnected
                                    ? "Welcome to Fees Up!"
                                    : "Syncing Data...",
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),

                              // TEXT: Fallback Logic
                              Text(
                                isConnected
                                    ? "It looks like you haven't set up a school yet. Create one to get started."
                                    : "We are waiting for your school data to download. Please check your internet connection.",
                                style: const TextStyle(color: Colors.white70),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),

                              // ACTION BUTTON
                              if (isConnected)
                                ElevatedButton(
                                  onPressed: () =>
                                      _showCreateSchoolDialog(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryBlue,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 32, vertical: 12),
                                  ),
                                  child: const Text("Create School Profile",
                                      style: TextStyle(color: Colors.white)),
                                )
                              else
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: CircularProgressIndicator(
                                      color: Colors.white),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // BOTTOM NAV
            bottomNavigationBar: Container(
              decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.white10))),
              child: BottomNavigationBar(
                backgroundColor: AppColors.surfaceGrey,
                currentIndex: navIndex,
                onTap: _onItemTapped,
                selectedItemColor: AppColors.primaryBlue,
                unselectedItemColor: Colors.white38,
                type: BottomNavigationBarType.fixed,
                showUnselectedLabels: true,
                items: const [
                  BottomNavigationBarItem(
                      icon: Icon(Icons.grid_view_rounded), label: "Home"),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.receipt_long_rounded),
                      label: "Transact"),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.school_outlined), label: "Students"),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.person_outline), label: "Profile"),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}