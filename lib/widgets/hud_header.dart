import 'package:flutter/material.dart';
import 'heart_indicator.dart';
import '../core/constants/app_colors.dart';

class HudHeader extends StatelessWidget {
  final int levelId;
  final String difficulty;
  final int lives;
  final VoidCallback onBack;
  final VoidCallback onSettings;
  final bool isDaily;

  const HudHeader({
    super.key,
    required this.levelId,
    required this.difficulty,
    required this.lives,
    required this.onBack,
    required this.onSettings,
    this.isDaily = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 22),
            splashRadius: 24,
          ),

          // Central Level & Difficulty Display
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isDaily ? 'DAILY PUZZLE' : 'LEVEL $levelId',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  difficulty.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryBlue,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),

          // Lives & Settings
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              HeartIndicator(lives: lives),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onSettings,
                icon: const Icon(Icons.settings_outlined, size: 24),
                splashRadius: 24,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
