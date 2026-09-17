import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final steps = [
      {'step': 'STEP 1', 'title': 'Inspect the Board', 'desc': 'Look closely at the directional arrows pointing UP, DOWN, LEFT, or RIGHT.'},
      {'step': 'STEP 2', 'title': 'Find an Unblocked Arrow', 'desc': 'An arrow can escape only when its forward exit ray towards the board edge has NO obstacles.'},
      {'step': 'STEP 3', 'title': 'Tap to Escape', 'desc': 'Tap the unblocked arrow. It will slide smoothly off the board!'},
      {'step': 'STEP 4', 'title': 'Unravel New Paths', 'desc': 'Clearing an arrow opens up exit paths for arrows that were previously trapped behind it.'},
      {'step': 'STEP 5', 'title': 'Use Boosters Wisely', 'desc': 'Need a hand? Use Hint (💡) to highlight a guaranteed move, or Undo (↶) to reverse a misstep.'},
      {'step': 'STEP 6', 'title': 'Clear the Entire Board', 'desc': 'Conquer all arrows without exhausting your 3 lives to achieve a 3-star victory!'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('HOW TO PLAY')),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: steps.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final s = steps[index];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    s['step']!,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.primaryBlue),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 4),
                      Text(
                        s['desc']!,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
