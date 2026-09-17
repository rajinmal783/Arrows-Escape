import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'storage_provider.dart';
import 'auth_provider.dart';
import '../models/user_profile.dart';

class ProfileNotifier extends StateNotifier<UserProfile> {
  final Ref _ref;

  ProfileNotifier(this._ref)
      : super(const UserProfile(id: 'guest', username: 'Player', coins: 100)) {
    loadProfile();
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
