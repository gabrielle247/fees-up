// lib/services/auth_service.dart (Revised Error Handling)

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 
// Note: We rely on Supabase SDK being initialized in main.dart

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // -----------------------------------------------------
  // Getters (No Change)
  // -----------------------------------------------------
  bool get isAuthenticated => _supabase.auth.currentUser != null;
  String? get currentUid => _supabase.auth.currentUser?.id; 

  // -----------------------------------------------------
  // Sign Up Logic (Using Vague Errors)
  // -----------------------------------------------------

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String schoolName,
  }) async {
    try {
      // 1. Create the user and get immediate session
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;

      if (user != null) {
        // 2. Call the PostgreSQL RPC function for secure profile creation
        await _supabase.rpc(
          'handle_new_user_profile',
          params: {
            'user_id': user.id, 
            'user_email': email,
            'user_full_name': fullName,
            'user_school_name': schoolName,
          }
        );
      }
      
    } on AuthException catch (e) {
      // 🛑 Vague Auth Error Mapping
      _handleVagueAuthError(e);

    } on PostgrestException catch (e) {
      // Catch errors from the RPC call (if database is down or RPC fails)
      _handleVagueNetworkError(e);

    } catch (e) {
      // Catch all other exceptions (including network/socket errors)
      _handleVagueNetworkError(e);
    }
  }

  // -----------------------------------------------------
  // Sign In Logic (Using Vague Errors)
  // -----------------------------------------------------
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
      // 🛑 Vague Auth Error Mapping
      _handleVagueAuthError(e);

    } catch (e) {
      // Catch all other exceptions (including network/socket errors)
      _handleVagueNetworkError(e);
    }
  }

  // -----------------------------------------------------
  // Sign Out Logic (No Change)
  // -----------------------------------------------------
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
  
  // -----------------------------------------------------
  // ⛔️ PRIVATE VAGUE ERROR HANDLERS ⛔️
  // -----------------------------------------------------

  /// Maps specific Auth errors (e.g., wrong password, rate limit) to vague messages.
  void _handleVagueAuthError(AuthException e) {
    debugPrint("Supabase Auth Error: ${e.message}");

    // Supabase error code for "Too Many Requests" (Rate Limit)
    // This often happens if user tries too many passwords in a short time.
    if (e.statusCode == '429') {
      throw Exception("Too many attempts. Please wait 60 seconds and try again.");
    }
    
    // For all other authentication failures (wrong email, wrong password, etc.)
    // We combine them into a single, uninformative error for security.
    throw Exception("Incorrect email or password.");
  }

  /// Maps all general network or unexpected exceptions to a single vague message.
  void _handleVagueNetworkError(Object e) {
    debugPrint("Unexpected Supabase Error: $e");
    // This covers socket exceptions, failed host lookups, RPC errors, etc.
    throw Exception("Network error. Please check your connection or try again.");
  }

}
