import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fees_up/data/constants/app_colors.dart';

// =============================================================================
// 1. LOCAL STRINGS & CONSTANTS (Strictly No UI String Literals)
// =============================================================================
class _LogStrings {
  static const String pageTitle = "Student Financial Log";
  
  // Header
  static const String lblIdPrefix = "ID: #";
  static const String lblGradePrefix = "Grade ";
  static const String lblBalance = "CURRENT BALANCE";
  static const String btnRecordPayment = "Record Payment";
  
  // Tabs
  static const String tabAll = "All Log";
  static const String tabInvoices = "Invoices";
  static const String tabPayments = "Payments";

  // List Items
  static const String statusUnpaid = "UNPAID";
  static const String statusPartial = "PARTIALLY PAID";
  static const String statusPaid = "PAID";
  
  static const String typeInvoice = "invoice";
  static const String typePayment = "payment";
  static const String currency = "\$";

  // Bottom Action
  static const String btnNewInvoice = "New Invoice";
  
  // Mock Data Keys
  static const String kTitle = "title";
  static const String kDate = "date";
  static const String kRef = "ref";
  static const String kAmount = "amount";
  static const String kType = "type";
  static const String kStatus = "status";
}

// =============================================================================
// 2. SCREEN IMPLEMENTATION
// =============================================================================
class StudentLoggingScreen extends StatefulWidget {
  final String? studentId;

  const StudentLoggingScreen({super.key, this.studentId});

  @override
  State<StudentLoggingScreen> createState() => _StudentLoggingScreenState();
}

