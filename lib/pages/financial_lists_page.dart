import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/database_service.dart';
import 'student_ledger_page.dart'; // Ensure this import exists for navigation

class FinancialListsPage extends StatelessWidget {
  final int initialIndex;

  const FinancialListsPage({super.key, this.initialIndex = 0});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: initialIndex,
      child: Scaffold(
        backgroundColor: const Color(0xff121b22),
        appBar: AppBar(
          backgroundColor: const Color(0xff121b22),
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            "Accounts Receivable",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          bottom: const TabBar(
            indicatorColor: Color(0xff3498db),
            labelColor: Color(0xff3498db),
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: "Outstanding Balances"),
              Tab(text: "Open Invoices"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _OutstandingBalancesView(),
            _OpenInvoicesView(),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// TAB 1: OUTSTANDING BALANCES (Student Centric)
// Shows students who owe money > 0
// -----------------------------------------------------------------------------
class _OutstandingBalancesView extends StatefulWidget {
  const _OutstandingBalancesView();

  @override
  State<_OutstandingBalancesView> createState() => _OutstandingBalancesViewState();
}

class _OutstandingBalancesViewState extends State<_OutstandingBalancesView> {
  List<Map<String, dynamic>> _students = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDebtors();
  }

  Future<void> _fetchDebtors() async {
    final db = await DatabaseService.instance.database;
    // Query students where owed_total > 0
    final result = await db.query(
      'students',
      where: 'owed_total > 0',
      orderBy: 'owed_total DESC', // Highest debt first
    );
    
    if (mounted) {
      setState(() {
        _students = result;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    
    if (_students.isEmpty) {
      return const _EmptyState(
        icon: Icons.check_circle_outline,
        title: "All Clear!",
        subtitle: "No students currently owe money.",
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _students.length,
      itemBuilder: (context, index) {
        final student = _students[index];
        final owed = (student['owed_total'] as num).toDouble();
        
        return Card(
          color: const Color(0xff1c2a35),
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: const Color(0xffef5350).withAlpha(30),
              child: const Icon(Icons.person, color: Color(0xffef5350)),
            ),
            title: Text(
              student['full_name'],
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              student['grade'] ?? 'No Grade',
              style: const TextStyle(color: Colors.grey),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "\$${owed.toStringAsFixed(2)}",
                  style: const TextStyle(
                    color: Color(0xffef5350),
                    fontSize: 16,
                    fontWeight: FontWeight.bold
                  ),
                ),
                const Text("OVERDUE", style: TextStyle(color: Colors.grey, fontSize: 10)),
              ],
            ),
            onTap: () {
              // Navigate to Student Ledger to take action
               Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => StudentLedgerPage(studentId: student['id']),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// TAB 2: OPEN INVOICES (Bill Centric)
// Shows specific bills that are not fully paid
// -----------------------------------------------------------------------------
class _OpenInvoicesView extends StatefulWidget {
  const _OpenInvoicesView();

  @override
  State<_OpenInvoicesView> createState() => _OpenInvoicesViewState();
}

class _OpenInvoicesViewState extends State<_OpenInvoicesView> {
  List<Map<String, dynamic>> _invoices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchInvoices();
  }

  Future<void> _fetchInvoices() async {
    final db = await DatabaseService.instance.database;
    // Query bills where paid_amount < total_amount
    // We join with students to get the name
    final result = await db.rawQuery('''
      SELECT 
        bills.*, 
        students.full_name as student_name 
      FROM bills
      INNER JOIN students ON bills.student_id = students.id
      WHERE bills.paid_amount < bills.total_amount
      ORDER BY bills.created_at DESC
    ''');

    if (mounted) {
      setState(() {
        _invoices = result;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    if (_invoices.isEmpty) {
      return const _EmptyState(
        icon: Icons.receipt_long,
        title: "No Open Invoices",
        subtitle: "All generated bills have been fully paid.",
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _invoices.length,
      itemBuilder: (context, index) {
        final bill = _invoices[index];
        final total = (bill['total_amount'] as num).toDouble();
        final paid = (bill['paid_amount'] as num).toDouble();
        final balance = total - paid;
        
        // Safety check for date
        String dateStr = "Unknown Date";
        if (bill['created_at'] != null) {
          final date = DateTime.fromMillisecondsSinceEpoch(bill['created_at'] as int);
          dateStr = DateFormat('MMM dd, yyyy').format(date);
        }

        return Card(
          color: const Color(0xff1c2a35),
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      bill['title'] ?? 'Tuition Fee',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xff42a5f5).withAlpha(30),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Inv #${bill['id'].toString().substring(0,4)}",
                        style: const TextStyle(color: Color(0xff42a5f5), fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "Billed to: ${bill['student_name']}",
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 12),
                const Divider(color: Colors.white10),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Issued: $dateStr", style: const TextStyle(color: Colors.white54, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(
                          "Total: \$${total.toStringAsFixed(2)}",
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text("Balance Due", style: TextStyle(color: Colors.white54, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(
                          "\$${balance.toStringAsFixed(2)}",
                          style: const TextStyle(color: Color(0xffef5350), fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// HELPER: Empty State
// -----------------------------------------------------------------------------
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.white24),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(subtitle, style: const TextStyle(color: Colors.white54)),
        ],
      ),
    );
  }
}