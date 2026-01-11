class Student {
  final String id;
  final String schoolId;
  final String firstName;
  final String lastName;
  final String? nationalId;
  final DateTime? dob;
  final String? gender;
  final String status;
  final DateTime enrollmentDate;  ///ISO 8601 string format
  final String? admissionNumber;
  final String? guardianName;
  final String? guardianPhone;
  final String? guardianEmail;
  final String? guardianRelationship;
  final String studentType;
  final DateTime admissionDate; ///ISO 8601 string format
  final bool isArchived; 
  final DateTime createdAt; ///ISO 8601 string format
  final DateTime updatedAt; ///ISO 8601 string format
  final double feesOwed;
  final String? subjects;

  Student({
    required this.id,
    required this.schoolId,
    required this.firstName,
    required this.lastName,
    this.nationalId,
    this.dob,
    this.gender,
    required this.status,
    required this.enrollmentDate, ///ISO 8601 string format
    this.admissionNumber,
    this.guardianName,
    this.guardianPhone,
    this.guardianEmail,
    this.guardianRelationship,
    required this.studentType,
    required this.admissionDate, ///ISO 8601 string format
    required this.isArchived,
    required this.createdAt, ///ISO 8601 string format
    required this.updatedAt, ///ISO 8601 string format
    required this.feesOwed,  this.subjects,
  });

  factory Student.fromJson(Map<String, dynamic> json) => Student(
        id: json['id'],
        schoolId: json['school_id'],
        firstName: json['first_name'],
        lastName: json['last_name'],
        nationalId: json['national_id'],
        dob: json['dob'] != null ? DateTime.parse(json['dob']) : null,
        gender: json['gender'],
        status: json['status'],
        enrollmentDate: DateTime.parse(json['enrollment_date']),
        admissionNumber: json['admission_number'],
        guardianName: json['guardian_name'],
        guardianPhone: json['guardian_phone'],
        guardianEmail: json['guardian_email'],
        guardianRelationship: json['guardian_relationship'],
        studentType: json['student_type'],
        admissionDate: DateTime.parse(json['admission_date']),
        isArchived: json['is_archived'] == 1,
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']),
        feesOwed: json['fees_owed'].toDouble(),
      );
}