class _StudentLoggingScreenState extends State<StudentLoggingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Mock Data - In production, this comes from LedgerRepository
  final List<Map<String, dynamic>> _transactions = [
    {
      _LogStrings.kTitle: "Lab Material Fee",
      _LogStrings.kDate: "Nov 02, 2023",
      _LogStrings.kRef: "INV-9901",
      _LogStrings.kAmount: 50.00,
      _LogStrings.kType: _LogStrings.typeInvoice,
      _LogStrings.kStatus: _LogStrings.statusUnpaid,
    },
    {
      _LogStrings.kTitle: "Online Transfer",
      _LogStrings.kDate: "Oct 15, 2023",
      _LogStrings.kRef: "Receipt #882",
      _LogStrings.kAmount: -800.00, // Negative for payments
      _LogStrings.kType: _LogStrings.typePayment,
      _LogStrings.kStatus: _LogStrings.statusPaid,
    },
    {
      _LogStrings.kTitle: "Q3 Tuition Fees",
      _LogStrings.kDate: "Oct 12, 2023",
      _LogStrings.kRef: "INV-8822",
      _LogStrings.kAmount: 1200.00,
      _LogStrings.kType: _LogStrings.typeInvoice,
      _LogStrings.kStatus: _LogStrings.statusPartial,
    },
    {
      _LogStrings.kTitle: "Academic Year Enrollment",
      _LogStrings.kDate: "Sep 01, 2023",
      _LogStrings.kRef: "SYS-INIT",
      _LogStrings.kAmount: 0.00, // Informational
      _LogStrings.kType: "system",
      _LogStrings.kStatus: _LogStrings.statusPaid,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleRecordPayment() {
    // Open payment dialog or route
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Opening Payment Gateway...")),
    );
  }

  void _handleCreateInvoice() {
    // Open manual invoice dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Creating Ad-hoc Invoice...")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(_LogStrings.pageTitle),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // --- Student Header Summary ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primaryBlue.withAlpha(40),
                  child: const Text(
                    "JD", // Placeholder initials
                    style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "John Doe", // Placeholder Name
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          "${_LogStrings.lblIdPrefix}SF-2024-001",
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.dividerColor.withAlpha(50),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            "${_LogStrings.lblGradePrefix}10 - A",
                            style: theme.textTheme.bodySmall?.copyWith(fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // --- Balance Card ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                // Using the brand blue gradient
                gradient: const LinearGradient(
                  colors: [AppColors.primaryBlue, Color(0xFF1E88E5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withAlpha(80),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _LogStrings.lblBalance,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white.withAlpha(180),
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(40),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.account_balance_wallet_outlined, color: Colors.white, size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "\$450.00",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _handleRecordPayment,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primaryBlue,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text(
                            _LogStrings.btnRecordPayment,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      InkWell(
                        onTap: () {},
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(40),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.print_outlined, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // --- Tabs ---
          TabBar(
            controller: _tabController,
            indicatorColor: AppColors.primaryBlue,
            indicatorSize: TabBarIndicatorSize.label,
            labelColor: AppColors.primaryBlue,
            unselectedLabelColor: theme.disabledColor,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: _LogStrings.tabAll),
              Tab(text: _LogStrings.tabInvoices),
              Tab(text: _LogStrings.tabPayments),
            ],
          ),
          
          const Divider(height: 1),

          // --- Transaction List (Timeline) ---
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _transactions.length,
              itemBuilder: (context, index) {
                final tx = _transactions[index];
                final isLast = index == _transactions.length - 1;
                
                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Timeline Column
                      Column(
                        children: [
                          _buildTimelineIcon(context, tx[_LogStrings.kType]),
                          if (!isLast)
                            Expanded(
                              child: Container(
                                width: 2,
                                color: theme.dividerColor.withAlpha(50),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      // Content Column
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 24.0),
                          child: _buildTransactionCard(context, tx),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          
          // --- Bottom Action Area ---
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              border: Border(top: BorderSide(color: theme.dividerColor)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(10),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                )
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _handleCreateInvoice,
                    icon: const Icon(Icons.add),
                    label: const Text(_LogStrings.btnNewInvoice),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.dividerColor),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.share_outlined),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Helpers ---
  
  Widget _buildTimelineIcon(BuildContext context, String type) {
    IconData icon;
    Color color;

    if (type == _LogStrings.typeInvoice) {
      icon = Icons.description_outlined;
      color = AppColors.errorRed; // Red for debt/invoice
    } else if (type == _LogStrings.typePayment) {
      icon = Icons.check_circle_outline;
      color = AppColors.successGreen; // Green for payment
    } else {
      icon = Icons.school_outlined;
      color = AppColors.textGrey;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 18, color: color),
    );
  }

  Widget _buildTransactionCard(BuildContext context, Map<String, dynamic> tx) {
    final theme = Theme.of(context);
    final amount = tx[_LogStrings.kAmount] as double;
    final isNegative = amount < 0; // Negative means payment (credit)
    
    // Formatting amount string: "+$50.00" or "-$800.00"
    final amountString = "${isNegative ? '' : '+'}${_LogStrings.currency}${amount.abs().toStringAsFixed(2)}";
    final amountColor = isNegative ? AppColors.successGreen : AppColors.errorRed;

    // Status Badge Color
    Color statusBg = AppColors.textGrey.withAlpha(30);
    Color statusText = AppColors.textGrey;
    
    if (tx[_LogStrings.kStatus] == _LogStrings.statusUnpaid) {
      statusBg = AppColors.errorRed.withAlpha(20);
      statusText = AppColors.errorRed;
    } else if (tx[_LogStrings.kStatus] == _LogStrings.statusPartial) {
      statusBg = AppColors.warningOrange.withAlpha(20);
      statusText = AppColors.warningOrange;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              tx[_LogStrings.kTitle],
              style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              amountString,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: amountColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          "${tx[_LogStrings.kDate]} • ${tx[_LogStrings.kRef]}",
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        
        // Status Badge (Only for invoices usually, but keeping logic generic)
        if (tx[_LogStrings.kType] == _LogStrings.typeInvoice)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              tx[_LogStrings.kStatus],
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: statusText,
              ),
            ),
          ),
      ],
    );
  }
}