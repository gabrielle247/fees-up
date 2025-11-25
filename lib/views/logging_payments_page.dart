import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../services/validators.dart';
import '../view_models/logging_payments_view_model.dart';

import '../utils/sized_box_normal.dart';
import '../utils/toobar_bottom.dart';

class LoggingPaymentsPage extends StatelessWidget {
  final String studentId;

  const LoggingPaymentsPage({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    if (studentId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Error")),
        body: const Center(child: Text("Student ID missing. Please go back.")),
      );
    }

    return ChangeNotifierProvider(
      create: (_) => LoggingPaymentsViewModel()..setStudentId(studentId),
      child: const _LoggingPaymentsForm(),
    );
  }
}

class _LoggingPaymentsForm extends StatefulWidget {
  const _LoggingPaymentsForm();

  @override
  State<_LoggingPaymentsForm> createState() => _LoggingPaymentsFormState();
}

class _LoggingPaymentsFormState extends State<_LoggingPaymentsForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LoggingPaymentsViewModel>();
    final colorScheme = Theme.of(context).colorScheme;

    var standardBoxDecoration = BoxDecoration(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(8.0),
      border: Border.all(color: colorScheme.tertiary, width: 1.0),
    );
    var fadedBoxDeco = BoxDecoration(
      // Fixed deprecation
      color: Colors.blueGrey.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(8.0),
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.receipt_long_rounded),
        ),
        title: const Text("Make Payment"),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.fromLTRB(0, 0, 16, 0),
            child: IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.close_rounded),
            ),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: ToolbarBottom(),
        ),
      ),

      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // --- SECTION 1: AMOUNT INPUT ---
                      displayTextField(
                        color: Colors.white,
                        size: 18.0,
                        fontWeight: FontWeight.w500,
                        data: "Total Cash Received",
                      ),
                      const SizedBoxNormal(10, 0.0),

                      TextFormField(
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),

                        onChanged: (val) {
                          double parsedAmount = double.tryParse(val) ?? 0.0;

                          vm.updateAmount(parsedAmount);
                        },

                        style: const TextStyle(color: Colors.white),

                        // ✅ STRICT VALIDATION ($0.50 - $500)
                        validator: Validators.validateMoney,

                        autovalidateMode: AutovalidateMode.onUserInteraction,

                        // ... decoration ...
                        decoration: InputDecoration(
                          hintText: "Enter amount (e.g. 150)",

                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,

                            fontSize: 14.0,
                          ),

                          prefixIcon: Icon(
                            Icons.attach_money,

                            color: Colors.grey.shade400,

                            size: 20,
                          ),

                          filled: true,

                          fillColor: colorScheme.surface,

                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),

                            borderSide: BorderSide(color: colorScheme.tertiary),
                          ),

                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),

                            borderSide: BorderSide(
                              color: colorScheme.secondary,
                            ),
                          ),

                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),

                            borderSide: BorderSide(color: colorScheme.error),
                          ),

                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),

                            borderSide: BorderSide(color: colorScheme.error),
                          ),
                        ),
                      ),

                      const SizedBoxNormal(24, 0.0),

                      // --- SECTION 2: SUMMARY ---
                      Container(
                        decoration: fadedBoxDeco,
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _buildSummaryRow(
                              context,
                              "Total Outstanding Debt:",
                              "\$ ${vm.totalOutstandingDebt.toStringAsFixed(2)}",
                              color: Colors.redAccent,
                            ),
                            const SizedBox(height: 8),
                            Divider(color: Colors.grey.shade800),
                            const SizedBox(height: 8),
                            _buildSummaryRow(
                              context,
                              "Amount Entered:",
                              "\$ ${vm.amount.toStringAsFixed(2)}",
                            ),
                            const SizedBox(height: 8),
                            if (vm.remainingCreditAfterDebt > 0)
                              _buildSummaryRow(
                                context,
                                "Surplus (Future Credit):",
                                "\$ ${vm.remainingCreditAfterDebt.toStringAsFixed(2)}",
                                color: Colors.greenAccent,
                                isBold: true,
                              ),
                          ],
                        ),
                      ),
                      const SizedBoxNormal(24, 0.0),

                      // --- SECTION 3: UNPAID BILLS LIST ---
                      displayTextField(
                        color: Colors.white,
                        size: 18.0,
                        fontWeight: FontWeight.w500,
                        data: "Bills to be Paid First",
                      ),
                      const SizedBoxNormal(10, 0.0),
                      Container(
                        decoration: standardBoxDecoration,
                        child: vm.isLoading
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : vm.unpaidBills.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.all(20),
                                child: Text(
                                  "No outstanding bills.",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                            : ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: vm.unpaidBills.length,
                                separatorBuilder: (c, i) => Divider(
                                  height: 1,
                                  color: colorScheme.tertiary.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                                itemBuilder: (context, index) {
                                  final bill = vm.unpaidBills[index];
                                  return ListTile(
                                    title: Text(
                                      DateFormat(
                                        'MMMM yyyy',
                                      ).format(bill.monthYear),
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    subtitle: Text(
                                      vm.getStatusLabel(bill),
                                      style: TextStyle(
                                        color: Colors.orange.shade300,
                                        fontSize: 12,
                                      ),
                                    ),
                                    trailing: Text(
                                      "\$${bill.outstandingBalance.toStringAsFixed(2)}",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // --- FOOTER ---
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border(top: BorderSide(color: colorScheme.tertiary)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: vm.isLoading
                        ? null
                        : () async {
                            if (!_formKey.currentState!.validate()) return;

                            bool success = await vm.logPayment();
                            if (success && context.mounted) {
                              context.pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Payment Logged Successfully"),
                                ),
                              );
                            } else if (!vm.isLoading && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Error: Could not process payment.",
                                  ),
                                ),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: colorScheme.primary,
                    ),
                    child: vm.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            "Confirm Payment",
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                  const SizedBoxNormal(15, 0),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: colorScheme.primary.withValues(
                        alpha: 0.3,
                      ),
                    ),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.white),
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

  Widget _buildSummaryRow(
    BuildContext context,
    String label,
    String value, {
    Color? color,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        Text(
          value,
          style: TextStyle(
            color: color ?? Colors.white,
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

Text displayTextField({
  required Color color,
  required double size,
  required FontWeight fontWeight,
  required String data,
  TextAlign align = TextAlign.start,
}) {
  return Text(
    data,
    style: TextStyle(color: color, fontSize: size, fontWeight: fontWeight),
    textAlign: align,
  );
}
