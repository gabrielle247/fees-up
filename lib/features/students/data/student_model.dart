import 'dart:convert';
import 'package:equatable/equatable.dart';

class Student extends Equatable {
  final String id; // UUID
  final String fullName;
  final String grade; // e.g., "Form 1", "Grade 7"
  final String parentContact;
  final DateTime registrationDate;
  final bool isActive;
  final double defaultMonthlyFee;
  final List<String> subjects; // Stored as JSON string in DB
  final String? adminUid; // For Row Level Security (RLS)

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

  // --- DATABASE MAPPING (Snake_Case for SQL/Supabase) ---

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'grade': grade,
      'parent_contact': parentContact,
      'registration_date': registrationDate.toIso8601String(),
      'is_active': isActive ? 1 : 0, // SQLite uses 0/1 for booleans
      'default_monthly_fee': defaultMonthlyFee,
      'subjects': jsonEncode(subjects), // List -> JSON String
      'admin_uid': adminUid,
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'] ?? '',
      fullName: map['full_name'] ?? '',
      grade: map['grade'] ?? '',
      parentContact: map['parent_contact'] ?? '',
      registrationDate: DateTime.tryParse(map['registration_date'] ?? '') ?? DateTime.now(),
      isActive: (map['is_active'] is int) ? (map['is_active'] == 1) : (map['is_active'] ?? true),
      defaultMonthlyFee: (map['default_monthly_fee'] as num?)?.toDouble() ?? 0.0,
      subjects: _parseSubjects(map['subjects']),
      adminUid: map['admin_uid'],
    );
  }

  // Safe JSON Parsing Helper
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
  List<Object?> get props => [id, fullName, grade, parentContact, isActive, adminUid];
}