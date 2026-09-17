import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('PRIVACY POLICY')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('ARROW ESCAPE PRIVACY COMMITMENT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              Text(
                'Arrow Escape respects your personal privacy. We collect minimal user information necessary for cloud game synchronization, leaderboards, and achievements.\n\n'
                '• Authentication: When signing in with Google OAuth, we store your public profile name, avatar, and email exclusively for authentication session persistence.\n\n'
                '• Gameplay Progress: Solved levels, star counts, high scores, and achievement unlock states are stored in encrypted Supabase cloud databases protected by Row Level Security (RLS).\n\n'
                '• Virtual Currency: All coins and boosters in the game are strictly virtual game tokens and hold zero real-world cash value.\n\n'
                '• Data Isolation: Row Level Security prevents any user from modifying or querying unauthorized records.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
