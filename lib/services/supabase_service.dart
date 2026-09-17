import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/app_constants.dart';
import '../models/user_profile.dart';
import '../models/level_progress.dart';
import '../models/leaderboard_entry.dart';
import '../models/achievement.dart';

class SupabaseService {
  static SupabaseClient? get client {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  static Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: AppConstants.supabaseUrl,
        anonKey: AppConstants.supabaseAnonKey,
      );
    } catch (e) {
      debugPrint('Supabase initialization fallback: $e');
    }
  }

  User? get currentUser => client?.auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  // --- Auth ---
  Future<bool> signInWithGoogle() async {
    final s = client;
    if (s == null) return false;
    try {
      if (kIsWeb) {
        return await s.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: Uri.base.origin,
        );
      } else {
        return await s.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: 'io.supabase.arrowescape://login-callback',
        );
      }
    } catch (e) {
      debugPrint('Google Sign-In error: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await client?.auth.signOut();
    } catch (e) {
      debugPrint('Sign-out error: $e');
    }
  }

  // --- Profile ---
  Future<UserProfile?> fetchProfile(String userId) async {
    final s = client;
    if (s == null) return null;
    try {
      final res = await s
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (res != null) {
        return UserProfile.fromJson(res);
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
    }
    return null;
  }

  Future<void> upsertProfile(UserProfile profile) async {
    final s = client;
    if (s == null || !isAuthenticated) return;
    try {
      await s.from('profiles').upsert(profile.toJson());
    } catch (e) {
      debugPrint('Error updating profile: $e');
    }
  }

  // --- Level Progress ---
  Future<List<LevelProgress>> fetchCloudProgress(String userId) async {
    final s = client;
    if (s == null) return [];
    try {
      final res = await s
          .from('levels_progress')
          .select()
          .eq('user_id', userId);

      return (res as List)
          .map((item) => LevelProgress.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching cloud progress: $e');
      return [];
    }
  }

  Future<void> upsertLevelProgress(String userId, LevelProgress progress) async {
    final s = client;
    if (s == null || !isAuthenticated) return;
    try {
      final data = progress.toJson();
      data['user_id'] = userId;
      await s.from('levels_progress').upsert(
            data,
            onConflict: 'user_id,level_id',
          );
    } catch (e) {
      debugPrint('Error syncing level progress: $e');
    }
  }

  // --- Leaderboard ---
  Future<List<LeaderboardEntry>> fetchLeaderboard({String periodType = 'all_time'}) async {
    final s = client;
    if (s == null) return [];
    try {
      final res = await s
          .from('leaderboard_public_view')
          .select()
          .eq('period_type', periodType)
          .order('score', ascending: false)
          .limit(50);

      return (res as List)
          .map((item) => LeaderboardEntry.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching leaderboard: $e');
      return [];
    }
  }

  Future<void> updateLeaderboardScore({
    required String userId,
    required String periodType,
    required String periodKey,
    required int score,
    required int stars,
  }) async {
    final s = client;
    if (s == null || !isAuthenticated) return;
    try {
      await s.from('leaderboard_entries').upsert(
        {
          'user_id': userId,
          'period_type': periodType,
          'period_key': periodKey,
          'score': score,
          'stars': stars,
          'updated_at': DateTime.now().toIso8601String(),
        },
        onConflict: 'user_id,period_type,period_key',
      );
    } catch (e) {
      debugPrint('Error updating leaderboard: $e');
    }
  }

  // --- Achievements ---
  Future<List<Achievement>> fetchAchievements() async {
    final s = client;
    if (s == null) return [];
    try {
      final res = await s.from('achievements').select();
      return (res as List)
          .map((item) => Achievement.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching achievements: $e');
      return [];
    }
  }
}
