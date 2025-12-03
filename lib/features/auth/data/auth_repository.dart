import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final SupabaseClient _supabase;

  AuthRepository(this._supabase);

  // Get current user (Sync)
  User? get currentUser => _supabase.auth.currentUser;

  // Stream auth state changes (for the router)
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Sign In
  Future<void> signIn(String email, String password) async {
    await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Sign Out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}// TODO Implement this library.