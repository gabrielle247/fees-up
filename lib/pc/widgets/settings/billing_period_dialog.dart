import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/providers/dashboard_provider.dart';

/// Universal Billing Period Configuration Dialog
/// Can be launched from anywhere in the app
class BillingPeriodDialog extends ConsumerStatefulWidget {
  final String? schoolId;
  final String? existingConfigId; // For editing existing config

  const BillingPeriodDialog({
    super.key,
    this.schoolId,
    this.existingConfigId,
  });

  @override
  ConsumerState<BillingPeriodDialog> createState() =>
      _BillingPeriodDialogState();
}

class _BillingPeriodDialogState extends ConsumerState<BillingPeriodDialog> {
  final _formKey = GlobalKey<FormState>();
  final _supabase = Supabase.instance.client;

  // Controllers
  final TextEditingController _tuitionController = TextEditingController();
  final TextEditingController _uniformController = TextEditingController();
  final TextEditingController _levyController = TextEditingController();
  final TextEditingController _transportController = TextEditingController();
  final TextEditingController _lateFeeController =
      TextEditingController(text: '5.0');

  // State
  String _selectedFrequency = 'monthly';
  int _billingDay = 1;
  int _dueDay = 15;
  String _selectedGrade = 'All Grades';
  bool _isLoading = false;
  bool _isActive = true;
  DateTime _effectiveFrom = DateTime.now();

