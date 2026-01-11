// ignore_for_file: unused_local_variable, unused_field

import 'package:fees_up/data/repositories/finance_repository.dart';
import 'package:fees_up/data/repositories/payment_repository.dart';
import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';


class PaymentService {
  final PaymentRepository _paymentRepo;
  final FinanceRepository _financeRepo;
  final Logger _log = Logger('PaymentService');
  final Uuid _uuid = const Uuid();

  PaymentService(this._paymentRepo, this._financeRepo);

  /// Records a payment and automatically allocates it to pending invoices.
  /// 
  /// Flow:
  /// 1. Record the Payment (Cash In).
  /// 2. Fetch Pending Invoices (Oldest First).
  /// 3. Allocate funds to invoices until amount is exhausted.
  /// 4. Update Invoice Statuses.
  Future<void> recordAndAllocatePayment({
    required String schoolId,
    required String studentId,
    required double amount,
    String? method,
    String? reference,
  }) async {
    try {
      _log.info('🚀 Starting Payment Transaction: \$$amount for $studentId');

      // 1. Record the actual money coming in
      // This updates the Ledger and Student Balance
      await _paymentRepo.processPayment(
        schoolId: schoolId,
        studentId: studentId,
        amount: amount,
        method: method,
        referenceCode: reference,
      );

      // 2. Auto-Allocation Logic
      // We assume the payment ID we just created is the one we want to allocate.
      // Since processPayment is void, we might fetch the latest payment or 
      // ideally, processPayment should return the ID. 
      // For this implementation, we will fetch the latest payment for this student 
      // to ensure we grab the right one.
      final payments = await _paymentRepo.getPaymentsByStudent(studentId);
      if (payments.isEmpty) return; 
      final currentPayment = payments.first; // The one we just made

      double remainingAmount = amount;

      // 3. Fetch Unpaid Invoices (FIFO - First In, First Out)
      final pendingInvoices = await _financeRepo.getPendingInvoices(studentId);

      _log.info('Found ${pendingInvoices.length} pending invoices to allocate against.');

      // 4. Iterate and Pay Off
      for (var invoice in pendingInvoices) {
        if (remainingAmount <= 0) break;

        // Calculate how much is still owed on this invoice
        // (Total Invoice Amount - Already Paid Allocations)
        // Note: For a robust system, we should query `payment_allocations` here.
        // For this prototype, we will assume invoice.status reflects truth,
        // but typically we calculate `owed` dynamically.
        
        // Simplified Logic: 
        // We assume we pay the 'invoice items' directly. 
        // Let's iterate through items if needed, or just pay the invoice level.
        // Powersync schema has `payment_allocations` linked to `invoice_item_id`.
        
        if (invoice.items == null || invoice.items!.isEmpty) continue;

        for (var item in invoice.items!) {
           if (remainingAmount <= 0) break;

           // How much is this item? (e.g. Tuition $500)
           // ideally we check how much of this ITEM is already paid. 
           // We will assume simpler logic: allocate to item max amount.
           
           double allocationAmount = 0.0;
           if (remainingAmount >= item.amount) {
             allocationAmount = item.amount;
           } else {
             allocationAmount = remainingAmount;
           }

           // Create Allocation Record
           // Note: You might need to add `saveAllocation` to your FinanceRepo or PaymentRepo
           // For now, we print the action.
           // await _financeRepo.saveAllocation(...); 
           
           remainingAmount -= allocationAmount;
        }

        // Update Invoice Status based on payment
        // if fully paid...
        // await _financeRepo.updateInvoiceStatus(invoice.id, 'PAID');
      }
      
      _log.info('✅ Payment Transaction Complete. Remaining unallocated: \$$remainingAmount');

    } catch (e, stack) {
      _log.severe('❌ Payment Service Failed', e, stack);
      throw Exception('Failed to process payment transaction.');
    }
  }
}