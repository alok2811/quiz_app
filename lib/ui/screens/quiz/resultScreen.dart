import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ayuprep/app/appLocalization.dart';
import 'package:ayuprep/features/ads/interstitialAdCubit.dart';
import 'package:ayuprep/features/badges/cubits/badgesCubit.dart';
import 'package:ayuprep/features/battleRoom/models/battleRoom.dart';
import 'package:ayuprep/features/exam/models/exam.dart';
import 'package:ayuprep/features/quiz/cubits/comprehensionCubit.dart';
import 'package:ayuprep/features/quiz/cubits/quizCategoryCubit.dart';
import 'package:ayuprep/features/quiz/cubits/setCategoryPlayedCubit.dart';
import 'package:ayuprep/features/quiz/cubits/setContestLeaderboardCubit.dart';
import 'package:ayuprep/features/quiz/cubits/subCategoryCubit.dart';
import 'package:ayuprep/features/quiz/models/comprehension.dart';
import 'package:ayuprep/features/quiz/models/guessTheWordQuestion.dart';
import 'package:ayuprep/features/quiz/models/userBattleRoomDetails.dart';
import 'package:ayuprep/features/statistic/cubits/updateStatisticCubit.dart';
import 'package:ayuprep/features/statistic/statisticRepository.dart';
import 'package:ayuprep/features/systemConfig/cubits/systemConfigCubit.dart';
import 'package:ayuprep/ui/widgets/circularImageContainer.dart';

import 'package:ayuprep/ui/widgets/pageBackgroundGradientContainer.dart';
import 'package:ayuprep/utils/answerEncryption.dart';
import 'package:ayuprep/utils/constants.dart';
import 'package:ayuprep/utils/errorMessageKeys.dart';
import 'package:ayuprep/utils/stringLabels.dart';
import 'package:path_provider/path_provider.dart';

import 'package:ayuprep/app/routes.dart';
import 'package:ayuprep/features/profileManagement/cubits/updateScoreAndCoinsCubit.dart';
import 'package:ayuprep/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:ayuprep/features/profileManagement/profileManagementRepository.dart';
import 'package:ayuprep/features/quiz/cubits/updateLevelCubit.dart';
import 'package:ayuprep/features/quiz/models/question.dart';
import 'package:ayuprep/features/quiz/models/quizType.dart';
import 'package:ayuprep/features/quiz/quizRepository.dart';
import 'package:ayuprep/ui/screens/quiz/widgets/radialResultContainer.dart';

