// ==========================================
// FILE: ./models/academic_models.dart
// ==========================================

class AcademicYear {
  final String id;
  final String schoolId;
  final String name; // e.g., "2026"
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final bool isLocked;
  final DateTime createdAt;

  AcademicYear({
    required this.id,
    required this.schoolId,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.isLocked,
    required this.createdAt,
  });

  factory AcademicYear.fromJson(Map<String, dynamic> json) => AcademicYear(
        id: json['id'],
        schoolId: json['school_id'],
        name: json['name'],
        startDate: DateTime.parse(json['start_date']),
        endDate: DateTime.parse(json['end_date']),
        isActive: json['is_active'] == 1 || json['is_active'] == true,
        isLocked: json['is_locked'] == 1 || json['is_locked'] == true,
        createdAt: DateTime.parse(json['created_at']),
      );
}

class Term {
  final String id;
  final String schoolId;
  final String academicYearId;
  final String name; // e.g., "Term 1"
  final DateTime startDate;
  final DateTime endDate;
  final DateTime dueDate; // When fees are strictly due for this term
  final bool isCurrent;
  final DateTime createdAt;

  Term({
    required this.id,
    required this.schoolId,
    required this.academicYearId,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.dueDate,
    required this.isCurrent,
    required this.createdAt,
  });

  factory Term.fromJson(Map<String, dynamic> json) => Term(
        id: json['id'],
        schoolId: json['school_id'],
        academicYearId: json['academic_year_id'],
        name: json['name'],
        startDate: DateTime.parse(json['start_date']),
        endDate: DateTime.parse(json['end_date']),
        dueDate: DateTime.parse(json['due_date']),
        isCurrent: json['is_current'] == 1 || json['is_current'] == true,
        createdAt: DateTime.parse(json['created_at']),
      );
}

class Enrollment {
  final String id;
  final String schoolId;
  final String studentId;
  final String academicYearId;
  final String gradeLevel; // e.g., "Form 4"
  final String classStream; // e.g., "East" or "A"
  final bool isActive;
  final DateTime createdAt;

  Enrollment({
    required this.id,
    required this.schoolId,
    required this.studentId,
    required this.academicYearId,
    required this.gradeLevel,
    required this.classStream,
    required this.isActive,
    required this.createdAt,
  });

  factory Enrollment.fromJson(Map<String, dynamic> json) => Enrollment(
        id: json['id'],
        schoolId: json['school_id'],
        studentId: json['student_id'],
        academicYearId: json['academic_year_id'],
        gradeLevel: json['grade_level'],
        classStream: json['class_stream'],
        isActive: json['is_active'] == 1 || json['is_active'] == true,
        createdAt: DateTime.parse(json['created_at']),
      );
}