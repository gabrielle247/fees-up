// lib/services/auth_service.dart (Final Clean Version)

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 
// Note: We rely on Supabase SDK being initialized in main.dart

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // -----------------------------------------------------
  // Getters
  // -----------------------------------------------------
  bool get isAuthenticated => _supabase.auth.currentUser != null;
  // 🛑 FIX: Supabase User object uses 'id', not 'uid'
  String? get currentUid => _supabase.auth.currentUser?.id; 


  // -----------------------------------------------------
  // Sign Up Logic (Immediate Sign-In)
  // -----------------------------------------------------

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String schoolName,
  }) async {
    try {
      // 1. Create the user and get immediate session (Supabase config must have confirmations OFF)
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;

      if (user != null) {
        // 2. Call the PostgreSQL RPC function for secure profile creation
        // This runs only once per user.
        await _supabase.rpc(
          'handle_new_user_profile',
          params: {
            // User ID must match Supabase's 'id' field
            'user_id': user.id, 
            'user_email': email,
            'user_full_name': fullName,
            'user_school_name': schoolName,
          }
        );
      }
      
    } on AuthException catch (e) {
      debugPrint("Sign Up Error: ${e.message}");
      // Re-throw the clean error message for the UI to display
      throw Exception(e.message); 
    } catch (e) {
      debugPrint("Unexpected Sign Up Error: $e");
      throw Exception("An unexpected error occurred during sign up.");
    }
  }

  // -----------------------------------------------------
  // Sign In Logic 
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
      debugPrint("Sign In Error: ${e.message}");
      throw Exception(e.message);
    } catch (e) {
      debugPrint("Unexpected Sign In Error: $e");
      throw Exception("An unexpected error occurred during login.");
    }
  }

  // -----------------------------------------------------
  // Sign Out Logic
  // -----------------------------------------------------
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}