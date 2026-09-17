import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/level_provider.dart';

class LevelSelectScreen extends ConsumerStatefulWidget {
  const LevelSelectScreen({super.key});

  @override
  ConsumerState<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends ConsumerState<LevelSelectScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _tiers = [
    'Beginner',
    'Normal',
    'Hard',
    'Super Hard',
    'Master',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tiers.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final levelState = ref.watch(levelProgressProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SELECT LEVEL'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.primaryBlue,
          unselectedLabelColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          indicatorColor: AppColors.primaryBlue,
          indicatorWeight: 3,
          tabs: _tiers.map((t) => Tab(text: t.toUpperCase())).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: List.generate(_tiers.length, (tierIndex) {
          final startLevel = tierIndex * 100 + 1;

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.9,
            ),
            itemCount: 100,
            itemBuilder: (context, index) {
              final levelId = startLevel + index;
              final isUnlocked = levelState.isLevelUnlocked(levelId);
              final progress = levelState.getProgress(levelId);
              final stars = progress?.stars ?? 0;
              final isCurrent = levelId == levelState.highestUnlockedLevel;

              return InkWell(
                onTap: isUnlocked ? () => context.push('/game/$levelId') : null,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? AppColors.primaryBlue.withOpacity(0.15)
                        : (isUnlocked
                            ? (isDark ? AppColors.surfaceDark : Colors.white)
                            : (isDark ? const Color(0xFF131B2E) : const Color(0xFFF1F5F9))),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isCurrent
                          ? AppColors.primaryBlue
                          : (isUnlocked
                              ? (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))
                              : Colors.transparent),
                      width: isCurrent ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!isUnlocked)
                        const Icon(Icons.lock_outline_rounded, size: 20, color: Colors.grey)
                      else ...[
                        Text(
                          '$levelId',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isCurrent
                                ? AppColors.primaryBlue
                                : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(3, (starIdx) {
                            final filled = starIdx < stars;
                            return Icon(
                              filled ? Icons.star_rounded : Icons.star_outline_rounded,
                              size: 11,
                              color: filled ? AppColors.accentAmber : Colors.grey.withOpacity(0.4),
                            );
                          }),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
