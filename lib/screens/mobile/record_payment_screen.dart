import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

// -----------------------------------------------------------------------------
// IMPORTS
// -----------------------------------------------------------------------------
import 'package:fees_up/data/constants/app_colors.dart';

class RecordPaymentScreen extends StatefulWidget {
  final String? preselectedStudentId;

  const RecordPaymentScreen({super.key, this.preselectedStudentId});

  @override
  State<RecordPaymentScreen> createState() => _RecordPaymentScreenState();
}

class _RecordPaymentScreenState extends State<RecordPaymentScreen> {
  // ---------------------------------------------------------------------------
  // STATE
  // ---------------------------------------------------------------------------
  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();
  final _studentSearchController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  String _selectedMethod = 'Cash'; // Cash, Bank, Mobile
  
  // Mock Data (In real app, fetch based on _studentSearchController or widget.studentId)
  final double _currentBalance = 1250.00;
  final double _totalBilled = 3500.00;
  final double _totalPaid = 2250.00;
  
  double _amountReceived = 0.0;

  @override
  void initState() {
    super.initState();
    // Simulate pre-filling a student if coming from their profile
    if (widget.preselectedStudentId != null) {
      _studentSearchController.text = "James Wilson"; // Mock name lookup
    }
    
    _amountController.addListener(_updateCalculations);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    _studentSearchController.dispose();
    super.dispose();
  }

  void _updateCalculations() {
    setState(() {
      _amountReceived = double.tryParse(_amountController.text) ?? 0.0;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primaryBlue,
              onPrimary: Colors.white,
              surface: AppColors.surfaceDarkGrey,
              onSurface: Colors.white,
            ), dialogTheme: const DialogThemeData(backgroundColor: AppColors.surfaceDarkGrey),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _submitPayment() {
    if (_amountReceived <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }
    
    // TODO: Implement PowerSync Insert Here
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment Recorded Successfully')),
    );
    context.pop();
  }

  // ---------------------------------------------------------------------------
  // UI BUILDER
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final remainingBalance = _currentBalance - _amountReceived;
    final dateFormat = DateFormat('MM/dd/yyyy');

    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundBlack,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Record Payment',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. SELECT STUDENT
                  const Text('Select Student', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _studentSearchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search Student...',
                      hintStyle: const TextStyle(color: AppColors.textGrey),
                      prefixIcon: const Icon(Icons.search, color: AppColors.textGrey),
                      filled: true,
                      fillColor: AppColors.surfaceDarkGrey,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),

                  // 2. STUDENT SUMMARY CARD
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withAlpha(20), // Subtle blue tint
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primaryBlue.withAlpha(50)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'CURRENT BALANCE',
                              style: TextStyle(
                                color: AppColors.textGrey,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'GRADE 10-B',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '\$${NumberFormat("#,##0.00").format(_currentBalance)}',
                          style: const TextStyle(
                            color: AppColors.primaryBlue,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Divider(color: AppColors.primaryBlue, thickness: 0.2),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Total Billed', style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
                                const SizedBox(height: 4),
                                Text(
                                  '\$${NumberFormat("#,##0.00").format(_totalBilled)}',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('Total Paid', style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
                                const SizedBox(height: 4),
                                Text(
                                  '\$${NumberFormat("#,##0.00").format(_totalPaid)}',
                                  style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 3. AMOUNT RECEIVED
                  const Text('Amount Received', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.attach_money, color: Colors.white),
                      hintText: '0.00',
                      hintStyle: const TextStyle(color: AppColors.textGrey),
                      filled: true,
                      fillColor: AppColors.surfaceDarkGrey,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 4. PAYMENT METHOD
                  const Text('Payment Method', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildMethodSelector('Cash', Icons.payments_outlined),
                      const SizedBox(width: 12),
                      _buildMethodSelector('Bank', Icons.account_balance_outlined),
                      const SizedBox(width: 12),
                      _buildMethodSelector('Mobile', Icons.phone_android_outlined),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 5. DATE RECEIVED
                  const Text('Date Received', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDarkGrey,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, color: AppColors.textGrey, size: 20),
                          const SizedBox(width: 12),
                          Text(
                            dateFormat.format(_selectedDate),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                          ),
                          const Spacer(),
                          const Icon(Icons.arrow_drop_down, color: AppColors.textGrey),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 6. REFERENCE CODE
                  const Text('Reference Code (Optional)', style: TextStyle(color: AppColors.textGrey)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _referenceController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Transaction ID or receipt #',
                      hintStyle: const TextStyle(color: AppColors.textGrey),
                      prefixIcon: const Icon(Icons.numbers, color: AppColors.textGrey, size: 20),
                      filled: true,
                      fillColor: AppColors.surfaceDarkGrey,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40), // Bottom padding
                ],
              ),
            ),
          ),
          
          // BOTTOM FOOTER
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppColors.surfaceDarkGrey,
              border: Border(top: BorderSide(color: AppColors.surfaceLightGrey, width: 0.5)),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Remaining Balance After',
                        style: TextStyle(color: AppColors.textGrey),
                      ),
                      Text(
                        '\$${NumberFormat("#,##0.00").format(remainingBalance)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _submitPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.check_circle, color: Colors.white),
                      label: const Text(
                        'Record Payment',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodSelector(String label, IconData icon) {
    final bool isSelected = _selectedMethod == label;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedMethod = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryBlue.withAlpha(30) : AppColors.surfaceDarkGrey,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primaryBlue : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.primaryBlue : AppColors.textGrey,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textGrey,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}