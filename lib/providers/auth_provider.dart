import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'storage_provider.dart';
import '../services/supabase_service.dart';

class AuthState {
  final User? user;
  final bool isLoading;
  final String? errorMessage;
  final bool isGuest;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
    this.isGuest = false,
  });

  bool get isAuthenticated => user != null || isGuest;

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? errorMessage,
    bool? isGuest,
    bool clearUser = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isGuest: isGuest ?? this.isGuest,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;

  AuthNotifier(this._ref) : super(const AuthState()) {
    _init();
  }

  void _init() {
    final client = SupabaseService.client;
    if (client != null) {
      state = state.copyWith(user: client.auth.currentUser);
      client.auth.onAuthStateChange.listen((data) {
        state = state.copyWith(user: data.session?.user);
        if (data.session?.user != null) {
          _syncOnLogin();
        }
      });
    }
  }

  Future<void> _syncOnLogin() async {
    try {
      await _ref.read(syncServiceProvider).syncAll();
    } catch (_) {}
  }

  Future<bool> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final success = await _ref.read(supabaseServiceProvider).signInWithGoogle();
      state = state.copyWith(isLoading: false, isGuest: false);
      return success;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  void continueAsGuest() {
    state = state.copyWith(isGuest: true, clearUser: true, isLoading: false);
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    await _ref.read(supabaseServiceProvider).signOut();
    state = const AuthState(isGuest: false);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});
