import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ayuprep/app/appLocalization.dart';
import 'package:ayuprep/features/profileManagement/cubits/updateUserDetailsCubit.dart';
import 'package:ayuprep/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:ayuprep/ui/widgets/customRoundedButton.dart';
import 'package:ayuprep/utils/errorMessageKeys.dart';
import 'package:ayuprep/utils/uiUtils.dart';
import 'package:ayuprep/utils/validators.dart';

class EditProfileFieldBottomSheetContainer extends StatefulWidget {
  final String
      fieldTitle; //value of fieldTitle will be from :  Email,Mobile Number,Name
  final String fieldValue; //
  final bool numericKeyboardEnable;
  final UpdateUserDetailCubit updateUserDetailCubit;
  //To determine if to close bottom sheet without updating name or not
  final bool canCloseBottomSheet;
  EditProfileFieldBottomSheetContainer(
      {Key? key,
      required this.fieldTitle,
      required this.fieldValue,
      required this.canCloseBottomSheet,
      required this.numericKeyboardEnable,
      required this.updateUserDetailCubit})
      : super(key: key);

  @override
  _EditProfileFieldBottomSheetContainerState createState() =>
      _EditProfileFieldBottomSheetContainerState();
}

class _EditProfileFieldBottomSheetContainerState
    extends State<EditProfileFieldBottomSheetContainer> {
  late TextEditingController textEditingController =
      TextEditingController(text: widget.fieldValue);

  late String errorMessage = "";

  String _buildButtonTitle(UpdateUserDetailState state) {
    if (state is UpdateUserDetailInProgress) {
      return AppLocalization.of(context)!.getTranslatedValues("updatingLbl")!;
    }
    if (state is UpdateUserDetailFailure) {
      return AppLocalization.of(context)!.getTranslatedValues("retryLbl")!;
    }
    return AppLocalization.of(context)!.getTranslatedValues("updateLbl")!;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UpdateUserDetailCubit, UpdateUserDetailState>(
      bloc: widget.updateUserDetailCubit,
      listener: (context, state) {
        if (state is UpdateUserDetailSuccess) {
          context.read<UserDetailsCubit>().updateUserProfile(
                email: widget.fieldTitle == "Email"
                    ? textEditingController.text.trim()
                    : null,
                mobile: widget.fieldTitle == "Mobile Number"
                    ? textEditingController.text.trim()
                    : null,
                name: widget.fieldTitle == "Name"
                    ? textEditingController.text.trim()
                    : null,
              );
          Navigator.of(context).pop();
        } else if (state is UpdateUserDetailFailure) {
          if (state.errorMessage == unauthorizedAccessCode) {
            UiUtils.showAlreadyLoggedInDialog(context: context);
            return;
          }
          setState(() {
            errorMessage = AppLocalization.of(context)!.getTranslatedValues(
                convertErrorCodeToLanguageKey(state.errorMessage))!;
          });
        }
      },
      child: WillPopScope(
        onWillPop: () {
          if (widget.canCloseBottomSheet) {
            if (widget.updateUserDetailCubit.state
                is UpdateUserDetailInProgress) {
              return Future.value(false);
            }
            return Future.value(true);
          } else {
            return Future.value(false);
          }
        },
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
              gradient: UiUtils.buildLinerGradient([
                Theme.of(context).scaffoldBackgroundColor,
                Theme.of(context).canvasColor
              ], Alignment.topCenter, Alignment.bottomCenter)),
          child: Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      margin: EdgeInsets.all(10.0),
                      alignment: Alignment.centerRight,
                      child: IconButton(
                          onPressed: () {
                            //
                            if (!widget.canCloseBottomSheet) {
                              return;
                            }
                            if (widget.updateUserDetailCubit.state
                                is! UpdateUserDetailInProgress) {
                              Navigator.of(context).pop();
                            }
                          },
                          icon: Icon(
                            Icons.close,
                            size: 28.0,
                            color: Theme.of(context).primaryColor,
                          )),
                    ),
                  ],
                ),
                Container(
                  alignment: Alignment.center,
                  child: Text(
                    "${widget.fieldTitle}",
                    style: TextStyle(
                        fontSize: 20.0,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold),
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
                  padding: EdgeInsetsDirectional.only(start: 20.0),
                  height: 60.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Theme.of(context).backgroundColor,
                  ),
                  child: TextField(
                    controller: textEditingController,
                    keyboardType: widget.numericKeyboardEnable
                        ? TextInputType.number
                        : TextInputType.text,
                    decoration: InputDecoration(
                      hintText: "Enter your ${widget.fieldTitle.toLowerCase()}",
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
                BlocBuilder<UpdateUserDetailCubit, UpdateUserDetailState>(
                  bloc: widget.updateUserDetailCubit,
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
                        onTap: state is UpdateUserDetailInProgress
                            ? () {}
                            : () {
                                if (errorMessage.isNotEmpty) {
                                  setState(() {
                                    errorMessage = "";
                                  });
                                }
                                final userProfile = context
                                    .read<UserDetailsCubit>()
                                    .getUserProfile();
                                //means it is not
                                if (widget.fieldTitle == "Mobile Number") {
                                  //Email,Mobile Number,Name
                                  if (!Validators.isCorrectMobileNumber(
                                      textEditingController.text.trim())) {
                                    setState(() {
                                      errorMessage = AppLocalization.of(
                                              context)!
                                          .getTranslatedValues("validMobMsg")!;
                                    });
                                    //showDialog(context: context, builder: (_) => ErrorMessageDialog(errorMessage: "Please enter valid number"));
                                    return;
                                  }
                                } else if (widget.fieldTitle == "Email") {
                                  if (!Validators.isValidEmail(
                                      textEditingController.text.trim())) {
                                    //showDialog(context: context, builder: (_) => ErrorMessageDialog(errorMessage: "Please enter valid email"));
                                    setState(() {
                                      errorMessage =
                                          AppLocalization.of(context)!
                                              .getTranslatedValues(
                                                  "enterValidEmailMsg")!;
                                    });
                                    return;
                                  }
                                }

                                widget.updateUserDetailCubit.updateProfile(
                                  userId: context
                                      .read<UserDetailsCubit>()
                                      .getUserId(),
                                  email: widget.fieldTitle == "Email"
                                      ? textEditingController.text.trim()
                                      : userProfile.email ?? "",
                                  mobile: widget.fieldTitle == "Mobile Number"
                                      ? textEditingController.text.trim()
                                      : userProfile.mobileNumber ?? "",
                                  name: widget.fieldTitle == "Name"
                                      ? textEditingController.text.trim()
                                      : userProfile.name ?? "",
                                );
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
