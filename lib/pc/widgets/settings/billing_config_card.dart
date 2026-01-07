import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../data/providers/dashboard_provider.dart';
import '../../../../data/viewmodels/settings/billing_settings_viewmodel.dart';

class BillingConfigCard extends ConsumerStatefulWidget {
  const BillingConfigCard({super.key});

  @override
  ConsumerState<BillingConfigCard> createState() => _BillingConfigCardState();
}

class _BillingConfigCardState extends ConsumerState<BillingConfigCard> {
  final _currencyController = TextEditingController();
  final _taxController = TextEditingController();
  final _defaultFeeController = TextEditingController();
  final _registrationFeeController = TextEditingController();
  final _lateFeeController = TextEditingController();
  final _graceDaysController = TextEditingController();
  final _invoicePrefixController = TextEditingController();
  final _invoiceSequenceController = TextEditingController();
  final _invoiceFooterController = TextEditingController();

  bool _allowPartialPayments = true;
  bool _hydrated = false;
  bool _saving = false;
  Map<String, dynamic>? _lastConfig;

  @override
  void dispose() {
    _currencyController.dispose();
    _taxController.dispose();
    _defaultFeeController.dispose();
    _registrationFeeController.dispose();
    _lateFeeController.dispose();
    _graceDaysController.dispose();
    _invoicePrefixController.dispose();
    _invoiceSequenceController.dispose();
    _invoiceFooterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dashboardAsync = ref.watch(dashboardDataProvider);

    return dashboardAsync.when(
      loading: () => _loadingCard(),
      error: (err, _) => _errorCard('Dashboard load failed: $err'),
      data: (dashboard) {
        if (dashboard.schoolId.isEmpty) {
          return _errorCard('No school context found.');
        }

        final configAsync =
            ref.watch(billingSettingsViewModelProvider(dashboard.schoolId));
        return configAsync.when(
          loading: () => _loadingCard(),
          error: (err, _) => _errorCard('Billing config load failed: $err'),
          data: (config) {
            _hydrateIfNeeded(config);
            return _buildContent(context, dashboard.schoolId);
          },
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, String schoolId) {
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
              const Text(
                'Billing Configuration',
                style: TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: AppColors.primaryBlue,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Manage currency, taxes, fees, and invoice defaults.',
            style: TextStyle(color: AppColors.textWhite54, fontSize: 12),
          ),
          const SizedBox(height: 24),
          const Divider(color: AppColors.divider),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildInput(
                  label: 'Base Currency',
                  controller: _currencyController,
                  isDropdown: true,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildInput(
                  label: 'Default Tax Rate (%)',
                  controller: _taxController,
                  suffix: '%',
                  inputType:
                      const TextInputType.numberWithOptions(decimal: true),
                  hint: 'e.g., 10',
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Text(
            'Default Fee Settings',
            style: TextStyle(
              color: AppColors.textWhite,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInput(
                  label: 'Annual Tuition Fee',
                  controller: _defaultFeeController,
                  prefix: '\$',
                  inputType:
                      const TextInputType.numberWithOptions(decimal: true),
                  hint: 'e.g., 1000.00',
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildInput(
                  label: 'One-time Registration Fee',
                  controller: _registrationFeeController,
                  prefix: '\$',
                  inputType:
                      const TextInputType.numberWithOptions(decimal: true),
                  hint: 'e.g., 500.00',
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Payment & Late Fee Policy',
                style: TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  const Text(
                    'Allow Partial Payments',
                    style:
                        TextStyle(color: AppColors.textWhite54, fontSize: 12),
                  ),
                  const SizedBox(width: 8),
                  Switch(
                    value: _allowPartialPayments,
                    onChanged: (v) => setState(() => _allowPartialPayments = v),
                    activeThumbColor: AppColors.primaryBlue,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInput(
                      label: 'Late Fee Percentage',
                      controller: _lateFeeController,
                      suffix: '%',
                      inputType:
                          const TextInputType.numberWithOptions(decimal: true),
                      hint: 'e.g., 2.5',
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Applied monthly to outstanding balance.',
                      style:
                          TextStyle(color: AppColors.textWhite38, fontSize: 10),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildInput(
                  label: 'Grace Period (Days)',
                  controller: _graceDaysController,
                  inputType: TextInputType.number,
                  hint: 'e.g., 7',
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: _buildInput(
                  label: 'Invoice Prefix',
                  controller: _invoicePrefixController,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildInput(
                  label: 'Invoice Sequence Seed',
                  controller: _invoiceSequenceController,
                  inputType: TextInputType.number,
                  hint: 'e.g., 1000',
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildInput(
            label: 'Invoice Footer Note',
            controller: _invoiceFooterController,
            maxLines: 4,
            helper:
                'This text will appear at the bottom of every invoice generated.',
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _hydrated && _lastConfig != null
                      ? () => _hydrateIfNeeded(_lastConfig!, force: true)
                      : null,
                  child: const Text('Reset'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _saving ? null : () => _onSave(context, schoolId),
                  child: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save Changes'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _hydrateIfNeeded(Map<String, dynamic> config, {bool force = false}) {
    if (_hydrated && !force) return;
    _lastConfig = config;

    _currencyController.text = (config['currency_code'] ?? 'USD').toString();
    _taxController.text = _formatNumber(config['tax_rate_percentage']);
    _defaultFeeController.text = _formatNumber(config['default_fee']);
    _registrationFeeController.text = _formatNumber(config['registration_fee']);
    _lateFeeController.text = _formatNumber(config['late_fee_percentage']);
    _graceDaysController.text = (config['grace_period_days'] ?? 0).toString();
    _invoicePrefixController.text =
        (config['invoice_prefix'] ?? 'INV-').toString();
    _invoiceSequenceController.text =
        (config['invoice_sequence_seed'] ?? 1000).toString();
    _invoiceFooterController.text =
        (config['invoice_footer_note'] ?? '').toString();

    final partialRaw = config['allow_partial_payments'];
    _allowPartialPayments =
        partialRaw is bool ? partialRaw : (partialRaw ?? 1) == 1;

    _hydrated = true;
    setState(() {});
  }

  Future<void> _onSave(BuildContext context, String schoolId) async {
    // Validate before saving
    final validation = _validateBillingConfig();
    if (validation.isNotEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ ${validation.join(", ")}'),
            backgroundColor: AppColors.warningOrange,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      return;
    }

    setState(() => _saving = true);
    try {
      await ref.read(billingSettingsViewModelProvider(schoolId).notifier).saveConfig(
            currencyCode: _currencyController.text.trim().isEmpty
                ? 'USD'
                : _currencyController.text.trim(),
            taxRate: _parseDouble(_taxController.text),
            registrationFee: _parseDouble(_registrationFeeController.text),
            gracePeriodDays: _parseInt(_graceDaysController.text, fallback: 7),
            invoicePrefix: _invoicePrefixController.text.trim().isEmpty
                ? 'INV-'
                : _invoicePrefixController.text.trim(),
            invoiceSequenceSeed:
                _parseInt(_invoiceSequenceController.text, fallback: 1000),
            lateFeePercentage: _parseDouble(_lateFeeController.text),
            defaultFee: _parseDouble(_defaultFeeController.text),
            allowPartialPayments: _allowPartialPayments,
            invoiceFooterNote: _invoiceFooterController.text.trim(),
          );

      if (mounted) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Billing settings saved')),
        );
      }
    } catch (e) {
      if (mounted) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /// Validate billing config for logical consistency
  List<String> _validateBillingConfig() {
    final errors = <String>[];
    final taxRate = _parseDouble(_taxController.text);
    final lateFee = _parseDouble(_lateFeeController.text);
    final graceDays = _parseInt(_graceDaysController.text, fallback: 7);
    final invoicePrefix = _invoicePrefixController.text.trim();
    final defaultFee = _parseDouble(_defaultFeeController.text);
    final registrationFee = _parseDouble(_registrationFeeController.text);

    if (taxRate < 0 || taxRate > 100) {
      errors.add('Tax rate must be 0-100%');
    }
    if (lateFee < 0 || lateFee > 100) {
      errors.add('Late fee must be 0-100%');
    }
    if (graceDays < 0 || graceDays > 90) {
      errors.add('Grace period must be 0-90 days');
    }
    if (invoicePrefix.isEmpty) {
      errors.add('Invoice prefix required');
    }
    if (defaultFee < 0) {
      errors.add('Default fee cannot be negative');
    }
    if (registrationFee < 0) {
      errors.add('Registration fee cannot be negative');
    }

    return errors;
  }

  Widget _loadingCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: const Center(
        child: SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _errorCard(String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warningOrange),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.warningOrange),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: AppColors.warningOrange),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput({
    required String label,
    required TextEditingController controller,
    bool isDropdown = false,
    String? suffix,
    String? prefix,
    int maxLines = 1,
    String? helper,
    TextInputType inputType = TextInputType.text,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: AppColors.textWhite70, fontSize: 13)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: AppColors.textWhite),
          keyboardType: inputType,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.backgroundBlack,
            contentPadding: const EdgeInsets.all(16),
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textWhite38),
            suffixText: suffix,
            prefixText: prefix,
            suffixStyle: const TextStyle(color: AppColors.textWhite54),
            prefixStyle: const TextStyle(color: AppColors.textWhite54),
            suffixIcon: isDropdown
                ? const Icon(Icons.keyboard_arrow_down,
                    color: AppColors.textWhite54)
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primaryBlue),
            ),
          ),
        ),
        if (helper != null) ...[
          const SizedBox(height: 4),
          Text(helper,
              style:
                  const TextStyle(color: AppColors.textWhite38, fontSize: 10)),
        ],
      ],
    );
  }

  String _formatNumber(dynamic value) {
    if (value == null) return '0';
    if (value is num) return value.toString();
    return double.tryParse(value.toString())?.toString() ?? '0';
  }

  double _parseDouble(String value) {
    return double.tryParse(value.trim()) ?? 0.0;
  }

  int _parseInt(String value, {required int fallback}) {
    return int.tryParse(value.trim()) ?? fallback;
  }
}
