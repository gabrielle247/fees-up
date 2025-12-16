import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // --- Session Properties ---
  bool get isAuthenticated => _supabase.auth.currentUser != null;
  String? get currentUid => _supabase.auth.currentUser?.id;

  /// Checks if a session already exists on app launch.
  Future<bool> getInitialAuthStatus() async {
    return _supabase.auth.currentSession != null;
  }

  // --- Sign Up (Transactions: School -> Profile) ---
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String schoolName,
  }) async {
    try {
      // 1. Create Auth User
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );

      final user = response.user;

      if (user != null) {
        // 2. Create the School & Profile
        await _initializeUserAndSchool(
          userId: user.id,
          email: email,
          fullName: fullName,
          schoolName: schoolName,
        );
      } else {
        // If email confirmation is ON, user might be null or session null
        // We throw to let the UI know to ask for confirmation
        return; 
      }
    } on AuthException catch (e) {
      _handleAuthError(e);
    } on PostgrestException catch (e) {
      throw Exception("Database Error: ${e.message}");
    } catch (e) {
      throw Exception("Unexpected Error: $e");
    }
  }

  // --- Sign In ---
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on AuthException catch (e) {
      _handleAuthError(e);
    } catch (e) {
      throw Exception("Connection failed. Please check your internet.");
    }
  }

  // --- Reset Password ---
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      _handleAuthError(e);
    } catch (e) {
      throw Exception("Could not send reset email: $e");
    }
  }

  // --- Sign Out & Exit ---
  Future<void> signOutAndShutdown() async {
    try {
      await _supabase.auth.signOut();
      await SystemNavigator.pop();
    } catch (e) {
      debugPrint("Error during sign out: $e");
      await SystemNavigator.pop();
    }
  }

  /// Allows an already-authenticated user (without profile) to complete setup.
  /// Creates a school and links a `user_profiles` record with role 'school_admin'.
  Future<void> completeProfileSetup({
    required String fullName,
    required String schoolName,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('Not authenticated');
    }

    try {
      // A. Create School
      final schoolResponse = await _supabase
          .from('schools')
          .insert({
            'name': schoolName,
            'subscription_tier': 'free',
          })
          .select()
          .single();

      final String schoolId = schoolResponse['id'];

      // B. Upsert User Profile (RLS should allow auth.uid())
      await _supabase.from('user_profiles').upsert({
        'id': user.id,
        'email': user.email,
        'full_name': fullName,
        'role': 'school_admin',
        'school_id': schoolId,
      });
    } on PostgrestException catch (e) {
      throw Exception("Database Error: ${e.message}");
    } catch (e) {
      throw Exception("Failed to complete profile: $e");
    }
  }

  // --- Helper: Database Initialization ---
  Future<void> _initializeUserAndSchool({
    required String userId,
    required String email,
    required String fullName,
    required String schoolName,
  }) async {
    // A. Insert School and get the returned ID
    // We use .select() to return the data created by the database default gen_random_uuid()
    final schoolResponse = await _supabase.from('schools').insert({
      'name': schoolName,
      'subscription_tier': 'free',
      // 'created_at' is handled by DB default
    }).select().single();

    final String schoolId = schoolResponse['id'];

    // B. Insert User Profile linked to that School
    await _supabase.from('user_profiles').insert({
      'id': userId,
      'email': email,
      'full_name': fullName,
      'role': 'school_admin',
      'school_id': schoolId,
      // 'is_banned': false (default)
    });
  }

  // --- Error Helper ---
  void _handleAuthError(AuthException e) {
    debugPrint("Supabase Auth Error: ${e.message} (Code: ${e.statusCode})");

    if (e.message.toLowerCase().contains("invalid login") ||
        e.message.toLowerCase().contains("invalid_grant")) {
      throw Exception("Incorrect email or password.");
    }
    if (e.statusCode == '429') {
      throw Exception("Too many attempts. Please wait 60 seconds.");
    }
    if (e.message.contains("User already registered")) {
      throw Exception("This email is already in use.");
    }
    
    // Fallback for other Supabase errors
    throw Exception(e.message);
  }
}