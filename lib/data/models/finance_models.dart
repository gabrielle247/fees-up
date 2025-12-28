// ==========================================
// BILL MODEL
// ==========================================
class Bill {
  final String id;
  final String schoolId;
  final String studentId;
  final String title;
  final double totalAmount;
  final double paidAmount;
  final bool isPaid;
  final DateTime? dueDate;
  final String billType; // 'monthly', 'adhoc'
  final bool isClosed;
  final String? termId;

  Bill({
    required this.id,
    required this.schoolId,
    required this.studentId,
    required this.title,
    required this.totalAmount,
    this.paidAmount = 0.0,
    this.isPaid = false,
    this.dueDate,
    this.billType = 'monthly',
    this.isClosed = false,
    this.termId,
  });

  factory Bill.fromRow(Map<String, dynamic> row) {
    return Bill(
      id: row['id'] as String,
      schoolId: row['school_id'] as String,
      studentId: row['student_id'] as String,
      title: row['title'] as String,
      totalAmount: (row['total_amount'] as num?)?.toDouble() ?? 0.0,
      paidAmount: (row['paid_amount'] as num?)?.toDouble() ?? 0.0,
      isPaid: (row['is_paid'] == 1),
      dueDate: row['due_date'] != null ? DateTime.tryParse(row['due_date']) : null,
      billType: row['bill_type'] ?? 'monthly',
      isClosed: (row['is_closed'] == 1),
      termId: row['term_id'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'school_id': schoolId,
      'student_id': studentId,
      'title': title,
      'total_amount': totalAmount,
      'paid_amount': paidAmount,
      'is_paid': isPaid ? 1 : 0,
      'due_date': dueDate?.toIso8601String(),
      'bill_type': billType,
      'is_closed': isClosed ? 1 : 0,
      'term_id': termId,
    };
  }
}

// ==========================================
// PAYMENT MODEL
// ==========================================
class Payment {
  final String id;
  final String schoolId;
  final String studentId;
  final double amount;
  final DateTime datePaid;
  final String method; // 'cash', 'ecocash', etc.
  final String? payerName;
  final String? billId;

  Payment({
    required this.id,
    required this.schoolId,
    required this.studentId,
    required this.amount,
    required this.datePaid,
    this.method = 'cash',
    this.payerName,
    this.billId,
  });

  factory Payment.fromRow(Map<String, dynamic> row) {
    return Payment(
      id: row['id'] as String,
      schoolId: row['school_id'] as String,
      studentId: row['student_id'] as String,
      amount: (row['amount'] as num?)?.toDouble() ?? 0.0,
      datePaid: row['date_paid'] != null 
          ? DateTime.tryParse(row['date_paid']) ?? DateTime.now()
          : DateTime.now(),
      method: row['method'] ?? 'cash',
      payerName: row['payer_name'] as String?,
      billId: row['bill_id'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'school_id': schoolId,
      'student_id': studentId,
      'amount': amount,
      'date_paid': datePaid.toIso8601String(),
      'method': method,
      'payer_name': payerName,
      'bill_id': billId,
    };
  }
}

class Expense {
  final String id;
  final String schoolId;
  final String title;
  final double amount;
  final String? category;
  final DateTime incurredAt;
  final String? description; // Maps to 'description' column
  final String? recipient;

  Expense({
    required this.id,
    required this.schoolId,
    required this.title,
    required this.amount,
    this.category,
    required this.incurredAt,
    this.description,
    this.recipient,
  });

  factory Expense.fromRow(Map<String, dynamic> row) {
    return Expense(
      id: row['id'] as String,
      schoolId: row['school_id'] as String,
      title: row['title'] as String,
      amount: (row['amount'] as num).toDouble(),
      category: row['category'] as String?,
      incurredAt: DateTime.tryParse(row['incurred_at'] ?? '') ?? DateTime.now(),
      description: row['description'] as String?,
      recipient: row['recipient'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'school_id': schoolId,
      'title': title,
      'amount': amount,
      'category': category,
      'incurred_at': incurredAt.toIso8601String(),
      'description': description,
      'recipient': recipient,
      // 'created_at' is usually handled by Supabase defaults, 
      // but for PowerSync offline-first, we often include it.
      'created_at': DateTime.now().toIso8601String(), 
    };
  }
}