import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/auth_repository.dart';

// 1. PROVIDER FOR REPOSITORY (Simple Provider)
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(Supabase.instance.client);
});

// 2. THE CONTROLLER (AsyncNotifier)
// We replace 'StateNotifier' with 'AsyncNotifier'.
// The state is 'void' because we just want to track loading/error status for actions.
final authControllerProvider = AsyncNotifierProvider<AuthController, void>(() {
  return AuthController();
});

class AuthController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // Initial state is null (idle)
    return null;
  }

  Future<void> signIn(String email, String password) async {
    // 1. Set state to Loading
    state = const AsyncValue.loading();

    // 2. Perform Action
    // guard() is a Riverpod helper that automatically catches errors 
    // and sets the state to AsyncValue.error if something fails.
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      await repo.signIn(email, password);
    });
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      await repo.signOut();
    });
  }
}