import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ayuprep/features/systemConfig/systemConfigRepository.dart';

abstract class AppSettingsState {}

class AppSettingsIntial extends AppSettingsState {}

class AppSettingsFetchInProgress extends AppSettingsState {}

class AppSettingsFetchSuccess extends AppSettingsState {
  final String settingsData;

  AppSettingsFetchSuccess(this.settingsData);
}

class AppSettingsFetchFailure extends AppSettingsState {
  final String errorCode;

  AppSettingsFetchFailure(this.errorCode);
}

class AppSettingsCubit extends Cubit<AppSettingsState> {
  final SystemConfigRepository _systemConfigRepository;

  AppSettingsCubit(this._systemConfigRepository) : super(AppSettingsIntial());

  void getAppSetting(String type) {
    emit(AppSettingsFetchInProgress());
    _systemConfigRepository.getAppSettings(type).then((value) => emit(AppSettingsFetchSuccess(value))).catchError((e) {
      emit(AppSettingsFetchFailure(e.toString()));
    });
  }
}
