import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ayuprep/app/appLocalization.dart';
import 'package:ayuprep/app/routes.dart';
import 'package:ayuprep/features/battleRoom/battleRoomRepository.dart';
import 'package:ayuprep/features/battleRoom/cubits/messageCubit.dart';
import 'package:ayuprep/features/battleRoom/models/message.dart';
import 'package:ayuprep/features/bookmark/bookmarkRepository.dart';
import 'package:ayuprep/features/bookmark/cubits/bookmarkCubit.dart';
import 'package:ayuprep/features/bookmark/cubits/updateBookmarkCubit.dart';
import 'package:ayuprep/features/battleRoom/cubits/battleRoomCubit.dart';
import 'package:ayuprep/features/profileManagement/cubits/updateScoreAndCoinsCubit.dart';
import 'package:ayuprep/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:ayuprep/features/profileManagement/profileManagementRepository.dart';
import 'package:ayuprep/features/quiz/models/question.dart';
import 'package:ayuprep/features/quiz/models/quizType.dart';
import 'package:ayuprep/features/quiz/models/userBattleRoomDetails.dart';
import 'package:ayuprep/features/systemConfig/cubits/systemConfigCubit.dart';
import 'package:ayuprep/features/tournament/cubits/tournamentBattleCubit.dart';
import 'package:ayuprep/features/tournament/cubits/tournamentCubit.dart';
import 'package:ayuprep/features/tournament/model/tournamentBattle.dart';
import 'package:ayuprep/features/tournament/model/tournamentPlayerDetails.dart';
import 'package:ayuprep/ui/screens/battle/widgets/messageBoxContainer.dart';
import 'package:ayuprep/ui/screens/battle/widgets/messageContainer.dart';

import 'package:ayuprep/ui/widgets/customBackButton.dart';
import 'package:ayuprep/ui/widgets/exitGameDailog.dart';
import 'package:ayuprep/ui/widgets/pageBackgroundGradientContainer.dart';
import 'package:ayuprep/ui/widgets/questionsContainer.dart';
import 'package:ayuprep/ui/widgets/quizPlayAreaBackgroundContainer.dart';
import 'package:ayuprep/ui/widgets/settingButton.dart';
import 'package:ayuprep/ui/widgets/settingsDialogContainer.dart';
import 'package:ayuprep/ui/widgets/userDetailsWithTimerContainer.dart';
import 'package:ayuprep/utils/answerEncryption.dart';
import 'package:ayuprep/utils/constants.dart';
import 'package:ayuprep/utils/errorMessageKeys.dart';
import 'package:ayuprep/utils/stringLabels.dart';
import 'package:ayuprep/utils/uiUtils.dart';

class BattleRoomQuizScreen extends StatefulWidget {
  final String? battleLbl;
  final bool isTournamentBattle;
  BattleRoomQuizScreen(
      {Key? key, this.battleLbl, required this.isTournamentBattle})
      : super(key: key);

  static Route<dynamic> route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
        builder: (_) => MultiBlocProvider(
                providers: [
                  BlocProvider<UpdateBookmarkCubit>(
                      create: (context) =>
                          UpdateBookmarkCubit(BookmarkRepository())),
                  BlocProvider<MessageCubit>(
                      create: (context) =>
                          MessageCubit(BattleRoomRepository())),
                  BlocProvider<UpdateScoreAndCoinsCubit>(
                    create: (context) =>
                        UpdateScoreAndCoinsCubit(ProfileManagementRepository()),
                  ),
                ],
                child: BattleRoomQuizScreen(
                  battleLbl: arguments['battleLbl'],
                  isTournamentBattle: arguments['isTournamentBattle'],
                )));
  }

  @override
  _BattleRoomQuizScreenState createState() => _BattleRoomQuizScreenState();
}

