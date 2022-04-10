import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ayuprep/app/appLocalization.dart';
import 'package:ayuprep/features/systemConfig/cubits/systemConfigCubit.dart';

import 'package:ayuprep/utils/stringLabels.dart';
import 'package:ayuprep/utils/uiUtils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateAppContainer extends StatelessWidget {
  const UpdateAppContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: UiUtils.dailogBlurSigma, sigmaY: UiUtils.dailogBlurSigma),
      child: Container(
        color: Colors.black45,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        alignment: Alignment.center,
        child: CupertinoAlertDialog(
          title: Text(
            AppLocalization.of(context)!.getTranslatedValues(warningKey)!,
            style: TextStyle(fontSize: 18),
          ),
          content: Padding(
            padding: EdgeInsets.only(
              top: 5.0,
            ),
            child: Text(
              AppLocalization.of(context)!.getTranslatedValues(updateApplicationKey)!,
              style: TextStyle(fontSize: 14.5),
            ),
          ),
          actions: [
            //CustomRoundedButton(widthPercentage: 0.5, backgroundColor: Theme., buttonTitle: buttonTitle, radius: radius, showBorder: showBorder, height: height,),
            CupertinoButton(
                onPressed: () async {
                  try {
                    String url = context.read<SystemConfigCubit>().getAppUrl();
                    if (url.isEmpty) {
                      UiUtils.setSnackbar(AppLocalization.of(context)!.getTranslatedValues(failedToGetAppUrlKey)!, context, false);

                      return;
                    }
                    bool canLaunchUrl = await canLaunch(url);
                    if (canLaunchUrl) {
                      launch(url);
                    }
                  } catch (e) {
                    UiUtils.setSnackbar(AppLocalization.of(context)!.getTranslatedValues(failedToGetAppUrlKey)!, context, false);
                  }
                },
                child: Text(
                  AppLocalization.of(context)!.getTranslatedValues(updateKey)!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
