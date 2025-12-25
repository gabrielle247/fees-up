import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../services/database_service.dart';

class AuthRepository {
  final GoTrueClient _auth;
  final DatabaseService _db;

  AuthRepository({GoTrueClient? auth, DatabaseService? db}) 
      : _auth = auth ?? Supabase.instance.client.auth,
        _db = db ?? DatabaseService();

  User? get currentUser => _auth.currentUser;
  
  Stream<AuthState> get authStateChanges => _auth.onAuthStateChange;

  /// Sign In with Friendly Errors
  Future<AuthResponse> signIn({required String email, required String password}) async {
    try {
      return await _auth.signInWithPassword(email: email, password: password);
    } on AuthException catch (e) {
      throw _getHumanReadableError(e.message);
    } on PostgrestException catch (e) {
      throw _getHumanReadableError(e.message);
    } catch (_) {
      throw 'Unable to login. Please check your internet connection.';
    }
  }

  /// Sign Out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      // Fail silently on logout errors, just clear local state if needed
    }
  }

  /// Setup School with Friendly Errors
  Future<void> signUpWithSchool({
    required String fullName,
    required String email,
    required String password,
    required String schoolName,
  }) async {
    try {
      // 1. Create Auth User
      final response = await _auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );

      final user = response.user;
      if (user == null) throw 'Sign up failed. Please try again.';

      // 2. Generate IDs
      final schoolId = const Uuid().v4();
      
      // 3. Write Data Locally (Offline First)
      // A. Create School
      await _db.insert('schools', {
        'id': schoolId,
        'name': schoolName,
        'subscription_tier': 'free',
        'max_students': 50,
        'is_suspended': 0,
        'created_at': DateTime.now().toIso8601String(),
      });

      // B. Create User Profile
      await _db.db.execute(
        'INSERT OR REPLACE INTO user_profiles (id, email, full_name, role, school_id, created_at) VALUES (?, ?, ?, ?, ?, ?)',
        [
          user.id,
          email,
          fullName,
          'school_admin',
          schoolId,
          DateTime.now().toIso8601String(),
        ]
      );

    } on AuthException catch (e) {
      throw _getHumanReadableError(e.message);
    } on PostgrestException catch (e) {
      throw _getHumanReadableError(e.message);
    } catch (e) {
      // Check for common connection errors
      if (e.toString().contains('SocketException') || e.toString().contains('Network')) {
        throw 'Connection failed. Please check your internet.';
      }
      throw 'Something went wrong. Please try again.';
    }
  }

  /// TRANSLATOR: Technical -> Human
  String _getHumanReadableError(String technicalMessage) {
    final msg = technicalMessage.toLowerCase();

    if (msg.contains('invalid login credentials')) {
      return 'Incorrect email or password.';
    }
    if (msg.contains('user already registered') || msg.contains('already exists')) {
      return 'An account with this email already exists.';
    }
    if (msg.contains('password should be at least')) {
      return 'Password is too short. It must be at least 6 characters.';
    }
    if (msg.contains('valid email')) {
      return 'Please enter a valid email address.';
    }
    if (msg.contains('network') || msg.contains('connection')) {
      return 'Network error. Please check your connection.';
    }
    
    // Fallback: If it's a server error we don't recognize, imply it's temporary
    return 'A server error occurred. Please try again later.';
  }
}