import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../data/providers/dashboard_provider.dart';
import '../../data/providers/fundraising_provider.dart';
import '../../data/services/database_service.dart'; // Database Access
import '../widgets/dashboard/sidebar.dart';
import '../widgets/dashboard/stat_cards.dart';
import '../widgets/dashboard/revenue_chart.dart';
import '../widgets/dashboard/quick_actions_grid.dart';
import '../widgets/dashboard/payment_dialog.dart'; 
import '../widgets/dashboard/student_dialog.dart';
import '../../mobile/widgets/dashboard/create_school_dialog.dart'; // Reusing the Mobile Dialog

class PCHomeScreen extends ConsumerWidget {
  const PCHomeScreen({super.key});

  void _showCreateSchoolDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const CreateSchoolDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardDataProvider);
    final fundraisingAsync = ref.watch(fundraisingProvider);
    
    // Connectivity Check
    final bool isConnected = DatabaseService().db.currentStatus.connected;

    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      body: Row(
        children: [
          const DashboardSidebar(),
          Expanded(
            child: dashboardAsync.when(
              // 1. LOADING STATE
              loading: () => const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppColors.primaryBlue),
                    SizedBox(height: 16),
                    Text("Loading School Data...", style: TextStyle(color: Colors.white54))
                  ],
                ),
              ),
              
              // 2. ERROR STATE
              error: (err, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.errorRed, size: 40),
                    const SizedBox(height: 16),
                    Text("Error: $err", style: const TextStyle(color: Colors.white)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.refresh(dashboardDataProvider),
                      child: const Text("Retry"),
                    )
                  ],
                ),
              ),

              // 3. DATA LOADED
              data: (data) {
                // Logic: Check if school exists
                final bool hasSchool = data.schoolId.isNotEmpty && data.schoolName != 'Loading...';

                return Stack(
                  children: [
                    // --- MAIN CONTENT LAYER ---
                    Column(
                      children: [
                        _buildTopBar(context, data.userName, data.schoolName, hasSchool, isConnected),

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

                                // KPI CARDS ROW
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
                                      const SizedBox(width: 24),
                                      
                                      // Dynamic Fundraising Card
                                      fundraisingAsync.when(
                                        loading: () => const Expanded(child: Center(child: CircularProgressIndicator())),
                                        error: (_,__) => const Expanded(child: SizedBox()), 
                                        data: (fundData) {
                                          if (fundData == null) {
                                            return const StatCard(
                                              title: "No Active Campaign",
                                              value: "-",
                                              icon: Icons.volunteer_activism,
                                              iconColor: Colors.grey,
                                              iconBgColor: Colors.white10,
                                            );
                                          }
                                          return StatCard(
                                            title: fundData.campaignName, 
                                            value: "${fundData.percentage.toStringAsFixed(1)}%", 
                                            icon: Icons.volunteer_activism,
                                            iconColor: const Color(0xFFA855F7),
                                            iconBgColor: const Color(0x22A855F7),
                                            footer: Text(
                                              "Raised \$${fundData.raisedAmount.toInt()} of \$${fundData.goalAmount.toInt()}",
                                              style: const TextStyle(color: Colors.white38, fontSize: 11)
                                            ),
                                          );
                                        }
                                      ),
                                      
                                      const SizedBox(width: 24),
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
                                SizedBox(
                                  height: 340,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      const Expanded(flex: 2, child: RevenueChart()),
                                      const SizedBox(width: 24),
                                      Expanded(
                                        flex: 1, 
                                        child: QuickActionsGrid(
                                          onActionSelected: (type) => _handleQuickAction(context, type, data.schoolId),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // RECENT PAYMENTS LIST
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

                    // --- GLOBAL OVERLAY: "NO SCHOOL" BLOCKER ---
                    if (!hasSchool)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withAlpha((0.85*255) as int), // Dim background
                          child: Center(
                            child: Container(
                              width: 500, // Limit width on PC
                              margin: const EdgeInsets.all(24),
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceGrey,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha((0.5 * 255) as int),
                                    blurRadius: 30,
                                    offset: const Offset(0, 10),
                                  )
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isConnected ? Icons.domain_add : Icons.cloud_off,
                                    size: 64,
                                    color: isConnected ? AppColors.primaryBlue : Colors.grey,
                                  ),
                                  const SizedBox(height: 24),
                                  
                                  Text(
                                    isConnected ? "Welcome to Fees Up!" : "Syncing Data...",
                                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 12),
                                  
                                  Text(
                                    isConnected 
                                      ? "It looks like you haven't set up a school yet. Create one now to access the dashboard."
                                      : "We are waiting for your school data to download. Please check your internet connection.",
                                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 32),
                                  
                                  if (isConnected)
                                    ElevatedButton(
                                      onPressed: () => _showCreateSchoolDialog(context),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primaryBlue,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                                      ),
                                      child: const Text("Create School Profile"),
                                    )
                                  else 
                                    const Column(
                                      children: [
                                        CircularProgressIndicator(color: Colors.white),
                                        SizedBox(height: 16),
                                        Text("Waiting for sync...", style: TextStyle(color: Colors.white38))
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _handleQuickAction(BuildContext context, QuickActionType type, String schoolId) {
    switch (type) {
      case QuickActionType.recordPayment:
        showDialog(
          context: context,
          barrierDismissible: false,
          barrierColor: Colors.black54,
          builder: (context) => PaymentDialog(schoolId: schoolId),
        );
        break;
      case QuickActionType.addExpense:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Expense Dialog coming soon!"), backgroundColor: AppColors.surfaceGrey),
        );
        break;
      case QuickActionType.registerStudent:
         showDialog(
          context: context,
          barrierDismissible: false,
          barrierColor: Colors.black54,
          builder: (context) => StudentDialog(schoolId: schoolId),
        );
         break;
      case QuickActionType.createCampaign:
         break;
    }
  }

  Widget _buildTopBar(BuildContext context, String userName, String schoolName, bool hasSchool, bool isConnected) {
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
              Text(
                userName.isEmpty ? "User" : userName, 
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)
              ),
              Text(
                hasSchool ? schoolName : (isConnected ? "Tap avatar to setup" : "Waiting for Sync..."), 
                style: TextStyle(color: hasSchool ? Colors.white54 : AppColors.warningOrange, fontSize: 11)
              ),
            ],
          ),
          const SizedBox(width: 12),
          
          // --- SMART PROFILE ICON ---
          InkWell(
            onTap: () {
               if (!hasSchool) {
                 _showCreateSchoolDialog(context);
               }
            },
            borderRadius: BorderRadius.circular(50),
            child: CircleAvatar(
              backgroundColor: hasSchool ? Colors.white24 : AppColors.warningOrange, 
              child: hasSchool 
                ? Text(userName.isNotEmpty ? userName[0] : "U", style: const TextStyle(color: Colors.white, fontSize: 12))
                : const Icon(Icons.priority_high, color: Colors.black, size: 20),
            ),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isPaid ? AppColors.successGreen.withAlpha(51) : Colors.orange.withAlpha(51),
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