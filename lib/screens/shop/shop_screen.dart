import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/profile_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/storage_provider.dart';

class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final activeTheme = ref.watch(activeCosmeticThemeProvider);
    final storage = ref.watch(localStorageProvider);
    final unlockedThemes = storage.getUnlockedThemes();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SHOP'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.accentAmber.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.monetization_on_rounded, color: AppColors.accentAmber, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      '${profile.coins}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.accentAmber),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: Boosters
            const Text(
              'GAMEPLAY BOOSTERS',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.8),
            ),
            const SizedBox(height: 12),

            _buildBoosterTile(
              context: context,
              ref: ref,
              title: '3x Hints Refill',
              subtitle: 'Reveals guaranteed valid moves',
              icon: Icons.lightbulb_outline_rounded,
              cost: 50,
              isDark: isDark,
              onBuy: () async {
                final ok = await ref.read(profileProvider.notifier).spendCoins(50);
                if (ok && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Purchased 3x Hints!')),
                  );
                } else if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Not enough coins! Complete more levels.')),
                  );
                }
              },
            ),
            const SizedBox(height: 10),

            _buildBoosterTile(
              context: context,
              ref: ref,
              title: '3x Undo Refill',
              subtitle: 'Revert any mistake with ease',
              icon: Icons.undo_rounded,
              cost: 40,
              isDark: isDark,
              onBuy: () async {
                final ok = await ref.read(profileProvider.notifier).spendCoins(40);
                if (ok && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Purchased 3x Undos!')),
                  );
                } else if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Not enough coins!')),
                  );
                }
              },
            ),
            const SizedBox(height: 28),

            // Section 2: Cosmetic Themes
            const Text(
              'COSMETIC THEMES',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.8),
            ),
            const SizedBox(height: 12),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.85,
              ),
              itemCount: AppColors.cosmeticThemes.length,
              itemBuilder: (context, index) {
                final entry = AppColors.cosmeticThemes.entries.elementAt(index);
                final key = entry.key;
                final palette = entry.value;
                final isUnlocked = unlockedThemes.contains(key);
                final isActive = activeTheme == key;
                final cost = key == 'classic' ? 0 : (150 + index * 50);

                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isActive ? AppColors.primaryBlue : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                      width: isActive ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Palette preview swatches
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: palette.bgLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.withOpacity(0.3)),
                        ),
                        child: Center(
                          child: Icon(Icons.arrow_forward_rounded, color: palette.lineLight, size: 28),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(palette.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const Spacer(),

                      // Equip or Buy Button
                      SizedBox(
                        width: double.infinity,
                        height: 36,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (isUnlocked) {
                              await ref.read(activeCosmeticThemeProvider.notifier).setTheme(key);
                            } else {
                              final ok = await ref.read(profileProvider.notifier).spendCoins(cost);
                              if (ok) {
                                await storage.unlockTheme(key);
                                await ref.read(activeCosmeticThemeProvider.notifier).setTheme(key);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Unlocked ${palette.name} Theme!')),
                                  );
                                }
                              } else if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Not enough coins!')),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isActive
                                ? AppColors.accentGreen
                                : (isUnlocked ? AppColors.primaryBlue : AppColors.cardDark),
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text(
                            isActive
                                ? 'Active'
                                : (isUnlocked ? 'Equip' : '$cost 🪙'),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBoosterTile({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required String subtitle,
    required IconData icon,
    required int cost,
    required bool isDark,
    required VoidCallback onBuy,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.primaryBlue, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onBuy,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentAmber,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              '$cost 🪙',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
