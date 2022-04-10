import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ayuprep/app/appLocalization.dart';
import 'package:ayuprep/features/auth/cubits/authCubit.dart';
import 'package:ayuprep/features/auth/cubits/referAndEarnCubit.dart';
import 'package:ayuprep/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:ayuprep/ui/widgets/customRoundedButton.dart';
import 'package:ayuprep/utils/errorMessageKeys.dart';

import 'package:ayuprep/utils/uiUtils.dart';

class ReferralCodeBottomSheetContainer extends StatefulWidget {
  final ReferAndEarnCubit referAndEarnCubit;
  ReferralCodeBottomSheetContainer({Key? key, required this.referAndEarnCubit}) : super(key: key);

  @override
  _ReferralCodeBottomSheetContainerState createState() => _ReferralCodeBottomSheetContainerState();
}

class _ReferralCodeBottomSheetContainerState extends State<ReferralCodeBottomSheetContainer> {
  final TextEditingController textEditingController = TextEditingController();
  late String errorMessage = "";

  String _buildButtonTitle(ReferAndEarnState state) {
    if (state is ReferAndEarnProgress) {
      return AppLocalization.of(context)!.getTranslatedValues("submittingButton")!;
    }
    if (state is ReferAndEarnFailure) {
      return AppLocalization.of(context)!.getTranslatedValues("retryLbl")!;
    }
    return AppLocalization.of(context)!.getTranslatedValues("submitBtn")!;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReferAndEarnCubit, ReferAndEarnState>(
      bloc: widget.referAndEarnCubit,
      listener: (context, state) {
        if (state is ReferAndEarnSuccess) {
          context.read<UserDetailsCubit>().updateCoins(addCoin: true, coins: int.parse(state.userProfile.coins!));
        }
        if (state is ReferAndEarnFailure) {
          setState(() {
            errorMessage = AppLocalization.of(context)!.getTranslatedValues(convertErrorCodeToLanguageKey(state.errorMessage))!;
          });
        }
      },
      child: WillPopScope(
        onWillPop: () {
          if (widget.referAndEarnCubit.state is ReferAndEarnProgress) {
            return Future.value(false);
          }
          return Future.value(true);
        },
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
              gradient: UiUtils.buildLinerGradient([Theme.of(context).scaffoldBackgroundColor, Theme.of(context).canvasColor], Alignment.topCenter, Alignment.bottomCenter)),
          child: Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: EdgeInsets.all(10.0),
                  alignment: Alignment.centerRight,
                  child: IconButton(
                      onPressed: () {
                        if (widget.referAndEarnCubit.state is! ReferAndEarnProgress) {
                          Navigator.of(context).pop();
                        }
                      },
                      icon: Icon(
                        Icons.close,
                        size: 28.0,
                        color: Theme.of(context).primaryColor,
                      )),
                ),

                Container(
                  alignment: Alignment.center,
                  child: Text(
                    AppLocalization.of(context)!.getTranslatedValues('referralCodeLbl')!,
                    style: TextStyle(fontSize: 20.0, color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: 15.0,
                ),
                //
                Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * (0.125),
                  ),
                  padding: EdgeInsets.only(left: 20.0),
                  height: 60.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Theme.of(context).backgroundColor,
                  ),
                  child: TextField(
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    controller: textEditingController,
                    decoration: InputDecoration(
                      hintText: AppLocalization.of(context)!.getTranslatedValues('enterReferralCodeLbl')!,
                      hintStyle: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * (0.02),
                ),

                AnimatedSwitcher(
                  duration: Duration(milliseconds: 250),
                  child: errorMessage.isEmpty
                      ? SizedBox(
                          height: 20.0,
                        )
                      : Container(
                          height: 20.0,
                          child: Text(
                            errorMessage,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                ),

                SizedBox(
                  height: MediaQuery.of(context).size.height * (0.02),
                ),
                //

                BlocBuilder<ReferAndEarnCubit, ReferAndEarnState>(
                  bloc: widget.referAndEarnCubit,
                  builder: (context, state) {
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * (0.3),
                      ),
                      child: CustomRoundedButton(
                        widthPercentage: MediaQuery.of(context).size.width,
                        backgroundColor: Theme.of(context).primaryColor,
                        buttonTitle: _buildButtonTitle(state),
                        radius: 10.0,
                        showBorder: false,
                        onTap: () {
                          if (state is! ReferAndEarnProgress) {
                            widget.referAndEarnCubit.getReward(
                              name: "",
                              userProfile: context.read<UserDetailsCubit>().getUserProfile(),
                              friendReferralCode: textEditingController.text.trim(),
                              authType: context.read<AuthCubit>().getAuthProvider(),
                            );
                          }
                        },
                        fontWeight: FontWeight.bold,
                        titleColor: Theme.of(context).backgroundColor,
                        height: 40.0,
                      ),
                    );
                  },
                ),

                //
                SizedBox(
                  height: MediaQuery.of(context).size.height * (0.05),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
