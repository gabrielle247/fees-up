import 'dart:ui';
// ignore: unused_import
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/finance_models.dart';
import '../../../../data/providers/expense_provider.dart';

class ExpenseDialog extends ConsumerStatefulWidget {
  final String schoolId;
  const ExpenseDialog({super.key, required this.schoolId});

  @override
  ConsumerState<ExpenseDialog> createState() => _ExpenseDialogState();
}

class _ExpenseDialogState extends ConsumerState<ExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _dateController = TextEditingController();
  final _recipientController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String? _selectedCategory;
  String? _selectedPaymentMethod;

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    _recipientController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primaryBlue,
              onPrimary: AppColors.textWhite,
              surface: AppColors.surfaceGrey,
              onSurface: AppColors.textWhite,
            ),
            dialogTheme: const DialogThemeData(backgroundColor: AppColors.backgroundBlack),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _submit() async {
    if (widget.schoolId.isEmpty) return; // Security check
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(expenseControllerProvider.notifier).saveExpense(
      title: _titleController.text.trim(),
      amount: double.tryParse(_amountController.text.trim()) ?? 0.0,
      date: _selectedDate,
      category: _selectedCategory,
      recipient: _recipientController.text.trim(),
      notes: _notesController.text.trim(),
      paymentMethod: _selectedPaymentMethod,
    );

    if (success && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Expense Saved"), backgroundColor: AppColors.successGreen),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Check if school ID is valid
    final hasSchool = widget.schoolId.isNotEmpty;

    final expensesAsync = ref.watch(recentExpensesProvider);
    final saveState = ref.watch(expenseControllerProvider);

    // Listen for errors
    ref.listen(expenseControllerProvider, (prev, next) {
      if (next.hasError && !next.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${next.error}"), backgroundColor: AppColors.errorRed),
        );
      }
    });

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        width: 1100,
        height: 800,
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
            // HEADER
            _buildHeader(),
            const Divider(height: 1, color: AppColors.divider),

            // MAIN CONTENT
            Expanded(
              child: !hasSchool 
                ? _buildNoSchoolState()
                : _buildFormAndList(expensesAsync),
            ),

            const Divider(height: 1, color: AppColors.divider),
            
            // FOOTER (Disabled if no school)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("Cancel", style: TextStyle(color: AppColors.textWhite70)),
                  ),
                  const SizedBox(width: 16),
                  if (hasSchool)
                    ElevatedButton.icon(
                      onPressed: saveState.isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: AppColors.textWhite,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: saveState.isLoading 
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                        : const Icon(Icons.check, size: 18),
                      label: Text(saveState.isLoading ? "Saving..." : "Save Expense", style: const TextStyle(fontWeight: FontWeight.bold)),
                    )
                  else
                    ElevatedButton(
                      onPressed: null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.disabledGrey.withValues(alpha: 0.2),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      ),
                      child: const Text("Action Disabled", style: TextStyle(color: AppColors.textWhite38)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- CONTENT STATES ---

  Widget _buildNoSchoolState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.school_outlined, size: 64, color: AppColors.textGrey.withValues(alpha: 0.5)),
          const SizedBox(height: 24),
          const Text(
            "School Configuration Required",
            style: TextStyle(color: AppColors.textWhite, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Please set up a school to start creating any student data\nor sync the school to the database.",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textGrey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildFormAndList(AsyncValue<List<Expense>> expensesAsync) {
    return Row(
      children: [
        // --- LEFT COLUMN: FORM ---
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("NEW EXPENSE ENTRY", style: TextStyle(color: AppColors.textGrey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    const SizedBox(height: 24),

                    _buildLabel("Expense Title"),
                    _buildTextField(
                      controller: _titleController,
                      hint: "e.g. Science Lab Equipment",
                      validator: (v) => v!.isEmpty ? "Required" : null,
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel("Amount"),
                              _buildTextField(
                                controller: _amountController,
                                hint: "0.00",
                                prefix: "\$ ",
                                inputType: const TextInputType.numberWithOptions(decimal: true),
                                validator: (v) {
                                  if (v == null || v.isEmpty) return "Required";
                                  if (double.tryParse(v) == null) return "Invalid";
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel("Incurred Date"),
                              GestureDetector(
                                onTap: _pickDate,
                                child: AbsorbPointer(
                                  child: _buildTextField(
                                    controller: _dateController,
                                    hint: "yyyy-mm-dd",
                                    suffixIcon: Icons.calendar_today_outlined,
                                  ),
                                ),
                              ),
                            ],
                          ),
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
                              _buildLabel("Category"),
                              _buildDropdown(
                                hint: "Select category",
                                value: _selectedCategory,
                                items: ["Supplies", "Utilities", "Transport", "Events", "Maintenance", "Salaries"],
                                onChanged: (val) => setState(() => _selectedCategory = val),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel("Payment Method"),
                              _buildDropdown(
                                hint: "Select method",
                                value: _selectedPaymentMethod,
                                items: ["Bank Transfer", "Credit Card", "Cash", "Petty Cash", "EcoCash"],
                                onChanged: (val) => setState(() => _selectedPaymentMethod = val),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _buildLabel("Recipient / Vendor"),
                    _buildTextField(
                      controller: _recipientController,
                      hint: "e.g. Office Depot",
                      prefixIcon: Icons.storefront_outlined,
                    ),
                    const SizedBox(height: 16),

                    _buildLabel("Notes / Description"),
                    _buildTextField(
                      controller: _notesController,
                      hint: "Additional details...",
                      maxLines: 3,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Visual Placeholder for Attachments (Custom Dashed Border)
                    Opacity(
                      opacity: 0.5,
                      child: _buildAttachmentArea(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        const VerticalDivider(width: 1, color: AppColors.divider),

        // --- RIGHT COLUMN: RECENT LIST (Streamed from DB) ---
        Expanded(
          flex: 4,
          child: Container(
            color: AppColors.surfaceDarkGrey,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("RECENT EXPENSES", style: TextStyle(color: AppColors.textGrey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                const SizedBox(height: 24),
                Expanded(
                  child: expensesAsync.when(
                    data: (expenses) {
                      if (expenses.isEmpty) {
                        return const Center(child: Text("No expenses recorded yet.", style: TextStyle(color: AppColors.textGrey)));
                      }
                      return ListView.separated(
                        itemCount: expenses.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return _buildExpenseItem(expenses[index]);
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue)),
                    error: (e, stack) => const Center(child: Text("Error loading data", style: TextStyle(color: AppColors.errorRed))),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.2), 
              borderRadius: BorderRadius.circular(8)
            ),
            child: const Icon(Icons.account_balance_wallet, color: AppColors.primaryBlue),
          ),
          const SizedBox(width: 16),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Manage Expenses", style: TextStyle(color: AppColors.textWhite, fontSize: 18, fontWeight: FontWeight.bold)),
              Text("Production Mode", style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: AppColors.textGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: TextStyle(color: AppColors.textWhite.withValues(alpha: 0.9), fontSize: 14, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    String? prefix, IconData? prefixIcon, IconData? suffixIcon,
    int maxLines = 1, TextInputType inputType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller, maxLines: maxLines, keyboardType: inputType,
      validator: validator,
      style: const TextStyle(color: AppColors.textWhite),
      decoration: InputDecoration(
        filled: true, 
        fillColor: AppColors.surfaceGrey, 
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.textWhite.withValues(alpha: 0.3)),
        prefixText: prefix, prefixStyle: const TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppColors.textWhite54, size: 20) : null,
        suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: AppColors.textWhite54, size: 20) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.surfaceLightGrey)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.surfaceLightGrey)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primaryBlue)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildDropdown({
    required String hint, required String? value, required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceGrey, borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.surfaceLightGrey),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value, 
          hint: Text(hint, style: TextStyle(color: AppColors.textWhite.withValues(alpha: 0.3))),
          dropdownColor: AppColors.surfaceGrey, 
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textWhite54),
          isExpanded: true, 
          style: const TextStyle(color: AppColors.textWhite),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildAttachmentArea() {
    return _DashedBorder(
      color: AppColors.divider,
      strokeWidth: 2,
      gap: 6,
      radius: 12,
      child: Container(
        width: double.infinity, height: 80,
        alignment: Alignment.center,
        color: AppColors.surfaceGrey.withValues(alpha: 0.5),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off, color: AppColors.textWhite38, size: 28),
            SizedBox(height: 8),
            Text("Attachments not supported in offline schema", style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseItem(Expense item) {
    IconData icon = Icons.attach_money;
    Color color = AppColors.primaryBlue;
    
    final cat = (item.category ?? '').toLowerCase();
    if (cat.contains('utility')) { icon = Icons.bolt; color = AppColors.warningOrange; }
    else if (cat.contains('transport')) { icon = Icons.directions_bus; color = AppColors.accentPurple; }
    else if (cat.contains('supplies')) { icon = Icons.science; color = AppColors.successGreen; }
    else if (cat.contains('maint')) { icon = Icons.build; color = AppColors.errorRed; }

    final dateStr = DateFormat('MMM d').format(item.incurredAt);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceGrey, 
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: const TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold)),
                Text("${item.category ?? 'General'} • $dateStr", 
                  style: const TextStyle(color: AppColors.textWhite54, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("-\$${item.amount.toStringAsFixed(2)}", style: const TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}

// --- CUSTOM DASHED BORDER WIDGET (Unchanged) ---
class _DashedBorder extends StatelessWidget {
  final Widget child;
  final Color color;
  final double strokeWidth;
  final double gap;
  final double radius;

  const _DashedBorder({
    required this.child,
    this.color = Colors.white,
    this.strokeWidth = 1.0,
    this.gap = 5.0,
    this.radius = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        color: color,
        strokeWidth: strokeWidth,
        gap: gap,
        radius: radius,
      ),
      child: child,
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double radius;

  _DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.gap,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final Path path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(radius),
      ));

    final Path dashedPath = _dashPath(path, width: 6, space: gap);
    canvas.drawPath(dashedPath, paint);
  }

  Path _dashPath(Path source, {required double width, required double space}) {
    final Path path = Path();
    for (final PathMetric metric in source.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        path.addPath(
          metric.extractPath(distance, distance + width),
          Offset.zero,
        );
        distance += width + space;
      }
    }
    return path;
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.gap != gap ||
        oldDelegate.radius != radius;
  }
}