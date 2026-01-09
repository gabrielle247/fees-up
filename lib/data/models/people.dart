import 'package:isar/isar.dart';

part 'people.g.dart';

@collection
class AcademicYear {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String id;

  @Index()
  late String schoolId;

  late String name;
  late DateTime startDate;
  late DateTime endDate;
  bool isActive = false;
  DateTime? createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'school_id': schoolId,
        'name': name,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'is_active': isActive,
        'created_at': createdAt?.toIso8601String(),
      };

  static AcademicYear fromJson(Map<String, dynamic> json) => AcademicYear()
    ..id = json['id'] as String
    ..schoolId = json['school_id'] as String
    ..name = json['name'] as String
    ..startDate = DateTime.parse(json['start_date'] as String)
    ..endDate = DateTime.parse(json['end_date'] as String)
    ..isActive = json['is_active'] as bool? ?? false
    ..createdAt = json['created_at'] != null
        ? DateTime.parse(json['created_at'] as String)
        : null;
}

@collection
class Student {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String id;

  @Index()
  late String schoolId;

  late String firstName;
  late String lastName;
  String? nationalId;
  DateTime? dob;
  String? gender;
  String? admissionNumber;
  String? currentGrade;

  String status = 'ACTIVE';
  DateTime? enrollmentDate;
  DateTime? createdAt;

  String get fullName => '$firstName $lastName';

  Map<String, dynamic> toJson() => {
        'id': id,
        'school_id': schoolId,
        'first_name': firstName,
        'last_name': lastName,
        'national_id': nationalId,
        'dob': dob?.toIso8601String(),
        'gender': gender,
        'admission_number': admissionNumber,
        'current_grade': currentGrade,
        'status': status,
        'enrollment_date': enrollmentDate?.toIso8601String(),
        'created_at': createdAt?.toIso8601String(),
      };

  static Student fromJson(Map<String, dynamic> json) => Student()
    ..id = json['id'] as String
    ..schoolId = json['school_id'] as String
    ..firstName = json['first_name'] as String
    ..lastName = json['last_name'] as String
    ..nationalId = json['national_id'] as String?
    ..dob = json['dob'] != null ? DateTime.parse(json['dob'] as String) : null
    ..gender = json['gender'] as String?
    ..admissionNumber = json['admission_number'] as String?
    ..currentGrade = json['current_grade'] as String?
    ..status = json['status'] as String? ?? 'ACTIVE'
    ..enrollmentDate = json['enrollment_date'] != null
        ? DateTime.parse(json['enrollment_date'] as String)
        : null
    ..createdAt = json['created_at'] != null
        ? DateTime.parse(json['created_at'] as String)
        : null;
}

@collection
class Enrollment {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String id;

  @Index()
  late String schoolId;

  @Index()
  late String studentId;

  @Index()
  late String academicYearId;

  late String gradeLevel;
  String? classStream;
  String? targetGrade;
  String? snapshotGrade;
  bool isActive = true;
  DateTime? createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'school_id': schoolId,
        'student_id': studentId,
        'academic_year_id': academicYearId,
        'grade_level': gradeLevel,
        'class_stream': classStream,
        'target_grade': targetGrade,
        'snapshot_grade': snapshotGrade,
        'is_active': isActive,
        'created_at': createdAt?.toIso8601String(),
      };

  static Enrollment fromJson(Map<String, dynamic> json) => Enrollment()
    ..id = json['id'] as String
    ..schoolId = json['school_id'] as String
    ..studentId = json['student_id'] as String
    ..academicYearId = json['academic_year_id'] as String
    ..gradeLevel = json['grade_level'] as String
    ..classStream = json['class_stream'] as String?
    ..targetGrade = json['target_grade'] as String?
    ..snapshotGrade = json['snapshot_grade'] as String?
    ..isActive = json['is_active'] as bool? ?? true
    ..createdAt = json['created_at'] != null
        ? DateTime.parse(json['created_at'] as String)
        : null;
}
