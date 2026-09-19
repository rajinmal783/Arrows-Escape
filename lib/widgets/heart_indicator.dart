import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class HeartIndicator extends StatelessWidget {
  final int lives;
  final int maxLives;

  const HeartIndicator({
    super.key,
    required this.lives,
    this.maxLives = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxLives, (index) {
        final isFilled = index < lives;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          child: Icon(
            isFilled ? Icons.favorite : Icons.favorite_border,
            color: isFilled ? AppColors.accentRed : Colors.grey.withAlpha(102),
            size: 24,
          ),
        );
      }),
    );
  }
}
