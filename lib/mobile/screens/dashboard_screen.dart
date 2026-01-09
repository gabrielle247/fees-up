import 'package:fees_up/constants/app_colors.dart';
import 'package:fees_up/data/providers/dashboard_providers.dart';
import 'package:fees_up/data/providers/core_providers.dart';
import 'package:fees_up/data/providers/school_providers.dart';
import 'package:fees_up/mobile/widgets/school_creation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fees_up/data/services/seeder_service.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch school state to decide what to show
    final currentSchoolAsync = ref.watch(currentSchoolProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      body: SafeArea(
        child: currentSchoolAsync.when(
          data: (school) {
            // IF NO SCHOOL -> Show "Create School" Prompt
            if (school == null) {
              return _NoSchoolState();
            }
            // IF SCHOOL EXISTS -> Show Dashboard
            return _DashboardContent();
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }
}

class _NoSchoolState extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.school_outlined,
                size: 80, color: AppColors.textGrey),
            const SizedBox(height: 24),
            const Text(
              "Welcome to Fees Up",
              style: TextStyle(
                color: AppColors.textWhite,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "To get started, create your school profile or load example data.",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textGrey, fontSize: 16),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                // Trigger Seeder
                final db = ref.read(driftDatabaseProvider);
                await SeederService(db).seedExampleData();
                // Refresh provider
                ref.invalidate(currentSchoolProvider);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text("Load Example Data (Demo)"),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () async {
                final result = await showDialog<bool>(
                  context: context,
                  builder: (context) => const SchoolCreationDialog(),
                );
                if (result == true && context.mounted) {
                  ref.invalidate(currentSchoolProvider);
                }
              },
              child: const Text("Create New School"),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardContent extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cashToday = ref.watch(totalCashTodayProvider);
    final totalOutstanding = ref.watch(totalOutstandingProvider);
    final pendingInvoices = ref.watch(pendingInvoicesCountProvider);
    final recentActivity = ref.watch(recentActivityProvider);
    final revenueGrowth = ref.watch(revenueGrowthProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Custom Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // User Avatar
                Stack(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.surfaceHighlight,
                        image: DecorationImage(
                          image: AssetImage('assets/images/avatar.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: AppColors.successGreen,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.backgroundBlack,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                // Welcome Text
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back,',
                        style: TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Finance Dashboard',
                        style: TextStyle(
                          color: AppColors.textWhite,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // Notification Bell
                Stack(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceGrey,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.notifications_outlined,
                        color: AppColors.textWhite,
                        size: 24,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: AppColors.errorRed,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // KPI Cards Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                // Total Income Card
                Expanded(
                  child: cashToday.when(
                    data: (amount) => _FinanceKPICard(
                      icon: Icons.account_balance_wallet,
                      iconColor: AppColors.successGreen,
                      iconBackground: AppColors.successGreenBg,
                      label: 'Total Income',
                      value: '\$${(amount / 100).toStringAsFixed(0)}',
                      // Use the dynamic growth provider
                      trendProvider: revenueGrowth,
                    ),
                    loading: () => const _FinanceKPICard(
                      icon: Icons.account_balance_wallet,
                      iconColor: AppColors.successGreen,
                      iconBackground: AppColors.successGreenBg,
                      label: 'Total Income',
                      value: '--',
                    ),
                    error: (err, stack) => const _FinanceKPICard(
                      icon: Icons.account_balance_wallet,
                      iconColor: AppColors.successGreen,
                      iconBackground: AppColors.successGreenBg,
                      label: 'Total Income',
                      value: '\$0',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Total Owing Card
                Expanded(
                  child: totalOutstanding.when(
                    data: (amount) => _FinanceKPICard(
                      icon: Icons.shopping_bag_outlined,
                      iconColor: AppColors.errorRed,
                      iconBackground: AppColors.errorRedBg,
                      label: 'Total Owing',
                      value: '\$${(amount / 100).toStringAsFixed(0)}',
                    ),
                    loading: () => const _FinanceKPICard(
                      icon: Icons.shopping_bag_outlined,
                      iconColor: AppColors.errorRed,
                      iconBackground: AppColors.errorRedBg,
                      label: 'Total Owing',
                      value: '--',
                    ),
                    error: (err, stack) => const _FinanceKPICard(
                      icon: Icons.shopping_bag_outlined,
                      iconColor: AppColors.errorRed,
                      iconBackground: AppColors.errorRedBg,
                      label: 'Total Owing',
                      value: '\$0',
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Outstanding Invoices Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceGrey,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Outstanding Invoices',
                        style: TextStyle(
                          color: AppColors.textWhite,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      pendingInvoices.when(
                        data: (count) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLightGrey,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            count.toString(),
                            style: const TextStyle(
                              color: AppColors.textWhite,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        loading: () => Container(),
                        error: (err, stack) => Container(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Total outstanding value to be collected',
                    style: TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 12),
                  totalOutstanding.when(
                    data: (amount) => Text(
                      '\$${(amount / 100).toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    loading: () => const Text(
                      '--',
                      style: TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    error: (err, stack) => const Text(
                      '\$0',
                      style: TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textWhite,
                            side: const BorderSide(
                              color: AppColors.surfaceLightGrey,
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            'View List',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.bolt, size: 20),
                          label: const Text(
                            'Generate All',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: AppColors.textWhite,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Recent Transactions Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Transactions',
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'View All',
                    style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Transactions List
          recentActivity.when(
            data: (activities) {
              if (activities.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 48,
                          color: AppColors.iconGrey,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'No recent transactions',
                          style: TextStyle(
                            color: AppColors.textGrey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: activities.length,
                separatorBuilder: (context, index) => const SizedBox(height: 4),
                itemBuilder: (context, index) => _TransactionItem(
                  activity: activities[index],
                ),
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(40),
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
            error: (err, stack) => const Padding(
              padding: EdgeInsets.all(40),
              child: Center(
                child: Text(
                  'Error loading transactions',
                  style: TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // View Full Ledger Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textWhite,
                  side: const BorderSide(
                    color: AppColors.surfaceLightGrey,
                    width: 1,
                  ),
                  backgroundColor: AppColors.surfaceGrey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'View Full Ledger',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 100), // Bottom navigation space
        ],
      ),
    );
  }
}

// Finance KPI Card Widget
class _FinanceKPICard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String label;
  final String value;
  final AsyncValue<double>? trendProvider; // Optional dynamic trend

  const _FinanceKPICard({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.label,
    required this.value,
    this.trendProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceGrey,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
              ),
              if (trendProvider != null)
                trendProvider!.when(
                  data: (trend) {
                    final isPositive = trend >= 0;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isPositive
                            ? AppColors.successGreenBg
                            : AppColors.errorRedBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isPositive
                                ? Icons.trending_up
                                : Icons.trending_down,
                            color: isPositive
                                ? AppColors.successGreen
                                : AppColors.errorRed,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${isPositive ? '+' : ''}${trend.toStringAsFixed(1)}%',
                            style: TextStyle(
                              color: isPositive
                                  ? AppColors.successGreen
                                  : AppColors.errorRed,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  loading: () => const SizedBox(),
                  error: (_, __) => const SizedBox(),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textGrey,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textWhite,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// Transaction Item Widget (Modified to be robust)
class _TransactionItem extends StatelessWidget {
  final ActivityFeedItem activity;

  const _TransactionItem({required this.activity});

  @override
  Widget build(BuildContext context) {
    late IconData iconData;
    late Color iconColor;
    late Color iconBackground;
    late Color amountColor;
    late String amountPrefix;

    switch (activity.type) {
      case 'payment':
        iconData = Icons.arrow_downward;
        iconColor = AppColors.successGreen;
        iconBackground = AppColors.successGreenBg;
        amountColor = AppColors.successGreen;
        amountPrefix = '+';
        break;
      case 'invoice':
        iconData = Icons.receipt_outlined;
        iconColor = AppColors.primaryBlue;
        iconBackground = AppColors.primaryBlue_20;
        amountColor = AppColors.textWhite;
        amountPrefix = '';
        break;
      default:
        iconData = Icons.info_outline;
        iconColor = AppColors.textGrey;
        iconBackground = AppColors.disabledGrey;
        amountColor = AppColors.textWhite;
        amountPrefix = '';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              iconData,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _getSubtitle(),
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (activity.amount != null)
                Text(
                  '$amountPrefix\$${(activity.amount! / 100).toStringAsFixed(2)}',
                  style: TextStyle(
                    color: amountColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                _formatTimestamp(),
                style: const TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getSubtitle() {
    // Robust extraction: Just return type + date if parsing fails
    try {
      if (activity.title.contains('from ')) {
        return 'Student';
      }
      if (activity.title.contains('for ')) {
        return 'Class Fee';
      }
    } catch (_) {}
    return activity.type.toUpperCase();
  }

  String _formatTimestamp() {
    final now = DateTime.now();
    final diff = now.difference(activity.timestamp);

    if (diff.inMinutes < 60) {
      return 'Today';
    } else if (diff.inHours < 24) {
      return 'Today, ${_formatTime(activity.timestamp)}';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else {
      return _formatDate(activity.timestamp);
    }
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  String _formatDate(DateTime dt) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}';
  }
}
