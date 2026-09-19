import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/profile_provider.dart';
import '../../providers/level_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/edit_profile_sheet.dart';
import '../../widgets/sign_out_dialog.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  String _getPlayerTier(int level) {
    if (level < 5) return 'Novice Solver';
    if (level < 15) return 'Adept Navigator';
    if (level < 30) return 'Expert Strategist';
    return 'Master Escapist';
  }

  Color _getTierColor(int level) {
    if (level < 5) return const Color(0xFF64748B);
    if (level < 15) return const Color(0xFF3B82F6);
    if (level < 30) return const Color(0xFF8B5CF6);
    return const Color(0xFFF59E0B);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final levelState = ref.watch(levelProgressProvider);
    final authState = ref.watch(authProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final completedLevelsCount = levelState.progressMap.values.where((p) => p.completed).length;
    final isGoogleUser = authState.user != null;
    final tier = _getPlayerTier(profile.level);
    final tierColor = _getTierColor(profile.level);

    return Scaffold(
      appBar: AppBar(
        title: const Text('PLAYER PROFILE'),
        actions: [
          IconButton(
            tooltip: 'Edit Profile',
            onPressed: () => EditProfileSheet.show(context),
            icon: const Icon(Icons.edit_rounded),
          ),
          IconButton(
            tooltip: 'Settings',
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: Column(
          children: [
            // 1. Profile Hero Card
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(isDark ? 50 : 15),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Avatar with Edit Badge
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      GestureDetector(
                        onTap: () => EditProfileSheet.show(context),
                        child: Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: tierColor, width: 3),
                            color: AppColors.primaryBlue.withAlpha(35),
                          ),
                          child: Center(
                            child: (profile.avatarUrl != null && profile.avatarUrl!.startsWith('http'))
                                ? ClipOval(
                                    child: Image.network(
                                      profile.avatarUrl!,
                                      width: 82,
                                      height: 82,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => const Text('🏹', style: TextStyle(fontSize: 40)),
                                    ),
                                  )
                                : Text(
                                    (profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty)
                                        ? profile.avatarUrl!
                                        : (profile.username.isNotEmpty ? profile.username[0].toUpperCase() : 'P'),
                                    style: TextStyle(
                                      fontSize: (profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty && !profile.avatarUrl!.startsWith('http')) ? 42 : 36,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryBlue,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => EditProfileSheet.show(context),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.primaryBlue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Player Name with Edit Tap
                  InkWell(
                    onTap: () => EditProfileSheet.show(context),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              profile.username.isNotEmpty ? profile.username : 'Player',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.3,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.edit_outlined, size: 18, color: AppColors.primaryBlue),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Player Tier & Google Verified Badges
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: tierColor.withAlpha(35),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: tierColor.withAlpha(80)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.military_tech_rounded, size: 14, color: tierColor),
                            const SizedBox(width: 4),
                            Text(
                              tier,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: tierColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isGoogleUser
                              ? AppColors.accentGreen.withAlpha(30)
                              : AppColors.accentAmber.withAlpha(30),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isGoogleUser ? Icons.verified_rounded : Icons.person_outline_rounded,
                              size: 14,
                              color: isGoogleUser ? AppColors.accentGreen : AppColors.accentAmber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isGoogleUser ? 'Google Sync' : 'Guest Account',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isGoogleUser ? AppColors.accentGreen : AppColors.accentAmber,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  if (isGoogleUser && authState.user?.email != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      authState.user!.email!,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                  ],

                  const SizedBox(height: 16),
                  // Edit Profile Button
                  SizedBox(
                    width: double.infinity,
                    height: 42,
                    child: OutlinedButton.icon(
                      onPressed: () => EditProfileSheet.show(context),
                      icon: const Icon(Icons.edit_note_rounded, size: 20),
                      label: const Text('Edit Player Tag & Avatar', style: TextStyle(fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        side: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 2. XP Progress Card
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
            const SizedBox(height: 20),

            // 3. Statistics Grid
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
            const SizedBox(height: 24),

            // 4. Quick Actions
            ListTile(
              onTap: () => context.push('/achievements'),
              leading: const Icon(Icons.emoji_events_rounded, color: AppColors.primaryBlue),
              title: const Text('Achievements & Badges', style: TextStyle(fontWeight: FontWeight.bold)),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              tileColor: isDark ? AppColors.surfaceDark : Colors.white,
            ),
            const SizedBox(height: 12),

            ListTile(
              onTap: () => context.push('/leaderboard'),
              leading: const Icon(Icons.leaderboard_rounded, color: AppColors.accentAmber),
              title: const Text('Global Leaderboards', style: TextStyle(fontWeight: FontWeight.bold)),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              tileColor: isDark ? AppColors.surfaceDark : Colors.white,
            ),
            const SizedBox(height: 12),

            if (isGoogleUser) ...[
              // Cloud Sync Tile
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
                    : const Icon(Icons.cloud_done_rounded, color: AppColors.accentGreen),
                title: const Text('Cloud Data Synchronized', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Tap to refresh cloud backup now', style: TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.sync_rounded, size: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                tileColor: isDark ? AppColors.surfaceDark : Colors.white,
              ),
              const SizedBox(height: 24),

              // Sign Out Button (Prominent & Safe)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () => SignOutDialog.show(context),
                  icon: const Icon(Icons.logout_rounded, color: AppColors.accentRed),
                  label: const Text(
                    'SIGN OUT OF ACCOUNT',
                    style: TextStyle(
                      color: AppColors.accentRed,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.accentRed, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ] else ...[
              ListTile(
                onTap: () => context.push('/login'),
                leading: const Icon(Icons.login_rounded, color: AppColors.primaryBlue),
                title: const Text('Sign In with Google to Sync', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Back up your progress permanently across devices', style: TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                tileColor: isDark ? AppColors.surfaceDark : Colors.white,
              ),
            ],
            const SizedBox(height: 20),
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

