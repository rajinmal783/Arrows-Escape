import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'storage_provider.dart';
import 'auth_provider.dart';
import '../models/user_profile.dart';

class ProfileNotifier extends StateNotifier<UserProfile> {
  final Ref _ref;

  ProfileNotifier(this._ref)
      : super(const UserProfile(id: 'guest', username: 'Player', coins: 100)) {
    loadProfile();
    
    // Listen for auth changes to pull cloud profile
    _ref.listen(authProvider, (previous, next) {
      if (next.user != null && previous?.user?.id != next.user!.id) {
        _pullCloudProfile(next.user!.id);
      }
    });
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
    final storage = _ref.read(localStorageProvider);
    state = storage.loadProfile();
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
    state = state.copyWith(username: newName);
    await _save();
  }

  Future<void> _save() async {
    final storage = _ref.read(localStorageProvider);
    await storage.saveProfile(state);

    final auth = _ref.read(authProvider);
    if (auth.user != null) {
      await _ref.read(supabaseServiceProvider).upsertProfile(state);
    }
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, UserProfile>((ref) {
  return ProfileNotifier(ref);
});
