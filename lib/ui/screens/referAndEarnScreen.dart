import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ayuprep/app/appLocalization.dart';
import 'package:ayuprep/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:ayuprep/features/systemConfig/cubits/systemConfigCubit.dart';
import 'package:ayuprep/ui/widgets/customBackButton.dart';
import 'package:ayuprep/ui/widgets/customRoundedButton.dart';
import 'package:ayuprep/ui/widgets/pageBackgroundGradientContainer.dart';
import 'package:ayuprep/utils/stringLabels.dart';

import 'package:ayuprep/utils/uiUtils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

class ReferAndEarnScreen extends StatelessWidget {
  ReferAndEarnScreen({Key? key}) : super(key: key);

  final verticalSpace = 20.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top,
        ),
        child: Stack(
          children: [
            PageBackgroundGradientContainer(),
            Platform.isIOS
                ? Container(
                    padding: EdgeInsets.only(left: 10),
                    alignment: Alignment.topLeft,
                    child: CustomBackButton(
                      iconColor: Theme.of(context).primaryColor,
                    ))
                : Container(),
            Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * (0.75),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height * (0.3),
                        child: SvgPicture.asset(
                            UiUtils.getImagePath("refer_earn.svg")),
                      ),
                      Transform.translate(
                        offset: Offset(0.0, -10.0),
                        child: Text(
                          AppLocalization.of(context)!
                              .getTranslatedValues("referAndEarn")!,
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 22.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          child: Text(
                            "${AppLocalization.of(context)!.getTranslatedValues("referFrdLbl")!} ${AppLocalization.of(context)!.getTranslatedValues(youWillGetKey)!} ${context.read<SystemConfigCubit>().getEarnCoin()} ${AppLocalization.of(context)!.getTranslatedValues(coinsLbl)!.toLowerCase()}. ${AppLocalization.of(context)!.getTranslatedValues(theyWillGetKey)!} ${context.read<SystemConfigCubit>().getReferCoin()} ${AppLocalization.of(context)!.getTranslatedValues(coinsLbl)!.toLowerCase()}.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        child:
                            SvgPicture.asset(UiUtils.getImagePath("steps.svg")),
                        height: MediaQuery.of(context).size.height * (0.2),
                      ),
                      Text(
                        AppLocalization.of(context)!
                            .getTranslatedValues("yourRefCOdeLbl")!,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 22.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: verticalSpace,
                      ),
                      Center(
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15.0),
                              border: Border.all(
                                color: Theme.of(context).primaryColor,
                              )),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 15.0,
                              ),
                              Text(
                                context
                                    .read<UserDetailsCubit>()
                                    .getUserProfile()
                                    .referCode!,
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Spacer(),
                              GestureDetector(
                                onTap: () async {
                                  await Clipboard.setData(ClipboardData(
                                      text: context
                                          .read<UserDetailsCubit>()
                                          .getUserProfile()
                                          .referCode!));
                                  UiUtils.setSnackbar(
                                      AppLocalization.of(context)!
                                          .getTranslatedValues(
                                              "referCodeCopyMsg")!,
                                      context,
                                      false);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15.0),
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  child: Transform.scale(
                                      scale: 0.4,
                                      child: SvgPicture.asset(
                                          UiUtils.getImagePath(
                                              "copy_icon.svg"))),
                                  width: 50.0,
                                ),
                              ),
                            ],
                          ),
                          height: 60.0,
                        ),
                      ),
                      SizedBox(
                        height: verticalSpace,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width * (0)),
                        child: CustomRoundedButton(
                          onTap: () {
                            Share.share(context
                                .read<UserDetailsCubit>()
                                .getUserProfile()
                                .referCode!);
                          },
                          widthPercentage:
                              MediaQuery.of(context).size.width * (0.7),
                          backgroundColor: Theme.of(context).primaryColor,
                          titleColor: Theme.of(context).backgroundColor,
                          buttonTitle: AppLocalization.of(context)!
                              .getTranslatedValues("shareNowLbl")!,
                          radius: 15.0,
                          textSize: 18.0,
                          showBorder: false,
                          fontWeight: FontWeight.bold,
                          height: 60.0,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
