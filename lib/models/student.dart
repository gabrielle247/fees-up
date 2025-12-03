import 'dart:convert';
import 'package:equatable/equatable.dart';

class Student extends Equatable {
  // Matches SQL 'id' (TEXT PRIMARY KEY)
  final String id;
  
  // Matches SQL 'full_name'
  final String fullName;
  
  // Matches SQL 'grade'
  final String grade; 
  
  // Matches SQL 'parent_contact'
  final String parentContact;
  
  // Matches SQL 'registration_date'
  final DateTime registrationDate;
  
  // Matches SQL 'is_active' (Stored as INTEGER 0/1, mapped to bool)
  final bool isActive;
  
  // Matches SQL 'default_monthly_fee'
  final double defaultMonthlyFee;
  
  // Matches SQL 'subjects' (Stored as JSON String)
  final List<String> subjects;
  
  // Matches SQL 'admin_uid' (For RLS/Sync)
  final String? adminUid;

  const Student({
    required this.id,
    required this.fullName,
    required this.grade,
    required this.parentContact,
    required this.registrationDate,
    this.isActive = true,
    this.defaultMonthlyFee = 0.0,
    this.subjects = const [],
    this.adminUid,
  });

  // --- FACTORY (From Database Map) ---
  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id']?.toString() ?? '',
      fullName: map['full_name'] ?? map['studentName'] ?? '', // Fallback for migration
      grade: map['grade'] ?? '',
      parentContact: map['parent_contact'] ?? map['parentContact'] ?? '',
      registrationDate: DateTime.tryParse(map['registration_date'] ?? '') ?? DateTime.now(),
      isActive: (map['is_active'] is int) ? (map['is_active'] == 1) : (map['is_active'] ?? true),
      defaultMonthlyFee: (map['default_monthly_fee'] as num?)?.toDouble() ?? 0.0,
      subjects: _parseSubjects(map['subjects']),
      adminUid: map['admin_uid'],
    );
  }

  // --- TO MAP (For Database Insert) ---
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'grade': grade,
      'parent_contact': parentContact,
      'registration_date': registrationDate.toIso8601String(),
      'is_active': isActive ? 1 : 0,
      'default_monthly_fee': defaultMonthlyFee,
      'subjects': jsonEncode(subjects), // Store List as JSON String
      'admin_uid': adminUid,
    };
  }

  // Helper to safely parse the subjects list/string
  static List<String> _parseSubjects(dynamic value) {
    if (value == null) return [];
    if (value is List) return List<String>.from(value);
    if (value is String) {
      try {
        return List<String>.from(jsonDecode(value));
      } catch (_) {
        return [];
      }
    }
    return [];
  }

  Student copyWith({
    String? id,
    String? fullName,
    String? grade,
    String? parentContact,
    DateTime? registrationDate,
    bool? isActive,
    double? defaultMonthlyFee,
    List<String>? subjects,
    String? adminUid,
  }) {
    return Student(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      grade: grade ?? this.grade,
      parentContact: parentContact ?? this.parentContact,
      registrationDate: registrationDate ?? this.registrationDate,
      isActive: isActive ?? this.isActive,
      defaultMonthlyFee: defaultMonthlyFee ?? this.defaultMonthlyFee,
      subjects: subjects ?? this.subjects,
      adminUid: adminUid ?? this.adminUid,
    );
  }

  @override
  List<Object?> get props => [id, fullName, grade, parentContact, isActive, defaultMonthlyFee, subjects, adminUid];
}