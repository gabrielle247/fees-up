class ClassModel {
  final String id;
  final String schoolId;
  final String name;
  final String? teacherId;
  final String? roomNumber;
  final String? subjectCode;

  ClassModel({
    required this.id,
    required this.schoolId,
    required this.name,
    this.teacherId,
    this.roomNumber,
    this.subjectCode,
  });

  factory ClassModel.fromRow(Map<String, dynamic> row) {
    return ClassModel(
      id: row['id'] as String,
      schoolId: row['school_id'] as String,
      name: row['name'] as String,
      teacherId: row['teacher_id'] as String?,
      roomNumber: row['room_number'] as String?,
      subjectCode: row['subject_code'] as String?,
    );
  }
}

class Enrollment {
  final String id;
  final String schoolId;
  final String studentId;
  final String classId;
  final DateTime enrolledAt;

  Enrollment({
    required this.id,
    required this.schoolId,
    required this.studentId,
    required this.classId,
    required this.enrolledAt,
  });

  factory Enrollment.fromRow(Map<String, dynamic> row) {
    return Enrollment(
      id: row['id'] as String,
      schoolId: row['school_id'] as String,
      studentId: row['student_id'] as String,
      classId: row['class_id'] as String,
      enrolledAt: DateTime.tryParse(row['enrolled_at'] ?? '') ?? DateTime.now(),
    );
  }
}

class SchoolYear {
  final String id;
  final String schoolId;
  final String yearLabel; // e.g., "2025"
  final DateTime startDate;
  final DateTime endDate;
  final bool active;

  SchoolYear({
    required this.id,
    required this.schoolId,
    required this.yearLabel,
    required this.startDate,
    required this.endDate,
    this.active = false,
  });

  factory SchoolYear.fromRow(Map<String, dynamic> row) {
    return SchoolYear(
      id: row['id'] as String,
      schoolId: row['school_id'] as String,
      yearLabel: row['year_label'] as String,
      startDate: DateTime.parse(row['start_date']),
      endDate: DateTime.parse(row['end_date']),
      active: (row['active'] == 1),
    );
  }
}

class SchoolYearMonth {
  final String id;
  final String schoolYearId;
  final String name; // "January"
  final int monthIndex; // 1
  final DateTime startDate;
  final DateTime endDate;
  final bool isBillable;

  SchoolYearMonth({
    required this.id,
    required this.schoolYearId,
    required this.name,
    required this.monthIndex,
    required this.startDate,
    required this.endDate,
    this.isBillable = true,
  });

  factory SchoolYearMonth.fromRow(Map<String, dynamic> row) {
    return SchoolYearMonth(
      id: row['id'] as String,
      schoolYearId: row['school_year_id'] as String,
      name: row['name'] as String,
      monthIndex: (row['month_index'] as num).toInt(),
      startDate: DateTime.parse(row['start_date']),
      endDate: DateTime.parse(row['end_date']),
      isBillable: (row['is_billable'] == 1),
    );
  }
}

class SchoolTerm {
  final String id;
  final String schoolId;
  final String name; // "Term 1"
  final DateTime startDate;
  final DateTime endDate;
  final int academicYear;

  SchoolTerm({
    required this.id,
    required this.schoolId,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.academicYear,
  });

  factory SchoolTerm.fromRow(Map<String, dynamic> row) {
    return SchoolTerm(
      id: row['id'] as String,
      schoolId: row['school_id'] as String,
      name: row['name'] as String,
      startDate: DateTime.parse(row['start_date']),
      endDate: DateTime.parse(row['end_date']),
      academicYear: (row['academic_year'] as num).toInt(),
    );
  }
}