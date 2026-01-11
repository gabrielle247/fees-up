// ==========================================
// FILE: ./models/discount_models.dart
// ==========================================

class Discount {
  final String id;
  final String schoolId;
  final String name; // e.g., "Staff Child"
  final double percentage; // e.g., 50.0
  final bool isActive;
  final DateTime createdAt;

  Discount({
    required this.id,
    required this.schoolId,
    required this.name,
    required this.percentage,
    required this.isActive,
    required this.createdAt,
  });

  factory Discount.fromJson(Map<String, dynamic> json) => Discount(
        id: json['id'],
        schoolId: json['school_id'],
        name: json['name'],
        percentage: double.parse(json['percentage'].toString()),
        isActive: json['is_active'] == 1 || json['is_active'] == true,
        createdAt: DateTime.parse(json['created_at']),
      );
}

// Links a specific student to a discount
class StudentDiscount {
  final String id;
  final String studentId;
  final String discountId;
  final String academicYearId; // Discounts might be reviewed yearly
  final DateTime assignedAt;

  StudentDiscount({
    required this.id,
    required this.studentId,
    required this.discountId,
    required this.academicYearId,
    required this.assignedAt,
  });

  factory StudentDiscount.fromJson(Map<String, dynamic> json) =>
      StudentDiscount(
        id: json['id'],
        studentId: json['student_id'],
        discountId: json['discount_id'],
        academicYearId: json['academic_year_id'],
        assignedAt: DateTime.parse(json['assigned_at']),
      );
}