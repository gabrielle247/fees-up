import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../repositories/auth_repository.dart';

// 1. The Repository Provider (This is what was missing)
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

// 2. Auth State Stream (Listens to Login/Logout events)
final authStateProvider = StreamProvider<AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.authStateChanges;
});

// 3. Current User Helper
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.value?.session?.user;
});