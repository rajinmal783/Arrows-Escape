import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class LevelCompleteDialog extends StatelessWidget {
  final int levelId;
  final int stars;
  final int score;
  final int moves;
  final int xpEarned;
  final int coinsEarned;
  final VoidCallback onNext;
  final VoidCallback onReplay;
  final VoidCallback onHome;

  const LevelCompleteDialog({
    super.key,
    required this.levelId,
    required this.stars,
    required this.score,
    required this.moves,
    required this.xpEarned,
    required this.coinsEarned,
    required this.onNext,
    required this.onReplay,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            const Text(
              'LEVEL COMPLETE!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
                color: AppColors.accentGreen,
              ),
            ),
            const SizedBox(height: 16),

            // 3-Star Rating
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                final isAwarded = index < stars;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: Icon(
                    isAwarded ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: isAwarded ? AppColors.accentAmber : Colors.grey.withAlpha(77),
                    size: 48,
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),

            // Performance Statistics
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.cardLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildStatRow('Moves Taken', '$moves'),
                  const Divider(height: 16),
                  _buildStatRow('Total Score', '$score pts'),
                  const Divider(height: 16),
                  _buildStatRow(
                    'Rewards Earned',
                    '+$xpEarned XP  •  +$coinsEarned Coins',
                    isHighlight: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2-Star Unlock Rule Banner
            if (stars < 2)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.accentAmber.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.accentAmber.withAlpha(120), width: 1.5),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_clock_rounded, color: AppColors.accentAmber, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Minimum 2 Stars (★★) required to unlock Level ${levelId + 1}!',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accentAmber,
                          height: 1.25,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Primary Button: NEXT LEVEL (if >= 2 stars) or RETRY FOR 2 STARS (if < 2 stars)
            if (stars >= 2)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: onNext,
                  icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                  label: const Text(
                    'NEXT LEVEL',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: onReplay,
                  icon: const Icon(Icons.replay_rounded, size: 20),
                  label: const Text(
                    'RETRY FOR 2 STARS',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentAmber,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            const SizedBox(height: 12),

            // Replay & Home Secondary Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onReplay,
                    icon: const Icon(Icons.replay_rounded, size: 18),
                    label: const Text('Replay'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onHome,
                    icon: const Icon(Icons.home_rounded, size: 18),
                    label: const Text('Home'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: isHighlight ? AppColors.accentGreen : null,
          ),
        ),
      ],
    );
  }
}
