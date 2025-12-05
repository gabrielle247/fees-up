import 'package:equatable/equatable.dart';

class SchoolTerm extends Equatable {
  final String id;
  final String name; // "Term 1", "Term 2", "Term 3"
  final int year;    // 2025
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive; // Is this the current term?
  final String? adminUid;

  const SchoolTerm({
    required this.id,
    required this.name,
    required this.year,
    required this.startDate,
    required this.endDate,
    this.isActive = false,
    this.adminUid,
  });

  // Computed: "Term 1 2025"
  String get label => '$name $year';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'year': year,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'is_active': isActive ? 1 : 0,
      'admin_uid': adminUid,
    };
  }

  factory SchoolTerm.fromMap(Map<String, dynamic> map) {
    return SchoolTerm(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      year: map['year'] ?? DateTime.now().year,
      startDate: DateTime.parse(map['start_date']),
      endDate: DateTime.parse(map['end_date']),
      isActive: (map['is_active'] is int) ? map['is_active'] == 1 : map['is_active'] ?? false,
      adminUid: map['admin_uid'],
    );
  }

  @override
  List<Object?> get props => [id, name, year, startDate, endDate, isActive];
}