import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/safe_data.dart';
import '../../../data/providers/payment_allocations_provider.dart';
import '../../../data/providers/invoices_provider.dart';

class PaymentAllocationsDialog extends ConsumerStatefulWidget {
  final String paymentId;
  final String studentId;
  final double paymentAmount;
  final String paymentDate;

  const PaymentAllocationsDialog({
    super.key,
    required this.paymentId,
    required this.studentId,
    required this.paymentAmount,
    required this.paymentDate,
  });

  @override
  ConsumerState<PaymentAllocationsDialog> createState() =>
      _PaymentAllocationsDialogState();
}

class _PaymentAllocationsDialogState
    extends ConsumerState<PaymentAllocationsDialog> {
  @override
  Widget build(BuildContext context) {
    final allocationsAsync =
        ref.watch(paymentAllocationsProvider(widget.paymentId));
    final unallocatedAsync =
        ref.watch(unallocatedPaymentAmountProvider(widget.paymentId));
    final billsAsync = ref.watch(studentInvoicesProvider(widget.studentId));

    return Dialog(
      backgroundColor: AppColors.surfaceGrey,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 700,
        constraints: const BoxConstraints(maxHeight: 600),
        decoration: BoxDecoration(
          color: AppColors.surfaceGrey,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.divider)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Payment Allocation Details',
                    style: TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textWhite54),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Payment Summary
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundBlack,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Payment Summary',
                              style: TextStyle(
                                color: AppColors.textWhite70,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              )),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Payment Amount',
                                  style:
                                      TextStyle(color: AppColors.textWhite54)),
                              Text(
                                NumberFormat.simpleCurrency()
                                    .format(widget.paymentAmount),
                                style: const TextStyle(
                                    color: AppColors.textWhite,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Payment Date',
                                  style:
                                      TextStyle(color: AppColors.textWhite54)),
                              Text(
                                widget.paymentDate,
                                style:
                                    const TextStyle(color: AppColors.textWhite),
                              ),
                            ],
                          ),
                          const Divider(
                            color: AppColors.divider,
                            height: 16,
                          ),
                          unallocatedAsync.when(
                            data: (unallocated) {
                              final color = unallocated > 0
                                  ? AppColors.warningOrange
                                  : AppColors.successGreen;
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Unallocated',
                                      style: TextStyle(
                                          color: color,
                                          fontWeight: FontWeight.bold)),
                                  Text(
                                    NumberFormat.simpleCurrency()
                                        .format(unallocated),
                                    style: TextStyle(
                                      color: color,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              );
                            },
                            loading: () => const Center(
                                child: CircularProgressIndicator()),
                            error: (_, __) => const Text('Error loading',
                                style: TextStyle(color: AppColors.errorRed)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Current Allocations
                    const Text('Current Allocations',
                        style: TextStyle(
                          color: AppColors.textWhite,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        )),
                    const SizedBox(height: 12),
                    allocationsAsync.when(
                      data: (allocations) {
                        if (allocations.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.backgroundBlack,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.divider),
                            ),
                            child: const Center(
                              child: Text('No allocations yet',
                                  style:
                                      TextStyle(color: AppColors.textWhite54)),
                            ),
                          );
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: allocations.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final alloc = allocations[index];
                            final billTitle = alloc['bill_title'] ?? 'Unknown';
                            final allocAmount =
                                SafeData.parseDouble(alloc['amount'], 0.0);

                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.backgroundBlack,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.divider),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(billTitle,
                                            style: const TextStyle(
                                              color: AppColors.textWhite,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis),
                                        Text(
                                            'Bill ID: ${alloc['bill_id'].toString().substring(0, 8)}...',
                                            style: const TextStyle(
                                              color: AppColors.textWhite54,
                                              fontSize: 11,
                                            )),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        NumberFormat.simpleCurrency()
                                            .format(allocAmount),
                                        style: const TextStyle(
                                          color: AppColors.successGreen,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 20,
                                        child: TextButton(
                                          onPressed: () {
                                            ref
                                                .read(
                                                    paymentAllocationNotifierProvider
                                                        .notifier)
                                                .removeAllocation(
                                                  allocationId:
                                                      alloc['id'].toString(),
                                                  billId: alloc['bill_id']
                                                      .toString(),
                                                )
                                                .then((_) {
                                              if (mounted) {
                                                // ignore: use_build_context_synchronously
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        '✅ Allocation removed'),
                                                  ),
                                                );
                                              }
                                            }).catchError((e) {
                                              if (mounted) {
                                                // ignore: use_build_context_synchronously
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content:
                                                        Text('❌ Error: $e'),
                                                  ),
                                                );
                                              }
                                            });
                                          },
                                          style: TextButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                            minimumSize:
                                                const Size.fromHeight(0),
                                            tapTargetSize: MaterialTapTargetSize
                                                .shrinkWrap,
                                          ),
                                          child: const Text('Remove',
                                              style: TextStyle(
                                                color: AppColors.warningOrange,
                                                fontSize: 10,
                                              )),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (err, _) => Text('Error: $err',
                          style: const TextStyle(color: AppColors.errorRed)),
                    ),
                    const SizedBox(height: 24),

                    // Allocate to Outstanding Bills
                    unallocatedAsync.when(
                      data: (unallocated) {
                        if (unallocated <= 0) {
                          return const SizedBox.shrink();
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Allocate to Outstanding Bills',
                                style: TextStyle(
                                  color: AppColors.textWhite,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                )),
                            const SizedBox(height: 12),
                            billsAsync.when(
                              data: (bills) {
                                final outstanding = bills
                                    .where((b) =>
                                        SafeData.parseInt(b['is_paid'] ?? 0) !=
                                        1)
                                    .toList();

                                if (outstanding.isEmpty) {
                                  return Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: AppColors.backgroundBlack,
                                      borderRadius: BorderRadius.circular(8),
                                      border:
                                          Border.all(color: AppColors.divider),
                                    ),
                                    child: const Center(
                                      child: Text('No outstanding bills',
                                          style: TextStyle(
                                              color: AppColors.textWhite54)),
                                    ),
                                  );
                                }

                                return ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: outstanding.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 8),
                                  itemBuilder: (context, index) {
                                    final bill = outstanding[index];
                                    final billTitle = bill['title'] ?? '---';
                                    final owed = SafeData.parseDouble(
                                        bill['total_amount'], 0.0);
                                    final paid = SafeData.parseDouble(
                                        bill['paid_amount'], 0.0);
                                    final remaining = owed - paid;

                                    return Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppColors.backgroundBlack,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: AppColors.divider),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(billTitle,
                                                    style: const TextStyle(
                                                      color:
                                                          AppColors.textWhite,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis),
                                                Text(
                                                    'Balance: ${NumberFormat.simpleCurrency().format(remaining)}',
                                                    style: const TextStyle(
                                                      color:
                                                          AppColors.textWhite54,
                                                      fontSize: 11,
                                                    )),
                                              ],
                                            ),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              final allocAmount =
                                                  remaining < unallocated
                                                      ? remaining
                                                      : unallocated;
                                              ref
                                                  .read(
                                                      paymentAllocationNotifierProvider
                                                          .notifier)
                                                  .allocatePayment(
                                                    paymentId: widget.paymentId,
                                                    billId:
                                                        bill['id'].toString(),
                                                    amount: allocAmount,
                                                  )
                                                  .then((_) {
                                                if (mounted) {
                                                  // ignore: use_build_context_synchronously
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                          '✅ Allocated ${NumberFormat.simpleCurrency().format(allocAmount)}'),
                                                    ),
                                                  );
                                                }
                                              }).catchError((e) {
                                                if (mounted) {
                                                  // ignore: use_build_context_synchronously
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content:
                                                          Text('❌ Error: $e'),
                                                    ),
                                                  );
                                                }
                                              });
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  AppColors.primaryBlue,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 8,
                                              ),
                                            ),
                                            child: const Text('Allocate',
                                                style: TextStyle(fontSize: 12)),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                              loading: () => const Center(
                                  child: CircularProgressIndicator()),
                              error: (err, _) => Text('Error: $err',
                                  style: const TextStyle(
                                      color: AppColors.errorRed)),
                            ),
                          ],
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.divider)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close',
                        style: TextStyle(color: AppColors.textWhite54)),
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
