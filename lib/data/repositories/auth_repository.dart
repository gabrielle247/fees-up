import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:powersync/powersync.dart';

// -----------------------------------------------------------------------------
// IMPORTS
// -----------------------------------------------------------------------------
import '../constants/app_strings.dart';

class AuthRepository {
  final GoTrueClient _auth;      // Supabase Auth Client
  final PowerSyncDatabase _db;   // Local DB for Profile Sync
  final Logger _log = Logger('AuthRepository');

  AuthRepository(this._db) : _auth = Supabase.instance.client.auth;

  /// ==========================================================================
  /// 1. SIGN IN
  /// ==========================================================================

  /// Signs in a user and ensures their local session is ready.
  Future<AuthResponse> signIn({
    required String email, 
    required String password
  }) async {
    try {
      _log.info('🔐 Attempting sign in for: $email');
      
      final response = await _auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _log.info('✅ Sign in successful. User ID: ${response.user!.id}');
        // Optional: Trigger a manual sync check here if needed
      }

      return response;
    } on AuthException catch (e) {
      _log.warning('⚠️ Sign in failed: ${e.message}');
      throw _humanizeError(e);
    } catch (e) {
      _log.severe('❌ Unexpected sign in error', e);
      throw AppStrings.genericError;
    }
  }

  /// ==========================================================================
  /// 2. SIGN UP
  /// ==========================================================================

  /// Registers a new user and creates their profile entry.
  Future<AuthResponse> signUp({
    required String email, 
    required String password, 
    required String fullName,
    String? schoolId, // Optional: If joining an existing school
  }) async {
    try {
      _log.info('📝 Attempting sign up for: $email');

      // 1. Create Auth User in Supabase
      final response = await _auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName}, // Store in metadata as backup
      );

      if (response.user == null) {
        throw const AuthException('Sign up failed: No user returned');
      }

      // 2. Create Profile Record (Critical for App Logic)
      // We write this to PowerSync so it exists locally immediately
      // and syncs up to the server in the background.
      _log.info('👤 Creating profile for user: ${response.user!.id}');
      
      await _db.execute('''
        INSERT INTO profiles (
          id, 
          email, 
          full_name, 
          school_id, 
          role_id, 
          created_at, 
          updated_at
        ) VALUES (uuid(), ?, ?, ?, ?, ?, ?)
      ''', [
        email,
        fullName,
        schoolId, // Nullable
        'admin',  // Default role for new signups (Change logic if needed)
        DateTime.now().toIso8601String(),
        DateTime.now().toIso8601String(),
      ]);

      _log.info('✅ Sign up and profile creation complete');
      return response;

    } on AuthException catch (e) {
      _log.warning('⚠️ Sign up failed: ${e.message}');
      throw _humanizeError(e);
    } catch (e) {
      _log.severe('❌ Unexpected sign up error', e);
      throw AppStrings.genericError;
    }
  }

  /// ==========================================================================
  /// 3. PASSWORD RESET (OTP)
  /// ==========================================================================

  /// Sends a 6-digit OTP code to the user's email.
  Future<void> sendPasswordResetOtp(String email) async {
    try {
      _log.info('📧 Sending password reset OTP to: $email');
      await _auth.resetPasswordForEmail(email);
      _log.info('✅ Reset OTP sent');
    } on AuthException catch (e) {
      throw _humanizeError(e);
    }
  }

  /// Verifies the OTP and updates the password.
  Future<void> verifyOtpAndUpdatePassword({
    required String email, 
    required String token, 
    required String newPassword
  }) async {
    try {
      _log.info('🔐 Verifying OTP and updating password');
      
      // Verify OTP
      final response = await _auth.verifyOTP(
        type: OtpType.recovery,
        token: token,
        email: email,
      );

      if (response.session == null) {
        throw const AuthException('Invalid code or session expired');
      }

      // Update Password
      await _auth.updateUser(
        UserAttributes(password: newPassword),
      );

      _log.info('✅ Password updated successfully');
    } on AuthException catch (e) {
      throw _humanizeError(e);
    }
  }

  /// ==========================================================================
  /// 4. CHANGE EMAIL
  /// ==========================================================================

  /// Initiates an email change. 
  /// Usually requires confirmation on both old and new emails.
  Future<void> changeEmail(String newEmail) async {
    try {
      _log.info('📧 Requesting email change to: $newEmail');
      await _auth.updateUser(UserAttributes(email: newEmail));
      _log.info('✅ Email change request sent');
    } on AuthException catch (e) {
      throw _humanizeError(e);
    }
  }

  /// ==========================================================================
  /// 5. USER SESSION & HELPERS
  /// ==========================================================================

  /// Returns the current authenticated user or null.
  User? get currentUser => _auth.currentUser;

  /// Signs out the user.
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _log.info('👋 User signed out');
    } catch (e) {
      _log.warning('Sign out error', e);
    }
  }

  /// ==========================================================================
  /// 6. SUPPORT (PLACEBO)
  /// ==========================================================================

  /// Simulates sending a high-priority help request to Cores Point Team.
  /// In production, this would hit a Slack webhook or Zendesk API.
  Future<void> contactSupport({
    required String subject, 
    required String message
  }) async {
    _log.info('🆘 Contacting Support: $subject');
    
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1500));
    
    // Placebo "Success" logic
    // We log it so you can see it working in debug console
    _log.info('''
      📨 [MOCK EMAIL SENT]
      To: support@corespoint.co
      From: ${currentUser?.email ?? 'Guest'}
      Subject: [Fees Up Help] $subject
      Body: $message
    ''');
  }

  /// ==========================================================================
  /// 7. ERROR HANDLING (NON-TECHNICAL)
  /// ==========================================================================

  /// Translates raw AuthExceptions into user-friendly messages.
  String _humanizeError(AuthException error) {
    final msg = error.message.toLowerCase();

    if (msg.contains('invalid login credentials')) {
      return 'Incorrect email or password.';
    }
    if (msg.contains('user already registered')) {
      return 'This email is already in use. Try logging in.';
    }
    if (msg.contains('rate limit')) {
      return 'Too many attempts. Please wait a moment.';
    }
    if (msg.contains('invalid token')) {
      return 'The code you entered is invalid or expired.';
    }
    if (msg.contains('password should be at least')) {
      return 'Password must be at least 6 characters.';
    }
    
    // Default fallback (remove "AuthException:" prefix if present)
    return error.message.replaceAll('AuthException:', '').trim();
  }
}