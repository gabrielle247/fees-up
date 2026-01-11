import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

// -----------------------------------------------------------------------------
// IMPORTS
// -----------------------------------------------------------------------------
import 'package:fees_up/data/constants/app_colors.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // ---------------------------------------------------------------------------
  // MOCK DATA (Invoices & Payments)
  // ---------------------------------------------------------------------------
  final List<Map<String, dynamic>> _transactions = [
    {
      'id': 'PAY-001',
      'type': 'payment',
      'student_name': 'James Wilson',
      'amount': 500.00,
      'date': DateTime.now().subtract(const Duration(hours: 2)),
      'status': 'Completed',
      'method': 'Cash',
      'reference': 'RCPT-1023'
    },
    {
      'id': 'INV-001',
      'type': 'invoice',
      'student_name': 'Sarah Jones',
      'amount': 1200.00,
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'status': 'Unpaid',
      'description': 'Term 1 Tuition'
    },
    {
      'id': 'PAY-002',
      'type': 'payment',
      'student_name': 'Michael Brown',
      'amount': 1200.00,
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'status': 'Voided', // Example of a deleted/reversed transaction
      'method': 'Bank Transfer',
      'reference': 'REF-9988'
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // ACTIONS
  // ---------------------------------------------------------------------------
  void _showTransactionDetails(Map<String, dynamic> tx) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDarkGrey,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => _TransactionDetailsModal(transaction: tx),
    );
  }

  // ---------------------------------------------------------------------------
  // UI BUILDER
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceDarkGrey,
        title: const Text('Transactions', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryBlue,
          labelColor: AppColors.primaryBlue,
          unselectedLabelColor: AppColors.textGrey,
          tabs: const [
            Tab(text: 'All History'),
            Tab(text: 'Invoices Only'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTransactionList(_transactions),
          _buildTransactionList(_transactions.where((t) => t['type'] == 'invoice').toList()),
        ],
      ),
    );
  }

  Widget _buildTransactionList(List<Map<String, dynamic>> items) {
    if (items.isEmpty) {
      return const Center(child: Text('No transactions found', style: TextStyle(color: AppColors.textGrey)));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (ctx, i) => const Divider(color: AppColors.surfaceLightGrey, height: 1),
      itemBuilder: (ctx, i) {
        final tx = items[i];
        final isPayment = tx['type'] == 'payment';
        final isVoided = tx['status'] == 'Voided';

        return ListTile(
          onTap: () => _showTransactionDetails(tx),
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          leading: CircleAvatar(
            backgroundColor: isVoided 
                ? AppColors.surfaceLightGrey 
                : (isPayment ? Colors.green.withAlpha(50) : Colors.orange.withAlpha(50)),
            child: Icon(
              isPayment ? Icons.arrow_downward : Icons.description_outlined,
              color: isVoided ? AppColors.textGrey : (isPayment ? Colors.greenAccent : Colors.orangeAccent),
              size: 20,
            ),
          ),
          title: Text(
            tx['student_name'],
            style: TextStyle(
              color: isVoided ? AppColors.textGrey : Colors.white,
              fontWeight: FontWeight.bold,
              decoration: isVoided ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Text(
            '${DateFormat('MMM d, y').format(tx['date'])} • ${tx['status']}',
            style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
          ),
          trailing: Text(
            '${isPayment ? "+" : ""}\$${tx['amount'].toStringAsFixed(2)}',
            style: TextStyle(
              color: isVoided ? AppColors.textGrey : (isPayment ? Colors.greenAccent : Colors.white),
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        );
      },
    );
  }
}

class _TransactionDetailsModal extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const _TransactionDetailsModal({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isPayment = transaction['type'] == 'payment';

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: AppColors.textGrey, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isPayment ? 'Payment Received' : 'Invoice Generated',
                style: const TextStyle(color: AppColors.textGrey, fontSize: 14),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (transaction['status'] == 'Voided' ? Colors.red : Colors.green).withAlpha(50),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  transaction['status'].toUpperCase(),
                  style: TextStyle(
                    color: transaction['status'] == 'Voided' ? Colors.redAccent : Colors.greenAccent,
                    fontSize: 10, 
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '\$${transaction['amount'].toStringAsFixed(2)}',
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          _DetailRow(label: 'Student', value: transaction['student_name']),
          _DetailRow(label: 'Date', value: DateFormat('MMM d, yyyy h:mm a').format(transaction['date'])),
          _DetailRow(label: 'Reference', value: transaction['reference'] ?? transaction['id']),
          if (isPayment) _DetailRow(label: 'Method', value: transaction['method']),
          if (!isPayment) _DetailRow(label: 'Description', value: transaction['description']),
          
          const SizedBox(height: 30),
          
          // ACTIONS
          if (transaction['status'] != 'Voided')
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.redAccent),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                label: Text(
                  isPayment ? 'Void Payment' : 'Cancel Invoice',
                  style: const TextStyle(color: Colors.redAccent),
                ),
                onPressed: () {
                  // TODO: Implement Void Logic
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Transaction Voided')),
                  );
                },
              ),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textGrey)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}