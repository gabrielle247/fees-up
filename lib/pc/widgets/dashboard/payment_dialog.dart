import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../data/services/database_service.dart';

class PaymentDialog extends ConsumerStatefulWidget {
  final String schoolId;
  
  const PaymentDialog({
    super.key, 
    required this.schoolId,
  });

  @override
  ConsumerState<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends ConsumerState<PaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _dbService = DatabaseService();

  // Controllers
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _payerController = TextEditingController();
  
  // State Variables
  String? _selectedStudentId; // Stores the valid UUID
  DateTime _selectedDate = DateTime.now();
  String _selectedMethod = 'Cash';
  String _selectedCategory = 'Tuition';
  bool _isLoading = false;

  // Constants
  final List<String> _methods = ['Cash', 'Bank Transfer', 'Mobile Money', 'Cheque'];
  final List<String> _categories = ['Tuition', 'Uniform', 'Levy', 'Transport', 'Donation'];

  @override
  void dispose() {
    _amountController.dispose();
    _payerController.dispose();
    super.dispose();
  }

  // --- LOGIC ---

  Future<void> _savePayment() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Validation: Ensure a student was actually selected from the list
    if (_selectedStudentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please search and select a valid student from the list'), 
          backgroundColor: AppColors.errorRed
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final newId = const Uuid().v4();
      final amount = double.tryParse(_amountController.text) ?? 0.0;

      final paymentData = {
        'id': newId,
        'school_id': widget.schoolId,
        'student_id': _selectedStudentId, // Valid UUID from autocomplete
        'amount': amount,
        'date_paid': DateFormat('yyyy-MM-dd').format(_selectedDate),
        'category': _selectedCategory,
        'payer_name': _payerController.text.trim(),
        'method': _selectedMethod,
        'created_at': DateTime.now().toIso8601String(),
      };

      await _dbService.insert('payments', paymentData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment recorded successfully!'),
            backgroundColor: AppColors.successGreen,
          ),
        );
        Navigator.of(context).pop(); 
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.errorRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
            BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 20, offset: const Offset(0, 10))
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
                    child: const Icon(Icons.account_balance_wallet, color: AppColors.primaryBlue),
                  ),
                  const SizedBox(width: 16),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Manage Payments", style: TextStyle(color: AppColors.textWhite, fontSize: 18, fontWeight: FontWeight.bold)),
                      Text("Record incoming fees and track recent transactions", style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
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
                              const Text("NEW PAYMENT ENTRY", style: TextStyle(color: AppColors.textGrey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                              const SizedBox(height: 24),

                              // --- SEARCHABLE STUDENT FIELD ---
                              _buildLabel("Student (Search Name or ID)", AppColors.textWhite),
                              StreamBuilder<List<Map<String, dynamic>>>(
                                stream: _dbService.watchStudents(widget.schoolId),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return const LinearProgressIndicator(color: AppColors.primaryBlue, backgroundColor: AppColors.surfaceGrey);
                                  }
                                  
                                  final students = snapshot.data!;
                                  
                                  return LayoutBuilder(
                                    builder: (context, constraints) {
                                      return Autocomplete<Map<String, dynamic>>(
                                        optionsBuilder: (TextEditingValue textEditingValue) {
                                          if (textEditingValue.text.isEmpty) {
                                            return students;
                                          }
                                          return students.where((student) {
                                            final name = student['full_name'].toString().toLowerCase();
                                            final id = (student['student_id'] ?? '').toString().toLowerCase();
                                            final query = textEditingValue.text.toLowerCase();
                                            return name.contains(query) || id.contains(query);
                                          });
                                        },
                                        displayStringForOption: (Map<String, dynamic> option) => 
                                            "${option['full_name']} (${option['student_id'] ?? 'N/A'})",
                                        
                                        onSelected: (Map<String, dynamic> selection) {
                                          setState(() {
                                            _selectedStudentId = selection['id'];
                                          });
                                        },

                                        // The Input Field
                                        fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                                          return TextFormField(
                                            controller: textEditingController,
                                            focusNode: focusNode,
                                            style: const TextStyle(color: AppColors.textWhite),
                                            decoration: InputDecoration(
                                              filled: true,
                                              fillColor: AppColors.surfaceGrey,
                                              hintText: "Type to search...",
                                              hintStyle: TextStyle(color: AppColors.textWhite.withValues(alpha: 0.3)),
                                              prefixIcon: const Icon(Icons.search, color: AppColors.textWhite54, size: 20),
                                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.surfaceLightGrey)),
                                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.surfaceLightGrey)),
                                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2)),
                                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                            ),
                                            onChanged: (text) {
                                              if (_selectedStudentId != null) {
                                                // logic to clear if needed
                                              }
                                            },
                                          );
                                        },

                                        // The Dropdown List Styling
                                        optionsViewBuilder: (context, onSelected, options) {
                                          return Align(
                                            alignment: Alignment.topLeft,
                                            child: Material(
                                              color: AppColors.surfaceGrey,
                                              elevation: 4.0,
                                              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
                                              child: Container(
                                                width: constraints.maxWidth,
                                                constraints: const BoxConstraints(maxHeight: 250),
                                                decoration: BoxDecoration(
                                                  border: Border.all(color: AppColors.surfaceLightGrey),
                                                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
                                                ),
                                                child: ListView.builder(
                                                  padding: EdgeInsets.zero,
                                                  itemCount: options.length,
                                                  itemBuilder: (BuildContext context, int index) {
                                                    final Map<String, dynamic> option = options.elementAt(index);
                                                    return ListTile(
                                                      title: Text(option['full_name'], style: const TextStyle(color: AppColors.textWhite)),
                                                      subtitle: Text(option['student_id'] ?? 'No ID', style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
                                                      onTap: () => onSelected(option),
                                                      hoverColor: AppColors.textWhite.withValues(alpha: 0.1),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    }
                                  );
                                },
                              ),
                              const SizedBox(height: 16),

                              // Amount & Date Row
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildLabel("Amount", AppColors.textWhite),
                                        _buildTextInput(
                                          controller: _amountController, 
                                          hint: "0.00", 
                                          isNumber: true,
                                          prefix: "\$ "
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildLabel("Payment Date", AppColors.textWhite),
                                        _buildDatePicker(context, _selectedDate, (d) => setState(() => _selectedDate = d)),
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
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildLabel("Category", AppColors.textWhite),
                                        _buildDropdown(
                                          value: _selectedCategory,
                                          items: _categories,
                                          onChanged: (v) => setState(() => _selectedCategory = v!),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildLabel("Payment Method", AppColors.textWhite),
                                        _buildDropdown(
                                          value: _selectedMethod,
                                          items: _methods,
                                          onChanged: (v) => setState(() => _selectedMethod = v!),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Payer Name
                              _buildLabel("Payer Name (Parent/Guardian)", AppColors.textWhite),
                              _buildTextInput(
                                controller: _payerController, 
                                hint: "e.g. Mr. Smith", 
                                prefixIcon: Icons.person_outline
                              ),
                              
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const VerticalDivider(width: 1, color: AppColors.divider),

                  // --- RIGHT: LIST SECTION (Flex 3) ---
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
                              const Text("RECENT PAYMENTS", style: TextStyle(color: AppColors.textGrey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                              StreamBuilder<List<Map<String, dynamic>>>(
                                stream: _dbService.watchAll('payments'), 
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) return const Text("\$0.00", style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold));
                                  double total = 0;
                                  for(var p in snapshot.data!) {
                                    total += (p['amount'] as num?)?.toDouble() ?? 0.0;
                                  }
                                  return Text("Total: \$${total.toStringAsFixed(2)}", style: const TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold));
                                }
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // List of Payments
                          Expanded(
                            child: StreamBuilder<List<Map<String, dynamic>>>(
                              stream: _dbService.watchAll('payments'),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue));
                                }
                                
                                final payments = snapshot.data ?? [];
                                
                                if (payments.isEmpty) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.receipt_long, size: 48, color: AppColors.textGrey.withValues(alpha: 0.2)),
                                        const SizedBox(height: 12),
                                        const Text("No payments recorded yet", style: TextStyle(color: AppColors.textGrey)),
                                      ],
                                    ),
                                  );
                                }

                                return ListView.separated(
                                  itemCount: payments.length,
                                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final payment = payments[index];
                                    final amount = (payment['amount'] as num?)?.toDouble() ?? 0.0;
                                    final dateStr = payment['date_paid'] ?? '';
                                    final payer = payment['payer_name'] ?? 'Unknown Payer';
                                    final method = payment['method'] ?? 'Cash';

                                    return Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceGrey,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                                      ),
                                      child: Row(
                                        children: [
                                          // Icon Box
                                          Container(
                                            width: 40, height: 40,
                                            decoration: BoxDecoration(
                                              color: _getMethodColor(method).withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              _getMethodIcon(method),
                                              color: _getMethodColor(method),
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          
                                          // Details
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(payer, style: const TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold, fontSize: 14)),
                                                const SizedBox(height: 2),
                                                Text("$method • $dateStr", style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
                                              ],
                                            ),
                                          ),

                                          // Amount
                                          Text(
                                            "+\$${amount.toStringAsFixed(2)}",
                                            style: const TextStyle(color: AppColors.successGreen, fontWeight: FontWeight.bold, fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const Divider(height: 1, color: AppColors.divider),

            // --- FOOTER ---
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel", style: TextStyle(color: AppColors.textWhite70)),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _savePayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      foregroundColor: AppColors.textWhite,
                    ),
                    icon: _isLoading 
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textWhite)) 
                      : const Icon(Icons.check, size: 18),
                    label: Text(_isLoading ? "Saving..." : "Save Payment", style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS (Uniform with StudentDialog) ---

  Widget _buildLabel(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: TextStyle(color: color.withValues(alpha: 0.9), fontSize: 14, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildTextInput({
    required TextEditingController controller, 
    required String hint, 
    bool isNumber = false,
    String? prefix,
    IconData? prefixIcon
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      style: const TextStyle(color: AppColors.textWhite),
      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.surfaceGrey,
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.textWhite.withValues(alpha: 0.3)),
        prefixText: prefix, prefixStyle: const TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppColors.textWhite54, size: 20) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.surfaceLightGrey)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.surfaceLightGrey)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
          dropdownColor: AppColors.surfaceGrey,
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textWhite54),
          isExpanded: true,
          style: const TextStyle(color: AppColors.textWhite),
          items: items.map((String val) {
            return DropdownMenuItem<String>(
              value: val,
              child: Text(val),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context, DateTime initial, Function(DateTime) onPicked) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: initial,
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 30)),
          builder: (context, child) {
            return Theme(
              data: ThemeData.dark().copyWith(
                colorScheme: const ColorScheme.dark(
                  primary: AppColors.primaryBlue,
                  onPrimary: AppColors.textWhite,
                  surface: AppColors.surfaceGrey,
                  onSurface: AppColors.textWhite,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) onPicked(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceGrey,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.surfaceLightGrey),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(DateFormat('MMM dd, yyyy').format(initial), style: const TextStyle(color: AppColors.textWhite)),
            const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.textWhite54),
          ],
        ),
      ),
    );
  }

  // --- HELPERS ---

  Color _getMethodColor(String method) {
    switch (method.toLowerCase()) {
      case 'cash': return AppColors.successGreen;
      case 'bank transfer': return AppColors.primaryBlue;
      case 'mobile money': return AppColors.warningOrange;
      default: return AppColors.accentPurple;
    }
  }

  IconData _getMethodIcon(String method) {
    switch (method.toLowerCase()) {
      case 'cash': return Icons.attach_money;
      case 'bank transfer': return Icons.account_balance;
      case 'mobile money': return Icons.phone_android;
      default: return Icons.credit_card;
    }
  }
}