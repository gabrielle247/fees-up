import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// -----------------------------------------------------------------------------
// 1. SUPABASE CLIENT PROVIDER
// -----------------------------------------------------------------------------
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// -----------------------------------------------------------------------------
// 2. AUTH STATE STREAM
// -----------------------------------------------------------------------------
final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client.auth.onAuthStateChange;
});

// -----------------------------------------------------------------------------
// 3. CURRENT USER
// -----------------------------------------------------------------------------
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  return authState.whenData((state) => state.session?.user).value;
});

// -----------------------------------------------------------------------------
// 4. AUTH CONTROLLER
// -----------------------------------------------------------------------------
final authControllerProvider = FutureProvider<bool>((ref) async {
  final client = ref.watch(supabaseClientProvider);
  final session = client.auth.currentSession;
  return session != null;
});

class AuthNotifier extends StateNotifier<AsyncValue<void>> {
  final SupabaseClient _client;

  AuthNotifier(this._client) : super(const AsyncValue.data(null));

  Future<void> signInWithEmail(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signUpWithEmail(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await _client.auth.signUp(
        email: email,
        password: password,
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      await _client.auth.signOut();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> resetPassword(String email) async {
    state = const AsyncValue.loading();
    try {
      await _client.auth.resetPasswordForEmail(email);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<void>>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AuthNotifier(client);
});