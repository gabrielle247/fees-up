import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/providers/financial_reports_provider.dart';
import '../../../../data/providers/report_builder_provider.dart';

/// Report Preview Dialog - Shows report data preview
/// Complies with Law of Fragments: Separate dialog logic
void showReportPreviewDialog(
  BuildContext context,
  WidgetRef ref,
  String schoolId,
  ReportBuilderState reportState,
) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 800,
        height: 600,
        decoration: BoxDecoration(
          color: AppColors.backgroundBlack,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.surfaceLightGrey),
        ),
        child: Column(
          children: [
            _buildHeader(context),
            const Divider(height: 1, color: AppColors.divider),
            Expanded(
              child: _buildContent(ref, schoolId, reportState),
            ),
            _buildFooter(context),
          ],
        ),
      ),
    ),
  );
}

Widget _buildHeader(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(24),
    child: Row(
      children: [
        const Icon(Icons.preview, color: AppColors.primaryBlue),
        const SizedBox(width: 16),
        const Text(
          'Report Preview',
          style: TextStyle(
            color: AppColors.textWhite,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close, color: AppColors.textGrey),
        ),
      ],
    ),
  );
}

Widget _buildContent(
  WidgetRef ref,
  String schoolId,
  ReportBuilderState reportState,
) {
  return Consumer(
    builder: (context, ref, child) {
      final invoiceStatsAsync = ref.watch(invoiceStatsProvider(
        InvoiceStatsParams(
          schoolId: schoolId,
          startDate: reportState.dateRange.start,
          endDate: reportState.dateRange.end,
        ),
      ));

      return invoiceStatsAsync.when(
        data: (stats) => SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPreviewSection(
                'Invoice Statistics',
                [
                  _buildPreviewRow(
                    'Total Invoices',
                    stats['total_invoices'].toString(),
                  ),
                  _buildPreviewRow(
                    'Paid Invoices',
                    stats['paid_count'].toString(),
                  ),
                  _buildPreviewRow(
                    'Pending Invoices',
                    stats['sent_count'].toString(),
                  ),
                  _buildPreviewRow(
                    'Total Billed',
                    '\$${NumberFormat('#,##0.00').format(stats['total_billed'])}',
                  ),
                  _buildPreviewRow(
                    'Total Collected',
                    '\$${NumberFormat('#,##0.00').format(stats['total_collected'])}',
                  ),
                  _buildPreviewRow(
                    'Collection Rate',
                    '${stats['collection_rate']}%',
                  ),
                ],
              ),
            ],
          ),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryBlue),
        ),
        error: (err, stack) => Center(
          child: Text(
            'Error loading preview: $err',
            style: const TextStyle(color: AppColors.errorRed),
          ),
        ),
      );
    },
  );
}

Widget _buildFooter(BuildContext context) {
  return Container(
    padding: const EdgeInsets.all(24),
    decoration: const BoxDecoration(
      border: Border(top: BorderSide(color: AppColors.divider)),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

Widget _buildPreviewSection(String title, List<Widget> rows) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          color: AppColors.textWhite,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 16),
      Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceGrey,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(children: rows),
      ),
    ],
  );
}

Widget _buildPreviewRow(String label, String value) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: AppColors.divider)),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textWhite70),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}
