import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../data/services/database_service.dart';

class PaymentDialog extends StatefulWidget {
  final String schoolId;
  
  const PaymentDialog({
    super.key, 
    required this.schoolId,
  });

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
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

  Future<void> _savePayment() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Validation: Ensure a student was actually selected from the list
    if (_selectedStudentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please search and select a valid student from the list'), 
          backgroundColor: Colors.red
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
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(); 
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF151718);
    const surfaceColor = Color(0xFF1F2227);
    const inputColor = Color(0xFF2A2D35);
    const primaryBlue = Color(0xFF3B82F6);
    const textWhite = Colors.white;
    const textGrey = Color(0xFF9CA3AF);

    return Dialog(
      backgroundColor: bgColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 1100,
        height: 700,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // --- HEADER ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryBlue.withAlpha(51),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.account_balance_wallet, color: primaryBlue),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Manage Payments", style: TextStyle(color: textWhite, fontSize: 18, fontWeight: FontWeight.bold)),
                        Text("Record incoming fees and track recent transactions", style: TextStyle(color: textGrey, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: textGrey),
                ),
              ],
            ),
            const Divider(color: Color(0xFF2E323A), height: 40),
            
            // --- BODY (Split View) ---
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- LEFT: FORM SECTION ---
                  Expanded(
                    flex: 4,
                    child: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("NEW PAYMENT ENTRY", style: TextStyle(color: textGrey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                            const SizedBox(height: 20),

                            // --- SEARCHABLE STUDENT FIELD ---
                            _buildLabel("Student (Search Name or ID)"),
                            StreamBuilder<List<Map<String, dynamic>>>(
                              stream: _dbService.watchStudents(widget.schoolId),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const LinearProgressIndicator(color: primaryBlue, backgroundColor: inputColor);
                                }
                                
                                final students = snapshot.data!;
                                
                                return LayoutBuilder(
                                  builder: (context, constraints) {
                                    return Autocomplete<Map<String, dynamic>>(
                                      optionsBuilder: (TextEditingValue textEditingValue) {
                                        // Filter logic
                                        if (textEditingValue.text.isEmpty) {
                                          return students; // Return all if empty
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
                                          _selectedStudentId = selection['id']; // Store UUID
                                        });
                                      },

                                      // The Input Field
                                      fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                                        return TextFormField(
                                          controller: textEditingController,
                                          focusNode: focusNode,
                                          style: const TextStyle(color: Colors.white),
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor: inputColor,
                                            hintText: "Type to search...",
                                            hintStyle: const TextStyle(color: Colors.white24),
                                            prefixIcon: const Icon(Icons.search, color: Colors.white24, size: 20),
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.white.withAlpha(10))),
                                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: primaryBlue)),
                                          ),
                                          // Clear ID if user types something new without selecting
                                          onChanged: (text) {
                                            if (_selectedStudentId != null) {
                                              // Optional: clear selection if they start typing again
                                              // setState(() => _selectedStudentId = null);
                                            }
                                          },
                                        );
                                      },

                                      // The Dropdown List Styling
                                      optionsViewBuilder: (context, onSelected, options) {
                                        return Align(
                                          alignment: Alignment.topLeft,
                                          child: Material(
                                            color: surfaceColor,
                                            elevation: 4.0,
                                            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
                                            child: Container(
                                              width: constraints.maxWidth, // Match field width
                                              constraints: const BoxConstraints(maxHeight: 250),
                                              child: ListView.builder(
                                                padding: EdgeInsets.zero,
                                                itemCount: options.length,
                                                itemBuilder: (BuildContext context, int index) {
                                                  final Map<String, dynamic> option = options.elementAt(index);
                                                  return ListTile(
                                                    title: Text(option['full_name'], style: const TextStyle(color: Colors.white)),
                                                    subtitle: Text(option['student_id'] ?? 'No ID', style: const TextStyle(color: textGrey, fontSize: 12)),
                                                    onTap: () => onSelected(option),
                                                    hoverColor: Colors.white.withAlpha(10),
                                                    tileColor: Colors.transparent,
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
                                      _buildLabel("Amount"),
                                      _buildTextInput(
                                        controller: _amountController, 
                                        hint: "0.00", 
                                        color: inputColor,
                                        isNumber: true,
                                        prefix: const Padding(
                                          padding: EdgeInsets.all(12.0),
                                          child: Text("\$", style: TextStyle(color: Colors.white70)),
                                        )
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildLabel("Payment Date"),
                                      GestureDetector(
                                        onTap: () async {
                                          final picked = await showDatePicker(
                                            context: context,
                                            initialDate: _selectedDate,
                                            firstDate: DateTime(2020),
                                            lastDate: DateTime.now().add(const Duration(days: 30)),
                                            builder: (context, child) {
                                              return Theme(
                                                data: ThemeData.dark().copyWith(
                                                  colorScheme: const ColorScheme.dark(
                                                    primary: primaryBlue,
                                                    onPrimary: Colors.white,
                                                    surface: surfaceColor,
                                                    onSurface: Colors.white,
                                                  ),
                                                ),
                                                child: child!,
                                              );
                                            },
                                          );
                                          if (picked != null) setState(() => _selectedDate = picked);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                          decoration: BoxDecoration(
                                            color: inputColor,
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: Colors.white10),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(DateFormat('MMM dd, yyyy').format(_selectedDate), style: const TextStyle(color: Colors.white)),
                                              const Icon(Icons.calendar_today, size: 16, color: textGrey),
                                            ],
                                          ),
                                        ),
                                      ),
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
                                      _buildLabel("Category"),
                                      _buildDropdown(
                                        value: _selectedCategory,
                                        items: _categories,
                                        onChanged: (v) => setState(() => _selectedCategory = v!),
                                        color: inputColor,
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
                                        value: _selectedMethod,
                                        items: _methods,
                                        onChanged: (v) => setState(() => _selectedMethod = v!),
                                        color: inputColor,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Payer Name
                            _buildLabel("Payer Name (Parent/Guardian)"),
                            _buildTextInput(
                              controller: _payerController, 
                              hint: "e.g. Mr. Smith", 
                              color: inputColor,
                              icon: Icons.person_outline
                            ),
                            
                            const SizedBox(height: 40),
                            
                            // Action Buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("Cancel", style: TextStyle(color: textGrey)),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton.icon(
                                  onPressed: _isLoading ? null : _savePayment,
                                  icon: _isLoading 
                                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                                    : const Icon(Icons.check, size: 18),
                                  label: const Text("Save Payment"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryBlue,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Separator
                  Container(width: 1, color: const Color(0xFF2E323A), margin: const EdgeInsets.symmetric(horizontal: 32)),

                  // --- RIGHT: LIST SECTION ---
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("RECENT PAYMENTS", style: TextStyle(color: textGrey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                            // Total Calculator
                            StreamBuilder<List<Map<String, dynamic>>>(
                              stream: _dbService.watchAll('payments'), 
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) return const Text("\$0.00", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold));
                                double total = 0;
                                for(var p in snapshot.data!) {
                                  total += (p['amount'] as num?)?.toDouble() ?? 0.0;
                                }
                                return Text("Total: \$${total.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold));
                              }
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // List of Payments
                        Expanded(
                          child: StreamBuilder<List<Map<String, dynamic>>>(
                            stream: _dbService.watchAll('payments'),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              
                              final payments = snapshot.data ?? [];
                              
                              if (payments.isEmpty) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.receipt_long, size: 48, color: textGrey.withAlpha(51)),
                                      const SizedBox(height: 12),
                                      const Text("No payments recorded yet", style: TextStyle(color: textGrey)),
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
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: surfaceColor,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.white.withAlpha(10)),
                                    ),
                                    child: Row(
                                      children: [
                                        // Icon Box
                                        Container(
                                          width: 40, height: 40,
                                          decoration: BoxDecoration(
                                            color: _getMethodColor(method).withAlpha(30),
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
                                              Text(payer, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                                              const SizedBox(height: 2),
                                              Text("$method • $dateStr", style: const TextStyle(color: textGrey, fontSize: 12)),
                                            ],
                                          ),
                                        ),

                                        // Amount
                                        Text(
                                          "+\$${amount.toStringAsFixed(2)}",
                                          style: const TextStyle(color: Color(0xFF4ADE80), fontWeight: FontWeight.bold, fontSize: 14),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
    );
  }

  Widget _buildTextInput({
    required TextEditingController controller, 
    required String hint, 
    required Color color,
    bool isNumber = false,
    Widget? prefix,
    IconData? icon
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
      decoration: InputDecoration(
        filled: true,
        fillColor: color,
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24),
        prefixIcon: icon != null ? Icon(icon, color: Colors.white24, size: 20) : prefix,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.white.withAlpha(10))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF3B82F6))),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withAlpha(10)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: const Color(0xFF1F2227),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white54),
          isExpanded: true,
          style: const TextStyle(color: Colors.white),
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

  // --- HELPERS ---

  Color _getMethodColor(String method) {
    switch (method.toLowerCase()) {
      case 'cash': return const Color(0xFF4ADE80);
      case 'bank transfer': return const Color(0xFF3B82F6);
      case 'mobile money': return const Color(0xFFF59E0B);
      default: return Colors.purple;
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