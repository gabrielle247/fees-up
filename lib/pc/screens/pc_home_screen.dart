import 'package:fees_up/pc/widgets/dashboard/campaign_dialog.dart';
import 'package:fees_up/pc/widgets/dashboard/expense_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../data/providers/dashboard_provider.dart';
import '../../data/providers/fundraising_provider.dart';
import '../../data/services/database_service.dart';
import '../widgets/sidebar.dart';
import '../widgets/dashboard/stat_cards.dart';
import '../widgets/dashboard/revenue_chart.dart';
import '../widgets/dashboard/quick_actions_grid.dart';
import '../widgets/dashboard/payment_dialog.dart';
import '../widgets/dashboard/student_dialog.dart';
import '../../mobile/widgets/dashboard/create_school_dialog.dart';

class PCHomeScreen extends ConsumerWidget {
  const PCHomeScreen({super.key});

  void _showCreateSchoolDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const CreateSchoolDialog(),
    );
  }

  // Helper for Initials
  String _getInitials(String name) {
    if (name.isEmpty) return "U";
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return "${parts[0][0]}${parts[1][0]}".toUpperCase();
    }
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardDataProvider);
    final fundraisingAsync = ref.watch(fundraisingProvider);

    // Direct connectivity check for UI feedback
    final bool isConnected = DatabaseService().db.currentStatus.connected;

    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // ZONE RULE: Desktop Only. Block small screens.
          if (constraints.maxWidth < 1024) {
            return _buildScreenTooSmallError();
          }

          return Row(
            children: [
              const DashboardSidebar(),
              Expanded(
                child: dashboardAsync.when(
                  loading: () => const Center(
                    child:
                        CircularProgressIndicator(color: AppColors.primaryBlue),
                  ),
                  error: (err, stack) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            color: AppColors.errorRed, size: 40),
                        const SizedBox(height: 16),
                        Text("Error: $err",
                            style: const TextStyle(color: AppColors.textWhite)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => ref.refresh(dashboardDataProvider),
                          child: const Text("Retry"),
                        )
                      ],
                    ),
                  ),
                  data: (data) {
                    final bool hasSchool = data.schoolId.isNotEmpty &&
                        data.schoolName != 'Loading...';

                    return Stack(
                      children: [
                        Column(
                          children: [
                            // Updated Top Bar with Connectivity Logic
                            _buildTopBar(context, data.userName,
                                data.schoolName, hasSchool, isConnected),
                            Expanded(
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildHeader(data.schoolName),
                                    const SizedBox(height: 24),

                                    // ZONE 1: KPI Summary (Fixed Height: 160px)
                                    SizedBox(
                                      height: 160,
                                      child: _buildKpiSection(
                                          data, fundraisingAsync),
                                    ),

                                    const SizedBox(height: 24),

                                    // ZONE 2: Primary Analytics & Actions (Fixed Height: 400px)
                                    SizedBox(
                                      height: 400,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          // Chart: Hero content
                                          const Expanded(
                                              flex: 2, child: RevenueChart()),
                                          const SizedBox(width: 24),

                                          // Actions: Secondary Panel
                                          Expanded(
                                            flex: 1,
                                            child: QuickActionsGrid(
                                              onActionSelected: (type) =>
                                                  _handleQuickAction(context,
                                                      type, data.schoolId),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 24),

                                    // ZONE 4: Data Tables (Fill remaining)
                                    _buildRecentPayments(data.recentPayments),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (!hasSchool)
                          _buildNoSchoolOverlay(context, isConnected),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- TOP BAR (FIXED) ---

  Widget _buildTopBar(BuildContext context, String userName, String schoolName,
      bool hasSchool, bool isConnected) {
    // Determine subtitle status (Offline / Syncing / School Name)
    String subtitle = schoolName;
    Color subtitleColor = AppColors.textWhite54;

    if (!hasSchool) {
      subtitle = isConnected ? "Tap avatar to setup" : "Waiting for Sync...";
      subtitleColor = AppColors.warningOrange;
    } else if (!isConnected) {
      subtitle = "Offline Mode";
      subtitleColor = AppColors.errorRed;
    } else if (schoolName == 'Loading...') {
      subtitle = "Syncing Data...";
      subtitleColor = AppColors.primaryBlueLight;
    }

    final initials = _getInitials(userName);

    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.divider))),
      child: Row(
        children: [
          const Text("Financial Dashboard",
              style: TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const Spacer(),

          // User Info Column
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(userName.isEmpty ? "User" : userName,
                  style: const TextStyle(
                      color: AppColors.textWhite,
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
              Row(
                children: [
                  if (!isConnected) ...[
                    const Icon(Icons.wifi_off,
                        size: 10, color: AppColors.errorRed),
                    const SizedBox(width: 4),
                  ],
                  Text(subtitle,
                      style: TextStyle(color: subtitleColor, fontSize: 11)),
                ],
              ),
            ],
          ),
          const SizedBox(width: 12),

          // Profile Avatar
          InkWell(
            onTap: () {
              if (!hasSchool) _showCreateSchoolDialog(context);
            },
            borderRadius: BorderRadius.circular(50),
            child: CircleAvatar(
              backgroundColor: hasSchool
                  ? AppColors.primaryBlue.withValues(alpha: 0.2)
                  : AppColors.warningOrange.withValues(alpha: 0.2),
              child: hasSchool
                  ? Text(initials,
                      style: const TextStyle(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 12))
                  : const Icon(Icons.priority_high,
                      color: AppColors.warningOrange, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  // --- HELPERS (Unchanged) ---

  Widget _buildScreenTooSmallError() {
    return Container(
      color: Colors.black,
      width: double.infinity,
      height: double.infinity,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.desktop_windows, size: 64, color: AppColors.errorRed),
          SizedBox(height: 24),
          Text(
            "Window Size Too Small",
            style: TextStyle(
                color: AppColors.textWhite,
                fontSize: 24,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Text(
            "This application requires a minimum resolution of 1024px width.",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textWhite70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String schoolName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Overview",
            style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textWhite)),
        Text("Status for $schoolName",
            style: const TextStyle(color: AppColors.textWhite54)),
      ],
    );
  }

  Widget _buildKpiSection(dynamic data, AsyncValue fundraisingAsync) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: StatCard(
            title: "Outstanding Bills",
            value:
                NumberFormat.simpleCurrency().format(data.outstandingBalance),
            icon: Icons.receipt_long,
            iconColor: AppColors.errorRed,
            iconBgColor: AppColors.errorRedBg,
            isAlert: data.outstandingBalance > 0,
            footer: const AlertBadge(text: "Updated", subText: "Just now"),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: fundraisingAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const SizedBox(),
            data: (fundData) {
              if (fundData == null) {
                return const StatCard(
                  title: "No Active Campaign",
                  value: "-",
                  icon: Icons.volunteer_activism,
                  iconColor: AppColors.iconGrey,
                  iconBgColor: AppColors.divider,
                );
              }
              return StatCard(
                title: fundData.campaignName,
                value: "${fundData.percentage.toStringAsFixed(1)}%",
                icon: Icons.volunteer_activism,
                iconColor: AppColors.accentPurple,
                iconBgColor: AppColors.purpleBg,
                footer: Text(
                    "Raised \$${fundData.raisedAmount.toInt()} of \$${fundData.goalAmount.toInt()}",
                    style: const TextStyle(
                        color: AppColors.textWhite38, fontSize: 11)),
              );
            },
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: StatCard(
            title: "Active Students",
            value: data.studentCount.toString(),
            icon: Icons.school,
            iconColor: AppColors.primaryBlue,
            iconBgColor: AppColors.primaryBlueBg,
            footer: const Text("Enrolled",
                style: TextStyle(color: AppColors.textWhite38, fontSize: 11)),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentPayments(List<dynamic> payments) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceGrey,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Recent Payments",
              style: TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (payments.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text("No recent payments found.",
                  style: TextStyle(color: AppColors.textWhite54)),
            )
          else
            ...payments.map((payment) {
              return Column(
                children: [
                  _buildPaymentRow(
                    payment['payer_name'] ?? 'Unknown',
                    payment['date_paid'] != null
                        ? DateFormat('MMM d, yyyy')
                            .format(DateTime.parse(payment['date_paid']))
                        : 'Unknown Date',
                    payment['category'] ?? 'Fee',
                    NumberFormat.simpleCurrency().format(payment['amount']),
                    true,
                  ),
                  const Divider(color: AppColors.divider),
                ],
              );
            }),
        ],
      ),
    );
  }

  Widget _buildNoSchoolOverlay(BuildContext context, bool isConnected) {
    return Positioned.fill(
      child: Container(
        color: AppColors.overlayDark,
        child: Center(
          child: Container(
            width: 500,
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.surfaceGrey,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
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
                  color:
                      isConnected ? AppColors.primaryBlue : AppColors.iconGrey,
                ),
                const SizedBox(height: 24),
                Text(
                  isConnected ? "Welcome to Fees Up!" : "Syncing Data...",
                  style: const TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  isConnected
                      ? "It looks like you haven't set up a school yet. Create one now to access the dashboard."
                      : "We are waiting for your school data to download. Please check your internet connection.",
                  style: const TextStyle(
                      color: AppColors.textWhite70, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                if (isConnected)
                  ElevatedButton(
                    onPressed: () => _showCreateSchoolDialog(context),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: AppColors.textWhite,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 20),
                        textStyle: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    child: const Text("Create School Profile"),
                  )
                else
                  const Column(
                    children: [
                      CircularProgressIndicator(color: AppColors.textWhite),
                      SizedBox(height: 16),
                      Text("Waiting for sync...",
                          style: TextStyle(color: AppColors.textWhite38))
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleQuickAction(
      BuildContext context, QuickActionType type, String schoolId) {
    switch (type) {
      case QuickActionType.recordPayment:
        showDialog(
            context: context,
            barrierDismissible: false,
            barrierColor: Colors.black54,
            builder: (context) => PaymentDialog(schoolId: schoolId));
        break;
      case QuickActionType.addExpense:
        showDialog(
            context: context,
            barrierDismissible: false,
            barrierColor: Colors.black54,
            builder: (context) => ExpenseDialog(schoolId: schoolId));
        break;
      case QuickActionType.registerStudent:
        showDialog(
            context: context,
            barrierDismissible: false,
            barrierColor: Colors.black54,
            builder: (context) => StudentDialog(schoolId: schoolId));
        break;
      case QuickActionType.createCampaign:
        showDialog(
            context: context,
            barrierDismissible: false,
            barrierColor: Colors.black54,
            builder: (context) => CampaignDialog(schoolId: schoolId));
        break;
    }
  }

  Widget _buildPaymentRow(
      String name, String date, String desc, String amount, bool isPaid) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.divider,
              child:
                  Icon(Icons.person, size: 16, color: AppColors.textWhite54)),
          const SizedBox(width: 12),
          Expanded(
              flex: 2,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(color: AppColors.textWhite)),
                    Text(date,
                        style: const TextStyle(
                            color: AppColors.textWhite38, fontSize: 12))
                  ])),
          Expanded(
              flex: 3,
              child: Text(desc,
                  style: const TextStyle(color: AppColors.textWhite70))),
          Expanded(
              flex: 1,
              child: Text(amount,
                  style: const TextStyle(
                      color: AppColors.textWhite,
                      fontWeight: FontWeight.bold))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isPaid
                  ? AppColors.successGreen.withValues(alpha: 0.2)
                  : AppColors.warningOrange.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              isPaid ? "Paid" : "Pending",
              style: TextStyle(
                  color:
                      isPaid ? AppColors.successGreen : AppColors.warningOrange,
                  fontSize: 11,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
