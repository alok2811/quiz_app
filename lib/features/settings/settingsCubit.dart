//State
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ayuprep/features/settings/settingsModel.dart';
import 'package:ayuprep/features/settings/settingsRepository.dart';

class SettingsState {
  final SettingsModel? settingsModel;
  SettingsState({this.settingsModel});
}

class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository _settingsRepository;
  SettingsCubit(this._settingsRepository) : super(SettingsState()) {
    _getCurrentSettings();
  }

  void _getCurrentSettings() {
    emit(SettingsState(settingsModel: SettingsModel.fromJson(_settingsRepository.getCurrentSettings())));
  }

  SettingsModel getSettings() {
    return state.settingsModel!;
  }

  void changeShowIntroSlider() {
    _settingsRepository.changeIntroSlider(false);
    emit(SettingsState(settingsModel: state.settingsModel!.copyWith(showIntroSlider: false)));
  }

  void changeSound(bool value) {
    _settingsRepository.changeSound(value);
    emit(SettingsState(settingsModel: state.settingsModel!.copyWith(sound: value)));
  }

  void changeBackgroundMusic(bool value) {
    _settingsRepository.changeBackgroundMusic(value);
    emit(SettingsState(settingsModel: state.settingsModel!.copyWith(backgroundMusic: value)));
  }

  void changeVibration(bool value) {
    _settingsRepository.changeVibration(value);
    emit(SettingsState(settingsModel: state.settingsModel!.copyWith(vibration: value)));
  }

  void changeFontSize(double value) {
    _settingsRepository.changePlayAreaFontSize(value);
    emit(SettingsState(settingsModel: state.settingsModel!.copyWith(playAreaFontSize: value)));
  }

  String? getLanguageCode() {
    return state.settingsModel!.languageCode;
  }
}
