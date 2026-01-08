import 'package:isar/isar.dart';

part 'billable.g.dart';

/// A billable item (subject, transport, etc.) that students can subscribe to.
/// Replaces the complex FeeStructure with simple subscription pricing.
@collection
class BillableItem {
  Id isarId = Isar.autoIncrement;
  @Index(unique: true, replace: true)
  late String id;
  @Index()
  late String schoolId;
  late String name; // e.g., "English", "Bus Zone A", "Tuition"
  late int price; // cents
  String? description;
  String? category; // subject, transport, tuition, etc.
  bool isActive = true;
  DateTime? createdAt;

  double get priceInDollars => price / 100.0;
  void setPriceFromDollars(double dollars) => price = (dollars * 100).toInt();

  Map<String, dynamic> toJson() => {
        'id': id,
        'school_id': schoolId,
        'name': name,
        'price': price / 100.0,
        'description': description,
        'category': category,
        'is_active': isActive,
        'created_at': createdAt?.toIso8601String(),
      };

  static BillableItem fromJson(Map<String, dynamic> json) => BillableItem()
    ..id = json['id'] as String
    ..schoolId = json['school_id'] as String
    ..name = json['name'] as String
    ..price = ((json['price'] as num?) ?? 0).toInt() * 100
    ..description = json['description'] as String?
    ..category = json['category'] as String?
    ..isActive = json['is_active'] as bool? ?? true
    ..createdAt = json['created_at'] != null
        ? DateTime.parse(json['created_at'] as String)
        : null;
}

/// Tracks which billables a student is subscribed to.
@collection
class StudentBillables {
  Id isarId = Isar.autoIncrement;
  @Index(unique: true, replace: true)
  late String id;
  @Index()
  late String schoolId;
  @Index()
  late String studentId;
  // List of billable IDs the student is subscribed to
  late List<String> billableIds = [];
  DateTime? createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'school_id': schoolId,
        'student_id': studentId,
        'billable_ids': billableIds,
        'created_at': createdAt?.toIso8601String(),
      };

  static StudentBillables fromJson(Map<String, dynamic> json) =>
      StudentBillables()
        ..id = json['id'] as String
        ..schoolId = json['school_id'] as String
        ..studentId = json['student_id'] as String
        ..billableIds =
            (json['billable_ids'] as List?)?.cast<String>().toList() ?? []
        ..createdAt = json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : null;
}
