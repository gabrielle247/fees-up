import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../data/providers/dashboard_provider.dart';
import '../../data/providers/fundraising_provider.dart';
import '../../data/services/database_service.dart';
import '../widgets/sidebar.dart';
import '../widgets/dashboard/revenue_chart.dart';
import '../widgets/dashboard/quick_actions_grid.dart';
import '../widgets/dashboard/payment_dialog.dart';
import '../widgets/dashboard/student_dialog.dart';
import '../widgets/dashboard/campaign_dialog.dart';
import '../widgets/dashboard/expense_dialog.dart';
import '../widgets/dashboard/dashboard_top_bar.dart';
import '../widgets/dashboard/dashboard_header.dart';
import '../widgets/dashboard/kpi_section.dart';
import '../widgets/dashboard/recent_payments_section.dart';
import '../widgets/dashboard/no_school_overlay.dart';
import '../widgets/dashboard/screen_size_error.dart';
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardDataProvider);
    final fundraisingAsync = ref.watch(fundraisingProvider);
    final bool isConnected = DatabaseService().db.currentStatus.connected;

    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // ZONE RULE: Desktop Only. Block small screens.
          if (constraints.maxWidth < 1024) {
            return const ScreenSizeError();
          }

          return Row(
            children: [
              const DashboardSidebar(),
              Expanded(
                child: dashboardAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  error: (err, stack) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: AppColors.errorRed,
                          size: 40,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Error: $err",
                          style: const TextStyle(color: AppColors.textWhite),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => ref.refresh(dashboardDataProvider),
                          child: const Text("Retry"),
                        ),
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
                            DashboardTopBar(
                              userName: data.userName,
                              schoolName: data.schoolName,
                              hasSchool: hasSchool,
                              isConnected: isConnected,
                              onAvatarTap: () {
                                if (!hasSchool) {
                                  _showCreateSchoolDialog(context);
                                }
                              },
                            ),
                            Expanded(
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    DashboardHeader(
                                        schoolName: data.schoolName),
                                    const SizedBox(height: 24),
                                    SizedBox(
                                      height: 160,
                                      child: KpiSection(
                                        outstandingBalance:
                                            data.outstandingBalance,
                                        studentCount: data.studentCount,
                                        fundraisingAsync: fundraisingAsync,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    SizedBox(
                                      height: 400,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          const Expanded(
                                            flex: 2,
                                            child: RevenueChart(),
                                          ),
                                          const SizedBox(width: 24),
                                          Expanded(
                                            flex: 1,
                                            child: QuickActionsGrid(
                                              onActionSelected: (type) =>
                                                  _handleQuickAction(
                                                context,
                                                type,
                                                data.schoolId,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    RecentPaymentsSection(
                                      payments: data.recentPayments,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (!hasSchool)
                          NoSchoolOverlay(
                            isConnected: isConnected,
                            onCreateSchool: () =>
                                _showCreateSchoolDialog(context),
                          ),
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

  void _handleQuickAction(
    BuildContext context,
    QuickActionType type,
    String schoolId,
  ) {
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
        showDialog(
          context: context,
          barrierDismissible: false,
          barrierColor: Colors.black54,
          builder: (context) => ExpenseDialog(schoolId: schoolId),
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
        showDialog(
          context: context,
          barrierDismissible: false,
          barrierColor: Colors.black54,
          builder: (context) => CampaignDialog(schoolId: schoolId),
        );
        break;
    }
  }
}
