import 'package:uuid/uuid.dart';
import '../../students/data/student_model.dart';
import '../data/bill_model.dart';
import '../data/bill_repository.dart';

class BillingService {
  final BillRepository _billRepo = BillRepository();
  final Uuid _uuid = const Uuid();

  // ---------------------------------------------------------------------------
  // MAIN LOGIC: GENERATE NEXT BILL
  // ---------------------------------------------------------------------------
  Future<void> evaluateBillingForStudent(Student student) async {
    // 1. STATUS CHECK: If student is inactive, DO NOT charge.
    // They are "not with the school for that period".
    if (!student.isActive) {
      return; 
    }

    // 2. Get the last bill to see when we billed them last
    final lastBill = await _billRepo.getLastBill(student.id);
    
    // 3. Determine the Target Date for the NEW bill
    final DateTime now = DateTime.now();
    DateTime targetBillingDate;

    if (lastBill == null) {
      // New student? Bill starts from registration date or "Now"
      targetBillingDate = student.registrationDate;
    } else {
      // Calculate next cycle based on the LAST bill's start date
      targetBillingDate = _calculateNextCycle(
        lastBill.billingCycleStart, 
        lastBill.cycleInterval // e.g. 'monthly', 'termly'
      );
    }

    // 4. CHECK: Is it time to bill yet?
    // If the target date is in the future, wait.
    if (targetBillingDate.isAfter(now)) {
      return; 
    }

    // 5. DOUBLE CHECK: If they were inactive during the `targetBillingDate`, 
    // we effectively skip this bill and set the pointer to "Now".
    // (This fulfills: "could come back but are not charged for that period")
    // logic: if targetDate was 3 months ago but they just activated today,
    // we shouldn't create 3 back-dated bills. We should align to the current cycle.
    if (targetBillingDate.difference(now).inDays.abs() > 45) {
       // Logic gap adjustment: Reset cycle to current period if they've been gone a long time
       targetBillingDate = _snapToCurrentCycle(now, lastBill?.cycleInterval ?? 'monthly');
    }

    // 6. GENERATE THE BILL
    final newBill = Bill(
      id: _uuid.v4(),
      studentId: student.id,
      totalAmount: student.defaultMonthlyFee, // Or look up Term Fee
      monthYear: targetBillingDate,
      billingCycleStart: targetBillingDate,
      cycleInterval: lastBill?.cycleInterval ?? 'monthly', // Inherit or get from Student
      createdAt: DateTime.now(),
    );

    await _billRepo.createBill(newBill);
  }

  // ---------------------------------------------------------------------------
  // CYCLE MATH HELPER
  // ---------------------------------------------------------------------------
  DateTime _calculateNextCycle(DateTime lastDate, String interval) {
    if (interval == 'monthly') {
      // Add 1 month
      return DateTime(lastDate.year, lastDate.month + 1, lastDate.day);
    } 
    else if (interval == 'annually') {
      // Add 1 year
      return DateTime(lastDate.year + 1, lastDate.month, lastDate.day);
    } 
    else if (interval == 'termly') {
      // 🛑 COMPLEX LOGIC:
      // You need to fetch the "Official School Terms" from DB.
      // For now, this is a placeholder that adds 4 months.
      return DateTime(lastDate.year, lastDate.month + 4, lastDate.day);
    }
    return lastDate;
  }

  DateTime _snapToCurrentCycle(DateTime now, String interval) {
    // If they return after a long break, align bill to start of this month/term
    return DateTime(now.year, now.month, 1); 
  }
}