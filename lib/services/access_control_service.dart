
/// Client-side access control helper (defense-in-depth).
/// **NOTE: Server-side RLS policies are REQUIRED for security.**
class AccessControlService {
  static final AccessControlService _instance = AccessControlService._internal();

  AccessControlService._internal();

  factory AccessControlService() {
    return _instance;
  }

  /// Check if the current user is an admin (school_admin or super_admin).
  bool isAdmin(String userRole) {
    return userRole == 'school_admin' || 
           userRole == 'super_admin' || 
           userRole.toLowerCase().contains('admin');
  }

  /// Check if the current user owns the given resource (matches auth.uid).
  bool ownsResource(String? resourceOwnerId, String? currentUserId) {
    if (resourceOwnerId == null || currentUserId == null) return false;
    return resourceOwnerId == currentUserId;
  }

  /// Check if the admin's school matches the resource's school.
  bool schoolMatches(String? resourceSchoolId, String? adminSchoolId) {
    if (resourceSchoolId == null || adminSchoolId == null) return false;
    return resourceSchoolId == adminSchoolId;
  }

  /// Guard: Throw if user lacks permission for the action.
  /// **This is client-side only—never trust this alone without RLS.**
  void guardAdmin(String userRole) {
    if (!isAdmin(userRole)) {
      throw Exception('Insufficient permissions: admin access required');
    }
  }

  /// Guard: Throw if resource school doesn't match user's school.
  void guardSchoolAccess(String? resourceSchoolId, String? userSchoolId) {
    if (!schoolMatches(resourceSchoolId, userSchoolId)) {
      throw Exception('Access denied: school mismatch');
    }
  }

  /// Guard: Throw if user doesn't own the resource.
  void guardOwnership(String? resourceOwnerId, String? currentUserId) {
    if (!ownsResource(resourceOwnerId, currentUserId)) {
      throw Exception('Access denied: you do not own this resource');
    }
  }
}
