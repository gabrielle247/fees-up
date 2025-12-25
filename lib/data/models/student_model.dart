class Student {
  final String id;
  final String schoolId;
  final String fullName;
  final String? studentId; // Manual ID (e.g., "STD-001")
  final String? grade;
  final String? parentContact;
  final DateTime? registrationDate;
  final String billingType; // 'monthly', 'termly'
  final double defaultFee;
  final bool isActive;
  final double owedTotal;
  final double paidTotal;
  final String? termId;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? address;
  final String? emergencyContactName;
  final String? medicalNotes;
  final bool photoConsent;

  Student({
    required this.id,
    required this.schoolId,
    required this.fullName,
    this.studentId,
    this.grade,
    this.parentContact,
    this.registrationDate,
    this.billingType = 'monthly',
    this.defaultFee = 0.0,
    this.isActive = true,
    this.owedTotal = 0.0,
    this.paidTotal = 0.0,
    this.termId,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.emergencyContactName,
    this.medicalNotes,
    this.photoConsent = false,
  });

  // Factory to create a Student from a PowerSync/SQLite Row
  factory Student.fromRow(Map<String, dynamic> row) {
    return Student(
      id: row['id'] as String,
      schoolId: row['school_id'] as String,
      fullName: row['full_name'] as String,
      studentId: row['student_id'] as String?,
      grade: row['grade'] as String?,
      parentContact: row['parent_contact'] as String?,
      registrationDate: row['registration_date'] != null 
          ? DateTime.tryParse(row['registration_date']) 
          : null,
      billingType: row['billing_type'] ?? 'monthly',
      defaultFee: (row['default_fee'] as num?)?.toDouble() ?? 0.0,
      isActive: (row['is_active'] == 1), // SQLite stores bools as 0/1
      owedTotal: (row['owed_total'] as num?)?.toDouble() ?? 0.0,
      paidTotal: (row['paid_total'] as num?)?.toDouble() ?? 0.0,
      termId: row['term_id'] as String?,
      dateOfBirth: row['date_of_birth'] != null 
          ? DateTime.tryParse(row['date_of_birth']) 
          : null,
      gender: row['gender'] as String?,
      address: row['address'] as String?,
      emergencyContactName: row['emergency_contact_name'] as String?,
      medicalNotes: row['medical_notes'] as String?,
      photoConsent: (row['photo_consent'] == 1),
    );
  }

  // Convert to Map for saving to Database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'school_id': schoolId,
      'full_name': fullName,
      'student_id': studentId,
      'grade': grade,
      'parent_contact': parentContact,
      'registration_date': registrationDate?.toIso8601String(),
      'billing_type': billingType,
      'default_fee': defaultFee,
      'is_active': isActive ? 1 : 0,
      'owed_total': owedTotal,
      'paid_total': paidTotal,
      'term_id': termId,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'address': address,
      'emergency_contact_name': emergencyContactName,
      'medical_notes': medicalNotes,
      'photo_consent': photoConsent ? 1 : 0,
    };
  }
}