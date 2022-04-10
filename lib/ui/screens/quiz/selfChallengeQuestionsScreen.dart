import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ayuprep/app/appLocalization.dart';
import 'package:ayuprep/app/routes.dart';
import 'package:ayuprep/features/bookmark/bookmarkRepository.dart';
import 'package:ayuprep/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:ayuprep/features/quiz/cubits/questionsCubit.dart';
import 'package:ayuprep/features/bookmark/cubits/updateBookmarkCubit.dart';
import 'package:ayuprep/features/quiz/models/question.dart';
import 'package:ayuprep/features/quiz/models/quizType.dart';
import 'package:ayuprep/features/quiz/quizRepository.dart';

import 'package:ayuprep/ui/widgets/circularProgressContainner.dart';
import 'package:ayuprep/ui/widgets/customBackButton.dart';
import 'package:ayuprep/ui/widgets/customRoundedButton.dart';
import 'package:ayuprep/ui/widgets/errorContainer.dart';
import 'package:ayuprep/ui/widgets/exitGameDailog.dart';
import 'package:ayuprep/ui/widgets/pageBackgroundGradientContainer.dart';
import 'package:ayuprep/ui/widgets/questionsContainer.dart';
import 'package:ayuprep/ui/widgets/quizPlayAreaBackgroundContainer.dart';
import 'package:ayuprep/ui/widgets/settingButton.dart';
import 'package:ayuprep/ui/widgets/settingsDialogContainer.dart';

import 'package:ayuprep/utils/errorMessageKeys.dart';

import 'package:ayuprep/utils/uiUtils.dart';

class SelfChallengeQuestionsScreen extends StatefulWidget {
  final String? categoryId;
  final String? subcategoryId;
  final int? minutes;
  final String? numberOfQuestions;
  SelfChallengeQuestionsScreen(
      {Key? key,
      required this.categoryId,
      required this.minutes,
      required this.numberOfQuestions,
      required this.subcategoryId})
      : super(key: key);

  @override
  _SelfChallengeQuestionsScreenState createState() =>
      _SelfChallengeQuestionsScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    Map? arguments = routeSettings.arguments as Map<dynamic, dynamic>?;

    //keys of map are categoryId,subcategoryId,minutes,numberOfQuestions
    return CupertinoPageRoute(
        builder: (_) => MultiBlocProvider(
                providers: [
                  BlocProvider<QuestionsCubit>(
                      create: (_) => QuestionsCubit(QuizRepository())),
                  BlocProvider<UpdateBookmarkCubit>(
                      create: (_) => UpdateBookmarkCubit(BookmarkRepository())),
                ],
                child: SelfChallengeQuestionsScreen(
                  categoryId: arguments!['categoryId'],
                  minutes: arguments['minutes'],
                  numberOfQuestions: arguments['numberOfQuestions'],
                  subcategoryId: arguments['subcategoryId'],
                )));
  }
}

