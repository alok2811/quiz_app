import 'package:ayuprep/features/settings/settingsLocalDataSource.dart';

class SettingsRepository {
  static final SettingsRepository _settingsRepository = SettingsRepository._internal();
  late SettingsLocalDataSource _settingsLocalDataSource;

  factory SettingsRepository() {
    _settingsRepository._settingsLocalDataSource = SettingsLocalDataSource();
    return _settingsRepository;
  }

  SettingsRepository._internal();

  Map<String, dynamic> getCurrentSettings() {
    return {
      "showIntroSlider": _settingsLocalDataSource.showIntroSlider(),
      "backgroundMusic": _settingsLocalDataSource.backgroundMusic(),
      "sound": _settingsLocalDataSource.sound(),
      "rewardEarned": _settingsLocalDataSource.rewardEarned(),
      "vibration": _settingsLocalDataSource.vibration(),
      "languageCode": _settingsLocalDataSource.languageCode(),
      "theme": _settingsLocalDataSource.theme(),
      "playAreaFontSize": _settingsLocalDataSource.playAreaFontSize()
    };
  }

  void changeIntroSlider(bool value) => _settingsLocalDataSource.setShowIntroSlider(value);

  void changeSound(bool value) => _settingsLocalDataSource.setSound(value);

  void changeVibration(bool value) => _settingsLocalDataSource.setVibration(value);

  void changeBackgroundMusic(bool value) => _settingsLocalDataSource.setbackgroundMusic(value);

  void changeQuestionLanguageId(String value) => _settingsLocalDataSource.setLanguageCode(value);

  void changePlayAreaFontSize(double value) => _settingsLocalDataSource.setPlayAreaFontSize(value);
}
