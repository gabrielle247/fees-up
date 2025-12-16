// lib/models/student_full.dart

/// Lightweight student model used by hydration routines.
/// This mirrors the `students` SQL table but is optimized for in-memory use.
class StudentModel {
  final String id;
  final String? fullName;
  final String? grade;
  final String? parentContact;
  final DateTime? registrationDate;
  final String? billingType;
  final bool isActive;
  final double? defaultFee;
  final String? adminUid;

  final double paidTotal;
  final double owedTotal;

  // NEW FIELD: simple comma-separated subjects string
  final String? subjects;

  StudentModel({
    required this.id,
    this.fullName,
    this.grade,
    this.parentContact,
    this.registrationDate,
    this.billingType,
    this.isActive = true,
    this.defaultFee,
    this.adminUid,
    this.paidTotal = 0.0,
    this.owedTotal = 0.0,
    this.subjects,
  });

  factory StudentModel.fromMap(Map<String, Object?> m) {
    DateTime? reg;
    try {
      if (m['registration_date'] != null) {
        reg = DateTime.parse(m['registration_date'] as String);
      }
    } catch (_) {}

    return StudentModel(
      id: m['id'] as String,
      fullName: m['full_name'] as String?,
      grade: m['grade'] as String?,
      parentContact: m['parent_contact'] as String?,
      registrationDate: reg,
      billingType: m['billing_type'] as String?,
      isActive: (m['is_active'] as int? ?? 1) == 1,
      defaultFee: (m['default_fee'] as num?)?.toDouble(),
      adminUid: m['admin_uid'] as String?,
      paidTotal: (m['paid_total'] as num?)?.toDouble() ?? 0.0,
      owedTotal: (m['owed_total'] as num?)?.toDouble() ?? 0.0,
      subjects: m['subjects'] as String?, // new
    );
  }
}

/// Lightweight bill model used in the StudentFull composite.
class BillModel {
  final String id;
  final String studentId;
  final String? termId;
  final String billType;
  final double totalAmount;
  final double paidAmount;
  final String? monthYear;
  final DateTime? cycleStart;
  final DateTime? cycleEnd;
  final bool isClosed;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BillModel({
    required this.id,
    required this.studentId,
    this.termId,
    required this.billType,
    required this.totalAmount,
    this.paidAmount = 0.0,
    this.monthYear,
    this.cycleStart,
    this.cycleEnd,
    this.isClosed = false,
    this.createdAt,
    this.updatedAt,
  });

  factory BillModel.fromMap(Map<String, Object?> m) {
    DateTime? cs;
    DateTime? ce;
    DateTime? ca;
    DateTime? ua;

    try {
      if (m['billing_cycle_start'] != null) {
        cs = DateTime.parse(m['billing_cycle_start'] as String);
      }
      if (m['billing_cycle_end'] != null) {
        ce = DateTime.parse(m['billing_cycle_end'] as String);
      }
    } catch (_) {}

    try {
      if (m['created_at'] != null) {
        ca = DateTime.fromMillisecondsSinceEpoch((m['created_at'] as num).toInt());
      }
    } catch (_) {}

    try {
      if (m['updated_at'] != null) {
        ua = DateTime.fromMillisecondsSinceEpoch((m['updated_at'] as num).toInt());
      }
    } catch (_) {}

    return BillModel(
      id: m['id'] as String,
      studentId: m['student_id'] as String,
      termId: m['term_id'] as String?,
      billType: (m['bill_type'] as String?) ?? 'monthly',
      totalAmount: (m['total_amount'] as num).toDouble(),
      paidAmount: (m['paid_amount'] as num?)?.toDouble() ?? 0.0,
      monthYear: m['month_year'] as String?,
      cycleStart: cs,
      cycleEnd: ce,
      isClosed: (m['is_closed'] as int? ?? 0) == 1,
      createdAt: ca,
      updatedAt: ua,
    );
  }
}

/// Lightweight payment model.
class PaymentModel {
  final String id;
  final String? billId;
  final String studentId;
  final double amount;
  final DateTime? datePaid;
  final String? method;
  final DateTime? createdAt;

  PaymentModel({
    required this.id,
    this.billId,
    required this.studentId,
    required this.amount,
    this.datePaid,
    this.method,
    this.createdAt,
  });

  factory PaymentModel.fromMap(Map<String, Object?> m) {
    DateTime? dp;
    DateTime? ca;

    try {
      if (m['date_paid'] != null) {
        dp = DateTime.parse(m['date_paid'] as String);
      }
    } catch (_) {}

    try {
      if (m['created_at'] != null) {
        ca = DateTime.fromMillisecondsSinceEpoch((m['created_at'] as num).toInt());
      }
    } catch (_) {}

    return PaymentModel(
      id: m['id'] as String,
      billId: m['bill_id'] as String?,
      studentId: m['student_id'] as String,
      amount: (m['amount'] as num).toDouble(),
      datePaid: dp,
      method: m['method'] as String?,
      createdAt: ca,
    );
  }
}

/// Hydrated composite containing the StudentModel, its bills, and its payments.
class StudentFull {
  final StudentModel student;
  final List<BillModel> bills;
  final List<PaymentModel> payments;

  StudentFull({
    required this.student,
    this.bills = const [],
    this.payments = const [],
  });

  double get totalBilled => bills.fold(0.0, (p, b) => p + b.totalAmount);
  double get totalPaid => payments.fold(0.0, (p, pay) => p + pay.amount);
  double get owed => (totalBilled - totalPaid).clamp(0.0, double.infinity);
}

