class SettingsModel {
  final bool showIntroSlider;
  final bool sound;
  final bool backgroundMusic;
  final bool vibration;
  final String languageCode;
  final double playAreaFontSize;
  final bool rewardEarned;
  final String theme;

  SettingsModel({required this.playAreaFontSize, required this.rewardEarned, required this.backgroundMusic, required this.languageCode, required this.sound, required this.showIntroSlider, required this.vibration, required this.theme});

  static SettingsModel fromJson(var settingsJson) {
    //to see the json response go to getCurrentSettings() function in settingsRepository
    return SettingsModel(
        playAreaFontSize: settingsJson['playAreaFontSize'],
        theme: settingsJson['theme'],
        rewardEarned: settingsJson['rewardEarned'],
        backgroundMusic: settingsJson['backgroundMusic'],
        sound: settingsJson['sound'],
        showIntroSlider: settingsJson['showIntroSlider'],
        vibration: settingsJson['vibration'],
        languageCode: settingsJson['languageCode']);
  }

  SettingsModel copyWith({String? theme, bool? showIntroSlider, bool? sound, bool? backgroundMusic, bool? vibration, String? languageCode, double? playAreaFontSize, bool? rewardEarned}) {
    return SettingsModel(
        theme: theme ?? this.theme,
        rewardEarned: rewardEarned ?? this.rewardEarned,
        playAreaFontSize: playAreaFontSize ?? this.playAreaFontSize,
        backgroundMusic: backgroundMusic ?? this.backgroundMusic,
        sound: sound ?? this.sound,
        showIntroSlider: showIntroSlider ?? this.showIntroSlider,
        vibration: vibration ?? this.vibration,
        languageCode: languageCode ?? this.languageCode);
  }
}
