class Student {
  final int id; // Local database ID (Internal)
  final String studentId; // Public ID (e.g., STU-123456)
  final String studentName;
  final DateTime registrationDate;
  final bool isActive;
  final double defaultMonthlyFee;

  // ✅ NEW FIELDS
  final String parentContact;
  final List<String> subjects;
  final String frequency;

  Student({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.registrationDate,
    required this.isActive,
    required this.defaultMonthlyFee,
    this.parentContact = '',
    this.subjects = const [],
    this.frequency = 'Monthly',
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      // Safely handle ID as int or string parse
      id: json['id'] is int 
          ? json['id'] 
          : int.tryParse(json['id'].toString()) ?? 0,
      
      studentId: json['studentId'] ?? '',
      studentName: json['studentName'] ?? '',
      
      // Robust Date Parsing
      registrationDate: DateTime.tryParse(json['registrationDate'] ?? '') 
          ?? DateTime.now(),
      
      isActive: json['isActive'] ?? true,
      
      // 🛡️ SAFETY: Handle 'int' coming from backend where 'double' is expected
      defaultMonthlyFee: (json['defaultMonthlyFee'] as num?)?.toDouble() ?? 0.0,

      // ✅ LOAD NEW FIELDS
      parentContact: json['parentContact'] ?? '',
      // Safely convert dynamic list to List<String>
      subjects: List<String>.from(json['subjects'] ?? []),
      frequency: json['frequency'] ?? 'Monthly',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'studentName': studentName,
      'registrationDate': registrationDate.toIso8601String(),
      'isActive': isActive,
      'defaultMonthlyFee': defaultMonthlyFee,
      'parentContact': parentContact,
      'subjects': subjects,
      'frequency': frequency,
    };
  }

  // ✅ COPIER: Essential for "Edit Student" features
  Student copyWith({
    int? id,
    String? studentId,
    String? studentName,
    DateTime? registrationDate,
    bool? isActive,
    double? defaultMonthlyFee,
    String? parentContact,
    List<String>? subjects,
    String? frequency,
  }) {
    return Student(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      registrationDate: registrationDate ?? this.registrationDate,
      isActive: isActive ?? this.isActive,
      defaultMonthlyFee: defaultMonthlyFee ?? this.defaultMonthlyFee,
      parentContact: parentContact ?? this.parentContact,
      subjects: subjects ?? this.subjects,
      frequency: frequency ?? this.frequency,
    );
  }

  // ✅ DEBUG HELPER: Makes console logs readable
  @override
  String toString() {
    return 'Student(name: $studentName, id: $studentId, active: $isActive)';
  }
}
