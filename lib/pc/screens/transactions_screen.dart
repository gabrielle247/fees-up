import 'package:fees_up/pc/widgets/sidebar.dart';
import 'package:fees_up/pc/widgets/transactions/universal_entry_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../data/providers/dashboard_provider.dart'; // To get schoolId
import '../widgets/transactions/transactions_header.dart';
import '../widgets/transactions/transactions_kpi_cards.dart';
import '../widgets/transactions/transactions_table.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. We need the School ID to pass to the transaction dialogs
    final dashboardAsync = ref.watch(dashboardDataProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      body: Row(
        children: [
          // 1. SHARED SIDEBAR
          const DashboardSidebar(),

          // 2. MAIN CONTENT AREA
          Expanded(
            child: Column(
              children: [
                // Top Header (Search & Profile)
                const TransactionsHeader(),
                const Divider(height: 1, color: AppColors.divider),

                // Scrollable Body
                Expanded(
                  child: dashboardAsync.when(
                    // A. LOADING STATE
                    loading: () => const Center(
                      child: CircularProgressIndicator(color: AppColors.primaryBlue),
                    ),
                    // B. ERROR STATE
                    error: (err, stack) => Center(
                      child: Text("Error loading school data: $err",
                          style: const TextStyle(color: AppColors.errorRed)),
                    ),
                    // C. DATA LOADED
                    data: (data) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Page Title & Action Buttons (Pass context & schoolId)
                            _buildPageActions(context, data.schoolId),
                            const SizedBox(height: 24),

                            // KPI Cards Row
                            const TransactionsKpiCards(),
                            const SizedBox(height: 32),

                            // Main Data Table
                            const TransactionsTable(),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageActions(BuildContext context, String schoolId) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Financial Records",
              style: TextStyle(
                color: AppColors.textWhite,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              "Manage and audit all incoming and outgoing transactions.",
              style: TextStyle(color: AppColors.textWhite54, fontSize: 14),
            ),
          ],
        ),
        Row(
          children: [
            // EXPORT ACTION (Mock)
            OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Exporting CSV... (Mock Action)"),
                    backgroundColor: AppColors.surfaceLightGrey,
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              icon: const Icon(Icons.download, size: 16),
              label: const Text("Export CSV"),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textWhite,
                side: const BorderSide(color: AppColors.divider),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              ),
            ),
            const SizedBox(width: 16),
            
            // NEW TRANSACTION ACTION (Real)
            ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: false, // Force explicit close
                  barrierColor: Colors.black54,
                  builder: (ctx) => UniversalTransactionDialog(
                    schoolId: schoolId,
                    initialType: TransactionType.payment, // Default to Payment
                  ),
                );
              }, 
              icon: const Icon(Icons.add, size: 16),
              label: const Text("New Transaction"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              ),
            ),
          ],
        ),
      ],
    );
  }
}