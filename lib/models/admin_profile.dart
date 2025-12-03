class AdminProfile {
  final String id; 
  final String email;
  final String fullName;
  final String schoolName;
  final String? avatarUrl;
  final DateTime? lastSyncedAt; 

  AdminProfile({
    required this.id,
    required this.email,
    required this.fullName,
    required this.schoolName,
    this.avatarUrl,
    this.lastSyncedAt,
  });

  factory AdminProfile.fromMap(Map<String, dynamic> map) {
    return AdminProfile(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      fullName: map['full_name'] ?? 'Administrator',
      schoolName: map['school_name'] ?? 'Fees Up School',
      avatarUrl: map['avatar_url'],
      lastSyncedAt: DateTime.tryParse(map['last_synced_at'] ?? ''),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'school_name': schoolName,
      'avatar_url': avatarUrl,
      'last_synced_at': lastSyncedAt?.toIso8601String(),
    };
  }
  
  AdminProfile copyWith({
    String? fullName,
    String? schoolName,
    String? avatarUrl,
    DateTime? lastSyncedAt,
  }) {
    return AdminProfile(
      id: id,
      email: email,
      fullName: fullName ?? this.fullName,
      schoolName: schoolName ?? this.schoolName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }
}