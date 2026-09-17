# 🏹 Arrow Escape
### *Think. Tap. Escape.*

A production-quality Flutter 2D logic puzzle game built for **Android**, **Web**, and **PWA**, powered by **Supabase** backend authentication and database with Row Level Security (RLS).

---

## 🌟 Game Overview

**Arrow Escape** is a minimalist, satisfying logic puzzle game. The player is presented with a board filled with intricate maze-like directional arrows pointing **UP**, **DOWN**, **LEFT**, or **RIGHT**.

- **The Core Rule**: An arrow can escape from the board **only when its complete path toward the corresponding edge is unobstructed**.
- **The Core Loop**: SEE → THINK → TAP → CLEAR → REVEAL → SOLVE → COMPLETE → REWARD → NEXT LEVEL.
- **Visual Aesthetic**: Warm light canvas (`#F8FAFC`), deep navy maze lines (`#172554`), rounded caps, geometric arrowheads, dark mode (`#0B1120`), and 7 unlockable cosmetic themes.

---

## 🚀 Key Features

1. **500 Playable Levels**:
   - **Beginner (1–100)**: Clean geometry, 6–12 arrows.
   - **Normal (101–200)**: Winding paths, 14–22 arrows.
   - **Hard (201–300)**: Intricate silhouettes, 24–36 arrows.
   - **Super Hard (301–400)**: Deep dependency chains, 38–54 arrows.
   - **Master (401–500)**: Grand master challenges, 56–80 arrows.
2. **Guaranteed 100% Solvability**:
   - Built with deterministic reverse-assembly generation.
   - Verified with an offline BFS/DFS puzzle solver.
3. **Boosters & Tools**:
   - 💡 **Hint**: Automatically discovers and pulses guaranteed valid moves.
   - ↶ **Undo**: Reverts moves with full board state restoration.
   - 🔲 **Grid**: Toggles subtle coordinate guidance dots.
   - ❤️ **Lives**: 3-heart mistake tolerance with friendly retries.
4. **Cloud & Offline-First Architecture**:
   - 100% playable offline with instant local storage (`SharedPreferences`).
   - Seamless background cloud synchronization with Supabase when online.
5. **Progression & Social**:
   - **XP & Player Leveling System** with dynamic rank formula.
   - **Virtual Coins** earned through level completions and challenges (no gambling, no pay-to-win).
   - **Daily Challenges**: Unique seeded daily puzzle per date with streak tracking (🔥).
   - **30 Achievements**: Catalog of unlockable milestones.
   - **Global Cloud Leaderboard**: Real-time rankings for Today, This Week, This Month, and All Time.
6. **Authentication**:
   - Supabase Auth + Google OAuth with guest play fallback.

---

## 🏗️ Architecture

```
lib/
├── app/
│   ├── app.dart                  # Riverpod root & MaterialApp.router
│   ├── routes.dart               # GoRouter paths & transitions
│   └── theme.dart                # Light, Dark & Cosmetic color schemes
├── core/
│   ├── constants/                # AppColors, AppConstants
│   └── audio/                    # Audio & Haptic feedback service
├── models/
│   ├── arrow.dart                # Arrow geometry & GridPoint
│   ├── puzzle_level.dart         # Level definitions
│   ├── game_state.dart           # Immutable gameplay state
│   ├── user_profile.dart         # Player XP, leveling, coins
│   ├── level_progress.dart       # High scores & star ratings
│   ├── achievement.dart          # 30 badge models
│   ├── daily_challenge.dart      # Daily seeded challenge
│   ├── leaderboard_entry.dart    # Cloud ranking records
│   └── inventory_item.dart       # Booster & theme inventory
├── game/
│   ├── move_validator.dart       # Unobstructed ray checks & collision detection
│   ├── puzzle_solver.dart        # BFS solver & solvability validation
│   ├── level_generator.dart      # Deterministic reverse-assembly generator
│   └── puzzle_painter.dart       # High-DPI anti-aliased CustomPainter
├── providers/
│   ├── auth_provider.dart        # Supabase Google OAuth & session
│   ├── game_provider.dart        # Active board controller & booster actions
│   ├── level_provider.dart       # Level unlocks & star records
│   ├── profile_provider.dart     # Player stats & reward transactions
│   ├── settings_provider.dart    # Sound, vibration, grid, theme, language
│   └── storage_provider.dart     # Service locator providers
├── screens/
│   ├── splash/                   # Animated splash screen
│   ├── login/                    # Google Sign-In & Guest login
│   ├── home/                     # Play CTA, daily card, navigation grid
│   ├── levels/                   # 500-level tabbed selection grid
│   ├── gameplay/                 # Main interactive puzzle canvas
│   ├── daily/                    # Seeded daily challenge & streak
│   ├── leaderboard/              # Filterable cloud leaderboard
│   ├── profile/                  # Player card, XP bar, lifetime stats
│   ├── achievements/             # 30 unlockable badges
│   ├── shop/                     # Booster refills & theme shop
│   ├── settings/                 # Sound, grid, theme, language controls
│   ├── help/                     # Interactive 6-step tutorial
│   └── privacy/                  # Privacy policy
├── services/
│   ├── supabase_service.dart     # Supabase client, queries & OAuth
│   ├── local_storage_service.dart# Offline persistence (SharedPreferences)
│   └── sync_service.dart         # Bidirectional cloud sync engine
└── widgets/
    ├── hud_header.dart           # Header HUD with hearts & settings
    ├── booster_bar.dart          # Hint, Undo, Grid buttons
    ├── puzzle_board_widget.dart  # Touch gesture mapping & painter host
    ├── level_complete_dialog.dart# 3-Star victory dialog
    └── level_failed_dialog.dart  # Friendly retry dialog
```

---

## 🗄️ Supabase Database & Security

### Tables & RLS Policies:
- **`profiles`**: User level, XP, coins, streak (`auth.uid() = id`).
- **`user_settings`**: Private settings (`auth.uid() = user_id`).
- **`levels_progress`**: Level completions and star ratings (`auth.uid() = user_id`).
- **`game_sessions`**: Session metrics and mistakes (`auth.uid() = user_id`).
- **`daily_challenges`**: Publicly readable date-seeded challenges.
- **`daily_challenge_results`**: User daily claims (`auth.uid() = user_id`).
- **`achievements`**: Pre-seeded 30 badges catalog.
- **`user_achievements`**: User unlocked badges (`auth.uid() = user_id`).
- **`user_inventory`**: Boosters and cosmetics (`auth.uid() = user_id`).
- **`leaderboard_entries`**: User high scores (`auth.uid() = user_id`).
- **`leaderboard_public_view`**: Safe public view exposing only username, avatar, score, and rank without private emails.

---

## 🌐 Web & Vercel Deployment

1. **Build Web**:
   ```bash
   flutter build web --release
   ```
2. **Deploy with Vercel**:
   - Root directory: `./`
   - Output directory: `build/web`
   - `vercel.json` is already configured for single-page routing rewrites so deep paths work seamlessly.

---

## 🧪 Testing

Run the full automated test suite:
```bash
flutter test
```
Includes:
- Ray collision & escape verification (`move_validator_test.dart`)
- Sequential dependency solving & circular deadlock detection (`puzzle_solver_test.dart`)
- Deterministic 500-level generation & solvability guarantees (`level_generator_test.dart`)
- Component widget tests (`widget_test.dart`).

---

## 📄 License
MIT License. Developed for Arrow Escape.
