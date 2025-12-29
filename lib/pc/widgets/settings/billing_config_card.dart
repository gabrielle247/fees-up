import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class BillingConfigCard extends StatelessWidget {
  const BillingConfigCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Billing Configuration", style: TextStyle(color: AppColors.textWhite, fontSize: 16, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: AppColors.primaryBlue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                child: const Icon(Icons.account_balance_wallet, color: AppColors.primaryBlue, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text("Manage currency, taxes, fees, and invoice defaults.", style: TextStyle(color: AppColors.textWhite54, fontSize: 12)),
          
          const SizedBox(height: 24),
          const Divider(color: AppColors.divider),
          const SizedBox(height: 24),

          // Currency & Tax Row
          Row(
            children: [
              Expanded(child: _buildInput("Base Currency", "USD - US Dollar (\$)", isDropdown: true)),
              const SizedBox(width: 24),
              Expanded(child: _buildInput("Default Tax Rate (%)", "0.0", suffix: "%", helper: "Not currently stored in schema")),
            ],
          ),
          const SizedBox(height: 32),

          // Fees Row (Matches default_fee in schema)
          const Text("Default Fee Settings", style: TextStyle(color: AppColors.textWhite, fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              // Mapped to billing_configs.default_fee
              Expanded(child: _buildInput("Annual Tuition Fee", "100.00", prefix: "\$")), 
              const SizedBox(width: 24),
              Expanded(child: _buildInput("One-time Registration Fee", "50.00", prefix: "\$")),
            ],
          ),
          const SizedBox(height: 32),

          // Payment Policy (Matches allow_partial_payments)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Payment & Late Fee Policy", style: TextStyle(color: AppColors.textWhite, fontSize: 13, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  const Text("Allow Partial Payments", style: TextStyle(color: AppColors.textWhite54, fontSize: 12)),
                  const SizedBox(width: 8),
                  Switch(
                    value: true, 
                    onChanged: (v) {},
                    activeThumbColor: AppColors.primaryBlue,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Late Fee Details (Matches late_fee_percentage)
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInput("Late Fee Percentage", "0.0", suffix: "%"),
                    const SizedBox(height: 4),
                    const Text("Applied monthly to outstanding balance.", style: TextStyle(color: AppColors.textWhite38, fontSize: 10)),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(child: _buildInput("Grace Period (Days)", "7")),
            ],
          ),
          const SizedBox(height: 32),

          // Footer Note (Matches invoice_footer_note)
          _buildInput(
            "Invoice Footer Note", 
            "Please include the invoice number in your wire transfer...",
            maxLines: 4,
            helper: "This text will appear at the bottom of every invoice generated."
          ),
        ],
      ),
    );
  }

  Widget _buildInput(String label, String value, {bool isDropdown = false, String? suffix, String? prefix, int maxLines = 1, String? helper}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textWhite70, fontSize: 13)),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: value,
          maxLines: maxLines,
          style: const TextStyle(color: AppColors.textWhite),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.backgroundBlack,
            contentPadding: const EdgeInsets.all(16),
            suffixText: suffix,
            prefixText: prefix,
            suffixStyle: const TextStyle(color: AppColors.textWhite54),
            prefixStyle: const TextStyle(color: AppColors.textWhite54),
            suffixIcon: isDropdown ? const Icon(Icons.keyboard_arrow_down, color: AppColors.textWhite54) : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.divider)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.divider)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primaryBlue)),
          ),
        ),
        if (helper != null) ...[
          const SizedBox(height: 4),
          Text(helper, style: const TextStyle(color: AppColors.textWhite38, fontSize: 10)),
        ]
      ],
    );
  }
}