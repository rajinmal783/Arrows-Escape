import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/profile_provider.dart';
import '../../providers/level_provider.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final levelState = ref.watch(levelProgressProvider);
    final authState = ref.watch(authProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final completedLevelsCount = levelState.progressMap.values.where((p) => p.completed).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('PLAYER PROFILE'),
        actions: [
          IconButton(
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Profile Card Header
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: AppColors.primaryBlue.withAlpha(38),
                    backgroundImage: (profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty)
                        ? NetworkImage(profile.avatarUrl!)
                        : null,
                    child: (profile.avatarUrl == null || profile.avatarUrl!.isEmpty)
                        ? Text(
                            profile.username.isNotEmpty ? profile.username[0].toUpperCase() : 'P',
                            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                          )
                        : null,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    profile.fullName?.isNotEmpty == true ? profile.fullName! : profile.username,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withAlpha(31),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      authState.user != null ? (authState.user!.email ?? 'Google Account') : 'Guest Account',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // XP Progress Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Player Level ${profile.level}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('${profile.xp} / ${profile.nextLevelXp} XP', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: profile.xpProgress.clamp(0.0, 1.0),
                      minHeight: 8,
                      backgroundColor: Colors.grey.withAlpha(51),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Statistics Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _buildStatTile('Levels Cleared', '$completedLevelsCount / 500', Icons.check_circle_rounded, AppColors.accentGreen, isDark),
                _buildStatTile('Total Stars', '${levelState.totalStars} ⭐', Icons.star_rounded, AppColors.accentAmber, isDark),
                _buildStatTile('Coins Held', '${profile.coins} 🪙', Icons.monetization_on_rounded, AppColors.accentAmber, isDark),
                _buildStatTile('Active Streak', '${profile.currentStreak} Days 🔥', Icons.local_fire_department_rounded, AppColors.accentRed, isDark),
              ],
            ),
            const SizedBox(height: 28),

            // Quick Actions: Achievements, Sync & Logout
            ListTile(
              onTap: () => context.push('/achievements'),
              leading: const Icon(Icons.emoji_events_rounded, color: AppColors.primaryBlue),
              title: const Text('View All Achievements', style: TextStyle(fontWeight: FontWeight.bold)),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              tileColor: isDark ? AppColors.surfaceDark : Colors.white,
            ),
            const SizedBox(height: 12),

            if (authState.user != null) ...[
              ListTile(
                onTap: authState.isLoading
                    ? null
                    : () async {
                        final ok = await ref.read(authProvider.notifier).syncNow();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(ok ? 'Synced successfully with Supabase Cloud!' : 'Sync failed. Please check internet connection.'),
                              backgroundColor: ok ? AppColors.accentGreen : AppColors.accentRed,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                leading: authState.isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      )
                    : const Icon(Icons.cloud_sync_rounded, color: AppColors.primaryBlue),
                title: const Text('Sync with Cloud', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Back up progress, stats & boosters', style: TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                tileColor: isDark ? AppColors.surfaceDark : Colors.white,
              ),
              const SizedBox(height: 12),
              ListTile(
                onTap: () async {
                  await ref.read(authProvider.notifier).signOut();
                  if (context.mounted) context.go('/login');
                },
                leading: const Icon(Icons.logout_rounded, color: AppColors.accentRed),
                title: const Text('Log Out', style: TextStyle(color: AppColors.accentRed, fontWeight: FontWeight.bold)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                tileColor: isDark ? AppColors.surfaceDark : Colors.white,
              ),
            ] else
              ListTile(
                onTap: () => context.push('/login'),
                leading: const Icon(Icons.login_rounded, color: AppColors.primaryBlue),
                title: const Text('Sign In with Google to Sync', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Save your puzzle progress across all devices', style: TextStyle(fontSize: 12)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                tileColor: isDark ? AppColors.surfaceDark : Colors.white,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatTile(String title, String val, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 6),
          Text(val, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
