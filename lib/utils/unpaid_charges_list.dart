import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; 

// Imports
import '../view_models/logging_payments_view_model.dart';
import '../models/finance.dart'; // Using the NEW Bill model

class UnpaidChargesList extends StatefulWidget {
  const UnpaidChargesList({super.key});

  @override
  State<UnpaidChargesList> createState() => _UnpaidChargesListState();
}

class _UnpaidChargesListState extends State<UnpaidChargesList> {
  
  @override
  void initState() {
    super.initState();
    // Trigger data load when widget mounts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // RENAMED: The VM method is now loadData() in the new architecture
        context.read<LoggingPaymentsViewModel>().loadData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LoggingPaymentsViewModel>(
      builder: (context, vm, child) {
        
        if (vm.isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: LinearProgressIndicator(),
            ),
          );
        }

        if (vm.unpaidBills.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline, color: Theme.of(context).colorScheme.secondary),
                const SizedBox(width: 8),
                const Text("No unpaid bills found.", style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true, 
          physics: const NeverScrollableScrollPhysics(),
          itemCount: vm.unpaidBills.length,
          
          separatorBuilder: (context, index) => Divider(
            height: 1, 
            color: Theme.of(context).colorScheme.tertiary.withAlpha(30), 
            indent: 16,
            endIndent: 16,
          ),
          
          itemBuilder: (context, index) {
            final Bill bill = vm.unpaidBills[index];
            
            // LOGIC: Top item is always the one being paid next
            final bool isNextUp = index == 0; 

            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              
              // Visual cue: The top bill is highlighted
              leading: Icon(
                Icons.priority_high_rounded, 
                size: 18,
                color: isNextUp ? Colors.orangeAccent : Colors.transparent
              ),

              title: Text(
                DateFormat('MMMM yyyy').format(bill.monthYear),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: isNextUp ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
              
              subtitle: Text(
                vm.getStatusLabel(bill), // Helper from VM
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 12
                ),
              ),

              trailing: Text(
                "\$${bill.outstandingBalance.toStringAsFixed(2)}",
                style: TextStyle(
                  color: isNextUp 
                      ? Theme.of(context).colorScheme.error 
                      : Colors.grey, // Older bills fade slightly
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            );
          },
        );
      },
    );
  }
}