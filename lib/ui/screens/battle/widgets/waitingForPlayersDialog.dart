import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ayuprep/app/appLocalization.dart';
import 'package:ayuprep/app/routes.dart';
import 'package:ayuprep/features/battleRoom/cubits/battleRoomCubit.dart';
import 'package:ayuprep/features/battleRoom/cubits/multiUserBattleRoomCubit.dart';
import 'package:ayuprep/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:ayuprep/features/quiz/models/quizType.dart';
import 'package:ayuprep/ui/screens/battle/widgets/customDialog.dart';
import 'package:ayuprep/ui/widgets/exitGameDailog.dart';
import 'package:ayuprep/utils/constants.dart';
import 'package:ayuprep/utils/errorMessageKeys.dart';
import 'package:ayuprep/utils/uiUtils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

class WaitingForPlayesDialog extends StatefulWidget {
  final QuizTypes quizType;
  final String? battleLbl;
  WaitingForPlayesDialog({Key? key, required this.quizType, this.battleLbl})
      : super(key: key);

  @override
  State<WaitingForPlayesDialog> createState() => _WaitingForPlayesDialogState();
}

class _WaitingForPlayesDialogState extends State<WaitingForPlayesDialog> {
  Widget profileAndNameContainer(
      BuildContext context,
      BoxConstraints constraints,
      String name,
      String profileUrl,
      Color borderColor) {
    return Column(
      children: [
        Container(
          width: constraints.maxWidth * (0.285),
          decoration: BoxDecoration(
              border:
                  Border.all(color: Theme.of(context).colorScheme.secondary)),
          height: constraints.maxHeight * (0.15),
          padding: EdgeInsets.symmetric(
            horizontal: 2.5,
            vertical: 2.5,
          ),
          child: profileUrl.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SvgPicture.asset(UiUtils.getImagePath("friend.svg")),
                )
              : CachedNetworkImage(
                  imageUrl: profileUrl,
                ),
        ),
        SizedBox(
          height: constraints.maxHeight * (0.015),
        ),
        Container(
          width: constraints.maxWidth * (0.3),
          height: constraints.maxHeight * (0.05),
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(
            horizontal: 5.0,
          ),
          child: Text(
            name.isEmpty
                ? AppLocalization.of(context)!
                    .getTranslatedValues('waitingLbl')!
                : name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Theme.of(context).backgroundColor,
            ),
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            border: Border.all(color: Theme.of(context).primaryColor),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ],
    );
  }