class _SelfChallengeQuestionsScreenState
    extends State<SelfChallengeQuestionsScreen> with TickerProviderStateMixin {
  int currentQuestionIndex = 0;
  late List<Question> ques;
  late AnimationController questionAnimationController;
  late AnimationController questionContentAnimationController;
  late AnimationController timerAnimationController;
  late Animation<double> questionSlideAnimation;
  late Animation<double> questionScaleUpAnimation;
  late Animation<double> questionScaleDownAnimation;
  late Animation<double> questionContentAnimation;
  late AnimationController animationController;
  late AnimationController topContainerAnimationController;

  bool isBottomSheetOpen = false;

  //to track if setting dialog is open
  bool isSettingDialogOpen = false;

  bool isExitDialogOpen = false;

  void _getQuestions() {
    Future.delayed(Duration.zero, () {
      context.read<QuestionsCubit>().getQuestions(
            QuizTypes.selfChallenge,
            categoryId: widget.categoryId,
            subcategoryId: widget.subcategoryId,
            numberOfQuestions: widget.numberOfQuestions,
            languageId: UiUtils.getCurrentQuestionLanguageId(context),
          );
    });
  }

  @override
  void initState() {
    initializeAnimation();
    timerAnimationController = AnimationController(
        vsync: this, duration: Duration(minutes: widget.minutes!))
      ..addStatusListener(currentUserTimerAnimationStatusListener);

    animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 100));
    topContainerAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 100));
    _getQuestions();
    super.initState();
  }

  void initializeAnimation() {
    questionContentAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 250))
          ..forward();
    questionAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 525));
    questionSlideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: questionAnimationController, curve: Curves.easeInOut));
    questionScaleUpAnimation = Tween<double>(begin: 0.0, end: 0.1).animate(
        CurvedAnimation(
            parent: questionAnimationController,
            curve: Interval(0.0, 0.5, curve: Curves.easeInQuad)));
    questionContentAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: questionContentAnimationController,
            curve: Curves.easeInQuad));
    questionScaleDownAnimation = Tween<double>(begin: 0.0, end: 0.05).animate(
        CurvedAnimation(
            parent: questionAnimationController,
            curve: Interval(0.5, 1.0, curve: Curves.easeOutQuad)));
  }

  @override
  void dispose() {
    timerAnimationController
        .removeStatusListener(currentUserTimerAnimationStatusListener);
    timerAnimationController.dispose();
    questionAnimationController.dispose();
    questionContentAnimationController.dispose();
    super.dispose();
  }

  void toggleSettingDialog() {
    isSettingDialogOpen = !isSettingDialogOpen;
  }

  void changeQuestion(
      {required bool increaseIndex, required int newQuestionIndex}) {
    questionAnimationController.forward(from: 0.0).then((value) {
      //need to dispose the animation controllers
      questionAnimationController.dispose();
      questionContentAnimationController.dispose();
      //initializeAnimation again
      setState(() {
        initializeAnimation();
        if (newQuestionIndex != -1) {
          currentQuestionIndex = newQuestionIndex;
        } else {
          if (increaseIndex) {
            currentQuestionIndex++;
          } else {
            currentQuestionIndex--;
          }
        }
      });
      //load content(options, image etc) of question
      questionContentAnimationController.forward();
    });
  }

  //if user has submitted the answer for current question
  bool hasSubmittedAnswerForCurrentQuestion() {
    return ques[currentQuestionIndex].attempted;
  }

  //update answer locally and on cloud
  void submitAnswer(String submittedAnswer) async {
    context.read<QuestionsCubit>().updateQuestionWithAnswerAndLifeline(
        ques[currentQuestionIndex].id,
        submittedAnswer,
        context.read<UserDetailsCubit>().getUserFirebaseId());
    //change question
    await Future.delayed(Duration(milliseconds: 500));
  }

  //listener for current user timer
  void currentUserTimerAnimationStatusListener(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      navigateToResult();
    }
  }

  void navigateToResult() {
    if (isBottomSheetOpen) {
      Navigator.of(context).pop();
    }
    if (isSettingDialogOpen) {
      Navigator.of(context).pop();
    }
    if (isExitDialogOpen) {
      Navigator.of(context).pop();
    }

    Navigator.of(context).pushReplacementNamed(Routes.result, arguments: {
      "numberOfPlayer": 1,
      "myPoints": context.read<QuestionsCubit>().currentPoints(),
      "quizType": QuizTypes.selfChallenge,
      "questions": context.read<QuestionsCubit>().questions(),
      "entryFee": 0
    });
  }

  Widget hasQuestionAttemptedContainer(int questionIndex, bool attempted) {
    return GestureDetector(
      onTap: () {
        if (questionIndex != currentQuestionIndex) {
          changeQuestion(increaseIndex: true, newQuestionIndex: questionIndex);
        }
      },
      child: Container(
        alignment: Alignment.center,
        margin: EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
        color: attempted
            ? Theme.of(context).primaryColor
            : Theme.of(context).colorScheme.secondary,
        height: 30.0,
        width: 30.0,
        child: Text(
          "${questionIndex + 1}",
          style: TextStyle(color: Theme.of(context).backgroundColor),
        ),
      ),
    );
  }

  void onTapBackButton() {
    isExitDialogOpen = true;
    showDialog(context: context, builder: (context) => ExitGameDailog())
        .then((value) => isExitDialogOpen = false);
  }

  void openBottomSheet(List<Question> questions) {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      isScrollControlled: true,
      context: context,
      builder: (context) => Container(
          padding: EdgeInsets.symmetric(horizontal: 5.0),
          decoration: BoxDecoration(
              color: Theme.of(context).backgroundColor,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20))),
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * (0.6)),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 10.0,
                ),
                Container(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: Icon(Icons.close),
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                Wrap(
                  children: List.generate(questions.length, (index) => index)
                      .map((index) => hasQuestionAttemptedContainer(
                          index, questions[index].attempted))
                      .toList(),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Container(
                  width: MediaQuery.of(context).size.width * (0.25),
                  child: CustomRoundedButton(
                    onTap: () {
                      timerAnimationController.stop();
                      Navigator.of(context).pop();
                      navigateToResult();
                    },
                    widthPercentage: MediaQuery.of(context).size.width,
                    backgroundColor: Theme.of(context).primaryColor,
                    buttonTitle: AppLocalization.of(context)!
                        .getTranslatedValues("submitBtn")!,
                    radius: 10,
                    showBorder: false,
                    titleColor: Theme.of(context).backgroundColor,
                    height: 30.0,
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor,
                        radius: 15,
                        child: Center(
                          child: Icon(
                            Icons.check,
                            color: Theme.of(context).backgroundColor,
                            size: 22,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10.0,
                      ),
                      Text(
                        AppLocalization.of(context)!
                            .getTranslatedValues("attemptedLbl")!,
                        style: TextStyle(
                            fontSize: 12.5,
                            color: Theme.of(context).colorScheme.secondary),
                      ),
                      Spacer(),
                      CircleAvatar(
                        radius: 15,
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                        child: Center(
                          child: Icon(
                            Icons.check,
                            color: Theme.of(context).backgroundColor,
                            size: 22,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10.0,
                      ),
                      Text(
                        AppLocalization.of(context)!
                            .getTranslatedValues("unAttemptedLbl")!,
                        style: TextStyle(
                            fontSize: 12.5,
                            color: Theme.of(context).colorScheme.secondary),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 15.0,
                ),
              ],
            ),
          )),
    ).then((value) {
      isBottomSheetOpen = false;
    });
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
                onTapBackButton();
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

  Widget _buildBottomMenu(BuildContext context) {
    return BlocBuilder<QuestionsCubit, QuestionsState>(
      bloc: context.read<QuestionsCubit>(),
      builder: (context, state) {
        if (state is QuestionsFetchSuccess) {
          return Padding(
            padding: EdgeInsets.only(bottom: 10.0),
            child: Row(
              children: [
                Opacity(
                  opacity: currentQuestionIndex != 0 ? 1.0 : 0.5,
                  child: IconButton(
                      onPressed: () {
                        if (!questionAnimationController.isAnimating) {
                          if (currentQuestionIndex != 0) {
                            changeQuestion(
                                increaseIndex: false, newQuestionIndex: -1);
                          }
                        }
                      },
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: Theme.of(context).colorScheme.secondary,
                      )),
                ),
                Spacer(),
                GestureDetector(
                  onTap: () {
                    isBottomSheetOpen = true;
                    openBottomSheet(state.questions);
                  },
                  child: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    radius: 20,
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: SvgPicture.asset(
                          UiUtils.getImagePath("moveto_icon.svg")),
                    ),
                  ),
                ),
                Spacer(),
                Opacity(
                  opacity: currentQuestionIndex != (state.questions.length - 1)
                      ? 1.0
                      : 0.5,
                  child: IconButton(
                      onPressed: () {
                        if (!questionAnimationController.isAnimating) {
                          if (currentQuestionIndex !=
                              (state.questions.length - 1)) {
                            changeQuestion(
                                increaseIndex: true, newQuestionIndex: -1);
                          }
                        }
                      },
                      icon: Icon(
                        Icons.arrow_forward_ios,
                        color: Theme.of(context).colorScheme.secondary,
                      )),
                ),
              ],
            ),
          );
        }
        return SizedBox();
      },
    );
  }

  // Widget _buildBookmarkButton(QuestionsCubit questionsCubit) {
  //   return BlocBuilder<QuestionsCubit, QuestionsState>(
  //     bloc: questionsCubit,
  //     builder: (context, state) {
  //       if (state is QuestionsFetchSuccess)
  //         return BookmarkButton(
  //           quizType: QuizTypes.quizZone, //Since quesitons coming from quizzone
  //           question: state.questions[currentQuestionIndex],
  //         );
  //       return SizedBox();
  //     },
  //   );
  // }

  Widget backButton() {
    return Align(
        alignment: Alignment.topLeft,
        child: Padding(
            padding:
                EdgeInsets.only(top: MediaQuery.of(context).padding.top - 10),
            child: CustomBackButton(
              iconColor: Theme.of(context).primaryColor,
            )));
  }

  @override
  Widget build(BuildContext context) {
    final quesCubit = context.read<QuestionsCubit>();
    return WillPopScope(
      onWillPop: () {
        onTapBackButton();
        return Future.value(false);
      },
      child: Scaffold(
        body: Stack(
          children: [
            PageBackgroundGradientContainer(),
            Align(
              alignment: Alignment.topCenter,
              child: QuizPlayAreaBackgroundContainer(
                heightPercentage: 0.9,
              ),
            ),
            BlocConsumer<QuestionsCubit, QuestionsState>(
                bloc: quesCubit,
                listener: (context, state) {
                  if (state is QuestionsFetchSuccess) {
                    if (!timerAnimationController.isAnimating) {
                      timerAnimationController.forward();
                    }
                  }
                },
                builder: (context, state) {
                  if (state is QuestionsFetchInProgress ||
                      state is QuestionsIntial) {
                    return Center(
                      child: CircularProgressContainer(
                        useWhiteLoader: true,
                      ),
                    );
                  }
                  if (state is QuestionsFetchFailure) {
                    return Center(
                      child: ErrorContainer(
                        showBackButton: true,
                        errorMessage: AppLocalization.of(context)!
                            .getTranslatedValues(convertErrorCodeToLanguageKey(
                                state.errorMessage)),
                        onTapRetry: () {
                          _getQuestions();
                        },
                        showErrorImage: true,
                      ),
                    );
                  }
                  final questions = (state as QuestionsFetchSuccess).questions;
                  ques = questions;
                  return Align(
                      alignment: Alignment.topCenter,
                      child: QuestionsContainer(
                        timerAnimationController: timerAnimationController,
                        quizType: QuizTypes.selfChallenge,
                        showAnswerCorrectness: false,
                        lifeLines: {},
                        topPadding: MediaQuery.of(context).size.height *
                            UiUtils.getQuestionContainerTopPaddingPercentage(
                                MediaQuery.of(context).size.height),
                        hasSubmittedAnswerForCurrentQuestion:
                            hasSubmittedAnswerForCurrentQuestion,
                        questions: questions,
                        submitAnswer: submitAnswer,
                        questionContentAnimation: questionContentAnimation,
                        questionScaleDownAnimation: questionScaleDownAnimation,
                        questionScaleUpAnimation: questionScaleUpAnimation,
                        questionSlideAnimation: questionSlideAnimation,
                        currentQuestionIndex: currentQuestionIndex,
                        questionAnimationController:
                            questionAnimationController,
                        questionContentAnimationController:
                            questionContentAnimationController,
                        guessTheWordQuestions: [],
                        guessTheWordQuestionContainerKeys: [],
                        // quizType: QuizTypes.selfChallenge,
                      ));
                }),
            BlocBuilder<QuestionsCubit, QuestionsState>(
              bloc: quesCubit,
              builder: (context, state) {
                if (state is QuestionsFetchSuccess) {
                  return Align(
                    alignment: Alignment.bottomCenter,
                    child: _buildBottomMenu(context),
                  );
                }
                return SizedBox();
              },
            ),
            _buildTopMenu(),
          ],
        ),
      ),
    );
  }
}
