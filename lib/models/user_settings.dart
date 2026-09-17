class UserSettings {
  final bool soundEnabled;
  final bool musicEnabled;
  final bool vibrationEnabled;
  final bool gridEnabled;
  final String theme;
  final String language;

  const UserSettings({
    this.soundEnabled = true,
    this.musicEnabled = true,
    this.vibrationEnabled = true,
    this.gridEnabled = false,
    this.theme = 'system',
    this.language = 'en',
  });

  Map<String, dynamic> toJson() => {
        'sound_enabled': soundEnabled,
        'music_enabled': musicEnabled,
        'vibration_enabled': vibrationEnabled,
        'grid_enabled': gridEnabled,
        'theme': theme,
        'language': language,
      };

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      soundEnabled: json['sound_enabled'] as bool? ?? true,
      musicEnabled: json['music_enabled'] as bool? ?? true,
      vibrationEnabled: json['vibration_enabled'] as bool? ?? true,
      gridEnabled: json['grid_enabled'] as bool? ?? false,
      theme: json['theme'] as String? ?? 'system',
      language: json['language'] as String? ?? 'en',
    );
  }

  UserSettings copyWith({
    bool? soundEnabled,
    bool? musicEnabled,
    bool? vibrationEnabled,
    bool? gridEnabled,
    String? theme,
    String? language,
  }) {
    return UserSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      gridEnabled: gridEnabled ?? this.gridEnabled,
      theme: theme ?? this.theme,
      language: language ?? this.language,
    );
  }
}