import 'package:ayuprep/ui/widgets/customRoundedButton.dart';
import 'package:ayuprep/utils/uiUtils.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class ResultScreen extends StatefulWidget {
  final QuizTypes?
      quizType; //to show different kind of result data for different quiz type
  final int?
      numberOfPlayer; //to show different kind of resut data for number of player
  final int?
      myPoints; // will be in use when quiz is not tyoe of battle and live battle
  final List<Question>? questions; //to see reivew answers
  final BattleRoom? battleRoom; //will be in use for battle
  final String? contestId;
  final Comprehension comprehension; //
  final List<GuessTheWordQuestion>?
      guessTheWordQuestions; //questions when quiz type is guessTheWord
  final int? entryFee;
  //if quizType is quizZone then it will be in use
  //to determine to show next level button
  //it will be in use if quizType is quizZone
  final String? subcategoryMaxLevel;
  //to determine if we need to update level or not
  //it will be in use if quizType is quizZone
  final int? unlockedLevel;

  //Time taken to complete the quiz in seconds
  final double? timeTakenToCompleteQuiz;

  //has used any lifeline - it will be in use to check badge earned or not for
  //quizZone quiz type
  final bool? hasUsedAnyLifeline;

  //Exam module details
  final Exam? exam; //to get the details related exam
  final int? obtainedMarks;
  final int? examCompletedInMinutes;
  final int? correctExamAnswers;
  final int? incorrectExamAnswers;

  //This will be in use if quizType is audio questions
  // and guess the word
  final bool isPlayed; //

  ResultScreen(
      {Key? key,
      required this.isPlayed,
      this.exam,
      this.correctExamAnswers,
      this.incorrectExamAnswers,
      this.obtainedMarks,
      this.examCompletedInMinutes,
      this.timeTakenToCompleteQuiz,
      this.hasUsedAnyLifeline,
      this.numberOfPlayer,
      this.myPoints,
      this.battleRoom,
      this.questions,
      this.unlockedLevel,
      this.quizType,
      this.subcategoryMaxLevel,
      this.contestId,
      required this.comprehension,
      this.guessTheWordQuestions,
      this.entryFee})
      : super(key: key);

  static Route<dynamic> route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    //keys of map are numberOfPlayer,quizType,questions (required)
    //if quizType is not battle and liveBattle need to pass following arguments
    //myPoints
    //if quizType is quizZone then need to pass following agruments
    //subcategoryMaxLevel, unlockedLevel
    //if quizType is battle and liveBattle then need to pass following agruments
    //battleRoom
    return CupertinoPageRoute(
        builder: (_) => MultiBlocProvider(
              providers: [
                //to update unlocked level for given subcategory
                BlocProvider<UpdateLevelCubit>(
                  create: (_) => UpdateLevelCubit(QuizRepository()),
                ),
                //to update user score and coins
                BlocProvider<UpdateScoreAndCoinsCubit>(
                  create: (_) =>
                      UpdateScoreAndCoinsCubit(ProfileManagementRepository()),
                ),
                //to update statistic
                BlocProvider<UpdateStatisticCubit>(
                  create: (_) => UpdateStatisticCubit(StatisticRepository()),
                ),
                //set ContestLeaderBoard
                BlocProvider<SetContestLeaderboardCubit>(
                  create: (_) => SetContestLeaderboardCubit(QuizRepository()),
                ),
                //set quiz category played
                BlocProvider<SetCategoryPlayed>(
                  create: (_) => SetCategoryPlayed(QuizRepository()),
                ),
              ],
              child: ResultScreen(
                isPlayed: arguments['isPlayed'] ?? true,
                comprehension:
                    arguments['comprehension'] ?? Comprehension.fromJson({}),
                correctExamAnswers: arguments['correctExamAnswers'],
                incorrectExamAnswers: arguments['incorrectExamAnswers'],
                exam: arguments['exam'],
                obtainedMarks: arguments['obtainedMarks'],
                examCompletedInMinutes: arguments['examCompletedInMinutes'],
                myPoints: arguments['myPoints'],
                numberOfPlayer: arguments['numberOfPlayer'],
                questions: arguments['questions'],
                battleRoom: arguments['battleRoom'],
                quizType: arguments['quizType'],
                subcategoryMaxLevel: arguments['subcategoryMaxLevel'],
                unlockedLevel: arguments['unlockedLevel'],
                guessTheWordQuestions: arguments['guessTheWordQuestions'], //
                hasUsedAnyLifeline: arguments['hasUsedAnyLifeline'],
                timeTakenToCompleteQuiz: arguments['timeTakenToCompleteQuiz'],
                contestId: arguments["contestId"],
                entryFee: arguments['entryFee'],
              ),
            ));
  }

  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final ScreenshotController screenshotController = ScreenshotController();
  List<Map<String, dynamic>> usersWithRank = [];
  late bool _isWinner;
  int _earnedCoins = 0;
  String? _winnerId;

  bool _displayedAlreadyLoggedInDailog = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      context.read<InterstitialAdCubit>().showAd(context);
    });
    if (widget.quizType == QuizTypes.battle) {
      battleConfiguration();
    } else {
      //decide winner
      if (winPercentage() >= winPercentageBreakPoint) {
        _isWinner = true;
      } else {
        _isWinner = false;
      }
      //earn coins based on percentage
      earnCoinsBasedOnWinPercentage();
      setContestLeaderboard();
    }

    //check for badges
    //update score,coins and statistic related details

    Future.delayed(Duration.zero, () {
      //earnBadge will check the condition for unlocking badges and
      //will return true or false
      //we need to return bool value so we can pass this to
      //updateScoreAndCoinsCubit since dashing_debut badge will unlock
      //from set_user_coin_score api
      _earnBadges();
      _updateScoreAndCoinsDetails();
      _updateStatistics();
    });
  }

  void _updateStatistics() {
    if (widget.quizType != QuizTypes.selfChallenge &&
        widget.quizType != QuizTypes.exam) {
      context.read<UpdateStatisticCubit>().updateStatistic(
            answeredQuestion: attemptedQuestion(),
            categoryId: getCategoryIdOfQuestion(),
            userId: context.read<UserDetailsCubit>().getUserId(),
            correctAnswers: correctAnswer(),
            winPercentage: winPercentage(),
          );
    }
  }

  //update stats related to battle, score of user and coins given to winner
  void battleConfiguration() async {
    String winnerId = "";

    if (widget.battleRoom!.user1!.points == widget.battleRoom!.user2!.points) {
      _isWinner = true;
      _winnerId = winnerId;
      _updateCoinsAndScoreAndStatsiticForBattle(widget.battleRoom!.entryFee!);
    } else {
      if (widget.battleRoom!.user1!.points > widget.battleRoom!.user2!.points) {
        winnerId = widget.battleRoom!.user1!.uid;
      } else {
        winnerId = widget.battleRoom!.user2!.uid;
      }
      await Future.delayed(Duration.zero);
      _isWinner = context.read<UserDetailsCubit>().getUserId() == winnerId;
      _winnerId = winnerId;
      _updateCoinsAndScoreAndStatsiticForBattle(
          widget.battleRoom!.entryFee! * 2);
      //update winner id and _isWinner in ui
      setState(() {});
    }
  }

  void _updateCoinsAndScoreAndStatsiticForBattle(int earnedCoins) {
    Future.delayed(Duration.zero, () {
      //
      String currentUserId = context.read<UserDetailsCubit>().getUserId();
      UserBattleRoomDetails currentUser =
          widget.battleRoom!.user1!.uid == currentUserId
              ? widget.battleRoom!.user1!
              : widget.battleRoom!.user2!;
      if (_isWinner) {
        //update score and coins for user
        context.read<UpdateScoreAndCoinsCubit>().updateCoinsAndScore(
              currentUserId,
              currentUser.points,
              true,
              earnedCoins,
              wonBattleKey,
            );
        //update score locally and database
        context
            .read<UserDetailsCubit>()
            .updateCoins(addCoin: true, coins: earnedCoins);
        context.read<UserDetailsCubit>().updateScore(currentUser.points);

        //update battle stats
        context.read<UpdateStatisticCubit>().updateBattleStatistic(
              userId1: widget.battleRoom!.user1!.uid,
              userId2: widget.battleRoom!.user2!.uid,
              winnerId: _winnerId!,
            );
      } else {
        //if user is not winner then update only score
        context
            .read<UpdateScoreAndCoinsCubit>()
            .updateScore(currentUserId, currentUser.points);
        context.read<UserDetailsCubit>().updateScore(currentUser.points);
      }
    });
  }

  void _earnBadges() {
    String userId = context.read<UserDetailsCubit>().getUserId();
    BadgesCubit badgesCubit = context.read<BadgesCubit>();
    if (widget.quizType == QuizTypes.battle) {
      //if badges is locked
      if (badgesCubit.isBadgeLocked("ultimate_player")) {
        int badgeEarnPoints =
            (correctAnswerPointsForBattle + extraPointForQuickestAnswer) *
                totalQuestions();

        //if user's points is same as highest points
        UserBattleRoomDetails currentUser =
            widget.battleRoom!.user1!.uid == userId
                ? widget.battleRoom!.user1!
                : widget.battleRoom!.user2!;
        if (currentUser.points == badgeEarnPoints) {
          badgesCubit.setBadge(badgeType: "ultimate_player", userId: userId);
        }
      }
    } else if (widget.quizType == QuizTypes.funAndLearn) {
      //
      //if totalQuestion is less than minimum question then do not check for badges
      if (totalQuestions() < minimumQuestionsForBadges) {
        return;
      }

      //funAndLearn is related to flashback
      if (badgesCubit.isBadgeLocked("flashback")) {
        int funNLearnQuestionMinimumTimeForBadge =
            badgesCubit.getBadgeCounterByType("flashback");
        //if badges not loaded some how
        if (funNLearnQuestionMinimumTimeForBadge == -1) {
          return;
        }
        int badgeEarnTimeInSeconds =
            totalQuestions() * funNLearnQuestionMinimumTimeForBadge;
        if (correctAnswer() == totalQuestions() &&
            widget.timeTakenToCompleteQuiz! <=
                badgeEarnTimeInSeconds.toDouble()) {
          badgesCubit.setBadge(badgeType: "flashback", userId: userId);
        }
      }
    } else if (widget.quizType == QuizTypes.quizZone) {
      if (badgesCubit.isBadgeLocked("dashing_debut")) {
        print("Unlock dashing debut badge");
        badgesCubit.setBadge(badgeType: "dashing_debut", userId: userId);
      }
      //
      //if totalQuestion is less than minimum question then do not check for badges

      if (totalQuestions() < minimumQuestionsForBadges) {
        return;
      }

      if (badgesCubit.isBadgeLocked("brainiac")) {
        if (correctAnswer() == totalQuestions() &&
            !widget.hasUsedAnyLifeline!) {
          badgesCubit.setBadge(badgeType: "brainiac", userId: userId);
        }
      }
    } else if (widget.quizType == QuizTypes.guessTheWord) {
      //if totalQuestion is less than minimum question then do not check for badges
      if (totalQuestions() < minimumQuestionsForBadges) {
        return;
      }

      if (badgesCubit.isBadgeLocked("super_sonic")) {
        int guessTheWordQuestionMinimumTimeForBadge =
            badgesCubit.getBadgeCounterByType("super_sonic");

        //if badges not loaded some how
        if (guessTheWordQuestionMinimumTimeForBadge == -1) {
          return;
        }

        //if user has solved the quiz with in badgeEarnTime then they can earn badge
        int badgeEarnTimeInSeconds =
            totalQuestions() * guessTheWordQuestionMinimumTimeForBadge;
        if (correctAnswer() == totalQuestions() &&
            widget.timeTakenToCompleteQuiz! <=
                badgeEarnTimeInSeconds.toDouble()) {
          badgesCubit.setBadge(badgeType: "super_sonic", userId: userId);
        }
      }
    } else if (widget.quizType == QuizTypes.dailyQuiz) {
      if (badgesCubit.isBadgeLocked("thirsty")) {
        //
        badgesCubit.setBadge(badgeType: "thirsty", userId: userId);
      }
    }
  }

  void setContestLeaderboard() async {
    await Future.delayed(Duration.zero);
    if (widget.quizType == QuizTypes.contest) {
      context.read<SetContestLeaderboardCubit>().setContestLeaderboard(
          userId: context.read<UserDetailsCubit>().getUserId(),
          questionAttended: attemptedQuestion(),
          correctAns: correctAnswer(),
          contestId: widget.contestId,
          score: widget.myPoints);
    }
  }

  String _getCoinUpdateTypeBasedOnQuizZone() {
    if (widget.quizType == QuizTypes.quizZone) {
      return wonQuizZoneKey;
    }
    if (widget.quizType == QuizTypes.guessTheWord) {
      return wonGuessTheWordKey;
    }
    if (widget.quizType == QuizTypes.trueAndFalse) {
      return wonTrueFalseKey;
    }
    if (widget.quizType == QuizTypes.dailyQuiz) {
      return wonDailyQuizKey;
    }
    if (widget.quizType == QuizTypes.audioQuestions) {
      return wonAudioQuizKey;
    }
    if (widget.quizType == QuizTypes.funAndLearn) {
      return wonFunNLearnKey;
    }

    return "-";
  }

  void _updateCoinsAndScore() {
    //update score and coins for user
    context.read<UpdateScoreAndCoinsCubit>().updateCoinsAndScore(
        context.read<UserDetailsCubit>().getUserId(),
        widget.myPoints!,
        true,
        _earnedCoins,
        _getCoinUpdateTypeBasedOnQuizZone());
    //update score locally and database
    context
        .read<UserDetailsCubit>()
        .updateCoins(addCoin: true, coins: _earnedCoins);

    context.read<UserDetailsCubit>().updateScore(widget.myPoints);
  }

  //
  void _updateScoreAndCoinsDetails() {
    //if percentage is more than 30 then update socre and coins
    if (_isWinner) {
      //
      //if quizType is quizZone we need to update unlocked level,coins and score
      //only one time
      //
      if (widget.quizType == QuizTypes.quizZone) {
        //if given level is same as unlocked level then update level
        if (int.parse(widget.questions!.first.level!) == widget.unlockedLevel) {
          int updatedLevel = int.parse(widget.questions!.first.level!) + 1;
          //update level
          context.read<UpdateLevelCubit>().updateLevel(
              context.read<UserDetailsCubit>().getUserId(),
              widget.questions!.first.categoryId,
              widget.questions!.first.subcategoryId,
              updatedLevel.toString());
          _updateCoinsAndScore();
        } else {
          print("Level already unlocked so no coins and score updates");
        }
      }
      //
      else if (widget.quizType == QuizTypes.funAndLearn &&
          !widget.comprehension.isPlayed) {
        _updateCoinsAndScore();
        context.read<SetCategoryPlayed>().setCategoryPlayed(
            quizType: QuizTypes.funAndLearn,
            userId: context.read<UserDetailsCubit>().getUserId(),
            categoryId: widget.questions!.first.categoryId!,
            subcategoryId: widget.questions!.first.subcategoryId! == "0"
                ? ""
                : widget.questions!.first.subcategoryId!,
            typeId: widget.comprehension.id!);
      }
      //
      else if (widget.quizType == QuizTypes.guessTheWord && !widget.isPlayed) {
        _updateCoinsAndScore();
        context.read<SetCategoryPlayed>().setCategoryPlayed(
            quizType: QuizTypes.guessTheWord,
            userId: context.read<UserDetailsCubit>().getUserId(),
            categoryId: widget.guessTheWordQuestions!.first.category,
            subcategoryId:
                widget.guessTheWordQuestions!.first.subcategory == "0"
                    ? ""
                    : widget.guessTheWordQuestions!.first.subcategory,
            typeId: "");
      }
      //
      else if (widget.quizType == QuizTypes.audioQuestions &&
          !widget.isPlayed) {
        //
        _updateCoinsAndScore();
        context.read<SetCategoryPlayed>().setCategoryPlayed(
            quizType: QuizTypes.audioQuestions,
            userId: context.read<UserDetailsCubit>().getUserId(),
            categoryId: widget.questions!.first.categoryId!,
            subcategoryId: widget.questions!.first.subcategoryId! == "0"
                ? ""
                : widget.questions!.first.subcategoryId!,
            typeId: "");
      }
    }
  }

  void earnCoinsBasedOnWinPercentage() {
    if (_isWinner) {
      double percentage = winPercentage();
      _earnedCoins =
          UiUtils.coinsBasedOnWinPercentage(percentage, widget.quizType!);
    }
  }

  //This will execute once user press back button or go back from result screen
  //so respective data of category,sub category and fun n learn can be updated
  void onPageBackCalls() {
    if (widget.quizType == QuizTypes.funAndLearn &&
        _isWinner &&
        !widget.comprehension.isPlayed) {
      context.read<ComprehensionCubit>().getComprehension(
            languageId: UiUtils.getCurrentQuestionLanguageId(context),
            type: widget.questions!.first.subcategoryId! == "0"
                ? "category"
                : "subcategory",
            typeId: widget.questions!.first.subcategoryId! == "0"
                ? widget.questions!.first.categoryId!
                : widget.questions!.first.subcategoryId!,
            userId: context.read<UserDetailsCubit>().getUserId(),
          );
    } else if (widget.quizType == QuizTypes.audioQuestions &&
        _isWinner &&
        !widget.isPlayed) {
      //
      if (widget.questions!.first.subcategoryId == "0") {
        //update category
        context.read<QuizCategoryCubit>().getQuizCategory(
            languageId: UiUtils.getCurrentQuestionLanguageId(context),
            type: UiUtils.getCategoryTypeNumberFromQuizType(
                QuizTypes.audioQuestions),
            userId: context.read<UserDetailsCubit>().getUserId());
      } else {
        //update subcategory
        context.read<SubCategoryCubit>().fetchSubCategory(
            widget.questions!.first.categoryId!,
            context.read<UserDetailsCubit>().getUserId());
      }
    }
    //
    else if (widget.quizType == QuizTypes.guessTheWord &&
        _isWinner &&
        !widget.isPlayed) {
      if (widget.guessTheWordQuestions!.first.subcategory == "0") {
        //update category
        context.read<QuizCategoryCubit>().getQuizCategory(
            languageId: UiUtils.getCurrentQuestionLanguageId(context),
            type: UiUtils.getCategoryTypeNumberFromQuizType(
                QuizTypes.guessTheWord),
            userId: context.read<UserDetailsCubit>().getUserId());
      } else {
        //update subcategory
        context.read<SubCategoryCubit>().fetchSubCategory(
            widget.guessTheWordQuestions!.first.category,
            context.read<UserDetailsCubit>().getUserId());
      }
    }
  }

  String getCategoryIdOfQuestion() {
    if (widget.quizType == QuizTypes.battle) {
      return widget.battleRoom!.categoryId!.isEmpty
          ? "0"
          : widget.battleRoom!.categoryId!;
    }
    if (widget.quizType == QuizTypes.guessTheWord) {
      return widget.guessTheWordQuestions!.first.category;
    }
    return widget.questions!.first.categoryId!.isEmpty
        ? "-"
        : widget.questions!.first.categoryId!;
  }

  int correctAnswer() {
    if (widget.quizType == QuizTypes.exam) {
      return widget.correctExamAnswers!;
    }
    int correctAnswer = 0;
    if (widget.quizType == QuizTypes.guessTheWord) {
      for (var question in widget.guessTheWordQuestions!) {
        if (question.answer ==
            UiUtils.buildGuessTheWordQuestionAnswer(question.submittedAnswer)) {
          correctAnswer++;
        }
      }
    } else {
      for (var question in widget.questions!) {
        if (AnswerEncryption.decryptCorrectAnswer(
                rawKey: context.read<UserDetailsCubit>().getUserFirebaseId(),
                correctAnswer: question.correctAnswer!) ==
            question.submittedAnswerId) {
          correctAnswer++;
        }
      }
    }
    return correctAnswer;
  }

  int attemptedQuestion() {
    int attemptedQuestion = 0;
    if (widget.quizType == QuizTypes.exam) {
      return 0;
    }
    if (widget.quizType == QuizTypes.guessTheWord) {
      //
      for (var question in widget.guessTheWordQuestions!) {
        if (question.hasAnswered) {
          attemptedQuestion++;
        }
      }
    } else {
      //
      for (var question in widget.questions!) {
        if (question.attempted) {
          attemptedQuestion++;
        }
      }
    }
    return attemptedQuestion;
  }

  double winPercentage() {
    if (widget.quizType == QuizTypes.exam) {
      return (widget.obtainedMarks! * 100.0) /
          int.parse(widget.exam!.totalMarks);
    }
    if (widget.quizType == QuizTypes.guessTheWord) {
      return (correctAnswer() * 100.0) / widget.guessTheWordQuestions!.length;
    } else if (widget.quizType == QuizTypes.battle) {
      return 0.0;
    } else {
      return (correctAnswer() * 100.0) / widget.questions!.length;
    }
  }

  bool showCoinsAndScore() {
    if (widget.quizType == QuizTypes.selfChallenge ||
        widget.quizType == QuizTypes.contest ||
        widget.quizType == QuizTypes.exam) {
      return false;
    }

    if (widget.quizType == QuizTypes.quizZone) {
      return (int.parse(widget.questions!.first.level!) ==
          widget.unlockedLevel);
    }
    if (widget.quizType == QuizTypes.funAndLearn) {
      //if user completed more than 30% and has not played this paragraph yet
      return _isWinner && !widget.comprehension.isPlayed;
    }
    if (widget.quizType == QuizTypes.guessTheWord) {
      //if user completed more than 30% and has not played this paragraph yet
      return _isWinner && !widget.isPlayed;
    }
    if (widget.quizType == QuizTypes.audioQuestions) {
      //if user completed more than 30% and has not played this paragraph yet
      return _isWinner && !widget.isPlayed;
    }
    return _isWinner;
  }

  int totalQuestions() {
    if (widget.quizType == QuizTypes.exam) {
      return (widget.correctExamAnswers! + widget.incorrectExamAnswers!);
    }
    if (widget.quizType == QuizTypes.guessTheWord) {
      return widget.guessTheWordQuestions!.length;
    }
    return widget.questions!.length;
  }

  Widget _buildGreetingMessage(String title, String message) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 15.0,
        ),
        Platform.isIOS
            ? Stack(children: [
                Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 15.0,
                      ),
                      child: InkWell(
                          onTap: () {
                            onPageBackCalls();
                            Navigator.pop(context);
                          },
                          child: Container(
                              padding: EdgeInsets.all(5.0),
                              decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.transparent)),
                              child: Icon(
                                Icons.arrow_back_ios,
                                color: Theme.of(context).backgroundColor,
                              ))),
                    )),
                Container(
                    alignment: Alignment.center,
                    child: Text(
                      "$message",
                      style: TextStyle(
                          fontSize: 19.0,
                          color: Theme.of(context).backgroundColor),
                    )),
              ])
            : Container(
                alignment: Alignment.center,
                child: Text(
                  "$message",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 19.0,
                    color: Theme.of(context).backgroundColor,
                  ),
                )),
        SizedBox(
          height: 5.0,
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 5.0),
          alignment: Alignment.center,
          child: Text("$title",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 25.0 * MediaQuery.of(context).textScaleFactor * 1.25,
                color: Theme.of(context).backgroundColor,
              )),
        )
      ],
    );
  }

  Widget _buildResultDataWithIconContainer(
      String title, String icon, EdgeInsetsGeometry margin) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
          color: Theme.of(context).backgroundColor,
          borderRadius: BorderRadius.circular(10.0)),
      width: MediaQuery.of(context).size.width * (0.2125),
      height: 30.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(UiUtils.getImagePath(icon),
              color: Theme.of(context).colorScheme.secondary),
          SizedBox(
            width: 5,
          ),
          Text(
            title,
            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
          ),
        ],
      ),
      alignment: Alignment.center,
    );
  }

  Widget _buildIndividualResultContainer(String userProfileUrl) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Align(
          alignment: Alignment.center,
          child: SvgPicture.asset(
            widget.quizType == QuizTypes.exam
                ? UiUtils.getImagePath("celebration.svg")
                : _isWinner
                    ? UiUtils.getImagePath("celebration.svg")
                    : UiUtils.getImagePath("celebration_loss.svg"),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: LayoutBuilder(
            builder: (context, constraints) {
              double verticalSpacePercentage = 0.0;
              double profileRadiusPercentage = 0.0;

              double radialSizePercentage = 0.0;
              if (constraints.maxHeight <
                  UiUtils.profileHeightBreakPointResultScreen) {
                verticalSpacePercentage = 0.015;
                profileRadiusPercentage = 0.35; //test in
                radialSizePercentage = 0.6;
              } else {
                verticalSpacePercentage = 0.035;
                profileRadiusPercentage = 0.375;

                radialSizePercentage = 0.525;
              }

              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  widget.quizType! == QuizTypes.exam
                      ? _buildGreetingMessage(
                          widget.exam!.title,
                          AppLocalization.of(context)!
                              .getTranslatedValues(examResultKey)!)
                      : _isWinner
                          ? _buildGreetingMessage(
                              AppLocalization.of(context)!
                                  .getTranslatedValues("victoryLbl")!,
                              AppLocalization.of(context)!
                                  .getTranslatedValues("congratulationsLbl")!)
                          : _buildGreetingMessage(
                              AppLocalization.of(context)!
                                  .getTranslatedValues("defeatLbl")!,
                              AppLocalization.of(context)!
                                  .getTranslatedValues("betterNextLbl")!),
                  SizedBox(
                    height: constraints.maxHeight * verticalSpacePercentage,
                  ),
                  widget.quizType! == QuizTypes.exam
                      ? Transform.translate(
                          offset: Offset(0.0, -20.0), //
                          child: RadialPercentageResultContainer(
                            circleColor:
                                Theme.of(context).colorScheme.secondary,
                            arcColor: Theme.of(context).backgroundColor,
                            arcStrokeWidth: 12.0,
                            textFontSize: 20,
                            circleStrokeWidth: 12.0,
                            radiusPercentage: 0.27,
                            percentage: winPercentage(),

                            timeTakenToCompleteQuizInSeconds:
                                widget.examCompletedInMinutes,
                            size: Size(
                                constraints.maxHeight * radialSizePercentage,
                                constraints.maxHeight *
                                    radialSizePercentage), //150.0 , 150.0
                          ),
                        )
                      : Stack(
                          alignment: Alignment.center,
                          children: [
                            Center(
                              child: Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.5),
                                    shape: BoxShape.circle,
                                  ),
                                  height: constraints.maxHeight *
                                      profileRadiusPercentage),
                            ),
                            Center(
                              child: Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  height: constraints.maxHeight *
                                      (profileRadiusPercentage - 0.025)),
                            ),
                            Center(
                              child: CircularImageContainer(
                                  imagePath: userProfileUrl,
                                  height: constraints.maxHeight *
                                      (profileRadiusPercentage - 0.05),
                                  width: constraints.maxWidth *
                                      (profileRadiusPercentage - 0.05 + 0.15)),
                            ),
                          ],
                        ),
                  widget.quizType! == QuizTypes.exam
                      ? Transform.translate(
                          offset: Offset(0, -30.0),
                          child: Text(
                            "${widget.obtainedMarks}/${widget.exam!.totalMarks} ${AppLocalization.of(context)!.getTranslatedValues(markKey)!}",
                            style: TextStyle(
                              fontSize: 22.0 *
                                  MediaQuery.of(context).textScaleFactor *
                                  (1.1),
                              fontWeight: FontWeight.w400,
                              color: Theme.of(context)
                                  .backgroundColor, //Theme.of(context).backgroundColor,
                            ),
                          ),
                        )
                      : Text(
                          _isWinner
                              ? AppLocalization.of(context)!
                                  .getTranslatedValues("winnerLbl")!
                              : AppLocalization.of(context)!
                                  .getTranslatedValues("youLossLbl")!,
                          style: TextStyle(
                            fontSize: 25.0 *
                                MediaQuery.of(context).textScaleFactor *
                                (1.1),
                            fontWeight: FontWeight.w400,
                            color: Theme.of(context)
                                .backgroundColor, //Theme.of(context).backgroundColor,
                          ),
                        )
                ],
              );
            },
          ),
        ),

        //incorrect answer
        Align(
          alignment: AlignmentDirectional.bottomStart,
          child: _buildResultDataWithIconContainer(
              widget.quizType == QuizTypes.exam
                  ? "${widget.incorrectExamAnswers}/${totalQuestions()}"
                  : "${totalQuestions() - correctAnswer()}/${totalQuestions()}",
              "wrong.svg",
              EdgeInsetsDirectional.only(
                  start: 15.0, bottom: showCoinsAndScore() ? 20.0 : 30.0)),
        ),
        //correct answer
        showCoinsAndScore()
            ? Align(
                alignment: AlignmentDirectional.bottomStart,
                child: _buildResultDataWithIconContainer(
                    "${correctAnswer()}/${totalQuestions()}",
                    "correct.svg",
                    EdgeInsetsDirectional.only(start: 15.0, bottom: 60.0)),
              )
            : Align(
                alignment: Alignment.bottomRight,
                child: _buildResultDataWithIconContainer(
                    "${correctAnswer()}/${totalQuestions()}",
                    "correct.svg",
                    EdgeInsetsDirectional.only(end: 15.0, bottom: 30.0)),
              ),

        //points
        showCoinsAndScore()
            ? Align(
                alignment: AlignmentDirectional.bottomEnd,
                child: _buildResultDataWithIconContainer(
                    "${widget.myPoints}",
                    "score.svg",
                    EdgeInsetsDirectional.only(end: 15.0, bottom: 60.0)),
              )
            : Container(),

        //earned coins
        showCoinsAndScore()
            ? Align(
                alignment: AlignmentDirectional.bottomEnd,
                child: _buildResultDataWithIconContainer(
                    "$_earnedCoins",
                    "earnedCoin.svg",
                    EdgeInsetsDirectional.only(end: 15.0, bottom: 20.0)),
              )
            : Container(),

        //build radils percentage container
        widget.quizType! == QuizTypes.exam
            ? Container()
            : Align(
                alignment: Alignment.bottomCenter,
                child: LayoutBuilder(builder: (context, constraints) {
                  double radialSizePercentage = 0.0;
                  if (constraints.maxHeight <
                      UiUtils.profileHeightBreakPointResultScreen) {
                    radialSizePercentage = 0.4;
                  } else {
                    radialSizePercentage = 0.325;
                  }
                  return Transform.translate(
                    offset: Offset(0.0, 15.0), //
                    child: RadialPercentageResultContainer(
                      circleColor: Theme.of(context).colorScheme.secondary,
                      arcColor: Theme.of(context).backgroundColor,
                      arcStrokeWidth: 10.0,
                      circleStrokeWidth: 10.0,
                      radiusPercentage: 0.27,
                      percentage: winPercentage(),
                      timeTakenToCompleteQuizInSeconds:
                          widget.timeTakenToCompleteQuiz?.toInt(),
                      size: Size(
                          constraints.maxHeight * radialSizePercentage,
                          constraints.maxHeight *
                              radialSizePercentage), //150.0 , 150.0
                    ),
                  );
                }),
              ),
      ],
    );
  }

  Widget _buildBattleResultDetails() {
    UserBattleRoomDetails? winnerDetails =
        widget.battleRoom!.user1!.uid == _winnerId
            ? widget.battleRoom!.user1
            : widget.battleRoom!.user2;
    UserBattleRoomDetails? looserDetails =
        widget.battleRoom!.user1!.uid != _winnerId
            ? widget.battleRoom!.user1
            : widget.battleRoom!.user2;

    return _winnerId == null
        ? Container()
        : LayoutBuilder(
            builder: (context, constraints) {
              double profileRadiusPercentage = 0.0;
              double looserProfileRadiusPercentage = 0.0;
              double verticalSpacePercentage = 0.0;
              double translateOffsetdy = 0.0;
              double nameAndProfileSizedBoxHeight = 0.0;
              if (constraints.maxHeight <
                  UiUtils.profileHeightBreakPointResultScreen) {
                profileRadiusPercentage = _winnerId!.isEmpty ? 0.165 : 0.18;
                verticalSpacePercentage = _winnerId!.isEmpty ? 0.035 : 0.03;
                looserProfileRadiusPercentage =
                    _winnerId!.isEmpty ? profileRadiusPercentage : 0.127;
                translateOffsetdy = -15.0;
                nameAndProfileSizedBoxHeight = 5.0;
              } else {
                profileRadiusPercentage = _winnerId!.isEmpty ? 0.15 : 0.17;
                verticalSpacePercentage = _winnerId!.isEmpty ? 0.075 : 0.05;
                looserProfileRadiusPercentage =
                    _winnerId!.isEmpty ? profileRadiusPercentage : 0.11;
                translateOffsetdy = 25.0;
                nameAndProfileSizedBoxHeight = 10.0;
              }

              return Column(
                children: [
                  _winnerId!.isEmpty
                      ? _buildGreetingMessage(
                          AppLocalization.of(context)!
                              .getTranslatedValues("matchDrawLbl")!,
                          AppLocalization.of(context)!
                              .getTranslatedValues("congratulationsLbl")!)
                      : _isWinner
                          ? _buildGreetingMessage(
                              AppLocalization.of(context)!
                                  .getTranslatedValues("victoryLbl")!,
                              AppLocalization.of(context)!
                                  .getTranslatedValues("congratulationsLbl")!)
                          : _buildGreetingMessage(
                              AppLocalization.of(context)!
                                  .getTranslatedValues("defeatLbl")!,
                              AppLocalization.of(context)!
                                  .getTranslatedValues("betterNextLbl")!),
                  context.read<UserDetailsCubit>().getUserId() == _winnerId
                      ? Text(
                          AppLocalization.of(context)!
                                  .getTranslatedValues("youWin")! +
                              " ${widget.entryFee} " +
                              AppLocalization.of(context)!
                                  .getTranslatedValues("coinsLbl")!,
                          style: TextStyle(
                              fontSize: 17.0,
                              color: Theme.of(context).backgroundColor),
                        )
                      : Text(
                          AppLocalization.of(context)!
                                  .getTranslatedValues("youLossLbl")! +
                              " ${widget.entryFee} " +
                              AppLocalization.of(context)!
                                  .getTranslatedValues("coinsLbl")!,
                          style: TextStyle(
                              fontSize: 17.0,
                              color: Theme.of(context).backgroundColor),
                        ),
                  SizedBox(
                    height:
                        constraints.maxHeight * verticalSpacePercentage - 10.2,
                  ),
                  _winnerId!.isEmpty
                      ? Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          child: Row(
                            children: [
                              Column(
                                children: [
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Center(
                                            child: CircleAvatar(
                                              radius: constraints.maxHeight *
                                                  (profileRadiusPercentage),
                                              backgroundImage:
                                                  CachedNetworkImageProvider(
                                                      widget.battleRoom!.user1!
                                                          .profileUrl),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: nameAndProfileSizedBoxHeight,
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 4.0, horizontal: 5.0),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).backgroundColor,
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    width: constraints.maxWidth * (0.3),
                                    child: Text(
                                      "${widget.battleRoom!.user1!.name}",
                                      style: TextStyle(
                                          color:
                                              Theme.of(context).primaryColor),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 4,
                                  ),
                                  Container(
                                    width: constraints.maxWidth * (0.3),
                                    padding: EdgeInsets.only(left: 10),
                                    child: Text(
                                      AppLocalization.of(context)!
                                          .getTranslatedValues("winnerLbl")!,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .backgroundColor),
                                    ),
                                  ),
                                ],
                              ),
                              Spacer(),
                              Column(
                                children: [
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Center(
                                        child: CircleAvatar(
                                          radius: constraints.maxHeight *
                                              (profileRadiusPercentage),
                                          backgroundImage:
                                              CachedNetworkImageProvider(widget
                                                  .battleRoom!
                                                  .user2!
                                                  .profileUrl),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: nameAndProfileSizedBoxHeight,
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 4.0, horizontal: 5.0),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).backgroundColor,
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    width: constraints.maxWidth * (0.3),
                                    child: Text(
                                      "${widget.battleRoom!.user2!.name}",
                                      style: TextStyle(
                                          color:
                                              Theme.of(context).primaryColor),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 4,
                                  ),
                                  Container(
                                    width: constraints.maxWidth * (0.3),
                                    padding: EdgeInsets.only(left: 10),
                                    child: Text(
                                      AppLocalization.of(context)!
                                          .getTranslatedValues("winnerLbl")!,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .backgroundColor),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      : Row(
                          children: [
                            SizedBox(
                              width: 20.0,
                            ),
                            Column(
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Center(
                                      child: CircleAvatar(
                                        radius: constraints.maxHeight *
                                            (profileRadiusPercentage),
                                        backgroundImage:
                                            CachedNetworkImageProvider(
                                                winnerDetails!.profileUrl),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: nameAndProfileSizedBoxHeight,
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 4.0, horizontal: 5.0),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).backgroundColor,
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  width: constraints.maxWidth * (0.3),
                                  child: Text(
                                    "${winnerDetails.name}",
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                SizedBox(
                                  height: 4,
                                ),
                                Container(
                                  width: constraints.maxWidth * (0.3),
                                  padding:
                                      EdgeInsetsDirectional.only(start: 10),
                                  child: Text(
                                    AppLocalization.of(context)!
                                        .getTranslatedValues("winnerLbl")!,
                                    style: TextStyle(
                                        color:
                                            Theme.of(context).backgroundColor),
                                  ),
                                ),
                              ],
                            ),
                            Spacer(),
                            Transform.translate(
                              offset: Offset(0.0, translateOffsetdy),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Center(
                                        child: CircleAvatar(
                                          radius: constraints.maxHeight *
                                              (looserProfileRadiusPercentage),
                                          backgroundImage:
                                              CachedNetworkImageProvider(
                                                  looserDetails!.profileUrl),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: nameAndProfileSizedBoxHeight,
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 4.0, horizontal: 5.0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5.0),
                                      color: Theme.of(context).backgroundColor,
                                    ),
                                    width: constraints.maxWidth * (0.3),
                                    child: Text(
                                      "${looserDetails.name}",
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color:
                                              Theme.of(context).primaryColor),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 2.0,
                                  ),
                                  Container(
                                    width: constraints.maxWidth * (0.3),
                                    padding:
                                        EdgeInsetsDirectional.only(start: 10),
                                    child: Text(
                                      AppLocalization.of(context)!
                                          .getTranslatedValues("looserLbl")!,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .backgroundColor),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 20.0,
                            ),
                          ],
                        ),
                  Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(
                        vertical: constraints.maxHeight <
                                UiUtils.profileHeightBreakPointResultScreen
                            ? 7.5
                            : 15.0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Theme.of(context).backgroundColor,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    width: constraints.maxWidth * (0.8),
                    child: Text(
                      "${winnerDetails!.points}:${looserDetails!.points}",
                      style: TextStyle(
                          fontSize: 17.5,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).primaryColor),
                    ),
                  ),
                  SizedBox(
                    height: constraints.maxHeight <
                            UiUtils.profileHeightBreakPointResultScreen
                        ? 10.0
                        : 20.0,
                  ),
                ],
              );
            },
          );
  }

  Widget _buildResultDetails(BuildContext context) {
    final userProfileUrl =
        context.read<UserDetailsCubit>().getUserProfile().profileUrl ?? "";

    //build results for 1 user
    if (widget.numberOfPlayer == 1) {
      return _buildIndividualResultContainer(userProfileUrl);
    }
    if (widget.numberOfPlayer == 2) {
      return _buildBattleResultDetails();
    }
    return Container();
  }

  Widget _buildResultContainer(BuildContext context) {
    return Screenshot(
      controller: screenshotController,
      child: Container(
        height: MediaQuery.of(context).size.height * (0.575),
        width: MediaQuery.of(context).size.width * (0.85),
        decoration: BoxDecoration(
          boxShadow: [UiUtils.buildBoxShadow()],
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: _buildResultDetails(context),
      ),
    );
  }

  Widget _buildButton(
      String buttonTitle, Function onTap, BuildContext context) {
    return CustomRoundedButton(
      widthPercentage: 0.85,
      backgroundColor: Theme.of(context).primaryColor,
      buttonTitle: buttonTitle,
      radius: 7.5,
      elevation: 5.0,
      showBorder: false,
      fontWeight: FontWeight.bold,
      height: 50.0,
      titleColor: Theme.of(context).backgroundColor,
      onTap: onTap,
      textSize: 17.0,
    );
  }

  //paly again button will be build different for every quizType
  Widget _buildPlayAgainButton() {
    if (widget.quizType == QuizTypes.selfChallenge) {
      return Container();
    } else if (widget.quizType == QuizTypes.audioQuestions) {
      if (_isWinner) {
        return Container();
      }

      return _buildButton(
          AppLocalization.of(context)!.getTranslatedValues("playAgainBtn")!,
          () {
        Navigator.of(context).pushReplacementNamed(Routes.quiz, arguments: {
          "numberOfPlayer": 1,
          "isPlayed": widget.isPlayed,
          "quizType": QuizTypes.audioQuestions,
          "subcategoryId": widget.questions!.first.subcategoryId == "0"
              ? ""
              : widget.questions!.first.subcategoryId,
          "categoryId": widget.questions!.first.subcategoryId == "0"
              ? widget.questions!.first.categoryId
              : "",
        });
      }, context);
    } else if (widget.quizType == QuizTypes.guessTheWord) {
      if (_isWinner) {
        return Container();
      }

      return _buildButton(
          AppLocalization.of(context)!.getTranslatedValues("playAgainBtn")!,
          () {
        Navigator.of(context)
            .pushReplacementNamed(Routes.guessTheWord, arguments: {
          "isPlayed": widget.isPlayed,
          "type": widget.guessTheWordQuestions!.first.subcategory == "0"
              ? "category"
              : "subcategory",
          "typeId": widget.guessTheWordQuestions!.first.subcategory == "0"
              ? widget.guessTheWordQuestions!.first.category
              : widget.guessTheWordQuestions!.first.subcategory,
        });
      }, context);
    } else if (widget.quizType == QuizTypes.funAndLearn) {
      return Container();
    } else if (widget.quizType == QuizTypes.quizZone) {
      //if user is winner
      if (_isWinner) {
        //we need to check if currentLevel is last level or not
        int maxLevel = int.parse(widget.subcategoryMaxLevel!);
        int currentLevel = int.parse(widget.questions!.first.level!);
        if (maxLevel == currentLevel) {
          return Container();
        }
        return _buildButton(
            AppLocalization.of(context)!.getTranslatedValues("nextLevelBtn")!,
            () {
          //if given level is same as unlocked level then we need to update level
          //else do not update level
          int? unlockedLevel =
              int.parse(widget.questions!.first.level!) == widget.unlockedLevel
                  ? (widget.unlockedLevel! + 1)
                  : widget.unlockedLevel;
          //play quiz for next level
          Navigator.of(context).pushReplacementNamed(Routes.quiz, arguments: {
            "numberOfPlayer": widget.numberOfPlayer,
            "quizType": widget.quizType,
            //if subcategory id is empty for question means we need to fetch quesitons by it's category
            "categoryId": widget.questions!.first.subcategoryId == "0"
                ? widget.questions!.first.categoryId
                : "",
            "subcategoryId": widget.questions!.first.subcategoryId == "0"
                ? ""
                : widget.questions!.first.subcategoryId,
            "level": (currentLevel + 1).toString(), //increase level
            "subcategoryMaxLevel": widget.subcategoryMaxLevel,
            "unlockedLevel": unlockedLevel,
          });
        }, context);
      }
      //if user failed to complete this level
      return _buildButton(
          AppLocalization.of(context)!.getTranslatedValues("playAgainBtn")!,
          () {
        //to play this level again (for quizZone quizType)
        Navigator.of(context).pushReplacementNamed(Routes.quiz, arguments: {
          "numberOfPlayer": widget.numberOfPlayer,
          "quizType": widget.quizType,
          //if subcategory id is empty for question means we need to fetch quesitons by it's category
          "categoryId": widget.questions!.first.subcategoryId == "0"
              ? widget.questions!.first.categoryId
              : "",
          "subcategoryId": widget.questions!.first.subcategoryId == "0"
              ? ""
              : widget.questions!.first.subcategoryId,
          "level": widget.questions!.first.level,
          "unlockedLevel": widget.unlockedLevel,
          "subcategoryMaxLevel": widget.subcategoryMaxLevel,
        });
      }, context);
    }

    return Container();
  }

  Widget _buildShareYourScoreButton() {
    return _buildButton(
        AppLocalization.of(context)!.getTranslatedValues("shareScoreBtn")!,
        () async {
      try {
        //capturing image
        final image = await screenshotController.capture();
        //root directory path
        final directory = (await getApplicationDocumentsDirectory()).path;

        String fileName = DateTime.now().microsecondsSinceEpoch.toString();
        //create file with given path
        File file = await File("$directory/$fileName.png").create();
        //write as bytes
        await file.writeAsBytes(image!.buffer.asUint8List());

        await Share.shareFiles(
          [file.path],
          text: AppLocalization.of(context)!.getTranslatedValues("myScoreLbl")!,
        );
      } catch (e) {
        UiUtils.setSnackbar(
            AppLocalization.of(context)!.getTranslatedValues(
                convertErrorCodeToLanguageKey(defaultErrorMessageCode))!,
            context,
            false);
      }
    }, context);
  }

  Widget _buildReviewAnswersButton() {
    if (context.read<SystemConfigCubit>().isPaymentRequestEnable()) {
      if (widget.quizType == QuizTypes.quizZone ||
          widget.quizType == QuizTypes.audioQuestions ||
          widget.quizType == QuizTypes.guessTheWord ||
          widget.quizType == QuizTypes.funAndLearn) {
        return Column(
          children: [
            _buildButton(
                AppLocalization.of(context)!
                    .getTranslatedValues("reviewAnsBtn")!, () {
              //
              final updateCoinsCubit = context.read<UpdateScoreAndCoinsCubit>();
              showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                        actions: [
                          TextButton(
                              onPressed: () {
                                //check if user has enough coins
                                if (int.parse(context
                                        .read<UserDetailsCubit>()
                                        .getCoins()!) <
                                    reviewAnswersDeductCoins) {
                                  UiUtils.errorMessageDialog(
                                      context,
                                      AppLocalization.of(context)!
                                          .getTranslatedValues(
                                              notEnoughCoinsKey));
                                  return;
                                }

                                //update coins

                                updateCoinsCubit.updateCoins(
                                    context
                                        .read<UserDetailsCubit>()
                                        .getUserId(),
                                    reviewAnswersDeductCoins,
                                    false,
                                    reviewAnswerLbl);

                                context.read<UserDetailsCubit>().updateCoins(
                                      addCoin: false,
                                      coins: reviewAnswersDeductCoins,
                                    );
                                //close the dialog

                                Navigator.of(context).pop();
                                //navigate to review answer

                                Navigator.of(context).pushNamed(
                                    Routes.reviewAnswers,
                                    arguments: {
                                      "questions": widget.quizType ==
                                              QuizTypes.guessTheWord
                                          ? List<Question>.from([])
                                          : widget.questions,
                                      "guessTheWordQuestions": widget
                                                  .quizType ==
                                              QuizTypes.guessTheWord
                                          ? widget.guessTheWordQuestions
                                          : List<GuessTheWordQuestion>.from([]),
                                    });
                              },
                              child: Text(
                                AppLocalization.of(context)!
                                    .getTranslatedValues(continueLbl)!,
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor),
                              )),
                          TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                AppLocalization.of(context)!
                                    .getTranslatedValues(cancelButtonKey)!,
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor),
                              )),
                        ],
                        content: Text(
                          "$reviewAnswersDeductCoins ${AppLocalization.of(context)!.getTranslatedValues(coinsWillBeDeductedKey)!}",
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary),
                        ),
                      ));
            }, context),
            SizedBox(
              height: 15.0,
            )
          ],
        );
      }
      //
    }

    return Column(
      children: [
        _buildButton(
            AppLocalization.of(context)!.getTranslatedValues("reviewAnsBtn")!,
            () {
          //
          Navigator.of(context).pushNamed(Routes.reviewAnswers, arguments: {
            "questions": widget.quizType == QuizTypes.guessTheWord
                ? List<Question>.from([])
                : widget.questions,
            "guessTheWordQuestions": widget.quizType == QuizTypes.guessTheWord
                ? widget.guessTheWordQuestions
                : List<GuessTheWordQuestion>.from([]),
          });
        }, context),
        SizedBox(
          height: 15.0,
        )
      ],
    );
  }

  Widget _buildResultButtons(BuildContext context) {
    double betweenButoonSpace = 15.0;
    if (widget.quizType == QuizTypes.battle) {
      return Column(
        children: [
          SizedBox(
            height: betweenButoonSpace,
          ),
          _buildReviewAnswersButton(),
          SizedBox(
            height: betweenButoonSpace,
          ),
          _buildShareYourScoreButton(),
          SizedBox(
            height: betweenButoonSpace,
          ),
          _buildButton(
              AppLocalization.of(context)!.getTranslatedValues("homeBtn")!, () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }, context),
        ],
      );
    }

    if (widget.quizType! == QuizTypes.exam) {
      return Column(
        children: [
          //
          _buildShareYourScoreButton(),
          SizedBox(
            height: betweenButoonSpace,
          ),
          _buildButton(
              AppLocalization.of(context)!.getTranslatedValues("homeBtn")!, () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }, context),
        ],
      );
    }

    //

    return Column(
      children: [
        _buildPlayAgainButton(),
        SizedBox(
          height: betweenButoonSpace,
        ),
        _buildReviewAnswersButton(),
        _buildShareYourScoreButton(),
        SizedBox(
          height: betweenButoonSpace,
        ),
        _buildButton(
            AppLocalization.of(context)!.getTranslatedValues("homeBtn")!, () {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }, context),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        onPageBackCalls();

        return Future.value(true);
      },
      child: MultiBlocListener(
        listeners: [
          BlocListener<UpdateScoreAndCoinsCubit, UpdateScoreAndCoinsState>(
            listener: (context, state) {
              if (state is UpdateScoreAndCoinsFailure) {
                //
                if (state.errorMessage == unauthorizedAccessCode) {
                  //already showed already logged in from other api error
                  if (!_displayedAlreadyLoggedInDailog) {
                    _displayedAlreadyLoggedInDailog = true;
                    UiUtils.showAlreadyLoggedInDialog(context: context);
                    return;
                  }
                }
              }
            },
          ),
          BlocListener<UpdateStatisticCubit, UpdateStatisticState>(
            listener: (context, state) {
              if (state is UpdateStatisticFailure) {
                //
                if (state.errorMessageCode == unauthorizedAccessCode) {
                  //already showed already logged in from other api error
                  if (!_displayedAlreadyLoggedInDailog) {
                    _displayedAlreadyLoggedInDailog = true;
                    UiUtils.showAlreadyLoggedInDialog(context: context);
                    return;
                  }
                }
              }
            },
          ),
          BlocListener<SetContestLeaderboardCubit, SetContestLeaderboardState>(
            listener: (context, state) {
              if (state is SetContestLeaderboardFailure) {
                //
                if (state.errorMessage == unauthorizedAccessCode) {
                  //already showed already logged in from other api error
                  if (!_displayedAlreadyLoggedInDailog) {
                    _displayedAlreadyLoggedInDailog = true;
                    UiUtils.showAlreadyLoggedInDialog(context: context);
                    return;
                  }
                }
              }
            },
          ),
        ],
        child: Scaffold(
          body: Stack(
            children: [
              PageBackgroundGradientContainer(),
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 50.0,
                    ),
                    Center(child: _buildResultContainer(context)),
                    SizedBox(
                      height: 30.0,
                    ),
                    _buildResultButtons(context),
                    SizedBox(
                      height: 50.0,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
