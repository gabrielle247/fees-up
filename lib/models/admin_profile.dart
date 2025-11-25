// lib/models/admin_profile.dart (Final Fixes)

class AdminProfile {
  // Matches public.admin_profile.id (Primary Key/Auth ID)
  final String id; 
  final String email;
  final String fullName;
  final String schoolName;
  final String? avatarUrl;
  final DateTime? lastSyncedAt; 
  
  // 🛑 FIX 1: Add missing field (required by the ViewModel)
  //final bool receiveNotifications; 

  AdminProfile({
    required this.id,
    required this.email,
    required this.fullName,
    required this.schoolName,
    this.avatarUrl,
    this.lastSyncedAt,
    // Set default value if not provided during construction
    //this.receiveNotifications = true, 
  });

  // Factory to create AdminProfile from Supabase
  factory AdminProfile.fromSupabaseRow(
    String userId,
    String? userEmail,
    Map<String, dynamic> row,
  ) {
    return AdminProfile(
      id: userId,
      email: userEmail ?? 'N/A',
      fullName: row['full_name'] ?? 'Administrator',
      schoolName: row['school_name'] ?? 'Fees Up School',
      avatarUrl: row['avatar_url'], 
      lastSyncedAt: DateTime.tryParse(row['last_synced_at'] ?? row['updated_at'] ?? ''),
      // 🛑 FIX 2: Pull the notification preference from the server row
      //receiveNotifications: row['receive_notifications'] ?? true, 
    );
  }

  // Factory to create AdminProfile from a local SQLite row
  factory AdminProfile.fromRow(Map<String, dynamic> row) {
    return AdminProfile(
      id: row['id'] ?? '',
      email: row['email'] ?? '',
      fullName: row['full_name'] ?? 'Administrator',
      schoolName: row['school_name'] ?? 'Fees Up School',
      avatarUrl: row['avatar_url'],
      lastSyncedAt: DateTime.tryParse(row['last_synced_at'] ?? ''),
      // 🛑 FIX 3: Default notification preference when loading from old local data
      //receiveNotifications: (row['receive_notifications'] == 0 || row['receive_notifications'] == false) ? false : true,
    );
  }

  // Converts the model to a map for insertion/update into the local SQLite table.
  Map<String, dynamic> toRow() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'school_name': schoolName,
      'avatar_url': avatarUrl,
      // 🛑 FIX 4: Add boolean field for local save
      //'receive_notifications': receiveNotifications ? 1 : 0, 
      'last_synced_at': DateTime.now().toIso8601String(),
    };
  }
  
  // ==========================================================
  // 🛑 FIX 5: Add the copyWith method (required for immutable state updates in ViewModel)
  // ==========================================================
  AdminProfile copyWith({
    String? fullName,
    String? schoolName,
    String? avatarUrl,
    //bool? receiveNotifications,
    DateTime? lastSyncedAt,
  }) {
    return AdminProfile(
      id: id,
      email: email,
      fullName: fullName ?? this.fullName,
      schoolName: schoolName ?? this.schoolName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      //receiveNotifications: receiveNotifications ?? this.receiveNotifications,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }
}