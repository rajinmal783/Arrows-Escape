class AppConstants {
  static const String appName = 'Arrow Escape';
  static const String appTagline = 'Think. Tap. Escape.';
  static const String appVersion = '1.0.0';

  // Supabase Configuration
  static const String supabaseUrl = 'https://pgenjibinbnyumpslvsp.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBnZW5qaWJpbmJueXVtcHNsdnNwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQyNjI3NzUsImV4cCI6MjA5OTgzODc3NX0.3YlsG4v1jQBZ2xa9nYYFxXbiF7qYzniUnwmyTkWp0-c';

  // Total Levels
  static const int totalLevels = 500;

  // Level Tiers
  static const int beginnerMax = 100;
  static const int normalMax = 200;
  static const int hardMax = 300;
  static const int superHardMax = 400;
  static const int masterMax = 500;

  // Boosters Defaults
  static const int defaultHints = 3;
  static const int defaultUndos = 3;
  static const int defaultLives = 3;

  // Virtual Coin Store Pricing
  static const int priceHintRefill = 50;
  static const int priceUndoRefill = 40;
  static const int priceExtraLife = 30;

  // Local Storage Keys
  static const String keyUserProgress = 'arrow_escape_user_progress';
  static const String keyUserSettings = 'arrow_escape_user_settings';
  static const String keyOfflineSyncQueue = 'arrow_escape_sync_queue';
  static const String keyCachedProfile = 'arrow_escape_cached_profile';
  static const String keyUnlockedThemes = 'arrow_escape_unlocked_themes';
  static const String keyActiveTheme = 'arrow_escape_active_theme';
  static const String keyLastDailyDate = 'arrow_escape_last_daily_date';
}
