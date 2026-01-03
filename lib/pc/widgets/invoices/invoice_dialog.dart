import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../data/services/database_service.dart';
// Use your provider for access
// ignore: unused_import
import '../../../../data/providers/school_provider.dart'; 

class InvoiceDialog extends ConsumerStatefulWidget {
  final String schoolId;
  const InvoiceDialog({super.key, required this.schoolId});

  @override
  ConsumerState<InvoiceDialog> createState() => _InvoiceDialogState();
}

class _InvoiceDialogState extends ConsumerState<InvoiceDialog> {
  final _formKey = GlobalKey<FormState>();
  
  // Use the Singleton directly as per your architecture
  final DatabaseService _dbService = DatabaseService();

  // Controllers
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descController = TextEditingController();

  // State
  String? _selectedStudentId;
  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));
  String _generatedInvoiceNum = "Loading...";
  String _invoiceStatus = 'draft'; // ✅ NEW: Draft status support
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchNextInvoiceNumber();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // --- LOGIC (Production Ready) ---

  Future<void> _fetchNextInvoiceNumber() async {
    try {
      // 1. Use the new .select() method you added to DatabaseService
      final result = await _dbService.select(
        'SELECT invoice_number FROM bills WHERE school_id = ? ORDER BY invoice_number DESC LIMIT 1',
        [widget.schoolId],
      );

      int nextNum = 1;
      if (result.isNotEmpty) {
        final lastInv = result.first['invoice_number'] as String?;
        if (lastInv != null && lastInv.startsWith('INV-')) {
          final numericPart = int.tryParse(lastInv.split('-')[1]);
          if (numericPart != null) {
            nextNum = numericPart + 1;
          }
        }
      }

      if (mounted) {
        setState(() {
          _generatedInvoiceNum = 'INV-${nextNum.toString().padLeft(5, '0')}';
        });
      }
    } catch (e) {
      if (mounted) setState(() => _generatedInvoiceNum = "INV-ERROR");
    }
  }

  Future<void> _submitInvoice() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedStudentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a student"), backgroundColor: AppColors.errorRed),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final newId = const Uuid().v4();
      final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
      final now = DateTime.now();

      // ✅ CORRECT: No schema hacks - database supports null values for adhoc bills
      final billData = {
        'id': newId,
        'school_id': widget.schoolId,
        'student_id': _selectedStudentId,
        'title': _titleController.text.trim(),
        'invoice_number': _generatedInvoiceNum, 
        'status': _invoiceStatus, // ✅ NEW: Respects draft/sent status
        'total_amount': amount,
        'paid_amount': 0.0,
        'is_paid': 0, 
        'is_closed': 0,
        'bill_type': 'adhoc', // Manual entry
        'due_date': DateFormat('yyyy-MM-dd').format(_dueDate),
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
        'month_year': DateFormat('yyyy-MM').format(now),
        // ✅ FIXED: Removed artificial 'term_id': 'adhoc-manual' hack
        // Database schema properly handles null values for school_year_id, month_index, term_id
        // These fields are intentionally left null for adhoc bills
      };

      await _dbService.insert('bills', billData);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Invoice $_generatedInvoiceNum generated successfully"), 
            backgroundColor: AppColors.successGreen
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: AppColors.errorRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- UI BUILD (Same visual, real logic) ---

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        width: 1100,
        height: 750,
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
            _buildHeader(),
            const Divider(height: 1, color: AppColors.divider),
            
            // MAIN CONTENT (Split View)
            Expanded(
              child: Row(
                children: [
                  // LEFT: FORM
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("INVOICE DETAILS", style: TextStyle(color: AppColors.textGrey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceGrey,
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: AppColors.surfaceLightGrey),
                                    ),
                                    child: Text(
                                      _generatedInvoiceNum, 
                                      style: const TextStyle(color: AppColors.primaryBlueLight, fontWeight: FontWeight.bold, fontFamily: 'monospace')
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              _buildLabel("Select Student"),
                              // Uses DatabaseService.watchStudents (Real Data)
                              _buildStudentAutocomplete(),
                              const SizedBox(height: 16),

                              _buildLabel("Title / Reason"),
                              _buildTextField(
                                controller: _titleController,
                                hint: "e.g. Broken Science Equipment",
                                validator: (v) => v!.isEmpty ? "Required" : null,
                              ),
                              const SizedBox(height: 16),

                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildLabel("Amount Due"),
                                        _buildTextField(
                                          controller: _amountController,
                                          hint: "0.00",
                                          prefix: "\$ ",
                                          isNumber: true,
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
                                        _buildLabel("Due Date"),
                                        _buildDatePicker(context),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildLabel("Invoice Status"),
                                        _buildStatusDropdown(),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              _buildLabel("Notes (Internal Only)"),
                              _buildTextField(
                                controller: _descController,
                                hint: "Additional context about this charge...",
                                maxLines: 3,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const VerticalDivider(width: 1, color: AppColors.divider),

                  // RIGHT: RECENT INVOICES LIST (Real Data Stream)
                  Expanded(
                    flex: 4,
                    child: Container(
                      color: AppColors.surfaceDarkGrey,
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("RECENT INVOICES", style: TextStyle(color: AppColors.textGrey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                          const SizedBox(height: 24),
                          Expanded(
                            child: StreamBuilder<List<Map<String, dynamic>>>(
                              // Uses DatabaseService.db.watch directly
                              stream: _dbService.db.watch(
                                'SELECT * FROM bills WHERE school_id = ? AND invoice_number IS NOT NULL ORDER BY created_at DESC LIMIT 20', 
                                parameters: [widget.schoolId]
                              ),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue));
                                final bills = snapshot.data ?? [];
                                
                                if (bills.isEmpty) {
                                  return const Center(child: Text("No invoices generated yet.", style: TextStyle(color: AppColors.textGrey)));
                                }

                                return ListView.separated(
                                  itemCount: bills.length,
                                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final bill = bills[index];
                                    final invNum = bill['invoice_number'] ?? '---';
                                    final amount = (bill['total_amount'] as num?)?.toDouble() ?? 0.0;
                                    final title = bill['title'] ?? 'Unknown Charge';
                                    final status = bill['status'] ?? 'pending';

                                    return Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceGrey,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 40, height: 40,
                                            decoration: BoxDecoration(
                                              color: AppColors.primaryBlue.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Icon(Icons.receipt, color: AppColors.primaryBlue, size: 20),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(invNum, style: const TextStyle(color: AppColors.primaryBlueLight, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                                                const SizedBox(height: 2),
                                                Text(title, style: const TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                                              ],
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text("\$${amount.toStringAsFixed(2)}", style: const TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold)),
                                              Text(status.toString().toUpperCase(), style: TextStyle(color: _getStatusColor(status), fontSize: 10, fontWeight: FontWeight.bold)),
                                            ],
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

            // FOOTER
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
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _submitInvoice,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      foregroundColor: AppColors.textWhite,
                    ),
                    icon: _isLoading 
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textWhite)) 
                      : const Icon(Icons.print, size: 18),
                    label: Text(_isLoading ? "Processing..." : "Generate Invoice", style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- UI HELPERS ---

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
            child: const Icon(Icons.description, color: AppColors.primaryBlue),
          ),
          const SizedBox(width: 16),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Create Invoice", style: TextStyle(color: AppColors.textWhite, fontSize: 18, fontWeight: FontWeight.bold)),
              Text("Manually generate a bill for a student", style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
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

  Widget _buildStudentAutocomplete() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _dbService.watchStudents(widget.schoolId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const LinearProgressIndicator(color: AppColors.primaryBlue, backgroundColor: AppColors.surfaceGrey);
        
        final students = snapshot.data!;
        
        return LayoutBuilder(
          builder: (context, constraints) {
            return Autocomplete<Map<String, dynamic>>(
              optionsBuilder: (TextEditingValue val) {
                if (val.text.isEmpty) return students;
                return students.where((s) {
                  return s['full_name'].toString().toLowerCase().contains(val.text.toLowerCase()) || 
                         (s['student_id'] ?? '').toString().toLowerCase().contains(val.text.toLowerCase());
                });
              },
              displayStringForOption: (option) => "${option['full_name']} (${option['student_id'] ?? 'N/A'})",
              onSelected: (selection) => setState(() => _selectedStudentId = selection['id']),
              
              fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                return TextFormField(
                  controller: controller,
                  focusNode: focusNode,
                  style: const TextStyle(color: AppColors.textWhite),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.surfaceGrey,
                    hintText: "Search student...",
                    hintStyle: TextStyle(color: AppColors.textWhite.withValues(alpha: 0.3)),
                    prefixIcon: const Icon(Icons.search, color: AppColors.textWhite54),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.surfaceLightGrey)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.surfaceLightGrey)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primaryBlue)),
                  ),
                );
              },
              optionsViewBuilder: (context, onSelected, options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    color: AppColors.surfaceGrey,
                    elevation: 4,
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
                    child: Container(
                      width: constraints.maxWidth,
                      constraints: const BoxConstraints(maxHeight: 250),
                      decoration: BoxDecoration(border: Border.all(color: AppColors.surfaceLightGrey)),
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: options.length,
                        itemBuilder: (context, index) {
                          final option = options.elementAt(index);
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
    String? prefix,
    bool isNumber = false,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(color: AppColors.textWhite),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.surfaceGrey,
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.textWhite.withValues(alpha: 0.3)),
        prefixText: prefix, prefixStyle: const TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.surfaceLightGrey)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.surfaceLightGrey)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2)),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _dueDate,
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          builder: (context, child) => Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: const ColorScheme.dark(
                primary: AppColors.primaryBlue,
                onPrimary: AppColors.textWhite,
                surface: AppColors.surfaceGrey,
                onSurface: AppColors.textWhite,
              ),
            ),
            child: child!,
          ),
        );
        if (picked != null) setState(() => _dueDate = picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), // Match input height
        decoration: BoxDecoration(
          color: AppColors.surfaceGrey,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.surfaceLightGrey),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(DateFormat('MMM dd, yyyy').format(_dueDate), style: const TextStyle(color: AppColors.textWhite)),
            const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.textWhite54),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch(status.toLowerCase()) {
      case 'paid': return AppColors.successGreen;
      case 'draft': return AppColors.textGrey;
      case 'overdue': return AppColors.errorRed;
      case 'sent': return AppColors.primaryBlueLight;
      default: return AppColors.textGrey;
    }
  }

  /// ✅ NEW: Status dropdown for draft/sent selection
  Widget _buildStatusDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceGrey,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.surfaceLightGrey),
      ),
      child: DropdownButton<String>(
        value: _invoiceStatus,
        isExpanded: true,
        underline: const SizedBox(),
        dropdownColor: AppColors.surfaceGrey,
        style: const TextStyle(color: AppColors.textWhite),
        items: [
          DropdownMenuItem(
            value: 'draft',
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.textGrey,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Draft', style: TextStyle(color: AppColors.textWhite)),
              ],
            ),
          ),
          DropdownMenuItem(
            value: 'sent',
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryBlueLight,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Sent', style: TextStyle(color: AppColors.textWhite)),
              ],
            ),
          ),
        ],
        onChanged: (value) {
          if (value != null) {
            setState(() => _invoiceStatus = value);
          }
        },
      ),
    );
  }
}