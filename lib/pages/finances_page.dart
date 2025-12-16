// lib/pages/finances_page.dart

import 'package:fees_up/pages/billing_settings_page.dart';
import 'package:fees_up/pages/expenses_dashboard_page.dart';
import 'package:fees_up/pages/financial_lists_page.dart';
import 'package:fees_up/pages/record_income_sheet.dart';
import 'package:fees_up/pages/revenue_analytics_page.dart';
import 'package:fees_up/pages/student_ledger_page.dart';
import 'package:fees_up/providers/finances_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class FinancesPage extends ConsumerWidget {
  const FinancesPage({super.key});

  // --- HELPER: Generic Navigation to Placeholder ---
  void _navigateToPlaceholder(BuildContext context, String title) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => _PlaceholderPage(title: title)),
    );
  }

  // --- ACTIONS ---

  void _handleDownloadReport(BuildContext context) {
    _navigateToPlaceholder(context, "Download Summary PDF");
  }

  void _handleRevenueClick(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (context) => const RevenueAnalyticsPage()),
  );
}

  void _handleOutstandingClick(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        // Open Tab 0 (Outstanding)
        builder: (context) => const FinancialListsPage(initialIndex: 0),
      ),
    );
  }

  void _handleOpenInvoicesClick(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        // Open Tab 1 (Invoices)
        builder: (context) => const FinancialListsPage(initialIndex: 1),
      ),
    );
  }

  // -- Quick Actions --

  void _actionAddExpense(BuildContext context) {
    // Navigate to the new Expenses Dashboard which handles viewing and adding
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ExpensesDashboardPage()),
    );
  }

  void _actionRecordPayment(BuildContext context) {
     Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const RecordIncomeSheet()),
    );
  }

  void _actionStartCampaigns(BuildContext context) {
    _navigateToPlaceholder(context, "Send Bulk Reminders");
  }

  void _actionBillingSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const BillingSettingsPage()),
    );
  }

  // -- View All Links --

  void _viewAllAttention(BuildContext context) {
    // In a real app, navigate to StudentList filtered by 'overdue'
    _navigateToPlaceholder(context, "Full Attention List");
  }

  void _viewAllTransactions(BuildContext context) {
    // In a real app, navigate to a dedicated TransactionsPage
    _navigateToPlaceholder(context, "Full Transaction History");
  }

  void _viewTransactionReceipt(BuildContext context, TransactionItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xff1c2a35),
        title: const Text(
          "Receipt Details",
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Amount: \$${item.amount.toStringAsFixed(2)}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Date: ${DateFormat('MMM dd, yyyy').format(item.date)}",
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 4),
            Text(
              "Ref: ${item.title} - ${item.subtitle}",
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Icon(Icons.receipt_long, size: 64, color: Colors.white24),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Close"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Share Receipt"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final financesAsync = ref.watch(financesProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currencyFormat = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 2,
    );

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // 1. Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 60,
                left: 20,
                right: 20,
                bottom: 20,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Finances",
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Overview • Q${((DateTime.now().month - 1) / 3).floor() + 1} ${DateTime.now().year}",
                        style: TextStyle(color: Colors.white.withAlpha(150)),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => _handleDownloadReport(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withAlpha(
                          100,
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withAlpha(30)),
                      ),
                      child: const Icon(Icons.download, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Content
          financesAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, s) => SliverFillRemaining(
              child: Center(
                child: Text(
                  "Error: $e",
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
            data: (data) {
              // LIMIT RECENT TRANSACTIONS TO 5
              final limitedTransactions = data.recentTransactions
                  .take(5)
                  .toList();

              return SliverList(
                delegate: SliverChildListDelegate([
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // Revenue Card
                        _RevenueCard(
                          totalRevenue: data.totalRevenueYtd,
                          currencyFormatter: currencyFormat,
                          onTap: () => _handleRevenueClick(context),
                        ),

                        const SizedBox(height: 16),

                        // Stats Row
                        Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                title: "Outstanding",
                                value: currencyFormat.format(
                                  data.totalOutstanding,
                                ),
                                icon: Icons.money_off_csred_outlined,
                                accentColor: const Color(0xffef5350),
                                showAction: true,
                                onTap: () => _handleOutstandingClick(context),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _StatCard(
                                title: "Open Invoices",
                                value: data.openInvoicesCount.toString(),
                                icon: Icons.receipt_long_outlined,
                                accentColor: const Color(0xff42a5f5),
                                onTap: () => _handleOpenInvoicesClick(context),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Quick Actions
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Quick Actions",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _QuickActionButton(
                              icon: Icons.pie_chart_outline, // Changed Icon
                              label: "Expenses\nDashboard", // Changed Label
                              onTap: () => _actionAddExpense(context),
                            ),
                            _QuickActionButton(
                              icon: Icons.add_card,
                              label: "Record\nPayment",
                              onTap: () => _actionRecordPayment(context),
                            ),
                            _QuickActionButton(
                              icon: Icons.campaign_outlined,
                              label: "Fund\nRaisers",
                              onTap: () => _actionStartCampaigns(context),
                            ),
                            _QuickActionButton(
                              icon: Icons.settings_outlined,
                              label: "Billing\nSettings",
                              onTap: () => _actionBillingSettings(context),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Attention Needed
                        _SectionHeader(
                          title: "Attention Needed",
                          onTap: () => _viewAllAttention(context),
                        ),
                        const SizedBox(height: 12),
                        if (data.attentionList.isEmpty)
                          const _EmptyState(text: "No overdue payments found.")
                        else
                          ...data.attentionList.map(
                            (item) => _AttentionTile(item: item),
                          ),

                        const SizedBox(height: 24),

                        // Recent Payments (Limited to 5)
                        _SectionHeader(
                          title: "Recent Transactions",
                          onTap: () => _viewAllTransactions(context),
                        ),
                        const SizedBox(height: 12),
                        if (limitedTransactions.isEmpty)
                          const _EmptyState(text: "No recent transactions.")
                        else
                          ...limitedTransactions.map(
                            (item) => GestureDetector(
                              onTap: () =>
                                  _viewTransactionReceipt(context, item),
                              child: _TransactionTile(item: item),
                            ),
                          ),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ]),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ... (Rest of your existing Widgets: _RevenueCard, _StatCard, etc., remain exactly the same) ...
// Ensure you include all the helper widgets (_RevenueCard, _StatCard, _QuickActionButton, _AttentionTile, _TransactionTile, _SectionHeader, _EmptyState, _PlaceholderPage) here from your previous code.

// -----------------------------------------------------------------------------
// HELPER: Revenue Card
// -----------------------------------------------------------------------------
class _RevenueCard extends StatelessWidget {
  final double totalRevenue;
  final NumberFormat currencyFormatter;
  final VoidCallback onTap;

  const _RevenueCard({
    required this.totalRevenue,
    required this.currencyFormatter,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xff0d47a1), Color(0xff42a5f5)],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xff42a5f5).withAlpha(80),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total Revenue (YTD)",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(50),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              currencyFormatter.format(totalRevenue),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(50),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.trending_up, color: Colors.white, size: 16),
                  SizedBox(width: 6),
                  Text(
                    "+12.5% vs last year", // Placeholder data
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// HELPER: Stat Card
// -----------------------------------------------------------------------------
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color accentColor;
  final bool showAction;
  final VoidCallback onTap;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.accentColor,
    this.showAction = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xff1c2a35), // Theme Surface
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withAlpha(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: accentColor, size: 18),
                ),
                if (showAction)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xffef5350).withAlpha(50),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xffef5350).withAlpha(100),
                      ),
                    ),
                    child: const Text(
                      "Action",
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xffff8a80),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// HELPER: Quick Action Button
// -----------------------------------------------------------------------------
class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: const Color(0xff1c2a35),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withAlpha(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(50),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: const Color(0xff3498db)),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// HELPER: Attention Tile
// -----------------------------------------------------------------------------
class _AttentionTile extends StatelessWidget {
  final AttentionItem item;

  const _AttentionTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => StudentLedgerPage(studentId: item.studentId),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xff1c2a35),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withAlpha(15)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: const Color(0xffef5350).withAlpha(50),
              child: Text(
                item.name.isNotEmpty ? item.name[0] : '?',
                style: const TextStyle(
                  color: Color(0xffff8a80),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    item.overdueText,
                    style: const TextStyle(
                      color: Color(0xffff8a80),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "-\$${item.amountOwed.toStringAsFixed(2)}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xffef5350).withAlpha(40),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    item.status.toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xffff8a80),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// HELPER: Transaction Tile
// -----------------------------------------------------------------------------
class _TransactionTile extends StatelessWidget {
  final TransactionItem item;

  const _TransactionTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xff1c2a35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(15)),
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: const Color(0xff2ecc71).withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.attach_money, color: Color(0xff2ecc71)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  item.subtitle,
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            "+\$${item.amount.toStringAsFixed(2)}",
            style: const TextStyle(
              color: Color(0xff2ecc71),
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// HELPER: Section Header
// -----------------------------------------------------------------------------
class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _SectionHeader({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: const Text(
            "View All",
            style: TextStyle(
              color: Color(0xff3498db),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// HELPER: Empty State
// -----------------------------------------------------------------------------
class _EmptyState extends StatelessWidget {
  final String text;
  const _EmptyState({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withAlpha(10),
          style: BorderStyle.solid,
        ),
      ),
      child: Center(
        child: Text(text, style: TextStyle(color: Colors.grey.shade500)),
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  final String title;
  const _PlaceholderPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff121b22),
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xff121b22),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Text(
          "Placeholder: $title",
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