class _BattleRoomQuizScreenState extends State<BattleRoomQuizScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController timerAnimationController = AnimationController(
      vsync: this, duration: Duration(seconds: questionDurationInSeconds))
    ..addStatusListener(currentUserTimerAnimationStatusListener)
    ..forward();

  late AnimationController opponentUserTimerAnimationController =
      AnimationController(
          vsync: this, duration: Duration(seconds: questionDurationInSeconds))
        ..forward();

  //to animate the question container
  late AnimationController questionAnimationController;
  late AnimationController questionContentAnimationController;
  //to slide the question container from right to left
  late Animation<double> questionSlideAnimation;
  //to scale up the second question
  late Animation<double> questionScaleUpAnimation;
  //to scale down the second question
  late Animation<double> questionScaleDownAnimation;
  //to slude the question content from right to left
  late Animation<double> questionContentAnimation;

  late AnimationController messageAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
      reverseDuration: Duration(milliseconds: 300));
  late Animation<double> messageAnimation = Tween<double>(begin: 0.0, end: 1.0)
      .animate(CurvedAnimation(
          parent: messageAnimationController, curve: Curves.easeOutBack));

  late AnimationController opponentMessageAnimationController =
      AnimationController(
          vsync: this,
          duration: Duration(milliseconds: 300),
          reverseDuration: Duration(milliseconds: 300));
  late Animation<double> opponentMessageAnimation =
      Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
          parent: opponentMessageAnimationController,
          curve: Curves.easeOutBack));

  late AnimationController messageBoxAnimationController =
      AnimationController(vsync: this, duration: Duration(milliseconds: 350));
  late Animation<double> messageBoxAnimation =
      Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
          parent: messageBoxAnimationController, curve: Curves.easeInOut));

  late int currentQuestionIndex = 0;

  //if user left the by pressing home button or lock screen
  //this will be true
  bool showYouLeftQuiz = false;

  //to track if setting dialog is open
  bool isSettingDialogOpen = false;

  bool isExitDialogOpen = false;

  final double bottomPadding = 15;

  //current user message timer
  Timer? currentUserMessageDisappearTimer;
  int currentUserMessageDisappearTimeInSeconds = 4;

  //opponent user message timer
  Timer? opponentUserMessageDisappearTimer;
  int opponentUserMessageDisappearTimeInSeconds = 4;

  //To track users latest message

  List<Message> latestMessagesByUsers = [];

  @override
  void initState() {
    //Add empty latest messages
    latestMessagesByUsers.add(Message.buildEmptyMessage());
    latestMessagesByUsers.add(Message.buildEmptyMessage());
    //

    //if battle is not from tournament then deduct coins
    if (!widget.isTournamentBattle) {
      Future.delayed(Duration.zero, () {
        context.read<UpdateScoreAndCoinsCubit>().updateCoins(
            context.read<UserDetailsCubit>().getUserId(),
            context.read<BattleRoomCubit>().getEntryFee(),
            false,
            playedBattleKey);
        context.read<UserDetailsCubit>().updateCoins(
            addCoin: false,
            coins: context.read<BattleRoomCubit>().getEntryFee());
      });
    }
    initializeAnimation();
    initMessageListener();
    questionContentAnimationController.forward();
    WidgetsBinding.instance!.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    timerAnimationController
        .removeStatusListener(currentUserTimerAnimationStatusListener);
    timerAnimationController.dispose();
    opponentUserTimerAnimationController.dispose();
    questionAnimationController.dispose();
    questionContentAnimationController.dispose();
    messageAnimationController.dispose();
    opponentMessageAnimationController.dispose();
    currentUserMessageDisappearTimer?.cancel();
    opponentUserMessageDisappearTimer?.cancel();
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    //delete battle room
    if (state == AppLifecycleState.paused) {
      //if user minimize or change the app
      if (widget.isTournamentBattle) {
        if (!context.read<TournamentBattleCubit>().opponentLeftTheGame(
            context.read<UserDetailsCubit>().getUserId())) {
          //delete all messages entered by current user
          deleteMessages(context.read<TournamentBattleCubit>().getRoomId());
        }
      } else {
        if (!context.read<BattleRoomCubit>().opponentLeftTheGame(
            context.read<UserDetailsCubit>().getUserId())) {
          //delete all messages entered by current user
          deleteMessages(context.read<BattleRoomCubit>().getRoomId());
          //delete battle room
          context.read<BattleRoomCubit>().deleteBattleRoom(false);
        }
      }
    }
    //show you left the game
    if (state == AppLifecycleState.resumed) {
      //
      if (widget.isTournamentBattle) {
        //
        if (!context.read<TournamentBattleCubit>().opponentLeftTheGame(
            context.read<UserDetailsCubit>().getUserId())) {
          setState(() {
            showYouLeftQuiz = true;
          });
        }
      } else {
        //
        if (!context.read<BattleRoomCubit>().opponentLeftTheGame(
            context.read<UserDetailsCubit>().getUserId())) {
          setState(() {
            showYouLeftQuiz = true;
          });
        }
      }

      timerAnimationController.stop();
      opponentUserTimerAnimationController.stop();
    }
  }

  void initMessageListener() {
    //to set listener for opponent message
    Future.delayed(Duration.zero, () {
      String roomId = widget.isTournamentBattle
          ? context.read<TournamentBattleCubit>().getRoomId()
          : context.read<BattleRoomCubit>().getRoomId();
      context.read<MessageCubit>().subscribeToMessages(roomId);
    });
  }

  //
  void initializeAnimation() {
    questionAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    questionContentAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 250));

    questionSlideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: questionAnimationController, curve: Curves.easeInOut));
    questionScaleUpAnimation = Tween<double>(begin: 0.0, end: 0.1).animate(
        CurvedAnimation(
            parent: questionAnimationController,
            curve: Interval(0.0, 0.5, curve: Curves.easeInQuad)));
    questionScaleDownAnimation = Tween<double>(begin: 0.0, end: 0.05).animate(
        CurvedAnimation(
            parent: questionAnimationController,
            curve: Interval(0.5, 1.0, curve: Curves.easeOutQuad)));
    questionContentAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: questionContentAnimationController,
            curve: Curves.easeInQuad));
  }

  void toggleSettingDialog() {
    isSettingDialogOpen = !isSettingDialogOpen;
  }

  //listener for current user timer
  void currentUserTimerAnimationStatusListener(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      print("User has left the question so submit answer as -1");
      submitAnswer("-1");
    }
  }

  void updateSubmittedAnswerForBookmark(Question question) {
    if (context.read<BookmarkCubit>().hasQuestionBookmarked(question.id)) {
      context.read<BookmarkCubit>().updateSubmittedAnswerId(
          question, context.read<UserDetailsCubit>().getUserId());
    }
  }

  //to submit the answer
  void submitAnswer(String submittedAnswer) async {
    timerAnimationController.stop();

    //if battle is from tournament
    if (widget.isTournamentBattle) {
      //submitted answer will be id of the answerOption
      final tournamentBattleCubit = context.read<TournamentBattleCubit>();
      if (!tournamentBattleCubit
          .getQuestions()[currentQuestionIndex]
          .attempted) {
        //update answer locally
        tournamentBattleCubit.updateQuestionAnswer(
            tournamentBattleCubit.getQuestions()[currentQuestionIndex].id!,
            submittedAnswer);
        updateSubmittedAnswerForBookmark(
            tournamentBattleCubit.getQuestions()[currentQuestionIndex]);

        //need to give the delay so user can see the correct answer or incorrect
        await Future.delayed(Duration(seconds: inBetweenQuestionTimeInSeconds));
        //update answer and current points in database

        tournamentBattleCubit.submitAnswer(
          context.read<UserDetailsCubit>().getUserId(),
          submittedAnswer,

          submittedAnswer ==
              AnswerEncryption.decryptCorrectAnswer(
                  rawKey: context.read<UserDetailsCubit>().getUserFirebaseId(),
                  correctAnswer: tournamentBattleCubit
                      .getQuestions()[currentQuestionIndex]
                      .correctAnswer!),
          UiUtils.determineBattleCorrectAnswerPoints(
              timerAnimationController.value), //
        );
      }
    } else {
      //if battle is not from tournament

      //submitted answer will be id of the answerOption
      final battleRoomCubit = context.read<BattleRoomCubit>();
      if (!battleRoomCubit.getQuestions()[currentQuestionIndex].attempted) {
        //update answer locally
        context.read<BattleRoomCubit>().updateQuestionAnswer(
            battleRoomCubit.getQuestions()[currentQuestionIndex].id,
            submittedAnswer);
        updateSubmittedAnswerForBookmark(
            battleRoomCubit.getQuestions()[currentQuestionIndex]);

        //need to give the delay so user can see the correct answer or incorrect
        await Future.delayed(Duration(seconds: inBetweenQuestionTimeInSeconds));
        //update answer and current points in database

        battleRoomCubit.submitAnswer(
          context.read<UserDetailsCubit>().getUserId(),
          submittedAnswer,
          submittedAnswer ==
              AnswerEncryption.decryptCorrectAnswer(
                  rawKey: context.read<UserDetailsCubit>().getUserFirebaseId(),
                  correctAnswer: battleRoomCubit
                      .getQuestions()[currentQuestionIndex]
                      .correctAnswer!),
          UiUtils.determineBattleCorrectAnswerPoints(
              timerAnimationController.value), //
        );
      }
    }
  }

  //if user has submitted the answer for current question
  bool hasSubmittedAnswerForCurrentQuestion() {
    return widget.isTournamentBattle
        ? context
            .read<TournamentBattleCubit>()
            .getQuestions()[currentQuestionIndex]
            .attempted
        : context
            .read<BattleRoomCubit>()
            .getQuestions()[currentQuestionIndex]
            .attempted;
  }

  //next question
  void changeQuestion() {
    questionAnimationController.forward(from: 0.0).then((value) {
      //need to dispose the animation controllers
      questionAnimationController.dispose();
      questionContentAnimationController.dispose();
      //initializeAnimation again
      setState(() {
        initializeAnimation();
        currentQuestionIndex++;
      });
      //load content(options, image etc) of question
      questionContentAnimationController.forward();
    });
  }

  void deleteMessages(String battleRoomId) {
    //to delete messages by given user
    context.read<MessageCubit>().deleteMessages(
        battleRoomId, context.read<UserDetailsCubit>().getUserId());
  }

  //tournament battle listener
  void tournamentBattleListener(
      BuildContext context,
      TournamentBattleState state,
      TournamentBattleCubit tournamentBattleCubit) {
    if (state is TournamentBattleStarted) {
      TournamentPlayerDetails opponentUserDetails = tournamentBattleCubit
          .getOpponentUserDetails(context.read<UserDetailsCubit>().getUserId());
      TournamentPlayerDetails currentUserDetails = tournamentBattleCubit
          .getCurrentUserDetails(context.read<UserDetailsCubit>().getUserId());

      //if user has left the game
      if (state.hasLeft) {
        timerAnimationController.stop();
        opponentUserTimerAnimationController.stop();
      } else {
        //check if opponent user has submitted the answer
        if (opponentUserDetails.answers.length == (currentQuestionIndex + 1)) {
          opponentUserTimerAnimationController.stop();
        }
        //if both users submitted the answer then change question
        if (state.tournamentBattle.user1.answers.length ==
            state.tournamentBattle.user2.answers.length) {
          //
          //if user has not submitted the answers for all questions then move to next question
          //
          if (state.tournamentBattle.user1.answers.length !=
              state.questions.length) {
            //
            //since submitting answer locally will change the cubit state
            //to avoid calling changeQuestion() called twice
            //need to add this condition
            //
            if (!state.questions[currentUserDetails.answers.length].attempted) {
              //stop any timer
              timerAnimationController.stop();
              opponentUserTimerAnimationController.stop();
              //change the question
              changeQuestion();
              //run timer again
              timerAnimationController.forward(from: 0.0);
              opponentUserTimerAnimationController.forward(from: 0.0);
            }
          }
          //else move to result screen
          else {
            //stop timers if any running
            timerAnimationController.stop();
            opponentUserTimerAnimationController.stop();

            //delete messages by current user
            deleteMessages(tournamentBattleCubit.getRoomId());

            //update tournament battles result
            String winnerId = state.tournamentBattle.user1.points >
                    state.tournamentBattle.user2.points
                ? state.tournamentBattle.user1.uid
                : state.tournamentBattle.user2.uid;
            context.read<TournamentCubit>().updateTournamentBattlesResult(
                tournamentBattleId: state.tournamentBattle.tournamentBattleId,
                winnerId: winnerId);

            //
            //delete room
            tournamentBattleCubit.deleteRoom();

            //create semi final
            if (winnerId == context.read<UserDetailsCubit>().getUserId()) {
              //if user is playing quater-final
              if (state.tournamentBattle.battleType ==
                  TournamentBattleType.quaterFinal) {
                tournamentBattleCubit.resetTournamentBattleResource();
              } else if (state.tournamentBattle.battleType ==
                  TournamentBattleType.semiFinal) {
                //create final
              }
            }

            //navigate to result
            if (isSettingDialogOpen) {
              Navigator.of(context).pop();
            }

            Navigator.of(context).pop();

            // Navigator.of(context).pushReplacementNamed(
            //   Routes.result,
            //   arguments: {
            //     "questions": state.questions,
            //     "battleRoom": state.battleRoom,
            //     "numberOfPlayer": 2,
            //     "quizType": QuizTypes.battle,
            //     "entryFee": state.battleRoom.entryFee,
            //   },
            // );

          }
        }
      }
    }
  }

  //for changing ui and other trigger other actions based on realtime changes that occured in game
  void battleRoomListener(BuildContext context, BattleRoomState state,
      BattleRoomCubit battleRoomCubit) {
    if (state is BattleRoomUserFound) {
      UserBattleRoomDetails opponentUserDetails = battleRoomCubit
          .getOpponentUserDetails(context.read<UserDetailsCubit>().getUserId());
      UserBattleRoomDetails currentUserDetails = battleRoomCubit
          .getCurrentUserDetails(context.read<UserDetailsCubit>().getUserId());

      //if user has left the game
      if (state.hasLeft) {
        timerAnimationController.stop();
        opponentUserTimerAnimationController.stop();
      } else {
        //check if opponent user has submitted the answer
        if (opponentUserDetails.answers.length == (currentQuestionIndex + 1)) {
          opponentUserTimerAnimationController.stop();
        }
        //if both users submitted the answer then change question
        if (state.battleRoom.user1!.answers.length ==
            state.battleRoom.user2!.answers.length) {
          //
          //if user has not submitted the answers for all questions then move to next question
          //
          if (state.battleRoom.user1!.answers.length !=
              state.questions.length) {
            //
            //since submitting answer locally will change the cubit state
            //to avoid calling changeQuestion() called twice
            //need to add this condition
            //
            if (!state.questions[currentUserDetails.answers.length].attempted) {
              //stop any timer
              timerAnimationController.stop();
              opponentUserTimerAnimationController.stop();
              //change the question
              changeQuestion();
              //run timer again
              timerAnimationController.forward(from: 0.0);
              opponentUserTimerAnimationController.forward(from: 0.0);
            }
          }
          //else move to result screen
          else {
            //stop timers if any running
            timerAnimationController.stop();
            opponentUserTimerAnimationController.stop();

            //delete messages by current user
            deleteMessages(battleRoomCubit.getRoomId());
            //delete room
            battleRoomCubit
                .deleteBattleRoom(widget.battleLbl == "playFrd" ? true : false);
            //navigate to result
            if (isSettingDialogOpen) {
              Navigator.of(context).pop();
            }
            if (isExitDialogOpen) {
              Navigator.of(context).pop();
            }
            Navigator.of(context).pushReplacementNamed(
              Routes.result,
              arguments: {
                "questions": state.questions,
                "battleRoom": state.battleRoom,
                "numberOfPlayer": 2,
                "quizType": QuizTypes.battle,
                "entryFee": state.battleRoom.entryFee,
              },
            );
          }
        }
      }
    }
  }

  void setCurrentUserMessageDisappearTimer() {
    if (currentUserMessageDisappearTimeInSeconds != 4) {
      currentUserMessageDisappearTimeInSeconds = 4;
    }

    currentUserMessageDisappearTimer =
        Timer.periodic(Duration(seconds: 1), (timer) {
      if (currentUserMessageDisappearTimeInSeconds == 0) {
        //
        timer.cancel();
        messageAnimationController.reverse();
      } else {
        print("$currentUserMessageDisappearTimeInSeconds");
        currentUserMessageDisappearTimeInSeconds--;
      }
    });
  }

  void setOpponentUserMessageDisappearTimer() {
    if (opponentUserMessageDisappearTimeInSeconds != 4) {
      opponentUserMessageDisappearTimeInSeconds = 4;
    }

    opponentUserMessageDisappearTimer =
        Timer.periodic(Duration(seconds: 1), (timer) {
      if (opponentUserMessageDisappearTimeInSeconds == 0) {
        //
        timer.cancel();
        opponentMessageAnimationController.reverse();
      } else {
        print("Opponent $opponentUserMessageDisappearTimeInSeconds");
        opponentUserMessageDisappearTimeInSeconds--;
      }
    });
  }

  void messagesListener(MessageState state) async {
    if (state is MessageFetchedSuccess) {
      //current user message

      if (context
          .read<MessageCubit>()
          .getUserLatestMessage(
              //fetch user id
              context.read<UserDetailsCubit>().getUserId(),
              messageId: latestMessagesByUsers[0].messageId
              //latest user message id
              )
          .messageId
          .isNotEmpty) {
        //Assign latest message
        latestMessagesByUsers[0] = context
            .read<MessageCubit>()
            .getUserLatestMessage(context.read<UserDetailsCubit>().getUserId(),
                messageId: latestMessagesByUsers[0].messageId);
        print(
            "Current user latest message : ${latestMessagesByUsers[0].message}");

        //Display latest message by current user
        //means timer is running
        if (currentUserMessageDisappearTimeInSeconds > 0 &&
            currentUserMessageDisappearTimeInSeconds < 4) {
          currentUserMessageDisappearTimer?.cancel();
          setCurrentUserMessageDisappearTimer();
        } else {
          messageAnimationController.forward();
          setCurrentUserMessageDisappearTimer();
        }
      }

      //opponrt user message

      if (context
          .read<MessageCubit>()
          .getUserLatestMessage(
              //fetch opponent user id
              context
                  .read<BattleRoomCubit>()
                  .getOpponentUserDetails(
                      context.read<UserDetailsCubit>().getUserId())
                  .uid,
              messageId: latestMessagesByUsers[1].messageId
              //latest user message id
              )
          .messageId
          .isNotEmpty) {
        //Assign latest message
        latestMessagesByUsers[1] = context
            .read<MessageCubit>()
            .getUserLatestMessage(
                context
                    .read<BattleRoomCubit>()
                    .getOpponentUserDetails(
                        context.read<UserDetailsCubit>().getUserId())
                    .uid,
                messageId: latestMessagesByUsers[1].messageId);
        print(
            "Opponent user latest message : ${latestMessagesByUsers[1].message}");

        //Display latest message by opponent user
        //means timer is running

        //means timer is running
        if (opponentUserMessageDisappearTimeInSeconds > 0 &&
            opponentUserMessageDisappearTimeInSeconds < 4) {
          opponentUserMessageDisappearTimer?.cancel();
          setOpponentUserMessageDisappearTimer();
        } else {
          opponentMessageAnimationController.forward();
          setOpponentUserMessageDisappearTimer();
        }
      }
    }
  }

  Widget _buildCurrentUserMessageContainer() {
    return PositionedDirectional(
      child: ScaleTransition(
        scale: messageAnimation,
        child: MessageContainer(
          quizType: widget.isTournamentBattle
              ? QuizTypes.tournament
              : QuizTypes.battle,
          isCurrentUser: true,
        ),
        alignment: Alignment(-0.5, 1.0), //-0.5 left side nad 0.5 is right side,
      ),
      start: 10,
      bottom: (bottomPadding * 2.5) +
          MediaQuery.of(context).size.width * timerHeightAndWidthPercentage,
    );
  }

  Widget _buildOpponentUserMessageContainer() {
    return PositionedDirectional(
      child: ScaleTransition(
        scale: opponentMessageAnimation,
        child: MessageContainer(
          quizType: widget.isTournamentBattle
              ? QuizTypes.tournament
              : QuizTypes.battle,
          isCurrentUser: false,
        ),
        alignment: Alignment(0.5, 1.0), //-0.5 left side nad 0.5 is right side,
      ),
      end: 10,
      bottom: (bottomPadding * 2.5) +
          MediaQuery.of(context).size.width * timerHeightAndWidthPercentage,
    );
  }

  Widget _buildCurrentUserDetailsContainer() {
    if (widget.isTournamentBattle) {
      TournamentBattleCubit tournamentBattleCubit =
          context.read<TournamentBattleCubit>();
      return PositionedDirectional(
          bottom: bottomPadding,
          start: 10,
          child: BlocBuilder<TournamentBattleCubit, TournamentBattleState>(
            bloc: tournamentBattleCubit,
            builder: (context, state) {
              if (state is TournamentBattleStarted) {
                TournamentPlayerDetails curretUserDetails =
                    tournamentBattleCubit.getCurrentUserDetails(
                        context.read<UserDetailsCubit>().getUserId());
                //it contains correct answer by respective user and user name
                return UserDetailsWithTimerContainer(
                  points: curretUserDetails.points.toString(),
                  isCurrentUser: true,
                  name: curretUserDetails.name,
                  timerAnimationController: timerAnimationController,
                  profileUrl: curretUserDetails.profileUrl,
                );
              }
              return Container();
            },
          ));
    }
    BattleRoomCubit battleRoomCubit = context.read<BattleRoomCubit>();
    return PositionedDirectional(
        bottom: bottomPadding,
        start: 10,
        child: BlocBuilder<BattleRoomCubit, BattleRoomState>(
          bloc: battleRoomCubit,
          builder: (context, state) {
            if (state is BattleRoomUserFound) {
              UserBattleRoomDetails curretUserDetails =
                  battleRoomCubit.getCurrentUserDetails(
                      context.read<UserDetailsCubit>().getUserId());
              //it contains correct answer by respective user and user name
              return UserDetailsWithTimerContainer(
                points: curretUserDetails.points.toString(),
                isCurrentUser: true,
                name: curretUserDetails.name,
                timerAnimationController: timerAnimationController,
                profileUrl: curretUserDetails.profileUrl,
              );
            }
            return Container();
          },
        ));
  }

  Widget _buildOpponentUserDetailsContainer() {
    if (widget.isTournamentBattle) {
      print("Fetch opponent details");
      TournamentBattleCubit tournamentBattleCubit =
          context.read<TournamentBattleCubit>();
      return PositionedDirectional(
          bottom: bottomPadding,
          end: 10,
          child: BlocBuilder<TournamentBattleCubit, TournamentBattleState>(
            bloc: tournamentBattleCubit,
            builder: (context, state) {
              if (state is TournamentBattleStarted) {
                TournamentPlayerDetails opponentUserDetails =
                    tournamentBattleCubit.getOpponentUserDetails(
                        context.read<UserDetailsCubit>().getUserId());
                //it contains correct answer by respective user and user name
                return UserDetailsWithTimerContainer(
                  points: opponentUserDetails.points.toString(),
                  isCurrentUser: false,
                  name: opponentUserDetails.name,
                  timerAnimationController:
                      opponentUserTimerAnimationController,
                  profileUrl: opponentUserDetails.profileUrl,
                );
              }
              return Container();
            },
          ));
    }

    BattleRoomCubit battleRoomCubit = context.read<BattleRoomCubit>();
    return PositionedDirectional(
        bottom: bottomPadding,
        end: 10,
        child: BlocBuilder<BattleRoomCubit, BattleRoomState>(
          bloc: battleRoomCubit,
          builder: (context, state) {
            if (state is BattleRoomUserFound) {
              UserBattleRoomDetails opponentUserDetails =
                  battleRoomCubit.getOpponentUserDetails(
                      context.read<UserDetailsCubit>().getUserId());
              //it contains correct answer by respective user and user name
              return UserDetailsWithTimerContainer(
                points: opponentUserDetails.points.toString(),
                isCurrentUser: false,
                name: opponentUserDetails.name,
                timerAnimationController: opponentUserTimerAnimationController,
                profileUrl: opponentUserDetails.profileUrl,
              );
            }
            return Container();
          },
        ));
  }

  Widget _buildYouWonContainer(Function onPressed) {
    return Container(
      alignment: Alignment.center,
      color: Theme.of(context).backgroundColor.withOpacity(0.1),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: AlertDialog(
        title: Text(
          AppLocalization.of(context)!.getTranslatedValues('youWonLbl')!,
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        content: Text(
          AppLocalization.of(context)!.getTranslatedValues('opponentLeftLbl')!,
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        actions: [
          CupertinoButton(
              child: Text(
                AppLocalization.of(context)!.getTranslatedValues('okayLbl')!,
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
              onPressed: () {
                onPressed();
              }),
        ],
      ),
    );
  }

  //if opponent user has left the game this dialog will be shown
  Widget _buildYouWonGameDailog() {
    return showYouLeftQuiz
        ? Container()
        : widget.isTournamentBattle
            ? BlocBuilder<TournamentBattleCubit, TournamentBattleState>(
                bloc: context.read<TournamentBattleCubit>(),
                builder: (context, state) {
                  if (state is TournamentBattleStarted) {
                    //show you won game only opponent user has left the game
                    if (context
                        .read<TournamentBattleCubit>()
                        .opponentLeftTheGame(
                            context.read<UserDetailsCubit>().getUserId())) {
                      return _buildYouWonContainer(() {
                        deleteMessages(
                            context.read<TournamentBattleCubit>().getRoomId());
                        Navigator.of(context).pop();
                      });
                    }
                  }
                  return Container();
                },
              )
            : BlocBuilder<BattleRoomCubit, BattleRoomState>(
                bloc: context.read<BattleRoomCubit>(),
                builder: (context, state) {
                  if (state is BattleRoomUserFound) {
                    //show you won game only opponent user has left the game
                    if (context.read<BattleRoomCubit>().opponentLeftTheGame(
                        context.read<UserDetailsCubit>().getUserId())) {
                      return _buildYouWonContainer(() {
                        deleteMessages(
                            context.read<BattleRoomCubit>().getRoomId());

                        context.read<UpdateScoreAndCoinsCubit>().updateCoins(
                              context.read<UserDetailsCubit>().getUserId(),
                              context.read<BattleRoomCubit>().getEntryFee() * 2,
                              true,
                              wonBattleKey,
                            );
                        context.read<UserDetailsCubit>().updateCoins(
                            addCoin: true,
                            coins:
                                context.read<BattleRoomCubit>().getEntryFee() *
                                    2);
                        Navigator.of(context).pop();
                      });
                    }
                  }
                  return Container();
                },
              );
  }

  //if currentUser has left the game
  Widget _buildCurrentUserLeftTheGame() {
    return showYouLeftQuiz
        ? Container(
            color: Theme.of(context).backgroundColor.withOpacity(0.12),
            child: Center(
              child: AlertDialog(
                content: Text(
                  AppLocalization.of(context)!
                      .getTranslatedValues('youLeftLbl')!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                actions: [
                  CupertinoButton(
                      child: Text(
                        AppLocalization.of(context)!
                            .getTranslatedValues('okayLbl')!,
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      })
                ],
              ),
            ),
          )
        : Container();
  }

  Widget _buildMessageButton() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: AnimatedBuilder(
        animation: messageBoxAnimationController,
        builder: (context, child) {
          Color? buttonColor = messageBoxAnimation
              .drive(ColorTween(
                  begin: Theme.of(context).colorScheme.secondary,
                  end: Theme.of(context).primaryColor))
              .value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: IconButton(
              onPressed: () {
                if (messageBoxAnimationController.isCompleted) {
                  messageBoxAnimationController.reverse();
                } else {
                  messageBoxAnimationController.forward();
                }
              },
              icon: Icon(CupertinoIcons.chat_bubble_2_fill),
              color: buttonColor,
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessageBoxContainer() {
    return Align(
      alignment: Alignment.topCenter,
      child: SlideTransition(
        position: messageBoxAnimation
            .drive(Tween<Offset>(begin: Offset(1.5, 0), end: Offset.zero)),
        child: MessageBoxContainer(
          quizType: QuizTypes.battle,
          topPadding: MediaQuery.of(context).size.height *
                  UiUtils.getQuestionContainerTopPaddingPercentage(
                      MediaQuery.of(context).size.height) +
              MediaQuery.of(context).padding.top,
          battleRoomId: widget.isTournamentBattle
              ? context.read<TournamentBattleCubit>().getRoomId()
              : context.read<BattleRoomCubit>().getRoomId(),
          closeMessageBox: () {
            messageBoxAnimationController.reverse();
          },
        ),
      ),
    );
  }

  Widget _buildTopMenu() {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        margin: EdgeInsets.only(
            right: MediaQuery.of(context).size.width *
                ((1.0 - UiUtils.quesitonContainerWidthPercentage) * 0.5),
            left: MediaQuery.of(context).size.width *
                ((1.0 - UiUtils.quesitonContainerWidthPercentage) * 0.5),
            top: MediaQuery.of(context).padding.top),
        child: Row(
          children: [
            CustomBackButton(
              onTap: () {
                BattleRoomCubit battleRoomCubit =
                    context.read<BattleRoomCubit>();
                //
                //if user left the game
                if (showYouLeftQuiz) {
                  Navigator.of(context).pop();
                }
                //if user already won the game
                if (battleRoomCubit.opponentLeftTheGame(
                    context.read<UserDetailsCubit>().getUserId())) {
                  return;
                }

                isExitDialogOpen = true;
                //show warning
                showDialog(
                    context: context,
                    builder: (context) {
                      return ExitGameDailog(
                        onTapYes: () {
                          //
                          timerAnimationController.stop();
                          opponentUserTimerAnimationController.stop();
                          //delete messages
                          deleteMessages(battleRoomCubit.getRoomId());
                          //delete battle room
                          battleRoomCubit.deleteBattleRoom(false);
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        },
                      );
                    }).then((value) => isExitDialogOpen = false);
              },
              iconColor: Theme.of(context).backgroundColor,
            ),
            Spacer(),
            SettingButton(onPressed: () {
              toggleSettingDialog();
              showDialog(
                  context: context,
                  builder: (_) => SettingsDialogContainer()).then((value) {
                toggleSettingDialog();
              });
            }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final battleRoomCubit = context.read<BattleRoomCubit>();
    return WillPopScope(
      onWillPop: () {
        //if user left the game
        if (showYouLeftQuiz) {
          return Future.value(true);
        }
        //if user already won the game
        if (battleRoomCubit.opponentLeftTheGame(
            context.read<UserDetailsCubit>().getUserId())) {
          return Future.value(false);
        }

        isExitDialogOpen = true;
        //show warning
        showDialog(
            context: context,
            builder: (context) {
              return ExitGameDailog(
                onTapYes: () {
                  //
                  timerAnimationController.stop();
                  opponentUserTimerAnimationController.stop();
                  //delete messages
                  deleteMessages(battleRoomCubit.getRoomId());
                  //delete battle room
                  battleRoomCubit.deleteBattleRoom(false);
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              );
            }).then((value) => isExitDialogOpen = false);
        return Future.value(false);
      },
      child: Scaffold(
        body: MultiBlocListener(
          listeners: [
            BlocListener<BattleRoomCubit, BattleRoomState>(
              bloc: battleRoomCubit,
              listener: (context, state) {
                if (!widget.isTournamentBattle) {
                  //since this listener will be call everytime if any changes occurred
                  //in battleRoomCubit
                  battleRoomListener(context, state, battleRoomCubit);
                }
              },
            ),
            BlocListener<TournamentBattleCubit, TournamentBattleState>(
              bloc: context.read<TournamentBattleCubit>(),
              listener: (context, state) {
                if (widget.isTournamentBattle) {
                  //since this listener will be call everytime if any changes occurred
                  //in battleRoomCubit
                  tournamentBattleListener(
                      context, state, context.read<TournamentBattleCubit>());
                }
              },
            ),
            BlocListener<MessageCubit, MessageState>(
              bloc: context.read<MessageCubit>(),
              listener: (context, state) {
                //this listener will be call everytime when new message will add
                messagesListener(state);
              },
            ),
            BlocListener<UpdateScoreAndCoinsCubit, UpdateScoreAndCoinsState>(
              listener: (context, state) {
                if (state is UpdateScoreAndCoinsFailure) {
                  if (state.errorMessage == unauthorizedAccessCode) {
                    timerAnimationController.stop();
                    opponentUserTimerAnimationController.stop();
                    UiUtils.showAlreadyLoggedInDialog(context: context);
                  }
                }
              },
            ),
          ],
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              PageBackgroundGradientContainer(),
              Align(
                alignment: Alignment.topCenter,
                child: QuizPlayAreaBackgroundContainer(
                  heightPercentage: 0.875,
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: QuestionsContainer(
                  topPadding: MediaQuery.of(context).size.height *
                      UiUtils.getQuestionContainerTopPaddingPercentage(
                          MediaQuery.of(context).size.height),
                  timerAnimationController: timerAnimationController,
                  quizType: QuizTypes.battle,
                  showAnswerCorrectness: context
                      .read<SystemConfigCubit>()
                      .getShowCorrectAnswerMode(),
                  lifeLines: {},
                  guessTheWordQuestionContainerKeys: [],
                  guessTheWordQuestions: [],
                  hasSubmittedAnswerForCurrentQuestion:
                      hasSubmittedAnswerForCurrentQuestion,
                  questions: battleRoomCubit.getQuestions(),
                  submitAnswer: submitAnswer,
                  questionContentAnimation: questionContentAnimation,
                  questionScaleDownAnimation: questionScaleDownAnimation,
                  questionScaleUpAnimation: questionScaleUpAnimation,
                  questionSlideAnimation: questionSlideAnimation,
                  currentQuestionIndex: currentQuestionIndex,
                  questionAnimationController: questionAnimationController,
                  questionContentAnimationController:
                      questionContentAnimationController,
                ),
              ),
              _buildMessageBoxContainer(),
              _buildCurrentUserDetailsContainer(),
              _buildCurrentUserMessageContainer(),
              _buildOpponentUserDetailsContainer(),
              _buildOpponentUserMessageContainer(),
              _buildMessageButton(),
              _buildYouWonGameDailog(),
              _buildCurrentUserLeftTheGame(),
              _buildTopMenu(),
            ],
          ),
        ),
      ),
    );
  }
}
