// lib/pages/student_ledger_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// Fix 1: Ambiguous Import Resolution (Applies prefix 'update' to UpdateStudentPage)
import '../pages/update_student_page.dart' as update; 

// --- Services & Models ---
import '../services/database_service.dart';
import '../models/student_full.dart'; // Primary import for StudentFull model

// -----------------------------------------------------------------------------
// PROVIDER
// -----------------------------------------------------------------------------
final studentLedgerProvider = FutureProvider.autoDispose
    .family<StudentFull?, String>((ref, studentId) async {
      final db = DatabaseService.instance;
      await db.refreshStudentFullCache(includeInactive: true);
      // StudentFull type is correctly imported here
      return await db.getStudentFullById(studentId); 
    });

// -----------------------------------------------------------------------------
// HELPER MODEL (LedgerItem remains unchanged)
// -----------------------------------------------------------------------------
class LedgerItem {
  final String id;
  final DateTime date;
  final String title;
  final String subtitle;
  final double amount;
  final bool isCredit;

  LedgerItem({
    required this.id,
    required this.date,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isCredit,
  });
}

// -----------------------------------------------------------------------------
// UI: STUDENT LEDGER PAGE
// -----------------------------------------------------------------------------
class StudentLedgerPage extends ConsumerWidget {
  final String studentId;

