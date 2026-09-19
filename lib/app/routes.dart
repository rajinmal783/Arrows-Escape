import 'package:go_router/go_router.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/login/login_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/levels/level_select_screen.dart';
import '../screens/gameplay/gameplay_screen.dart';
import '../screens/daily/daily_challenge_screen.dart';
import '../screens/leaderboard/leaderboard_screen.dart';
import '../screens/achievements/achievements_screen.dart';
import '../screens/shop/shop_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/help/help_screen.dart';
import '../screens/privacy/privacy_screen.dart';
import '../screens/not_found_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  errorBuilder: (context, state) => const NotFoundScreen(),
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/levels',
      builder: (context, state) => const LevelSelectScreen(),
    ),
    GoRoute(
      path: '/game/:id',
      builder: (context, state) {
        final levelId = int.tryParse(state.pathParameters['id'] ?? '1') ?? 1;
        return GameplayScreen(levelId: levelId);
      },
    ),
    GoRoute(
      path: '/daily',
      builder: (context, state) => const DailyChallengeScreen(),
    ),
    GoRoute(
      path: '/daily-play',
      builder: (context, state) => const GameplayScreen(levelId: 0, isDaily: true),
    ),
    GoRoute(
      path: '/leaderboard',
      builder: (context, state) => const LeaderboardScreen(),
    ),
    GoRoute(
      path: '/achievements',
      builder: (context, state) => const AchievementsScreen(),
    ),
    GoRoute(
      path: '/shop',
      builder: (context, state) => const ShopScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/help',
      builder: (context, state) => const HelpScreen(),
    ),
    GoRoute(
      path: '/privacy',
      builder: (context, state) => const PrivacyScreen(),
    ),
  ],
);
