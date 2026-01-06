import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/providers/invoices_provider.dart';
import '../../../../core/utils/safe_data.dart';

class StudentBillsDialog extends ConsumerWidget {
  final String studentId;
  final String studentName;
  const StudentBillsDialog(
      {super.key, required this.studentId, required this.studentName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final billsAsync = ref.watch(studentInvoicesProvider(studentId));

    return Dialog(
      backgroundColor: AppColors.backgroundBlack,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 520,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceGrey,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bills for $studentName',
                      style: const TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      studentId,
                      style: const TextStyle(
                          color: AppColors.textWhite54, fontSize: 12),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: AppColors.textWhite54),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(height: 1, color: AppColors.divider),
            const SizedBox(height: 16),
            billsAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child:
                      CircularProgressIndicator(color: AppColors.primaryBlue),
                ),
              ),
              error: (err, _) => Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Failed to load bills: $err',
                    style: const TextStyle(color: AppColors.errorRed)),
              ),
              data: (bills) {
                if (bills.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No bills found for this student.',
                        style: TextStyle(color: AppColors.textWhite54)),
                  );
                }

                return ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 360),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: bills.length,
                    separatorBuilder: (_, __) =>
                        const Divider(color: AppColors.divider),
                    itemBuilder: (context, index) {
                      final bill = bills[index];
                      final title = (bill['title'] ?? 'Bill').toString();
                      final total =
                          SafeData.parseDouble(bill['total_amount'], 0.0);
                      final paid =
                          SafeData.parseDouble(bill['paid_amount'], 0.0);
                      final status = (bill['status'] ?? '').toString();
                      final created = (bill['created_at'] ?? '').toString();
                      final dateLabel = created.isEmpty
                          ? ''
                          : DateFormat('MMM d, yyyy').format(
                              DateTime.tryParse(created) ?? DateTime.now());

                      final isPaid = (bill['is_paid'] as int?) == 1 ||
                          status.toLowerCase() == 'paid';
                      final balance = (total - paid).clamp(0, double.infinity);

                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(title,
                            style: const TextStyle(
                                color: AppColors.textWhite,
                                fontSize: 14,
                                fontWeight: FontWeight.w600)),
                        subtitle: Text(dateLabel,
                            style: const TextStyle(
                                color: AppColors.textWhite54, fontSize: 12)),
                        trailing: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(NumberFormat.simpleCurrency().format(total),
                                style: const TextStyle(
                                    color: AppColors.textWhite,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isPaid
                                        ? AppColors.successGreen
                                            .withValues(alpha: 0.2)
                                        : AppColors.warningOrange
                                            .withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    isPaid ? 'Paid' : 'Unpaid',
                                    style: TextStyle(
                                      color: isPaid
                                          ? AppColors.successGreen
                                          : AppColors.warningOrange,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  balance > 0
                                      ? '- ${NumberFormat.simpleCurrency().format(balance)}'
                                      : 'Settled',
                                  style: TextStyle(
                                    color: balance > 0
                                        ? AppColors.textWhite70
                                        : AppColors.successGreen,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
