// ==========================================
// TEACHER MODEL
// ==========================================
class Teacher {
  final String id;
  final String schoolId;
  final String fullName;
  final String? adminUid; // Links to user_profiles if they have logged in
  final DateTime createdAt;

  Teacher({
    required this.id,
    required this.schoolId,
    required this.fullName,
    this.adminUid,
    required this.createdAt,
  });

  factory Teacher.fromRow(Map<String, dynamic> row) {
    return Teacher(
      id: row['id'] as String,
      schoolId: row['school_id'] as String,
      fullName: row['full_name'] as String,
      adminUid: row['admin_uid'] as String?,
      createdAt: row['created_at'] != null 
          ? DateTime.tryParse(row['created_at']) ?? DateTime.now() 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'school_id': schoolId,
      'full_name': fullName,
      'admin_uid': adminUid,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

// ==========================================
// TEACHER ACCESS TOKEN MODEL
// ==========================================
class TeacherAccessToken {
  final String id;
  final String schoolId;
  final String teacherId;
  final String grantedByTeacherId;
  final String accessCode;
  final String permissionType; // 'attendance', 'campaigns', 'both'
  final bool isUsed;
  final DateTime? usedAt;
  final DateTime expiresAt;

  TeacherAccessToken({
    required this.id,
    required this.schoolId,
    required this.teacherId,
    required this.grantedByTeacherId,
    required this.accessCode,
    required this.permissionType,
    this.isUsed = false,
    this.usedAt,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  factory TeacherAccessToken.fromRow(Map<String, dynamic> row) {
    return TeacherAccessToken(
      id: row['id'] as String,
      schoolId: row['school_id'] as String,
      teacherId: row['teacher_id'] as String,
      grantedByTeacherId: row['granted_by_teacher_id'] as String,
      accessCode: row['access_code'] as String,
      permissionType: row['permission_type'] ?? 'attendance',
      isUsed: (row['is_used'] == 1), // SQLite boolean handling
      usedAt: row['used_at'] != null 
          ? DateTime.tryParse(row['used_at']) 
          : null,
      expiresAt: row['expires_at'] != null 
          ? DateTime.tryParse(row['expires_at']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'school_id': schoolId,
      'teacher_id': teacherId,
      'granted_by_teacher_id': grantedByTeacherId,
      'access_code': accessCode,
      'permission_type': permissionType,
      'is_used': isUsed ? 1 : 0,
      'used_at': usedAt?.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
    };
  }
}