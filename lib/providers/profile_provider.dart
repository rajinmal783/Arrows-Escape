import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'storage_provider.dart';
import 'auth_provider.dart';
import '../models/user_profile.dart';

class ProfileNotifier extends StateNotifier<UserProfile> {
  final Ref _ref;

  ProfileNotifier(this._ref)
      : super(const UserProfile(id: 'guest', username: 'Guest Player', coins: 100)) {
    loadProfile();
    
    // Listen for auth changes to pull cloud profile or reset to guest
    _ref.listen(authProvider, (previous, next) {
      if (next.user != null && previous?.user?.id != next.user!.id) {
        _pullCloudProfile(next.user!.id);
      } else if (next.user == null) {
        resetToGuest();
      }
    });
  }

  void resetToGuest() {
    state = const UserProfile(
      id: 'guest',
      username: 'Guest Player',
      coins: 100,
      level: 1,
      xp: 0,
      hintsCount: 3,
      undosCount: 3,
    );
  }

  Future<void> _pullCloudProfile(String userId) async {
    final cloud = await _ref.read(supabaseServiceProvider).fetchProfile(userId);
    if (cloud != null) {
      state = cloud;
      final storage = _ref.read(localStorageProvider);
      await storage.saveProfile(cloud);
    }
  }

  void loadProfile() {
    final auth = _ref.read(authProvider);
    if (auth.user == null) {
      resetToGuest();
      return;
    }
    final storage = _ref.read(localStorageProvider);
    state = storage.loadProfile(userId: auth.user!.id);
  }

  Future<void> addRewards({required int xp, required int coins}) async {
    final newXp = state.xp + xp;
    final newCoins = state.coins + coins;
    final newLevel = 1 + (newXp ~/ 150);

    state = state.copyWith(
      xp: newXp,
      coins: newCoins,
      level: newLevel,
    );

    await _save();
  }

  Future<bool> spendCoins(int amount) async {
    if (state.coins < amount) return false;

    state = state.copyWith(coins: state.coins - amount);
    await _save();
    return true;
  }

  Future<void> addBoosters({int hints = 0, int undos = 0}) async {
    state = state.copyWith(
      hintsCount: state.hintsCount + hints,
      undosCount: state.undosCount + undos,
    );
    await _save();
  }

  Future<void> useHint() async {
    if (state.hintsCount > 0) {
      state = state.copyWith(hintsCount: state.hintsCount - 1);
      await _save();
    }
  }

  Future<void> useUndo() async {
    if (state.undosCount > 0) {
      state = state.copyWith(undosCount: state.undosCount - 1);
      await _save();
    }
  }

  Future<void> updateStreak(int streak) async {
    final longest = streak > state.longestStreak ? streak : state.longestStreak;
    state = state.copyWith(
      currentStreak: streak,
      longestStreak: longest,
    );
    await _save();
  }

  Future<void> updateUsername(String newName) async {
    state = state.copyWith(username: newName, fullName: newName);
    final auth = _ref.read(authProvider);
    if (auth.user != null) {
      await _ref.read(localStorageProvider).setUserSetCustomName(auth.user!.id, true);
    }
    await _save();
  }

  Future<void> updateProfileDetails({required String username, String? avatarUrl}) async {
    state = state.copyWith(
      username: username,
      fullName: username,
      avatarUrl: avatarUrl ?? state.avatarUrl,
    );
    final auth = _ref.read(authProvider);
    if (auth.user != null) {
      await _ref.read(localStorageProvider).setUserSetCustomName(auth.user!.id, true);
    }
    await _save();
  }

  Future<void> _save() async {
    final auth = _ref.read(authProvider);
    if (auth.user != null) {
      final storage = _ref.read(localStorageProvider);
      await storage.saveProfile(state);
      await _ref.read(supabaseServiceProvider).upsertProfile(state);
    }
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, UserProfile>((ref) {
  return ProfileNotifier(ref);
});