  const StudentLedgerPage({super.key, required this.studentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentAsync = ref.watch(studentLedgerProvider(studentId));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: studentAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
        data: (StudentFull? studentFull) { 
          if (studentFull == null) {
            return const Center(child: Text("Student not found"));
          }

          // --- PREPARE DATA ---
          final List<LedgerItem> transactions = [];

          for (var b in studentFull.bills) { 
            transactions.add(
              LedgerItem(
                id: b.id,
                date: b.createdAt ?? DateTime.now(),
                title: b.billType == 'monthly' ? 'Monthly Fee' : 'Term Fee',
                subtitle: b.monthYear ?? 'Standard Charge',
                amount: b.totalAmount,
                isCredit: false,
              ),
            );
          }
          for (var p in studentFull.payments) { 
            transactions.add(
              LedgerItem(
                id: p.id,
                date: p.datePaid ?? DateTime.now(),
                title: 'Payment Received',
                subtitle: p.method ?? 'Cash',
                amount: p.amount,
                isCredit: true,
              ),
            );
          }
          transactions.sort((a, b) => b.date.compareTo(a.date));

          // Parse Subjects
          List<String> subjectList = [];
          if (studentFull.student.subjects != null &&
              studentFull.student.subjects!.isNotEmpty) {
            subjectList = studentFull.student.subjects!.split(',');
          }

          return CustomScrollView(
            slivers: [
              // --- 1. App Bar ---
              SliverAppBar(
                pinned: true,
                title: Text(studentFull.student.fullName ?? 'Student Profile'),
                backgroundColor: colorScheme.surface,
                foregroundColor: colorScheme.onSurface,
                elevation: 0,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () async {
                      // Navigate to UpdateStudentPage using the prefixed name
                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => update.UpdateStudentPage(
                            studentId: studentId,
                            initialStudentData: studentFull,
                          ),
                        ),
                      );
                      if (result == true) {
                        ref.invalidate(studentLedgerProvider(studentId));
                      }
                    },
                  ),
                ],
              ),

              // --- 2. Profile Header ---
              SliverToBoxAdapter(
                child: _buildProfileHeader(context, studentFull),
              ),

              // --- 3. Enrolled Subjects ---
              if (subjectList.isNotEmpty)
                SliverToBoxAdapter(
                  child: _buildSubjectsSection(context, subjectList),
                ),

              // --- 4. Financial Stats ---
              SliverToBoxAdapter(
                child: _buildFinancialStats(context, studentFull),
              ),

              // --- 5. Personal Details ---
              SliverToBoxAdapter(
                child: _buildPersonalDetails(context, studentFull),
              ),

              // --- 6. Ledger Title ---
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Text(
                    "Transaction History",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // --- 7. Transaction List ---
              if (transactions.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Center(
                      child: Text(
                        "No transactions recorded.",
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        _buildTransactionTile(context, transactions[index]),
                    childCount: transactions.length,
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),

      // --- Bottom Action Bar ---
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showAddBillModal(context, ref, studentId),
                icon: Icon(
                  Icons.remove_circle_outline,
                  color: colorScheme.error,
                ),
                label: Text(
                  "Add Charge",
                  style: TextStyle(color: colorScheme.error),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: colorScheme.error),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showAddPaymentModal(context, ref, studentId),
                // Fix 3: Undefined 'icons' changed to 'Icons'
                icon: Icon(Icons.add_card, color: colorScheme.onPrimary), 
                label: Text(
                  "Add Payment",
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildProfileHeader(BuildContext context, StudentFull s) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: colorScheme.surface,
      padding: const EdgeInsets.only(bottom: 16, top: 10),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: colorScheme.primaryContainer, width: 3),
            ),
            child: CircleAvatar(
              radius: 40,
              backgroundColor: colorScheme.primaryContainer,
              child: Text(
                s.student.fullName?[0].toUpperCase() ?? '?',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            s.student.fullName ?? 'Unknown',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${s.student.grade ?? 'Unassigned'} • ${s.student.billingType?.toUpperCase() ?? 'MONTHLY'}',
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          // Status Chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              // FIX 12: Replaced withOpacity (0.1) -> withAlpha(25) [~10% of 255]
              color: s.student.isActive ? Colors.green.withAlpha(25) : colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                // FIX 13: Replaced withOpacity (0.3) -> withAlpha(76)
                color: s.student.isActive ? Colors.green.withAlpha(76) : colorScheme.error.withAlpha(76),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  s.student.isActive ? Icons.check_circle : Icons.cancel,
                  size: 16,
                  color: s.student.isActive ? Colors.green : colorScheme.error,
                ),
                const SizedBox(width: 6),
                Text(
                  s.student.isActive ? 'ACTIVE STUDENT' : 'INACTIVE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: s.student.isActive ? Colors.green : colorScheme.error,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // NEW: Subjects Section
  Widget _buildSubjectsSection(BuildContext context, List<String> subjects) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Enrolled Subjects",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: subjects
                .map(
                  (sub) => Chip(
                    label: Text(
                      sub,
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSecondaryContainer,
                      ),
                    ),
                    backgroundColor: colorScheme.secondaryContainer,
                    side: BorderSide.none,
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialStats(BuildContext context, StudentFull s) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: _statCard(
              context,
              "Billed",
              s.totalBilled,
              colorScheme.onSurface,
              colorScheme.surfaceContainerLow,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _statCard(
              context,
              "Paid",
              s.totalPaid,
              Colors.green,
              colorScheme.surfaceContainerLow,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _statCard(
              context,
              "Owed",
              s.owed,
              colorScheme.error,
              // FIX 14: Replaced withOpacity(0.2) -> withAlpha(51)
              colorScheme.errorContainer.withAlpha(51),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(
    BuildContext context,
    String label,
    double amount,
    Color textColor,
    Color bgColor,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        // FIX 15: Replaced withOpacity(0.5) -> withAlpha(128)
        border: Border.all(color: colorScheme.outlineVariant.withAlpha(128)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '\$${amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalDetails(BuildContext context, StudentFull s) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        color: colorScheme.surfaceContainerLow,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          // FIX 16: Replaced withOpacity(0.5) -> withAlpha(128)
          side: BorderSide(color: colorScheme.outlineVariant.withAlpha(128)),
        ),
        child: Column(
          children: [
            _detailRow(
              context,
              Icons.person_outline,
              "Parent / Guardian",
              s.student.parentContact ?? "No Name",
            ),
            Divider(
              height: 1,
              indent: 50,
              // FIX 17: Replaced withOpacity(0.5) -> withAlpha(128)
              color: colorScheme.outlineVariant.withAlpha(128),
            ),
            _detailRow(
              context,
              Icons.phone_outlined,
              "Contact Number",
              s.student.parentContact ?? "No Number",
            ),
            Divider(
              height: 1,
              indent: 50,
              // FIX 18: Replaced withOpacity(0.5) -> withAlpha(128)
              color: colorScheme.outlineVariant.withAlpha(128),
            ),
            _detailRow(
              context,
              Icons.calendar_today_outlined,
              "Registered",
              s.student.registrationDate != null
                  ? DateFormat(
                      'MMM dd, yyyy',
                    ).format(s.student.registrationDate!)
                  : 'Unknown',
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTile(BuildContext context, LedgerItem item) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        // FIX 19: Replaced withOpacity(0.5) -> withAlpha(128)
        border: Border.all(color: colorScheme.outlineVariant.withAlpha(128)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              // FIX 20: Replaced withOpacity(0.1) -> withAlpha(25)
              color: item.isCredit ? Colors.green.withAlpha(25) : colorScheme.error.withAlpha(25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              item.isCredit ? Icons.arrow_downward : Icons.arrow_upward,
              color: item.isCredit ? Colors.green : colorScheme.error,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  DateFormat('MMM dd, yyyy').format(item.date),
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${item.isCredit ? '+' : '-'}\$${item.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: item.isCredit ? Colors.green : colorScheme.onSurface,
                ),
              ),
              if (!item.isCredit)
                Text(
                  item.subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // --- ACTIONS (MODALS) ---
  // Modals are updated to use Theme colors for backgrounds and text.

  void _showAddPaymentModal(
    BuildContext context,
    WidgetRef ref,
    String studentId,
  ) {
    final amountController = TextEditingController();
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Record Payment",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              autofocus: true,
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: "Amount",
                prefixText: "\$ ",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(amountController.text);
                if (amount != null && amount > 0) {
                  final db = DatabaseService.instance;
                  final bills = await db.getStudentBills(studentId);
                  String? billId;
                  if (bills.isNotEmpty) {
                    billId = bills.first['id'] as String;
                  }

                  if (billId != null) {
                    await db.recordPayment(
                      billId: billId,
                      studentId: studentId,
                      amount: amount,
                      datePaid: DateTime.now(),
                      method: 'Cash',
                    );
                    if (context.mounted) {
                      Navigator.pop(context);
                      ref.invalidate(studentLedgerProvider(studentId));
                    }
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("No bill to pay against!"),
                        ),
                      );
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Confirm Payment"),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  void _showAddBillModal(
    BuildContext context,
    WidgetRef ref,
    String studentId,
  ) {
    final amountController = TextEditingController();
    final descController = TextEditingController();
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Add Manual Charge",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: descController,
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: "Description (e.g. Uniform)",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: "Amount",
                prefixText: "\$ ",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(amountController.text);
                if (amount != null && amount > 0) {
                  final db = DatabaseService.instance;
                  await db.createBillForStudent(
                    studentId: studentId,
                    totalAmount: amount,
                    billType: 'custom',
                    monthYear: descController.text.isNotEmpty
                        ? descController.text
                        : 'Manual Charge',
                    createdAt: DateTime.now(),
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    ref.invalidate(studentLedgerProvider(studentId));
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Create Charge"),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}