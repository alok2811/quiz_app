import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ayuprep/app/appLocalization.dart';
import 'package:ayuprep/features/settings/settingsCubit.dart';
import 'package:ayuprep/ui/screens/battle/widgets/customDialog.dart';
import 'package:ayuprep/utils/stringLabels.dart';
import 'package:ayuprep/utils/uiUtils.dart';
import 'fontSizeDialog.dart';

class SettingsDialogContainer extends StatelessWidget {
  SettingsDialogContainer({Key? key}) : super(key: key);

  late final List<SettingItem> settingItems = [
    SettingItem(icon: UiUtils.getImagePath("sound_icon.svg"), showSwitch: true, title: soundLbl),
    SettingItem(icon: UiUtils.getImagePath("vibrate_icon.svg"), showSwitch: true, title: vibrationLbl),
    SettingItem(icon: UiUtils.getImagePath("fontsize_icon.svg"), showSwitch: false, title: fontSizeLbl),
  ];
  Widget _buildSettingsItem(int settingItemIndex, BuildContext context) {
    final sizedBoxHeight = 2.5;
    return Container(
      padding: EdgeInsets.only(top: 10.0, left: 20.0, right: 20.0),
      child: GestureDetector(
        onTap: () {
          if (settingItemIndex == 0) {
            context.read<SettingsCubit>().changeSound(!context.read<SettingsCubit>().state.settingsModel!.sound);
          } else if (settingItemIndex == 1) {
            context.read<SettingsCubit>().changeVibration(!context.read<SettingsCubit>().state.settingsModel!.vibration);
          } else if (settingItemIndex == 2) {
            Navigator.of(context).pop();
            showDialog(context: context, builder: (_) => FontSizeDialog(bloc: context.read<SettingsCubit>()));
          }
        },
        child: Column(
          children: [
            SizedBox(
              height: sizedBoxHeight,
            ),
            Row(
              children: [
                SizedBox(
                  width: 15.0,
                ),
                Container(
                  width: 30.0,
                  height: 27.0,
                  transform: Matrix4.identity()..scale(0.8),
                  child: SvgPicture.asset(
                    settingItems[settingItemIndex].icon!,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(
                  width: 15.0,
                ),
                Text(
                  "${AppLocalization.of(context)!.getTranslatedValues(settingItems[settingItemIndex].title)}",
                  style: TextStyle(fontSize: 16, color: Theme.of(context).primaryColor),
                ),
                settingItems[settingItemIndex].showSwitch! ? Spacer() : Container(),
                settingItems[settingItemIndex].showSwitch!
                    ? Transform.translate(
                        offset: Offset(10.0, 0.0),
                        child: Container(
                            height: 27.50,
                            child: Transform.scale(
                              scale: 0.6,
                              child: BlocBuilder<SettingsCubit, SettingsState>(
                                bloc: context.read<SettingsCubit>(),
                                builder: (context, state) {
                                  bool? value = false;

                                  //see this values in settingItems list
                                  if (settingItemIndex == 0) {
                                    value = state.settingsModel!.sound;
                                  } else if (settingItemIndex == 1) {
                                    value = state.settingsModel!.vibration;
                                  }
                                  return CupertinoSwitch(
                                    value: value,
                                    activeColor: Theme.of(context).primaryColor,
                                    onChanged: (value) {
                                      //see this values in settingItems list
                                      if (settingItemIndex == 0) {
                                        context.read<SettingsCubit>().changeSound(value);
                                      } else if (settingItemIndex == 1) {
                                        context.read<SettingsCubit>().changeVibration(value);
                                      }
                                    },
                                  );
                                },
                              ),
                            )),
                      )
                    : Container()
              ],
            ),
            SizedBox(
              height: sizedBoxHeight,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsContainer(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: settingItems.map((e) {
        int index = settingItems.indexOf(e);
        return _buildSettingsItem(index, context);
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      height: MediaQuery.of(context).size.height * 0.35,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(UiUtils.dailogRadius), gradient: UiUtils.buildLinerGradient([Theme.of(context).scaffoldBackgroundColor, Theme.of(context).canvasColor], Alignment.topCenter, Alignment.bottomCenter)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * (0.025),
            ),
            Text(AppLocalization.of(context)!.getTranslatedValues("settingLbl")!, style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(
              height: MediaQuery.of(context).size.height * (0.025),
            ),
            _buildSettingsContainer(context),
          ],
        ),
      ),
    );
  }
}

class SettingItem {
  final String? icon;
  final String? title;
  final bool? showSwitch;

  SettingItem({this.icon, this.showSwitch, this.title});
}