  final List<String> _frequencies = ['monthly', 'termly', 'annual', 'adhoc'];
  final List<String> _grades = [
    'All Grades',
    'Grade 1',
    'Grade 2',
    'Grade 3',
    'Grade 4',
    'Grade 5',
    'Grade 6',
    'Grade 7',
    'Grade 8',
    'Grade 9',
    'Grade 10',
    'Grade 11',
    'Grade 12'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingConfigId != null) {
      _loadExistingConfig();
    }
  }

  Future<void> _loadExistingConfig() async {
    setState(() => _isLoading = true);
    try {
      final config = await _supabase
          .from('billing_configs')
          .select()
          .eq('id', widget.existingConfigId!)
          .single();

      if (mounted) {
        _tuitionController.text = (config['default_fee'] ?? 0).toString();
        _lateFeeController.text =
            (config['late_fee_percentage'] ?? 5.0).toString();
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('Failed to load configuration: $e');
      }
    }
  }

  Future<void> _saveBillingPeriod() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Get school_id
      final schoolId = widget.schoolId ??
          (await ref.read(dashboardDataProvider.future)).schoolId;

      if (schoolId.isEmpty) {
        throw Exception('School ID not found');
      }

      final configData = {
        'id': widget.existingConfigId ?? const Uuid().v4(),
        'school_id': schoolId,
        'currency_code': 'USD',
        'late_fee_percentage': double.tryParse(_lateFeeController.text) ?? 5.0,
        'allow_partial_payments': true,
        'invoice_footer_note': 'Thank you for your payment',
        'default_fee': double.tryParse(_tuitionController.text) ?? 0.0,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Upsert billing config
      await _supabase.from('billing_configs').upsert(configData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Billing configuration saved successfully'),
            backgroundColor: AppColors.successGreen,
          ),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      _showError('Failed to save configuration: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.errorRed,
      ),
    );
  }

  @override
  void dispose() {
    _tuitionController.dispose();
    _uniformController.dispose();
    _levyController.dispose();
    _transportController.dispose();
    _lateFeeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        width: 900,
        constraints: const BoxConstraints(maxHeight: 720),
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
            // Header
            _buildHeader(),
            const Divider(height: 1, color: AppColors.divider),

            // Body
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryBlue,
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(32),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFrequencySection(),
                            const SizedBox(height: 32),
                            _buildFeeComponentsSection(),
                            const SizedBox(height: 32),
                            _buildBillingDatesSection(),
                            const SizedBox(height: 32),
                            _buildAdvancedSettings(),
                          ],
                        ),
                      ),
                    ),
            ),

            // Footer
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.calendar_month,
              color: AppColors.primaryBlue,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.existingConfigId != null
                      ? 'Edit Billing Configuration'
                      : 'Create Billing Period',
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Configure recurring billing cycles and fee structures',
                  style: TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: AppColors.textGrey),
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }

  Widget _buildFrequencySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Billing Frequency',
          style: TextStyle(
            color: AppColors.textWhite,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildDropdownField(
                label: 'Frequency',
                value: _selectedFrequency,
                items: _frequencies,
                onChanged: (value) {
                  setState(() => _selectedFrequency = value!);
                },
                icon: Icons.repeat,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDropdownField(
                label: 'Grade Level',
                value: _selectedGrade,
                items: _grades,
                onChanged: (value) {
                  setState(() => _selectedGrade = value!);
                },
                icon: Icons.school,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeeComponentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fee Components',
          style: TextStyle(
            color: AppColors.textWhite,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Set standard fees for this billing period',
          style: TextStyle(color: AppColors.textGrey, fontSize: 12),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _tuitionController,
                label: 'Tuition',
                hint: '5000.00',
                icon: Icons.school,
                prefix: '\$',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _uniformController,
                label: 'Uniform',
                hint: '150.00',
                icon: Icons.checkroom,
                prefix: '\$',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _levyController,
                label: 'Levy',
                hint: '200.00',
                icon: Icons.account_balance,
                prefix: '\$',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _transportController,
                label: 'Transport',
                hint: '300.00',
                icon: Icons.directions_bus,
                prefix: '\$',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBillingDatesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Billing Schedule',
          style: TextStyle(
            color: AppColors.textWhite,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildNumberField(
                label: 'Billing Day',
                value: _billingDay,
                min: 1,
                max: 28,
                onChanged: (value) => setState(() => _billingDay = value),
                helper: 'Day of month when bills are generated',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildNumberField(
                label: 'Due Day',
                value: _dueDay,
                min: 1,
                max: 31,
                onChanged: (value) => setState(() => _dueDay = value),
                helper: 'Payment deadline day',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildDateField(
          label: 'Effective From',
          value: _effectiveFrom,
          onChanged: (date) => setState(() => _effectiveFrom = date),
        ),
      ],
    );
  }

  Widget _buildAdvancedSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Advanced Settings',
          style: TextStyle(
            color: AppColors.textWhite,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildTextField(
                controller: _lateFeeController,
                label: 'Late Fee Percentage',
                hint: '5.0',
                icon: Icons.percent,
                suffix: '%',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceGrey,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        color: AppColors.textGrey, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Late Fee Calculation',
                            style: TextStyle(
                              color: AppColors.textWhite,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Applied ${_lateFeeController.text}% after due date',
                            style: const TextStyle(
                              color: AppColors.textGrey,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          value: _isActive,
          onChanged: (value) => setState(() => _isActive = value),
          title: const Text(
            'Active Configuration',
            style: TextStyle(color: AppColors.textWhite, fontSize: 14),
          ),
          subtitle: const Text(
            'Enable this billing period for new students',
            style: TextStyle(color: AppColors.textGrey, fontSize: 12),
          ),
          activeThumbColor: AppColors.successGreen,
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textGrey),
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _saveBillingPeriod,
            icon: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.check, size: 20),
            label: Text(_isLoading ? 'Saving...' : 'Save Configuration'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widgets

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? icon,
    String? prefix,
    String? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textWhite70,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: AppColors.textWhite),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textGrey),
            prefixIcon: icon != null
                ? Icon(icon, color: AppColors.textGrey, size: 20)
                : null,
            prefixText: prefix,
            suffixText: suffix,
            filled: true,
            fillColor: AppColors.surfaceGrey,
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
          validator: (value) {
            if (value == null || value.isEmpty) return null;
            if (double.tryParse(value) == null) {
              return 'Enter a valid number';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textWhite70,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value,
          onChanged: onChanged,
          dropdownColor: AppColors.surfaceGrey,
          style: const TextStyle(color: AppColors.textWhite),
          decoration: InputDecoration(
            prefixIcon: icon != null
                ? Icon(icon, color: AppColors.textGrey, size: 20)
                : null,
            filled: true,
            fillColor: AppColors.surfaceGrey,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
          ),
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(
                item
                    .split('_')
                    .map((word) => word[0].toUpperCase() + word.substring(1))
                    .join(' '),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNumberField({
    required String label,
    required int value,
    required int min,
    required int max,
    required ValueChanged<int> onChanged,
    String? helper,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textWhite70,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceGrey,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: value > min ? () => onChanged(value - 1) : null,
                icon: const Icon(Icons.remove),
                color: AppColors.textWhite,
              ),
              Expanded(
                child: Text(
                  value.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: value < max ? () => onChanged(value + 1) : null,
                icon: const Icon(Icons.add),
                color: AppColors.textWhite,
              ),
            ],
          ),
        ),
        if (helper != null) ...[
          const SizedBox(height: 4),
          Text(
            helper,
            style: const TextStyle(
              color: AppColors.textGrey,
              fontSize: 11,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime value,
    required ValueChanged<DateTime> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textWhite70,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: value,
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
              builder: (context, child) {
                return Theme(
                  data: ThemeData.dark().copyWith(
                    colorScheme: const ColorScheme.dark(
                      primary: AppColors.primaryBlue,
                      surface: AppColors.surfaceGrey,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) onChanged(picked);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.surfaceGrey,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today,
                    color: AppColors.textGrey, size: 20),
                const SizedBox(width: 12),
                Text(
                  DateFormat('MMM dd, yyyy').format(value),
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Helper function to show billing period dialog from anywhere
Future<bool?> showBillingPeriodDialog(
  BuildContext context, {
  String? schoolId,
  String? existingConfigId,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => BillingPeriodDialog(
      schoolId: schoolId,
      existingConfigId: existingConfigId,
    ),
  );
}
