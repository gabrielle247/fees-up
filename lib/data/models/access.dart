import 'package:isar/isar.dart';

part 'access.g.dart';

@collection
class Role {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String id;

  late String name;
  String? description;
  DateTime? createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'created_at': createdAt?.toIso8601String(),
      };

  static Role fromJson(Map<String, dynamic> json) => Role()
    ..id = json['id'] as String
    ..name = json['name'] as String? ?? 'USER'
    ..description = json['description'] as String?
    ..createdAt = json['created_at'] != null
        ? DateTime.parse(json['created_at'] as String)
        : null;
}

@collection
class Profile {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String id;

  @Index()
  late String schoolId;

  late String fullName;
  String? firstName;
  late String email;
  late String roleId;

  bool isBanned = false;
  DateTime? createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'school_id': schoolId,
        'full_name': fullName,
        'first_name': firstName,
        'email': email,
        'role_id': roleId,
        'is_banned': isBanned,
        'created_at': createdAt?.toIso8601String(),
      };

  static Profile fromJson(Map<String, dynamic> json) => Profile()
    ..id = json['id'] as String
    ..schoolId = json['school_id'] as String
    ..fullName = json['full_name'] as String
    ..firstName = json['first_name'] as String?
    ..email = json['email'] as String
    ..roleId = json['role_id'] as String
    ..isBanned = json['is_banned'] as bool? ?? false
    ..createdAt = json['created_at'] != null
        ? DateTime.parse(json['created_at'] as String)
        : null;
}
