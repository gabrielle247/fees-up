import 'dart:math';
import 'package:equatable/equatable.dart';

enum BillStatus { unpaid, partial, paid, overdue }

class Bill extends Equatable {
  final String id;
  final String studentId;
  final double totalAmount;
  final double paidAmount;
  
  // LOGIC FIELDS
  final DateTime monthYear;         // The "Label" Date (e.g. Jan 1, 2025)
  final DateTime billingCycleStart; // Technical start date
  final String cycleInterval;       // 'monthly', 'termly', 'yearly'
  
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? adminUid;

  const Bill({
    required this.id,
    required this.studentId,
    required this.totalAmount,
    this.paidAmount = 0.0,
    required this.monthYear,
    required this.billingCycleStart,
    this.cycleInterval = 'monthly',
    this.createdAt,
    this.updatedAt,
    this.adminUid,
  });

  // --- COMPUTED PROPERTIES ---
  
  double get outstandingBalance => max(0.0, totalAmount - paidAmount);
  
  BillStatus get status {
    if (paidAmount >= (totalAmount - 0.01)) return BillStatus.paid; // Tolerance for float errors
    if (paidAmount > 0) return BillStatus.partial;
    // Add logic here if you want to check due dates for 'overdue'
    return BillStatus.unpaid;
  }

  // --- DATABASE MAPPING ---

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_id': studentId,
      'total_amount': totalAmount,
      'paid_amount': paidAmount,
      'month_year': monthYear.toIso8601String(),
      'billing_cycle_start': billingCycleStart.toIso8601String(),
      'cycle_interval': cycleInterval,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'admin_uid': adminUid,
    };
  }

  factory Bill.fromMap(Map<String, dynamic> map) {
    return Bill(
      id: map['id'] ?? '',
      studentId: map['student_id'] ?? '',
      totalAmount: (map['total_amount'] as num?)?.toDouble() ?? 0.0,
      paidAmount: (map['paid_amount'] as num?)?.toDouble() ?? 0.0,
      monthYear: DateTime.parse(map['month_year']),
      billingCycleStart: DateTime.parse(map['billing_cycle_start']),
      cycleInterval: map['cycle_interval'] ?? 'monthly',
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
      adminUid: map['admin_uid'],
    );
  }

  Bill copyWith({
    double? paidAmount,
    DateTime? updatedAt,
  }) {
    return Bill(
      id: id,
      studentId: studentId,
      totalAmount: totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      monthYear: monthYear,
      billingCycleStart: billingCycleStart,
      cycleInterval: cycleInterval,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      adminUid: adminUid,
    );
  }

  @override
  List<Object?> get props => [id, studentId, totalAmount, paidAmount, monthYear];
}