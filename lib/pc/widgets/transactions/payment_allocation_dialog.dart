import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../data/services/transaction_service.dart';

/// 🔒 SECURE Payment Allocation Dialog
/// Allows users to allocate a payment across one or more bills
/// Supports partial payments and multi-bill allocation
class PaymentAllocationDialog extends ConsumerStatefulWidget {
  final String paymentId;
  final double paymentAmount;
  final List<Map<String, dynamic>> outstandingBills;
  final String studentId;
  final String schoolId;
  final VoidCallback onAllocationComplete;

  const PaymentAllocationDialog({
    super.key,
    required this.paymentId,
    required this.paymentAmount,
    required this.outstandingBills,
    required this.studentId,
    required this.schoolId,
    required this.onAllocationComplete,
  });

  @override
  ConsumerState<PaymentAllocationDialog> createState() =>
      _PaymentAllocationDialogState();
}

class _PaymentAllocationDialogState
    extends ConsumerState<PaymentAllocationDialog> {
  late final TransactionService _transactionService;
  final Map<String, double> _allocations = {}; // billId -> allocatedAmount
  double _remainingAmount = 0.0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _transactionService = TransactionService(supabase: Supabase.instance.client);
    _remainingAmount = widget.paymentAmount;

    // Initialize allocations with zero for each bill
    for (final bill in widget.outstandingBills) {
      _allocations[bill['id'] as String] = 0.0;
    }
  }

  /// Update allocation for a bill
  void _updateAllocation(String billId, double amount) {
    setState(() {
      _allocations[billId] = amount.clamp(0.0, widget.paymentAmount);

      // Recalculate remaining
      _remainingAmount = widget.paymentAmount -
          _allocations.values.fold(0.0, (sum, val) => sum + val);
    });
  }

  /// Auto-allocate: Fill bills in order until payment is exhausted
  void _autoAllocate() {
    setState(() {
      double remaining = widget.paymentAmount;
      _allocations.clear();

      for (final bill in widget.outstandingBills) {
        final billId = bill['id'] as String;
        final outstanding = bill['outstanding_balance'] as double? ?? 0.0;

        if (remaining <= 0) {
          _allocations[billId] = 0.0;
        } else if (remaining >= outstanding) {
          _allocations[billId] = outstanding;
          remaining -= outstanding;
        } else {
          _allocations[billId] = remaining;
          remaining = 0.0;
        }
      }

      _remainingAmount = remaining;
    });
  }

  /// Split equally across all bills
  void _splitEqually() {
    final perBill = widget.paymentAmount / widget.outstandingBills.length;
    setState(() {
      for (final bill in widget.outstandingBills) {
        _allocations[bill['id'] as String] = perBill;
      }
      _remainingAmount = 0.0;
    });
  }

  /// Submit allocations
  Future<void> _submitAllocations() async {
    // Validate: at least one allocation
    final hasAllocations =
        _allocations.values.any((amount) => amount > 0);
    if (!hasAllocations) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Allocate payment to at least one bill'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Get non-zero allocations
      final allocationsToProcess = _allocations.entries
          .where((e) => e.value > 0)
          .map((e) => MapEntry(e.key, e.value))
          .toList();

      // Allocate payment to bills
      await _transactionService.allocatePaymentToMultipleBills(
        paymentId: widget.paymentId,
        billAllocations: allocationsToProcess, schoolId: '',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment allocated successfully'),
            backgroundColor: AppColors.successGreen,
          ),
        );

        widget.onAllocationComplete();
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        width: 900,
        constraints: const BoxConstraints(maxHeight: 700),
        decoration: BoxDecoration(
          color: AppColors.backgroundBlack,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.surfaceLightGrey),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.attach_money,
                        color: AppColors.primaryBlue),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Allocate Payment",
                          style: TextStyle(
                              color: AppColors.textWhite,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      Text(
                          'Payment: \$${widget.paymentAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                              color: AppColors.textGrey, fontSize: 13)),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: AppColors.textGrey),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.divider),

            // CONTENT
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick Actions
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _autoAllocate,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                AppColors.primaryBlue.withValues(alpha: 0.2),
                            foregroundColor: AppColors.primaryBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: const Icon(Icons.auto_awesome, size: 18),
                          label: const Text('Auto-Allocate'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: _splitEqually,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                AppColors.primaryBlue.withValues(alpha: 0.2),
                            foregroundColor: AppColors.primaryBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: const Icon(Icons.rule_folder, size: 18),
                          label: const Text('Split Equally'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Bills List
                    Text('Outstanding Bills',
                        style: TextStyle(
                          color: AppColors.textWhite.withValues(alpha: 0.9),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        )),
                    const SizedBox(height: 16),

                    if (widget.outstandingBills.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceGrey,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text('No outstanding bills',
                              style: TextStyle(color: AppColors.textGrey)),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: widget.outstandingBills.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final bill = widget.outstandingBills[index];
                          final billId = bill['id'] as String;
                          final title = bill['title'] as String? ?? 'Unknown Bill';
                          final outstanding =
                              bill['outstanding_balance'] as double? ?? 0.0;
                          final allocated = _allocations[billId] ?? 0.0;

                          return _buildBillAllocationRow(
                            billId: billId,
                            title: title,
                            outstandingAmount: outstanding,
                            allocatedAmount: allocated,
                            onAllocationChanged: _updateAllocation,
                          );
                        },
                      ),

                    const SizedBox(height: 24),

                    // Summary
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDarkGrey,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.surfaceLightGrey),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Total Allocated',
                                  style: TextStyle(
                                    color: AppColors.textWhite
                                        .withValues(alpha: 0.7),
                                    fontSize: 12,
                                  )),
                              Text(
                                '\$${(widget.paymentAmount - _remainingAmount).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: AppColors.textWhite,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: AppColors.surfaceLightGrey,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Remaining',
                                  style: TextStyle(
                                    color: AppColors.textWhite
                                        .withValues(alpha: 0.7),
                                    fontSize: 12,
                                  )),
                              Text(
                                '\$${_remainingAmount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: _remainingAmount > 0.01
                                      ? AppColors.warningOrange
                                      : AppColors.successGreen,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Divider(height: 1, color: AppColors.divider),

            // FOOTER
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel',
                        style: TextStyle(color: AppColors.textWhite70)),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _submitAllocations,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      foregroundColor: AppColors.textWhite,
                    ),
                    icon: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.textWhite,
                            ),
                          )
                        : const Icon(Icons.check, size: 18),
                    label: Text(
                      _isLoading ? 'Allocating...' : 'Confirm Allocation',
                      style: const TextStyle(fontWeight: FontWeight.bold),
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

  Widget _buildBillAllocationRow({
    required String billId,
    required String title,
    required double outstandingAmount,
    required double allocatedAmount,
    required Function(String, double) onAllocationChanged,
  }) {
    final controller = TextEditingController(
      text: allocatedAmount > 0 ? allocatedAmount.toStringAsFixed(2) : '',
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceGrey,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.surfaceLightGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: AppColors.textWhite,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(
                      'Outstanding: \$${outstandingAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                          color: AppColors.textGrey, fontSize: 12)),
                ],
              ),
              Text(
                _getProgressBar(allocatedAmount, outstandingAmount),
                style: const TextStyle(
                  color: AppColors.primaryBlueLight,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('\$',
                  style: TextStyle(
                      color: AppColors.textWhite,
                      fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(color: AppColors.textWhite),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.surfaceDarkGrey,
                    hintText: '0.00',
                    hintStyle: TextStyle(
                        color: AppColors.textWhite.withValues(alpha: 0.3)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: const BorderSide(
                          color: AppColors.surfaceLightGrey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: const BorderSide(
                          color: AppColors.surfaceLightGrey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide:
                          const BorderSide(color: AppColors.primaryBlue),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                  ),
                  onChanged: (value) {
                    final amount = double.tryParse(value) ?? 0.0;
                    onAllocationChanged(billId, amount);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getProgressBar(double allocated, double outstanding) {
    if (outstanding == 0) return '100%';
    final percentage = ((allocated / outstanding) * 100).clamp(0.0, 100.0);
    return '${percentage.toStringAsFixed(0)}%';
  }
}
