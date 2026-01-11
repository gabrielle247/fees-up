import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fees_up/data/constants/app_colors.dart';
import 'package:fees_up/data/constants/app_strings.dart';

// =============================================================================
// 1. LOCAL STRINGS & CONSTANTS (Strictly No UI String Literals)
// =============================================================================


// =============================================================================
// 2. SCREEN IMPLEMENTATION
// =============================================================================
class BillingInfoScreen extends StatefulWidget {
  const BillingInfoScreen({super.key});

  @override
  State<BillingInfoScreen> createState() => _BillingInfoScreenState();
}

class _BillingInfoScreenState extends State<BillingInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // --- State Variables ---
  String _frequency = AppStrings.freqTermly;
  final TextEditingController _dueDaysController = TextEditingController(text: "14");
  
  // Penalty State
  bool _enableLateFees = false;
  String _penaltyType = AppStrings.typePercent;
  final TextEditingController _penaltyValueController = TextEditingController(text: "5");
  final TextEditingController _gracePeriodController = TextEditingController(text: "7");

  // Mock Fee Heads (In a real app, this would be a dynamic list)
  final List<Map<String, String>> _feeHeads = [
    {"name": AppStrings.lblTuition, "amount": "150.00"},
    {"name": AppStrings.lblLevy, "amount": "30.00"},
    {"name": AppStrings.lblSports, "amount": "10.00"},
  ];

  @override
  void dispose() {
    _dueDaysController.dispose();
    _penaltyValueController.dispose();
    _gracePeriodController.dispose();
    super.dispose();
  }

  Future<void> _handleComplete() async {
    setState(() => _isLoading = true);
    
    // Simulate API save
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isLoading = false);
      // Setup Complete -> Go to Dashboard
      context.go(AppStrings.routeDashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;
    
    // Consistent Border Color
    final borderColor = isDark ? AppColors.surfaceLightGrey : AppColors.lightBorder;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.pageTitle),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // --- Header ---
                      Text(
                        AppStrings.header,
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppStrings.subHeader,
                        style: textTheme.bodyMedium,
                      ),
                      
                      const SizedBox(height: 32),

                      // ================= SECTION 1: BILLING CYCLES =================
                      _buildSectionHeader(context, AppStrings.secCycle),
                      
                      _buildLabel(context, AppStrings.lblFrequency),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: theme.cardTheme.color,
                          border: Border.all(color: borderColor),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _frequency,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down),
                            items: [
                              AppStrings.freqTermly,
                              AppStrings.freqMonthly,
                              AppStrings.freqAdhoc,
                            ].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value, style: textTheme.bodyLarge),
                              );
                            }).toList(),
                            onChanged: (newValue) => setState(() => _frequency = newValue!),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),

                      _buildLabel(context, AppStrings.lblDueDate),
                      TextFormField(
                        controller: _dueDaysController,
                        keyboardType: TextInputType.number,
                        style: textTheme.bodyLarge,
                        decoration: const InputDecoration(
                          hintText: AppStrings.numText,
                          suffixText: AppStrings.dayText, 
                          helperText: AppStrings.hintDueDate,
                          prefixIcon: Icon(Icons.calendar_today_outlined),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // ================= SECTION 2: FEE STRUCTURE =================
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSectionHeader(context, AppStrings.secStructure, padding: 0),
                          TextButton.icon(
                            onPressed: () {}, // Placebo add action
                            icon: const Icon(Icons.add_circle_outline, size: 16),
                            label: const Text(AppStrings.btnAddHead),
                            style: TextButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // Fee Heads List
                      Container(
                        decoration: BoxDecoration(
                          color: theme.cardTheme.color,
                          border: Border.all(color: borderColor),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Column(
                            children: _feeHeads.map((fee) {
                              final isLast = fee == _feeHeads.last;
                              return Column(
                                children: [
                                  ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                                    leading: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryBlue.withAlpha(25),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.monetization_on_outlined, 
                                        size: 20, 
                                        color: isDark ? AppColors.primaryBlueLight : AppColors.primaryBlue
                                      ),
                                    ),
                                    title: Text(
                                      fee[AppStrings.keyName]!, 
                                      style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)
                                    ),
                                    trailing: Text(
                                      "${AppStrings.currency}${fee[AppStrings.keyAmount]}",
                                      style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  if (!isLast) Divider(height: 1, color: borderColor.withAlpha(50)),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // ================= SECTION 3: PENALTIES =================
                      _buildSectionHeader(context, AppStrings.secPenalties),
                      
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          AppStrings.lblEnableLateFee,
                          style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        value: _enableLateFees,
                        activeThumbColor: AppColors.primaryBlue,
                        onChanged: (val) => setState(() => _enableLateFees = val),
                      ),

                      if (_enableLateFees) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel(context, AppStrings.lblPenaltyType),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: theme.cardTheme.color,
                                      border: Border.all(color: borderColor),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: _penaltyType,
                                        isExpanded: true,
                                        items: [
                                          AppStrings.typePercent,
                                          AppStrings.typeFixed,
                                        ].map((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value, style: textTheme.bodyMedium),
                                          );
                                        }).toList(),
                                        onChanged: (v) => setState(() => _penaltyType = v!),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel(context, "Value"),
                                  TextFormField(
                                    controller: _penaltyValueController,
                                    keyboardType: TextInputType.number,
                                    style: textTheme.bodyLarge,
                                    decoration: InputDecoration(
                                      hintText: "0",
                                      suffixText: _penaltyType == AppStrings.typePercent ? "%" : "\$",
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildLabel(context, AppStrings.lblGracePeriod),
                        TextFormField(
                          controller: _gracePeriodController,
                          keyboardType: TextInputType.number,
                          style: textTheme.bodyLarge,
                          decoration: const InputDecoration(
                            hintText: "7",
                            suffixText: "Days",
                            prefixIcon: Icon(Icons.timelapse),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            
            // --- Bottom Action ---
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleComplete,
                  child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(AppStrings.btnSaveFinish),
                          SizedBox(width: 8),
                          Icon(Icons.check_circle_outline),
                        ],
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, {double padding = 16.0}) {
    return Padding(
      padding: EdgeInsets.only(bottom: padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          const Divider(),
        ],
      ),
    );
  }
}