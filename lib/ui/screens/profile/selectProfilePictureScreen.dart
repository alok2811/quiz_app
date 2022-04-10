import 'dart:io';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ayuprep/app/appLocalization.dart';
import 'package:ayuprep/app/routes.dart';
import 'package:ayuprep/features/auth/authRepository.dart';
import 'package:ayuprep/features/auth/cubits/authCubit.dart';
import 'package:ayuprep/features/auth/cubits/referAndEarnCubit.dart';
import 'package:ayuprep/features/profileManagement/cubits/uploadProfileCubit.dart';
import 'package:ayuprep/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:ayuprep/features/profileManagement/models/userProfile.dart';
import 'package:ayuprep/features/profileManagement/profileManagementRepository.dart';
import 'package:ayuprep/features/systemConfig/cubits/systemConfigCubit.dart';
import 'package:ayuprep/ui/screens/profile/widgets/chooseProfileDialog.dart';
import 'package:ayuprep/ui/widgets/circularProgressContainner.dart';
import 'package:ayuprep/ui/widgets/errorContainer.dart';

import 'package:ayuprep/ui/widgets/pageBackgroundGradientContainer.dart';
import 'package:ayuprep/utils/errorMessageKeys.dart';
import 'package:ayuprep/utils/stringLabels.dart';
import 'package:ayuprep/utils/uiUtils.dart';

import 'package:path_provider/path_provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SelectProfilePictureScreen extends StatefulWidget {
  final bool updateProfileAndName;

  SelectProfilePictureScreen({required this.updateProfileAndName});

  @override
  _SelectProfilePictureScreen createState() => _SelectProfilePictureScreen();

  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider<UploadProfileCubit>(
                create: (context) => UploadProfileCubit(
                      ProfileManagementRepository(),
                    )),
            BlocProvider<ReferAndEarnCubit>(
                create: (_) => ReferAndEarnCubit(AuthRepository())),
          ],
          child: SelectProfilePictureScreen(
            updateProfileAndName: routeSettings.arguments as bool,
          )),
    );
  }
}

class _SelectProfilePictureScreen extends State<SelectProfilePictureScreen> {
  File? image;
  TextEditingController? textEditingController;
  TextEditingController inviteTextEditingController = TextEditingController();
  bool iHaveInviteCode = false;

  //convert image to file
  Future<void> uploadProfileImage(String imageName) async {
    final byteData =
        await rootBundle.load(UiUtils.getprofileImagePath(imageName));
    final file = File('${(await getTemporaryDirectory()).path}/temp.png');
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    final userId = context.read<UserDetailsCubit>().getUserId();
    context.read<UploadProfileCubit>().uploadProfilePicture(file, userId);
  }

