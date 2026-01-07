import 'package:uuid/uuid.dart';
import 'billing_configuration.dart';

class BillLineItem {
  final String id;
  final BillingType type;
  final String description;
  final double unitPrice;
  final int quantity;
  final double total;
  final String? notes;

  BillLineItem({
    String? id,
    required this.type,
    required this.description,
    required this.unitPrice,
    this.quantity = 1,
    this.notes,
  })  : id = id ?? const Uuid().v4(),
        total = unitPrice * quantity;

  Map<String, dynamic> toMap() => {
        'id': id,
        'type': type.code,
        'description': description,
        'unit_price': unitPrice,
        'quantity': quantity,
        'total': total,
        'notes': notes,
      };
}

class GeneratedBill {
  final String id;
  final String schoolId;
  final String studentId;
  final String studentName;
  final String gradeLevel;
  final DateTime billingDate;
  final DateTime dueDate;
  final List<BillLineItem> lineItems;
  final double subtotal;
  final double lateFee;
  final double discount;
  final double total;
  final String frequency;
  final bool isSwitchBill; // Bill due to billing switch

  GeneratedBill({
    String? id,
    required this.schoolId,
    required this.studentId,
    required this.studentName,
    required this.gradeLevel,
    required this.billingDate,
    required this.dueDate,
    required this.lineItems,
    double? lateFee,
    double? discount,
    required this.frequency,
    this.isSwitchBill = false,
  })  : id = id ?? const Uuid().v4(),
        lateFee = lateFee ?? 0.0,
        discount = discount ?? 0.0,
        subtotal = lineItems.fold(0.0, (sum, item) => sum + item.total),
        total = (lineItems.fold(0.0, (sum, item) => sum + item.total) +
                (lateFee ?? 0.0) -
                (discount ?? 0.0))
            .clamp(0.0, double.infinity);

  Map<String, dynamic> toMap() => {
        'id': id,
        'school_id': schoolId,
        'student_id': studentId,
        'student_name': studentName,
        'grade_level': gradeLevel,
        'billing_date': billingDate.toIso8601String(),
        'due_date': dueDate.toIso8601String(),
        'line_items': lineItems.map((li) => li.toMap()).toList(),
        'subtotal': subtotal,
        'late_fee': lateFee,
        'discount': discount,
        'total': total,
        'frequency': frequency,
        'is_switch_bill': isSwitchBill,
      };
}
