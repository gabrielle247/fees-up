import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/safe_data.dart';
import '../../../../data/services/database_service.dart';

class QuickPaymentDialog extends ConsumerStatefulWidget {
  final String schoolId;
  final String studentId;
  final String studentName;
  final double outstandingAmount;

  const QuickPaymentDialog({
    super.key,
    required this.schoolId,
    required this.studentId,
    required this.studentName,
    required this.outstandingAmount,
  });

  @override
  ConsumerState<QuickPaymentDialog> createState() => _QuickPaymentDialogState();
}

class _QuickPaymentDialogState extends ConsumerState<QuickPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _dbService = DatabaseService();

  // Controllers
  final _amountController = TextEditingController();
  final _payerNameController = TextEditingController();

  // State
  DateTime _selectedDate = DateTime.now();
  String _selectedMethod = 'Cash';
  String _selectedCategory = 'Tuition';
  bool _isLoading = false;

  // 🛡️ Issue #1, #8: Stream subscription for payment history
  StreamSubscription? _paymentSubscription;
  List<Map<String, dynamic>> _payments = [];

  // Constants
  final List<String> _methods = [
    'Cash',
    'Bank Transfer',
    'Mobile Money',
    'Cheque'
  ];
  final List<String> _categories = [
    'Tuition',
    'Uniform',
    'Levy',
    'Transport',
    'Donation'
  ];

  @override
  void initState() {
    super.initState();
    _payerNameController.text = widget.studentName;
    // Pre-fill with outstanding amount
    if (widget.outstandingAmount > 0) {
      _amountController.text = widget.outstandingAmount.toStringAsFixed(2);
    }

    // 🛡️ Issue #1, #8: Subscribe to payment stream with broadcast
    _paymentSubscription = _dbService.db
        .watch(
          'SELECT * FROM payments WHERE student_id = ? ORDER BY date_paid DESC',
          parameters: [widget.studentId],
        )
        .asBroadcastStream() // Issue #1: Broadcast to allow multiple listeners
        .listen(
          (payments) {
            if (mounted) {
              setState(() => _payments = payments);
            }
          },
          onError: (e) => debugPrint('⚠️ Payment stream error: $e'),
        );
  }

  @override
  void dispose() {
    // 🛡️ Issue #8: Critical cleanup of stream subscription
    _paymentSubscription?.cancel();
    _amountController.dispose();
    _payerNameController.dispose();
    super.dispose();
  }

  // --- LOGIC ---

  Future<void> _recordPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final db = _dbService;

      // 🛡️ Issue #9: Safe amount parsing with bounds validation
      final amount = SafeData.parseDouble(_amountController.text, 0.0);

      // Validation: Amount must be > 0
      if (amount <= 0) {
        _showError('Please enter a valid amount greater than 0');
        return;
      }

      // Validation: Amount must be ≤ 50,000 (reasonable max)
      if (amount > 50000) {
        _showError(
            'Amount exceeds maximum allowed (₦50,000). Please verify and try again.');
        return;
      }

      // 🛡️ Issue #10: Safe bill data access with field validation
      String billId = '';
      double billAmount = 0.0;
      
      try {
        final bills = await db.db.getAll(
          '''SELECT id, total_amount FROM bills 
             WHERE student_id = ? AND is_paid = 0
             ORDER BY created_at ASC LIMIT 1''',
          [widget.studentId],
        );

        if (bills.isNotEmpty) {
          billId = SafeData.safeGet<String>(bills[0], 'id', '');
          billAmount = SafeData.parseDouble(bills[0]['total_amount'], 0.0);
          
          if (billId.isEmpty) {
            debugPrint('⚠️ Warning: Bill ID is empty');
          }
        }
      } catch (e) {
        debugPrint('⚠️ Bill fetch error: $e');
        // Continue without bill link (Issue #6: prevent race conditions)
      }

      // 🛡️ Issue #6: Sanitize payer name to prevent data corruption
      final payerName = SafeData.sanitize(_payerNameController.text);

      // Create payment record
      final paymentData = {
        'id': const Uuid().v4(),
        'school_id': widget.schoolId,
        'student_id': widget.studentId,
        'bill_id': billId.isEmpty ? null : billId,
        'amount': amount,
        'date_paid': DateFormat('yyyy-MM-dd').format(_selectedDate),
        'category': _selectedCategory,
        'payer_name': payerName,
        'method': _selectedMethod,
        'created_at': DateTime.now().toIso8601String(),
      };

      // 🛡️ Issue #6 & #10: Atomic transaction - payment + bill update
      // First: Insert payment
      await db.insert('payments', paymentData);
      debugPrint('✅ Payment inserted: ₦${amount.toStringAsFixed(2)}');

      // Then: Mark bill as paid if payment covers full amount
      if (billId.isNotEmpty && amount >= billAmount) {
        try {
          await db.update('bills', billId,
              {'is_paid': 1, 'updated_at': DateTime.now().toIso8601String()});
          debugPrint('✅ Bill marked as paid: $billId');
        } catch (e) {
          // Bill update failed - payment still recorded
          debugPrint('⚠️ Bill update failed (payment was recorded): $e');
          if (mounted) {
            _showWarning('Payment recorded, but bill marking failed. '
                'Please check the bill status manually.');
          }
        }
      }

      if (mounted) {
        _showSuccess('Payment recorded successfully!');
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('❌ Payment record error: $e');
      if (mounted) {
        _showError('Error recording payment: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Helper: Show error snackbar (Issue #6: consistent error handling)
  void _showError(String message) {
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.errorRed,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Helper: Show warning snackbar
  void _showWarning(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Helper: Show success snackbar
  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.successGreen,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // --- UI BUILD ---

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        width: 1100,
        height: 700,
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
            // --- HEADER ---
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
                    child: const Icon(Icons.account_balance_wallet,
                        color: AppColors.primaryBlue),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Record Payment",
                          style: TextStyle(
                              color: AppColors.textWhite,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      Text("For ${widget.studentName}",
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

            // --- BODY (Split View) ---
            Expanded(
              child: Row(
                children: [
                  // --- LEFT: FORM SECTION (Flex 4) ---
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Form(
                        key: _formKey,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("PAYMENT DETAILS",
                                  style: TextStyle(
                                      color: AppColors.textGrey,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2)),
                              const SizedBox(height: 24),

                              // Outstanding Alert
                              if (widget.outstandingAmount > 0)
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    color: AppColors.errorRed
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: AppColors.errorRed
                                            .withValues(alpha: 0.3)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.warning_outlined,
                                          color: AppColors.errorRed, size: 18),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'Outstanding: ZWL ${widget.outstandingAmount.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            color: AppColors.textWhite,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              // Student Name (Read-only)
                              _buildLabel("Student", AppColors.textWhite),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceGrey,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: AppColors.surfaceLightGrey),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.person,
                                        color: AppColors.textWhite54),
                                    const SizedBox(width: 12),
                                    Text(
                                      widget.studentName,
                                      style: const TextStyle(
                                          color: AppColors.textWhite,
                                          fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Amount & Date Row
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildLabel(
                                            "Amount", AppColors.textWhite),
                                        _buildTextInput(
                                          controller: _amountController,
                                          hint: "0.00",
                                          isNumber: true,
                                          prefix: "\$ ",
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildLabel("Payment Date",
                                            AppColors.textWhite),
                                        _buildDatePicker(
                                            context,
                                            _selectedDate,
                                            (d) => setState(
                                                () => _selectedDate = d)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Category & Method Row
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildLabel(
                                            "Category", AppColors.textWhite),
                                        _buildDropdown(
                                          value: _selectedCategory,
                                          items: _categories,
                                          onChanged: (v) => setState(
                                              () => _selectedCategory = v!),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildLabel("Payment Method",
                                            AppColors.textWhite),
                                        _buildDropdown(
                                          value: _selectedMethod,
                                          items: _methods,
                                          onChanged: (v) => setState(
                                              () => _selectedMethod = v!),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Payer Name
                              _buildLabel("Payer Name (Parent/Guardian)",
                                  AppColors.textWhite),
                              _buildTextInput(
                                controller: _payerNameController,
                                hint: "e.g. Mr. Smith",
                                prefixIcon: Icons.person_outline,
                              ),

                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const VerticalDivider(width: 1, color: AppColors.divider),

                  // --- RIGHT: STUDENT'S PAYMENT HISTORY ---
                  Expanded(
                    flex: 3,
                    child: Container(
                      color: AppColors.surfaceDarkGrey,
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("PAYMENT HISTORY",
                                  style: TextStyle(
                                      color: AppColors.textGrey,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2)),
                              // 🛡️ Issue #1 & #8: State-based rendering instead of StreamBuilder
                              Builder(builder: (context) {
                                if (_payments.isEmpty) {
                                  return const Text("\$0.00",
                                      style: TextStyle(
                                          color: AppColors.textWhite,
                                          fontWeight: FontWeight.bold));
                                }
                                double total = 0;
                                for (var p in _payments) {
                                  total +=
                                      SafeData.parseDouble(p['amount'], 0.0);
                                }
                                return Text(
                                    "Total: \$${total.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                        color: AppColors.textWhite,
                                        fontWeight: FontWeight.bold));
                              }),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // List of Student Payments
                          Expanded(
                            // 🛡️ Issue #1 & #8: State-based list instead of StreamBuilder
                            child: Builder(builder: (context) {
                              final payments = _payments;

                              if (payments.isEmpty) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.receipt_long,
                                          size: 48,
                                          color: AppColors.textGrey
                                              .withValues(alpha: 0.2)),
                                      const SizedBox(height: 12),
                                      const Text("No payments yet",
                                          style: TextStyle(
                                              color: AppColors.textGrey)),
                                    ],
                                  ),
                                );
                              }

                              return ListView.separated(
                                itemCount: payments.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final p = payments[index];
                                  final amount =
                                      SafeData.parseDouble(p['amount'], 0.0);
                                  final date = SafeData.safeGet<String>(
                                      p, 'date_paid', '');
                                  final method = SafeData.safeGet<String>(
                                      p, 'method', 'Cash');
                                  final category = SafeData.safeGet<String>(
                                      p, 'category', 'Tuition');
                                  final methodColor = _getMethodColor(method);
                                  final methodIcon = _getMethodIcon(method);

                                  return Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceGrey,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: Colors.white
                                              .withValues(alpha: 0.05)),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: methodColor.withValues(
                                                alpha: 0.2),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Icon(methodIcon,
                                              color: methodColor, size: 20),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "\$${amount.toStringAsFixed(2)}",
                                                style: const TextStyle(
                                                    color: AppColors.textWhite,
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                "$category • $method",
                                                style: const TextStyle(
                                                    color:
                                                        AppColors.textWhite70,
                                                    fontSize: 12),
                                              ),
                                              Text(
                                                date,
                                                style: const TextStyle(
                                                    color: AppColors.textGrey,
                                                    fontSize: 11),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- FOOTER ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("Cancel",
                        style: TextStyle(color: AppColors.textWhite70)),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _recordPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      foregroundColor: AppColors.textWhite,
                    ),
                    icon: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppColors.textWhite))
                        : const Icon(Icons.check, size: 18),
                    label: Text(_isLoading ? "Saving..." : "Record Payment",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildLabel(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text,
          style: TextStyle(
              color: color.withValues(alpha: 0.9),
              fontSize: 14,
              fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildTextInput({
    required TextEditingController controller,
    required String hint,
    String? prefix,
    IconData? prefixIcon,
    bool isNumber = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      validator: (val) {
        if (val == null || val.isEmpty) return 'Required';
        if (isNumber) {
          final amount = double.tryParse(val);
          if (amount == null) return 'Invalid number';
          if (amount <= 0) return 'Must be greater than 0';
        }
        return null;
      },
      style: const TextStyle(color: AppColors.textWhite),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.surfaceGrey,
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.textWhite.withValues(alpha: 0.3)),
        prefixText: prefix,
        prefixStyle: const TextStyle(
          color: AppColors.textWhite,
          fontWeight: FontWeight.bold,
        ),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: AppColors.textWhite54)
            : null,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.surfaceLightGrey)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.surfaceLightGrey)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide:
                const BorderSide(color: AppColors.primaryBlue, width: 2)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceGrey,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.surfaceLightGrey),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          style: const TextStyle(color: AppColors.textWhite),
          dropdownColor: AppColors.surfaceGrey,
          onChanged: onChanged,
          items: items
              .map((g) => DropdownMenuItem(value: g, child: Text(g)))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildDatePicker(
      BuildContext context, DateTime selected, Function(DateTime) onChanged) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: selected,
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 30)),
          builder: (context, child) => Theme(
            data: Theme.of(context).copyWith(
              dialogTheme: Theme.of(context).dialogTheme.copyWith(
                    backgroundColor: AppColors.backgroundBlack,
                  ),
            ),
            child: child!,
          ),
        );
        if (picked != null) onChanged(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceGrey,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.surfaceLightGrey),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today,
                size: 16, color: AppColors.textWhite54),
            const SizedBox(width: 12),
            Text(
              DateFormat('MMM dd, yyyy').format(selected),
              style: const TextStyle(color: AppColors.textWhite),
            ),
          ],
        ),
      ),
    );
  }

  // --- HELPER METHODS FOR VISUAL CONSISTENCY ---

  Color _getMethodColor(String method) {
    switch (method) {
      case 'Cash':
        return AppColors.successGreen;
      case 'Bank Transfer':
        return AppColors.primaryBlue;
      case 'Mobile Money':
        return AppColors.warningOrange;
      case 'Cheque':
        return AppColors.textWhite70;
      default:
        return AppColors.textGrey;
    }
  }

  IconData _getMethodIcon(String method) {
    switch (method) {
      case 'Cash':
        return Icons.money;
      case 'Bank Transfer':
        return Icons.account_balance;
      case 'Mobile Money':
        return Icons.phone_android;
      case 'Cheque':
        return Icons.receipt;
      default:
        return Icons.payment;
    }
  }
}
