import 'package:equatable/equatable.dart';

class Bill extends Equatable {
  final String id;
  final String studentId;
  final String title; // e.g., "Term 1 Tuition", "Uniform Fee"
  final double totalAmount;
  final double paidAmount; // How much has been paid so far
  final DateTime dueDate;
  final DateTime createdAt;
  final String? adminUid;

  const Bill({
    required this.id,
    required this.studentId,
    required this.title,
    required this.totalAmount,
    this.paidAmount = 0.0,
    required this.dueDate,
    required this.createdAt,
    this.adminUid,
  });

  // Helper to check if bill is fully settled
  bool get isPaid => paidAmount >= totalAmount;

  // Helper to check remaining balance
  double get balanceDue => totalAmount - paidAmount;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_id': studentId,
      'title': title,
      'total_amount': totalAmount,
      'paid_amount': paidAmount,
      'due_date': dueDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'admin_uid': adminUid,
    };
  }

  factory Bill.fromMap(Map<String, dynamic> map) {
    return Bill(
      id: map['id'] ?? '',
      studentId: map['student_id'] ?? '',
      title: map['title'] ?? '',
      totalAmount: (map['total_amount'] as num?)?.toDouble() ?? 0.0,
      paidAmount: (map['paid_amount'] as num?)?.toDouble() ?? 0.0,
      dueDate: DateTime.tryParse(map['due_date'] ?? '') ?? DateTime.now(),
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
      adminUid: map['admin_uid'],
    );
  }

  Bill copyWith({
    String? id,
    String? studentId,
    String? title,
    double? totalAmount,
    double? paidAmount,
    DateTime? dueDate,
    String? adminUid,
  }) {
    return Bill(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      title: title ?? this.title,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt, // CreatedAt should rarely change
      adminUid: adminUid ?? this.adminUid,
    );
  }

  @override
  List<Object?> get props => [
        id,
        studentId,
        title,
        totalAmount,
        paidAmount,
        dueDate,
        adminUid,
      ];
}