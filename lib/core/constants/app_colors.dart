import 'package:flutter/material.dart';

class AppColors {
  // Light Theme / Default Minimal Aesthetic
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFF1F5F9);
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);

  // Dark Theme Aesthetic
  static const Color backgroundDark = Color(0xFF0B1120);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color cardDark = Color(0xFF172033);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  // Maze & Puzzle Line Work
  static const Color puzzleLineLight = Color(0xFF172554); // Deep Navy
  static const Color puzzleLineSecondary = Color(0xFF1E293B);
  static const Color puzzleLineDark = Color(0xFFE2E8F0); // Crisp light line on dark

  // Accent & HUD Colors
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color accentCyan = Color(0xFF06B6D4);
  static const Color accentGreen = Color(0xFF10B981);
  static const Color accentAmber = Color(0xFFF59E0B);
  static const Color accentRed = Color(0xFFEF4444);
  static const Color accentPurple = Color(0xFF8B5CF6);

  // Gameplay Highlight states
  static const Color validMoveHighlight = Color(0xFF10B981);
  static const Color blockedMoveHighlight = Color(0xFFEF4444);
  static const Color hintPulseGlow = Color(0xFFF59E0B);
  static const Color gridDot = Color(0xFFCBD5E1);
  static const Color gridDotDark = Color(0xFF334155);

  // Cosmetic Themes
  static const Map<String, ThemePalette> cosmeticThemes = {
    'classic': ThemePalette(
      name: 'Classic',
      bgLight: Color(0xFFF8FAFC),
      lineLight: Color(0xFF172554),
      accent: Color(0xFF2563EB),
    ),
    'ocean': ThemePalette(
      name: 'Ocean',
      bgLight: Color(0xFFF0F9FF),
      lineLight: Color(0xFF0369A1),
      accent: Color(0xFF0284C7),
    ),
    'neon': ThemePalette(
      name: 'Neon',
      bgLight: Color(0xFF0D1117),
      lineLight: Color(0xFF00FFCC),
      accent: Color(0xFFFF007F),
    ),
    'forest': ThemePalette(
      name: 'Forest',
      bgLight: Color(0xFFF0FDF4),
      lineLight: Color(0xFF166534),
      accent: Color(0xFF22C55E),
    ),
    'sunset': ThemePalette(
      name: 'Sunset',
      bgLight: Color(0xFFFFF7ED),
      lineLight: Color(0xFF9A3412),
      accent: Color(0xFFF97316),
    ),
    'midnight': ThemePalette(
      name: 'Midnight',
      bgLight: Color(0xFF0F172A),
      lineLight: Color(0xFF38BDF8),
      accent: Color(0xFF818CF8),
    ),
    'galaxy': ThemePalette(
      name: 'Galaxy',
      bgLight: Color(0xFF180E29),
      lineLight: Color(0xFFA855F7),
      accent: Color(0xFFEC4899),
    ),
  };
}

class ThemePalette {
  final String name;
  final Color bgLight;
  final Color lineLight;
  final Color accent;

  const ThemePalette({
    required this.name,
    required this.bgLight,
    required this.lineLight,
    required this.accent,
  });
}
