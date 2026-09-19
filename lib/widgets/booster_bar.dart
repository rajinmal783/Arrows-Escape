import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class BoosterBar extends StatelessWidget {
  final int hints;
  final int undos;
  final bool gridVisible;
  final bool showGridToggle;
  final VoidCallback onHint;
  final VoidCallback onUndo;
  final VoidCallback onGridToggle;
  final VoidCallback onRestart;

  const BoosterBar({
    super.key,
    required this.hints,
    required this.undos,
    required this.gridVisible,
    this.showGridToggle = true,
    required this.onHint,
    required this.onUndo,
    required this.onGridToggle,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Restart Level
          _buildBoosterItem(
            icon: Icons.refresh_rounded,
            label: 'Restart',
            onTap: onRestart,
            isDark: isDark,
          ),

          // Undo Booster
          _buildBoosterItem(
            icon: Icons.undo_rounded,
            label: 'Undo',
            badgeCount: undos,
            onTap: onUndo,
            isDark: isDark,
          ),

          // Hint Booster
          _buildBoosterItem(
            icon: Icons.lightbulb_outline_rounded,
            label: 'Hint',
            badgeCount: hints,
            badgeColor: AppColors.accentAmber,
            onTap: onHint,
            isDark: isDark,
            isPrimary: true,
          ),

          // Grid Toggle Booster
          if (showGridToggle)
            _buildBoosterItem(
              icon: Icons.grid_4x4_rounded,
              label: 'Grid',
              isActive: gridVisible,
              onTap: onGridToggle,
              isDark: isDark,
            ),
        ],
      ),
    );
  }

  Widget _buildBoosterItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
    int? badgeCount,
    Color? badgeColor,
    bool isActive = false,
    bool isPrimary = false,
  }) {
    final bg = isPrimary
        ? AppColors.primaryBlue.withAlpha(31)
        : (isDark ? AppColors.surfaceDark : AppColors.cardLight);

    final iconColor = isPrimary
        ? AppColors.primaryBlue
        : (isActive ? AppColors.primaryBlue : (isDark ? Colors.white70 : Colors.black87));

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: bg,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isActive ? AppColors.primaryBlue : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: iconColor, size: 26),
                ),
                if (badgeCount != null)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: badgeColor ?? AppColors.primaryBlue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$badgeCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
