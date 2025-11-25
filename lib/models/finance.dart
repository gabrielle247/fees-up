import 'dart:math';
import 'package:flutter/foundation.dart';

// --- HELPER: 8-Char UUID Generator ---
String generateShortId() {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final rnd = Random();
  return String.fromCharCodes(Iterable.generate(
      8, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
}

// --- ENUMS ---
enum BillStatus { unpaid, partial, paid, overdue;

  void operator [](String other) {} }

// --- MODEL: BILL ---
@immutable
class Bill {
  final String id; // 8-char unique ID
  final String studentId;
  final double totalAmount; // The target amount (Fee)
  final double paidAmount;  // The amount accumulated so far
  final DateTime monthYear; // The month this bill belongs to (Day is ignored in logic)
  final DateTime dueDate;
  final DateTime createdAt;

  const Bill({
    required this.id,
    required this.studentId,
    required this.totalAmount,
    this.paidAmount = 0.0, // Default to 0 if new
    required this.monthYear,
    required this.dueDate,
    required this.createdAt,
  });

  // --- LOGIC: Computed Properties (The "Brain") ---
  
  // 1. Status is derived from math, never manually set.
  BillStatus get status {
    // allow a tiny floating point error margin (e.g. 0.0001)
    if (paidAmount >= (totalAmount - 0.01)) return BillStatus.paid;
    if (DateTime.now().isAfter(dueDate) && paidAmount < totalAmount) return BillStatus.overdue;
    if (paidAmount > 0) return BillStatus.partial;
    return BillStatus.unpaid;
  }

  // 2. How much is left to pay?
  double get outstandingBalance => max(0.0, totalAmount - paidAmount);

  // 3. Unique Key for preventing duplicates (e.g. "2025-11")
  String get uniqueMonthKey => "${monthYear.year}-${monthYear.month.toString().padLeft(2, '0')}";

  // --- SERIALIZATION (JSON) ---

  Map<String, dynamic> toJson() => {
        'id': id,
        'studentId': studentId,
        'totalAmount': totalAmount,
        'paidAmount': paidAmount,
        'monthYear': monthYear.toIso8601String(),
        'dueDate': dueDate.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        // We include status in JSON for easy reading, but we don't load it back.
        // We recalculate it on load to ensure accuracy.
        'status_label': status.name, 
      };

  factory Bill.fromJson(Map<String, dynamic> json) {
    return Bill(
      id: json['id'],
      studentId: json['studentId'],
      totalAmount: (json['totalAmount'] as num).toDouble(),
      paidAmount: (json['paidAmount'] as num?)?.toDouble() ?? 0.0,
      monthYear: DateTime.parse(json['monthYear']),
      dueDate: DateTime.parse(json['dueDate']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  // CopyWith helps when updating the paidAmount without losing other data
  Bill copyWith({
    String? id,
    String? studentId,
    double? totalAmount,
    double? paidAmount,
    DateTime? monthYear,
    DateTime? dueDate,
    DateTime? createdAt,
  }) {
    return Bill(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      monthYear: monthYear ?? this.monthYear,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// --- MODEL: PAYMENT ---
@immutable
class Payment {
  final String id;
  final String billId;    // STRICT: A payment must belong to a specific bill
  final String studentId; // Redundant but useful for quick filtering
  final double amount;
  final DateTime datePaid;
  final String method;    // e.g., "Cash", "EcoCash"

  const Payment({
    required this.id,
    required this.billId,
    required this.studentId,
    required this.amount,
    required this.datePaid,
    this.method = 'Cash',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'billId': billId,
        'studentId': studentId,
        'amount': amount,
        'datePaid': datePaid.toIso8601String(),
        'method': method,
      };

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      billId: json['billId'] ?? '',
      studentId: json['studentId'] ?? '',
      amount: (json['amount'] as num).toDouble(),
      datePaid: DateTime.parse(json['datePaid']),
      method: json['method'] ?? 'Cash',
    );
  }
}