  Widget _buildCurrentProfilePictureContainer(String imageUrl) {
    if (imageUrl.isEmpty) {
      return GestureDetector(
        onTap: () {
          //_showImagePickerDialog();
          showDialog(
              barrierDismissible: false,
              context: context,
              builder: (_) => ChooseProfileDialog(
                  id: context.read<UserDetailsCubit>().getUserId(),
                  bloc: context.read<UploadProfileCubit>()));
        },
        child: Container(
          child: Center(
            child: Icon(
              Icons.add_a_photo,
              color: Theme.of(context).backgroundColor,
            ),
          ),
          width: MediaQuery.of(context).size.width * (0.3),
          height: MediaQuery.of(context).size.width * (0.3),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            shape: BoxShape.circle,
          ),
        ),
      );
    }
    return SizedBox(
      width: MediaQuery.of(context).size.width * (0.3),
      height: MediaQuery.of(context).size.width * (0.3),
      child: LayoutBuilder(builder: (context, constraints) {
        return Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width * (0.3),
              height: MediaQuery.of(context).size.width * (0.3),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                image: DecorationImage(
                    image: CachedNetworkImageProvider(imageUrl)),
                shape: BoxShape.circle,
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(constraints.maxWidth * (0.15)),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                  child: GestureDetector(
                    onTap: () {
                      showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (_) => ChooseProfileDialog(
                              id: context.read<UserDetailsCubit>().getUserId(),
                              bloc: context.read<UploadProfileCubit>()));
                    },
                    child: Container(
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.add_a_photo,
                        color: Theme.of(context).primaryColor,
                        size: 20.0,
                      ),
                      decoration: BoxDecoration(
                          color: Theme.of(context)
                              .backgroundColor
                              .withOpacity(0.7),
                          borderRadius: BorderRadius.circular(
                              constraints.maxWidth * (0.15))),
                      height: constraints.maxWidth * (0.3),
                      width: constraints.maxWidth * (0.3),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSelectAvatarText() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Theme.of(context).backgroundColor,
      ),
      width: MediaQuery.of(context).size.width * (0.8),
      height: 60.0,
      alignment: Alignment.center,
      child: Text(
          AppLocalization.of(context)!
              .getTranslatedValues("selectProfilePhotoLbl")!,
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            fontSize: 22.5,
            fontWeight: FontWeight.bold,
          )),
    );
  }

  Widget _buildDefaultAvtarImage(int index, String imageName) {
    return GestureDetector(
      onTap: () {
        uploadProfileImage(imageName);
      },
      child: LayoutBuilder(builder: (context, constraints) {
        double profileRadiusPercentage = 0.0;
        if (constraints.maxHeight <
            UiUtils.profileHeightBreakPointResultScreen) {
          profileRadiusPercentage = 0.175;
        } else {
          profileRadiusPercentage = 0.2;
        }
        return Row(
          //crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
                margin: EdgeInsets.all(10),
                height: MediaQuery.of(context).size.height * .15,
                width: MediaQuery.of(context).size.width * .23,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                ),
                child: CircleAvatar(
                    radius: constraints.maxHeight *
                        (profileRadiusPercentage - 0.0535),
                    backgroundImage:
                        AssetImage(UiUtils.getprofileImagePath(imageName))))
          ],
        );
      }),
    );
  }

  Widget _buildDefaultAvtarImages() {
    final defaultProfileImages =
        (context.read<SystemConfigCubit>().state as SystemConfigFetchSuccess)
            .defaultProfileImages;

    return SizedBox(
        height: MediaQuery.of(context).size.height * (0.13),
        child: ListView.builder(
            shrinkWrap: true,
            physics: BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: defaultProfileImages.length,
            itemBuilder: (context, index) {
              return _buildDefaultAvtarImage(
                index,
                defaultProfileImages[index],
              );
            }));
  }

  //continue button will listen to two cubit one is for changing name and other is
  //for uploading profile picture
  Widget _buildContinueButton(UserProfile userProfile) {
    if (widget.updateProfileAndName) {
      //first consumer is for uploading profile picture
      return BlocConsumer<UploadProfileCubit, UploadProfileState>(
        bloc: context.read<UploadProfileCubit>(),
        listener: (context, state) {
          if (state is UploadProfileFailure) {
            UiUtils.setSnackbar(
                AppLocalization.of(context)!.getTranslatedValues(
                    convertErrorCodeToLanguageKey(state.errorMessage))!,
                context,
                false);
          } else if (state is UploadProfileSuccess) {
            context
                .read<UserDetailsCubit>()
                .updateUserProfileUrl(state.imageUrl);
          }
        },
        builder: (context, state) {
          //second is for updating name
          return BlocConsumer<ReferAndEarnCubit, ReferAndEarnState>(
            bloc: context.read<ReferAndEarnCubit>(),
            listener: (context, referAndEarnState) {
              if (referAndEarnState is ReferAndEarnFailure) {
                UiUtils.setSnackbar(
                    AppLocalization.of(context)!.getTranslatedValues(
                        convertErrorCodeToLanguageKey(
                            referAndEarnState.errorMessage))!,
                    context,
                    false);
              }
              if (referAndEarnState is ReferAndEarnSuccess) {
                context.read<UserDetailsCubit>().updateUserProfile(
                    name: referAndEarnState.userProfile.name,
                    coins: referAndEarnState.userProfile.coins!);

                Navigator.of(context)
                    .pushReplacementNamed(Routes.home, arguments: true);
              }
            },
            builder: (context, referAndEarnState) {
              String textButtonKey = "";
              if (state is UploadProfileInProgress) {
                textButtonKey = "uploadingBtn";
              } else if (referAndEarnState is ReferAndEarnProgress) {
                textButtonKey = "uploadingBtn";
              } else {
                textButtonKey = "continueLbl";
              }

              return TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: EdgeInsetsDirectional.only(
                      end: 40, start: 40, bottom: 15, top: 15),
                  side: BorderSide(
                      color: Theme.of(context).primaryColor, width: 1),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15.0))),
                ),
                onPressed: () {
                  //if upload profile is in progress
                  if (state is UploadProfileInProgress) {
                    return;
                  }
                  //if update name is in progress
                  if (state is ReferAndEarnProgress) {
                    return;
                  }
                  //if profile is empty
                  if (userProfile.profileUrl!.isEmpty) {
                    UiUtils.setSnackbar(
                        AppLocalization.of(context)!
                            .getTranslatedValues("selectProfileLbl")!,
                        context,
                        false);
                    return;
                  }

                  //if use has not enter the name then so enter name snack bar
                  if (textEditingController!.text.isEmpty) {
                    UiUtils.setSnackbar(
                        AppLocalization.of(context)!
                            .getTranslatedValues("enterValidNameMsg")!,
                        context,
                        false);
                    return;
                  }

                  context.read<ReferAndEarnCubit>().getReward(
                      name: textEditingController!.text.trim(),
                      userProfile: userProfile,
                      friendReferralCode: iHaveInviteCode
                          ? inviteTextEditingController.text.trim()
                          : "",
                      authType: context.read<AuthCubit>().getAuthProvider());

                  return;
                },
                child: Text(
                  AppLocalization.of(context)!
                      .getTranslatedValues(textButtonKey)!,
                  style: Theme.of(context).textTheme.headline5!.merge(
                      TextStyle(color: Theme.of(context).backgroundColor)),
                ),
              );
            },
          );
        },
      );
    }
    return BlocConsumer<UploadProfileCubit, UploadProfileState>(
      bloc: context.read<UploadProfileCubit>(),
      builder: (context, state) {
        String textButtonKey = "";
        if (state is UploadProfileInProgress) {
          textButtonKey = "uploadingBtn";
        } else {
          textButtonKey = "continueLbl";
        }

        return TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            padding: EdgeInsetsDirectional.only(
                end: 40, start: 40, bottom: 15, top: 15),
            side: BorderSide(color: Theme.of(context).primaryColor, width: 1),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15.0))),
          ),
          onPressed: () {
            //if upload profile is in progress
            if (state is UploadProfileInProgress) {
              return;
            }
            Navigator.of(context).pop();
          },
          child: Text(
            AppLocalization.of(context)!.getTranslatedValues(textButtonKey)!,
            style: Theme.of(context)
                .textTheme
                .headline5!
                .merge(TextStyle(color: Theme.of(context).backgroundColor)),
          ),
        );
      },
      listener: (context, state) {
        if (state is UploadProfileFailure) {
          UiUtils.setSnackbar(
              AppLocalization.of(context)!.getTranslatedValues(
                  convertErrorCodeToLanguageKey(state.errorMessage))!,
              context,
              false);
        } else if (state is UploadProfileSuccess) {
          context.read<UserDetailsCubit>().updateUserProfileUrl(state.imageUrl);
        }
      },
    );
  }

  Widget _buildNameTextFieldContainer() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Theme.of(context).backgroundColor,
      ),
      width: MediaQuery.of(context).size.width * (0.8),
      height: 60.0,
      alignment: Alignment.center,
      child: TextField(
        controller: textEditingController,
        textAlign: TextAlign.center,
        style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          hintText:
              AppLocalization.of(context)!.getTranslatedValues("enterNameLbl")!,
          border: InputBorder.none,
          hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildInviteCodeCheckBoxContainer() {
    return Container(
      width: MediaQuery.of(context).size.width * (0.8),
      alignment: Alignment.center,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 2.0,
          ),
          InkWell(
            onTap: () {
              setState(() {
                iHaveInviteCode = !iHaveInviteCode;
              });
            },
            child: AnimatedContainer(
              child: iHaveInviteCode
                  ? Icon(
                      Icons.check,
                      color: Theme.of(context).backgroundColor,
                      size: 18.0,
                    )
                  : SizedBox(),
              duration: Duration(milliseconds: 300),
              width: 20,
              height: 20,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: iHaveInviteCode
                    ? Theme.of(context).primaryColor
                    : Colors.transparent,
                border: Border.all(
                  width: 1.5,
                  color: iHaveInviteCode
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 10.0,
          ),
          Text(
            AppLocalization.of(context)!
                .getTranslatedValues(iHaveInviteCodeKey)!,
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInviteCodeTextFieldContainer() {
    return iHaveInviteCode
        ? Container(
            margin: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * (0.035),
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Theme.of(context).backgroundColor,
            ),
            width: MediaQuery.of(context).size.width * (0.8),
            height: 60.0,
            alignment: Alignment.center,
            child: TextField(
              controller: inviteTextEditingController,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: AppLocalization.of(context)!
                    .getTranslatedValues(enterReferralCodeLbl)!,
                border: InputBorder.none,
                hintStyle: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.bold),
              ),
            ),
          )
        : Container();
  }

  List<Widget> _buildNameAndReferCodeContainer() {
    if (widget.updateProfileAndName) {
      return [
        _buildNameTextFieldContainer(),
        SizedBox(
          height: MediaQuery.of(context).size.height * (0.025),
        ),
        _buildInviteCodeCheckBoxContainer(),
        _buildInviteCodeTextFieldContainer(),
        SizedBox(
          height: MediaQuery.of(context).size.height * (0.025),
        ),
      ];
    }
    return [Container()];
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return Future.value(false);
      },
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            PageBackgroundGradientContainer(),
            BlocConsumer<UserDetailsCubit, UserDetailsState>(
              listener: (context, state) {
                //when user register first time then set this listener
                if (state is UserDetailsFetchSuccess &&
                    widget.updateProfileAndName) {
                  UiUtils.fetchBookmarkAndBadges(
                      context: context, userId: state.userProfile.userId!);
                }
              },
              bloc: context.read<UserDetailsCubit>(),
              builder: (context, state) {
                if (state is UserDetailsFetchInProgress ||
                    state is UserDetailsInitial) {
                  return Center(
                    child: CircularProgressContainer(
                      useWhiteLoader: false,
                    ),
                  );
                }
                if (state is UserDetailsFetchFailure) {
                  return ErrorContainer(
                    showBackButton: true,
                    errorMessage: AppLocalization.of(context)!
                        .getTranslatedValues(
                            convertErrorCodeToLanguageKey(state.errorMessage)),
                    onTapRetry: () {
                      context.read<UserDetailsCubit>().fetchUserDetails(
                          context.read<AuthCubit>().getUserFirebaseId());
                    },
                    showErrorImage: true,
                  );
                }

                UserProfile userProfile =
                    (state as UserDetailsFetchSuccess).userProfile;
                if (textEditingController == null) {
                  textEditingController =
                      TextEditingController(text: userProfile.name);
                }
                return SingleChildScrollView(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top,
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * (0.025),
                      ),
                      Center(
                          child: _buildCurrentProfilePictureContainer(
                              userProfile.profileUrl ?? "")),
                      SizedBox(
                        height: 15.0,
                      ),
                      Center(
                        child: Text(
                          AppLocalization.of(context)!
                              .getTranslatedValues("orLbl")!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 25.0,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15.0,
                      ),
                      _buildSelectAvatarText(),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * (0.025),
                      ),
                      _buildDefaultAvtarImages(),
                      SizedBox(
                        height: MediaQuery.of(context).size.height *
                            (widget.updateProfileAndName ? 0.025 : 0.05),
                      ),
                      //
                      ..._buildNameAndReferCodeContainer(),
                      //
                      _buildContinueButton(userProfile),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
