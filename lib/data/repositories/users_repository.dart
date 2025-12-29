import 'package:supabase_flutter/supabase_flutter.dart';

class UsersRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getSchoolUsers(String schoolId) async {
    final response = await _client.rpc('get_school_users', params: {
      'target_school_id': schoolId,
    });
    return List<Map<String, dynamic>>.from(response as List);
  }

  Future<void> addUserByEmail({
    required String email,
    required String schoolId,
    required String role,
  }) async {
    final result = await _client.rpc('link_user_to_school', params: {
      'target_email': email,
      'target_school_id': schoolId,
      'assign_role': role,
    });

    if (result != 'success') {
      throw result; // Throw the specific error message from SQL (e.g. "User not found")
    }
  }

  Future<void> toggleStatus({
    required String userId,
    required String schoolId,
    required bool ban,
  }) async {
    await _client.rpc('toggle_user_access', params: {
      'target_user_id': userId,
      'target_school_id': schoolId,
      'should_ban': ban,
    });
  }
}