// ==========================================
// BILL ITEM MODEL (Line items inside a bill)
// ==========================================
class BillItem {
  final String id;
  final String billId;
  final String schoolId;
  final String description;
  final double amount;
  final int quantity;

  BillItem({
    required this.id,
    required this.billId,
    required this.schoolId,
    required this.description,
    required this.amount,
    this.quantity = 1,
  });

  // Calculate total for this line item
  double get total => amount * quantity;

  factory BillItem.fromRow(Map<String, dynamic> row) {
    return BillItem(
      id: row['id'] as String,
      billId: row['bill_id'] as String,
      schoolId: row['school_id'] as String,
      description: row['description'] as String,
      amount: (row['amount'] as num?)?.toDouble() ?? 0.0,
      quantity: (row['quantity'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bill_id': billId,
      'school_id': schoolId,
      'description': description,
      'amount': amount,
      'quantity': quantity,
    };
  }
}

// ==========================================
// PAYMENT ALLOCATION MODEL (Splitting one payment across bills)
// ==========================================
class PaymentAllocation {
  final String id;
  final String paymentId;
  final String billId;
  final String schoolId;
  final double amount;

  PaymentAllocation({
    required this.id,
    required this.paymentId,
    required this.billId,
    required this.schoolId,
    required this.amount,
  });

  factory PaymentAllocation.fromRow(Map<String, dynamic> row) {
    return PaymentAllocation(
      id: row['id'] as String,
      paymentId: row['payment_id'] as String,
      billId: row['bill_id'] as String,
      schoolId: row['school_id'] as String,
      amount: (row['amount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'payment_id': paymentId,
      'bill_id': billId,
      'school_id': schoolId,
      'amount': amount,
    };
  }
}

// ==========================================
// CREDIT MODEL (Discounts or overpayments)
// ==========================================
class Credit {
  final String id;
  final String schoolId;
  final String studentId;
  final String? billId; // If applied to a specific bill
  final double amount;
  final String? reason;
  final String? creditId; // Manual reference ID

  Credit({
    required this.id,
    required this.schoolId,
    required this.studentId,
    required this.amount,
    this.billId,
    this.reason,
    this.creditId,
  });

  factory Credit.fromRow(Map<String, dynamic> row) {
    return Credit(
      id: row['id'] as String,
      schoolId: row['school_id'] as String,
      studentId: row['student_id'] as String,
      amount: (row['amount'] as num?)?.toDouble() ?? 0.0,
      billId: row['bill_id'] as String?,
      reason: row['reason'] as String?,
      creditId: row['credit_id'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'school_id': schoolId,
      'student_id': studentId,
      'amount': amount,
      'bill_id': billId,
      'reason': reason,
      'credit_id': creditId,
    };
  }
}