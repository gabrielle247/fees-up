import 'package:fees_up/data/models/school_models.dart';
import 'package:fees_up/data/view_models/prodivers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


// -----------------------------------------------------------------------------
// STATE MODEL
// -----------------------------------------------------------------------------
class SessionState {
  final User? user;
  final School? currentSchool;
  final bool isLoading;
  final String? error;

  const SessionState({
    this.user,
    this.currentSchool,
    this.isLoading = false,
    this.error,
  });

  bool get isAuthenticated => user != null;
  bool get hasSchool => currentSchool != null;

  SessionState copyWith({
    User? user,
    School? currentSchool,
    bool? isLoading,
    String? error,
  }) {
    return SessionState(
      user: user ?? this.user,
      currentSchool: currentSchool ?? this.currentSchool,
      isLoading: isLoading ?? this.isLoading,
      error: error, // Nullable update
    );
  }
}

// -----------------------------------------------------------------------------
// PROVIDER
// -----------------------------------------------------------------------------
final sessionProvider = StateNotifierProvider<SessionNotifier, SessionState>((ref) {
  return SessionNotifier(ref);
});

class SessionNotifier extends StateNotifier<SessionState> {
  final Ref _ref;

  SessionNotifier(this._ref) : super(const SessionState()) {
    _init();
  }

  Future<void> _init() async {
    final authRepo = _ref.read(authRepositoryProvider);
    final user = authRepo.currentUser;

    if (user != null) {
      state = state.copyWith(user: user, isLoading: true);
      await _loadSchoolContext(user.id);
    }
  }

  Future<void> _loadSchoolContext(String userId) async {
    try {
      final schoolRepo = _ref.read(schoolRepositoryProvider);
      // Try finding a school owned by this user
      final school = await schoolRepo.getSchoolByOwner(userId);
      
      if (school != null) {
        state = state.copyWith(currentSchool: school, isLoading: false);
      } else {
        // Fallback: If offline/local, try getting the default local school
        final localSchool = await schoolRepo.getLocalSchool();
        state = state.copyWith(currentSchool: localSchool, isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(error: "Failed to load school context", isLoading: false);
    }
  }

  Future<void> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final authRepo = _ref.read(authRepositoryProvider);
      final response = await authRepo.signIn(email: email, password: password);
      
      if (response.user != null) {
        state = state.copyWith(user: response.user);
        await _loadSchoolContext(response.user!.id);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _ref.read(authRepositoryProvider).signOut();
    state = const SessionState(); // Reset state
  }
  
  // Update local school state after creating a new school
  void setSchool(School school) {
    state = state.copyWith(currentSchool: school);
  }
}