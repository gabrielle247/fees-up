import 'package:equatable/equatable.dart';

class Payment extends Equatable {
  final String id;
  final String billId;
  final String studentId;
  final double amount;
  final DateTime datePaid;
  final String method; // 'Cash', 'Ecocash', 'Bank Transfer'
  final String? adminUid;

  const Payment({
    required this.id,
    required this.billId,
    required this.studentId,
    required this.amount,
    required this.datePaid,
    this.method = 'Cash',
    this.adminUid,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bill_id': billId,
      'student_id': studentId,
      'amount': amount,
      'date_paid': datePaid.toIso8601String(),
      'method': method,
      'admin_uid': adminUid,
    };
  }

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'] ?? '',
      billId: map['bill_id'] ?? '',
      studentId: map['student_id'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      datePaid: DateTime.parse(map['date_paid']),
      method: map['method'] ?? 'Cash',
      adminUid: map['admin_uid'],
    );
  }

  @override
  List<Object?> get props => [id, billId, amount, datePaid, method];
}