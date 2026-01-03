import 'package:fees_up/pc/widgets/invoices/invoice_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../data/providers/dashboard_provider.dart';
import '../widgets/sidebar.dart';
import '../widgets/invoices/invoices_header.dart';
import '../widgets/invoices/invoices_stats.dart';
import '../widgets/invoices/invoices_table.dart';

class InvoicesScreen extends ConsumerWidget {
  const InvoicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fetch School ID for the "Create New Invoice" action
    final dashboardAsync = ref.watch(dashboardDataProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      body: Row(
        children: [
          // 1. Sidebar (Shared)
          const DashboardSidebar(),

          // 2. Main Content
          Expanded(
            child: Column(
              children: [
                // A. Top Header
                const InvoicesHeader(),
                const Divider(height: 1, color: AppColors.divider),

                // B. Scrollable Body
                Expanded(
                  child: dashboardAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue)),
                    error: (e, _) => Center(child: Text("Error: $e", style: const TextStyle(color: AppColors.errorRed))),
                    data: (data) => SingleChildScrollView(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Stats Row (Pass schoolId and function to open dialog)
                          InvoicesStats(
                            schoolId: data.schoolId,
                            onCreateInvoice: () {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (_) => InvoiceDialog(schoolId: data.schoolId),
                              );
                            },
                          ),
                          const SizedBox(height: 32),

                          // 2. Filter Bar & Table
                          const InvoicesTable(),
                        ],
                      ),
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
}