  void showRoomDestroyed(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) => WillPopScope(
            onWillPop: () {
              return Future.value(false);
            },
            child: AlertDialog(
              content: Text(
                AppLocalization.of(context)!
                    .getTranslatedValues('roomDeletedOwnerLbl')!,
                style:
                    TextStyle(color: Theme.of(context).colorScheme.secondary),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      AppLocalization.of(context)!
                          .getTranslatedValues('okayLbl')!,
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ))
              ],
            )));
  }

  void onBackEvent() {
    if (widget.quizType == QuizTypes.battle) {
      if (context.read<BattleRoomCubit>().state is BattleRoomCreated ||
          context.read<BattleRoomCubit>().state is BattleRoomUserFound) {
        //if user
        showDialog(
            context: context,
            builder: (context) => ExitGameDailog(
                  onTapYes: () {
                    bool createdRoom = false;

                    if (context.read<BattleRoomCubit>().state
                        is BattleRoomUserFound) {
                      createdRoom = (context.read<BattleRoomCubit>().state
                                  as BattleRoomUserFound)
                              .battleRoom
                              .user1!
                              .uid ==
                          context
                              .read<UserDetailsCubit>()
                              .getUserProfile()
                              .userId;
                    } else {
                      createdRoom = (context.read<BattleRoomCubit>().state
                                  as BattleRoomCreated)
                              .battleRoom
                              .user1!
                              .uid ==
                          context
                              .read<UserDetailsCubit>()
                              .getUserProfile()
                              .userId;
                    }
                    //if room is created by current user then delete room
                    if (createdRoom) {
                      context.read<BattleRoomCubit>().deleteBattleRoom(
                          false); // : context.read<MultiUserBattleRoomCubit>().deleteMultiUserBattleRoom();
                    } else {
                      context
                          .read<BattleRoomCubit>()
                          .removeOpponentFromBattleRoom();
                    }
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                ));
      }
    } else {
      //
      showDialog(
          context: context,
          builder: (context) => ExitGameDailog(
                onTapYes: () {
                  bool createdRoom = (context
                              .read<MultiUserBattleRoomCubit>()
                              .state as MultiUserBattleRoomSuccess)
                          .battleRoom
                          .user1!
                          .uid ==
                      context.read<UserDetailsCubit>().getUserProfile().userId;

                  //if room is created by current user then delete room
                  if (createdRoom) {
                    context
                        .read<MultiUserBattleRoomCubit>()
                        .deleteMultiUserBattleRoom();
                  } else {
                    //if room is not created by current user then remove user from room
                    context.read<MultiUserBattleRoomCubit>().deleteUserFromRoom(
                        context
                            .read<UserDetailsCubit>()
                            .getUserProfile()
                            .userId!);
                  }
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      onWillPop: () {
        onBackEvent();
        return Future.value(false);
      },
      onBackButtonPress: () {
        onBackEvent();
      },
      height: MediaQuery.of(context).size.height * (0.79),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(UiUtils.dailogRadius),
            gradient: UiUtils.buildLinerGradient([
              Theme.of(context).scaffoldBackgroundColor,
              Theme.of(context).canvasColor
            ], Alignment.topCenter, Alignment.bottomCenter)),
        child: widget.quizType == QuizTypes.battle
            ? BlocListener<BattleRoomCubit, BattleRoomState>(
                bloc: context.read<BattleRoomCubit>(),
                listener: (context, state) {
                  if (state is BattleRoomUserFound) {
                    //if game is ready to play
                    if (state.battleRoom.readyToPlay!) {
                      //if user has joined room then navigate to quiz screen
                      if (state.battleRoom.user1!.uid !=
                          context
                              .read<UserDetailsCubit>()
                              .getUserProfile()
                              .userId) {
                        Navigator.of(context).pushReplacementNamed(
                            Routes.battleRoomQuiz,
                            arguments: {
                              "battleLbl": widget.battleLbl,
                              "isTournamentBattle": false
                            });
                      }
                    }

                    //if owner deleted the room then show this dialog
                    if (!state.isRoomExist) {
                      if (context
                              .read<UserDetailsCubit>()
                              .getUserProfile()
                              .userId !=
                          state.battleRoom.user1!.uid) {
                        //Room destroyed by owner
                        showRoomDestroyed(context);
                      }
                    }
                  }
                },
                child: LayoutBuilder(builder: (context, constraints) {
                  return Column(
                    children: [
                      Container(
                        height: constraints.maxHeight * (0.11),
                        width: constraints.maxWidth,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(UiUtils.dailogRadius),
                            topRight: Radius.circular(UiUtils.dailogRadius),
                          ),
                          color: Theme.of(context).primaryColor,
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5.0),
                          child: Stack(
                            children: [
                              Align(
                                alignment: Alignment.center,
                                child: Text(
                                  AppLocalization.of(context)!
                                          .getTranslatedValues(
                                              'entryAmountLbl')! +
                                      " : ${context.read<BattleRoomCubit>().getEntryFee()}",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Theme.of(context).backgroundColor,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Align(
                                  alignment: Alignment.centerRight,
                                  child: IconButton(
                                    onPressed: () {
                                      try {
                                        String inviteMessage =
                                            "$groupBattleInviteMessage${context.read<BattleRoomCubit>().getRoomCode()}";
                                        Share.share(inviteMessage);
                                      } catch (e) {
                                        UiUtils.setSnackbar(
                                            AppLocalization.of(context)!
                                                .getTranslatedValues(
                                                    convertErrorCodeToLanguageKey(
                                                        defaultErrorMessageCode))!,
                                            context,
                                            false);
                                      }
                                    },
                                    iconSize: 20,
                                    icon: Icon(Icons.share),
                                    color: Theme.of(context).backgroundColor,
                                  ))
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: constraints.maxHeight * (0.025),
                      ),
                      Container(
                        width: constraints.maxWidth * (0.85),
                        height: constraints.maxHeight * (0.175),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    //
                                    child: Text(
                                        AppLocalization.of(context)!
                                                .getTranslatedValues(
                                                    'roomCodeLbl')! +
                                            " : ${context.read<BattleRoomCubit>().getRoomCode()}",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 18.0,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                          height: 1.2,
                                        )),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 5.0,
                            ),
                            Text(
                                AppLocalization.of(context)!
                                    .getTranslatedValues('shareRoomCodeLbl')!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w300,
                                  fontSize: 13.5,
                                  height: 1.2,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                )),
                          ],
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Theme.of(context).colorScheme.secondary),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                      SizedBox(
                        height: constraints.maxHeight * (0.0275),
                      ),
                      BlocBuilder<BattleRoomCubit, BattleRoomState>(
                        bloc: context.read<BattleRoomCubit>(),
                        builder: (context, state) {
                          if (state is BattleRoomUserFound) {
                            return profileAndNameContainer(
                                context,
                                constraints,
                                state.battleRoom.user1!.name,
                                state.battleRoom.user1!.profileUrl,
                                Theme.of(context).backgroundColor);
                          }
                          if (state is BattleRoomCreated) {
                            return profileAndNameContainer(
                                context,
                                constraints,
                                state.battleRoom.user1!.name,
                                state.battleRoom.user1!.profileUrl,
                                Theme.of(context).backgroundColor);
                          }
                          return profileAndNameContainer(context, constraints,
                              "", "", Theme.of(context).backgroundColor);
                        },
                      ),
                      SizedBox(
                        height: constraints.maxHeight * (0.027),
                      ),
                      CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Text(
                          AppLocalization.of(context)!
                              .getTranslatedValues('vsLbl')!,
                          style: TextStyle(
                              color: Theme.of(context).backgroundColor),
                        ),
                      ),
                      SizedBox(
                        height: constraints.maxHeight * (0.03),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        child: BlocBuilder<BattleRoomCubit, BattleRoomState>(
                          bloc: context.read<BattleRoomCubit>(),
                          builder: (context, state) {
                            if (state is BattleRoomUserFound) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  profileAndNameContainer(
                                      context,
                                      constraints,
                                      state.battleRoom.user2!.name,
                                      state.battleRoom.user2!.profileUrl,
                                      Colors.black54),
                                ],
                              );
                            }
                            if (state is BattleRoomCreated) {
                              return profileAndNameContainer(
                                  context,
                                  constraints,
                                  "",
                                  "",
                                  Theme.of(context).backgroundColor);
                            }
                            return Container();
                          },
                        ),
                      ),
                      Spacer(),
                      BlocBuilder<BattleRoomCubit, BattleRoomState>(
                        bloc: context.read<BattleRoomCubit>(),
                        builder: (context, state) {
                          if (state is BattleRoomCreated) {
                            return TextButton(
                              onPressed: () async {
                                //need minimum 2 player to start the game
                                //mark as ready to play in database
                                if (state.battleRoom.user2!.uid.isEmpty) {
                                  UiUtils.errorMessageDialog(
                                      context,
                                      AppLocalization.of(context)!
                                          .getTranslatedValues(
                                              convertErrorCodeToLanguageKey(
                                                  canNotStartGameCode)));
                                } else {
                                  context.read<BattleRoomCubit>().startGame();
                                  await Future.delayed(
                                      Duration(milliseconds: 500));
                                  //navigate to quiz screen
                                  Navigator.of(context).pushReplacementNamed(
                                      Routes.battleRoomQuiz,
                                      arguments: {
                                        "battleLbl": widget.battleLbl,
                                        "isTournamentBattle": false
                                      });
                                }
                              },
                              child: Text(
                                  AppLocalization.of(context)!
                                      .getTranslatedValues('startLbl')!,
                                  style: TextStyle(
                                      fontSize: 20.0,
                                      color: Theme.of(context).primaryColor)),
                            );
                          }
                          if (state is BattleRoomUserFound) {
                            if (state.battleRoom.user1!.uid !=
                                context
                                    .read<UserDetailsCubit>()
                                    .getUserProfile()
                                    .userId) {
                              return Container();
                            }

                            return TextButton(
                              onPressed: () async {
                                //need minimum 2 player to start the game
                                //mark as ready to play in database
                                if (state.battleRoom.user2!.uid.isEmpty) {
                                  UiUtils.errorMessageDialog(
                                      context,
                                      AppLocalization.of(context)!
                                          .getTranslatedValues(
                                              convertErrorCodeToLanguageKey(
                                                  canNotStartGameCode)));
                                } else {
                                  context.read<BattleRoomCubit>().startGame();
                                  await Future.delayed(
                                      Duration(milliseconds: 500));
                                  //navigate to quiz screen
                                  Navigator.of(context).pushReplacementNamed(
                                      Routes.battleRoomQuiz,
                                      arguments: {
                                        "battleLbl": widget.battleLbl,
                                        "isTournamentBattle": false
                                      });
                                }
                              },
                              child: Text(
                                  AppLocalization.of(context)!
                                      .getTranslatedValues('startLbl')!,
                                  style: TextStyle(
                                      fontSize: 20.0,
                                      color: Theme.of(context).primaryColor)),
                            );
                          }
                          return Container();
                        },
                      ),
                      SizedBox(
                        height: constraints.maxHeight * (0.01),
                      ),
                    ],
                  );
                }),
              )
            : BlocListener<MultiUserBattleRoomCubit, MultiUserBattleRoomState>(
                listener: (context, state) {
                  if (state is MultiUserBattleRoomSuccess) {
                    //if game is ready to play
                    if (state.battleRoom.readyToPlay!) {
                      //if user has joined room then navigate to quiz screen
                      if (state.battleRoom.user1!.uid !=
                          context
                              .read<UserDetailsCubit>()
                              .getUserProfile()
                              .userId) {
                        Navigator.of(context).pushReplacementNamed(
                            Routes.multiUserBattleRoomQuiz);
                      }
                    }

                    //if owner deleted the room then show this dialog
                    if (!state.isRoomExist) {
                      if (context
                              .read<UserDetailsCubit>()
                              .getUserProfile()
                              .userId !=
                          state.battleRoom.user1!.uid) {
                        //Room destroyed by owner
                        showRoomDestroyed(context);
                      }
                    }
                  }
                },
                child: LayoutBuilder(builder: (context, constraints) {
                  return Column(
                    children: [
                      Container(
                        height: constraints.maxHeight * (0.10),
                        width: constraints.maxWidth,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(UiUtils.dailogRadius),
                            topRight: Radius.circular(UiUtils.dailogRadius),
                          ),
                          color: Theme.of(context).primaryColor,
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5.0),
                          child: Stack(
                            children: [
                              Align(
                                alignment: Alignment.center,
                                child: Text(
                                  AppLocalization.of(context)!
                                          .getTranslatedValues(
                                              'entryAmountLbl')! +
                                      " : ${context.read<MultiUserBattleRoomCubit>().getEntryFee()}",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Theme.of(context).backgroundColor,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Align(
                                  alignment: Alignment.centerRight,
                                  child: IconButton(
                                    onPressed: () {
                                      try {
                                        String inviteMessage =
                                            "$groupBattleInviteMessage${context.read<MultiUserBattleRoomCubit>().getRoomCode()}";
                                        Share.share(inviteMessage);
                                      } catch (e) {
                                        UiUtils.setSnackbar(
                                            AppLocalization.of(context)!
                                                .getTranslatedValues(
                                                    convertErrorCodeToLanguageKey(
                                                        defaultErrorMessageCode))!,
                                            context,
                                            false);
                                      }
                                    },
                                    iconSize: 20,
                                    icon: Icon(Icons.share),
                                    color: Theme.of(context).backgroundColor,
                                  ))
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: constraints.maxHeight * (0.025),
                      ),
                      Container(
                        width: constraints.maxWidth * (0.85),
                        height: constraints.maxHeight * (0.175),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    //
                                    child: Text(
                                        AppLocalization.of(context)!
                                                .getTranslatedValues(
                                                    'roomCodeLbl')! +
                                            " : ${context.read<MultiUserBattleRoomCubit>().getRoomCode()}",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 18.0,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                          height: 1.2,
                                        )),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 5.0,
                            ),
                            Text(
                                AppLocalization.of(context)!
                                    .getTranslatedValues('shareRoomCodeLbl')!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w300,
                                  fontSize: 13.5,
                                  height: 1.2,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                )),
                          ],
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Theme.of(context).colorScheme.secondary),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                      SizedBox(
                        height: constraints.maxHeight * (0.0275),
                      ),
                      BlocBuilder<MultiUserBattleRoomCubit,
                          MultiUserBattleRoomState>(
                        bloc: context.read<MultiUserBattleRoomCubit>(),
                        builder: (context, state) {
                          if (state is MultiUserBattleRoomSuccess) {
                            return profileAndNameContainer(
                                context,
                                constraints,
                                state.battleRoom.user1!.name,
                                state.battleRoom.user1!.profileUrl,
                                Theme.of(context).backgroundColor);
                          }
                          return profileAndNameContainer(context, constraints,
                              "", "", Theme.of(context).backgroundColor);
                        },
                      ),
                      SizedBox(
                        height: constraints.maxHeight * (0.027),
                      ),
                      CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Text(
                          AppLocalization.of(context)!
                              .getTranslatedValues('vsLbl')!,
                          style: TextStyle(
                              color: Theme.of(context).backgroundColor),
                        ),
                      ),
                      SizedBox(
                        height: constraints.maxHeight * (0.03),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        child: BlocBuilder<MultiUserBattleRoomCubit,
                            MultiUserBattleRoomState>(
                          bloc: context.read<MultiUserBattleRoomCubit>(),
                          builder: (context, state) {
                            if (state is MultiUserBattleRoomSuccess) {
                              return widget.quizType == QuizTypes.battle
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        profileAndNameContainer(
                                            context,
                                            constraints,
                                            state.battleRoom.user2!.name,
                                            state.battleRoom.user2!.profileUrl,
                                            Colors.black54),
                                      ],
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        profileAndNameContainer(
                                            context,
                                            constraints,
                                            state.battleRoom.user2!.name,
                                            state.battleRoom.user2!.profileUrl,
                                            Colors.black54),
                                        profileAndNameContainer(
                                            context,
                                            constraints,
                                            state.battleRoom.user3!.name,
                                            state.battleRoom.user3!.profileUrl,
                                            Colors.black54),
                                        profileAndNameContainer(
                                            context,
                                            constraints,
                                            state.battleRoom.user4!.name,
                                            state.battleRoom.user4!.profileUrl,
                                            Colors.black54),
                                      ],
                                    );
                            } else {
                              return Container();
                            }
                          },
                        ),
                      ),
                      Spacer(),
                      BlocBuilder<MultiUserBattleRoomCubit,
                          MultiUserBattleRoomState>(
                        bloc: context.read<MultiUserBattleRoomCubit>(),
                        builder: (context, state) {
                          if (state is MultiUserBattleRoomSuccess) {
                            if (state.battleRoom.user1!.uid !=
                                context
                                    .read<UserDetailsCubit>()
                                    .getUserProfile()
                                    .userId) {
                              return Container();
                            }
                            return TextButton(
                              onPressed: () {
                                //need minimum 2 player to start the game
                                //mark as ready to play in database
                                if (state.battleRoom.user2!.uid.isEmpty) {
                                  UiUtils.errorMessageDialog(
                                      context,
                                      AppLocalization.of(context)!
                                          .getTranslatedValues(
                                              convertErrorCodeToLanguageKey(
                                                  canNotStartGameCode)));
                                } else {
                                  //start quiz
                                  /*    widget.quizType==QuizTypes.battle?context.read<BattleRoomCubit>().startGame():*/ context
                                      .read<MultiUserBattleRoomCubit>()
                                      .startGame();
                                  //navigate to quiz screen
                                  widget.quizType == QuizTypes.battle
                                      ? Navigator.of(context)
                                          .pushReplacementNamed(
                                              Routes.battleRoomQuiz,
                                              arguments: {
                                              "battleLbl": widget.battleLbl,
                                              "isTournamentBattle": false
                                            })
                                      : Navigator.of(context)
                                          .pushReplacementNamed(
                                              Routes.multiUserBattleRoomQuiz);
                                }
                              },
                              child: Text(
                                  AppLocalization.of(context)!
                                      .getTranslatedValues('startLbl')!,
                                  style: TextStyle(
                                      fontSize: 20.0,
                                      color: Theme.of(context).primaryColor)),
                            );
                          }
                          return Container();
                        },
                      ),
                      SizedBox(
                        height: constraints.maxHeight * (0.01),
                      ),
                    ],
                  );
                }),
              ),
      ),
    );
  }
}
