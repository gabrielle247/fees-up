import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';

/// Recent Payments Section Fragment - Displays list of recent payments
/// Complies with Law of Fragments: Self-contained payment display logic
class RecentPaymentsSection extends StatelessWidget {
  final List<dynamic> payments;

  const RecentPaymentsSection({
    super.key,
    required this.payments,
  });

  @override
  Widget build(BuildContext context) {
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
          const Text(
            "Recent Payments",
            style: TextStyle(
              color: AppColors.textWhite,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (payments.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                "No recent payments found.",
                style: TextStyle(color: AppColors.textWhite54),
              ),
            )
          else
            ...payments.map((payment) {
              return Column(
                children: [
                  _PaymentRow(
                    name: payment['payer_name'] ?? 'Unknown',
                    date: payment['date_paid'] != null
                        ? DateFormat('MMM d, yyyy')
                            .format(DateTime.parse(payment['date_paid']))
                        : 'Unknown Date',
                    description: payment['category'] ?? 'Fee',
                    amount:
                        NumberFormat.simpleCurrency().format(payment['amount']),
                    isPaid: true,
                  ),
                  const Divider(color: AppColors.divider),
                ],
              );
            }),
        ],
      ),
    );
  }
}

/// Payment Row Widget - Individual payment display item
class _PaymentRow extends StatelessWidget {
  final String name;
  final String date;
  final String description;
  final String amount;
  final bool isPaid;

  const _PaymentRow({
    required this.name,
    required this.date,
    required this.description,
    required this.amount,
    required this.isPaid,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.divider,
            child: Icon(
              Icons.person,
              size: 16,
              color: AppColors.textWhite54,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(color: AppColors.textWhite),
                ),
                Text(
                  date,
                  style: const TextStyle(
                    color: AppColors.textWhite38,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              description,
              style: const TextStyle(color: AppColors.textWhite70),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              amount,
              style: const TextStyle(
                color: AppColors.textWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
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
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
