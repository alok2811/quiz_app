import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ayuprep/app/appLocalization.dart';
import 'package:ayuprep/features/bookmark/bookmarkRepository.dart';
import 'package:ayuprep/features/bookmark/cubits/audioQuestionBookmarkCubit.dart';
import 'package:ayuprep/features/bookmark/cubits/bookmarkCubit.dart';
import 'package:ayuprep/features/bookmark/cubits/guessTheWordBookmarkCubit.dart';
import 'package:ayuprep/features/bookmark/cubits/updateBookmarkCubit.dart';
import 'package:ayuprep/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:ayuprep/features/quiz/cubits/guessTheWordQuizCubit.dart';
import 'package:ayuprep/features/quiz/cubits/questionsCubit.dart';

import 'package:ayuprep/features/quiz/models/quizType.dart';
import 'package:ayuprep/features/quiz/quizRepository.dart';
import 'package:ayuprep/ui/screens/quiz/widgets/audioQuestionContainer.dart';
import 'package:ayuprep/ui/screens/quiz/widgets/guessTheWordQuestionContainer.dart';
import 'package:ayuprep/ui/widgets/customBackButton.dart';
import 'package:ayuprep/ui/widgets/customRoundedButton.dart';

import 'package:ayuprep/ui/widgets/errorContainer.dart';
import 'package:ayuprep/ui/widgets/exitGameDailog.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ayuprep/ui/widgets/pageBackgroundGradientContainer.dart';
import 'package:ayuprep/ui/widgets/questionsContainer.dart';
import 'package:ayuprep/ui/widgets/quizPlayAreaBackgroundContainer.dart';
import 'package:ayuprep/ui/widgets/settingButton.dart';
import 'package:ayuprep/ui/widgets/settingsDialogContainer.dart';
import 'package:ayuprep/utils/constants.dart';

import 'package:ayuprep/utils/errorMessageKeys.dart';
import 'package:ayuprep/utils/stringLabels.dart';

import 'package:ayuprep/utils/uiUtils.dart';

class BookmarkQuizScreen extends StatefulWidget {
  final QuizTypes quizType;
  BookmarkQuizScreen({Key? key, required this.quizType}) : super(key: key);

  @override
  _BookmarkQuizScreenState createState() => _BookmarkQuizScreenState();
  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
        builder: (_) => MultiBlocProvider(
                providers: [
                  //for quesitons of audio and quizzone
                  BlocProvider<QuestionsCubit>(
                    create: (_) => QuestionsCubit(QuizRepository()),
                  ),
                  //for guess the word question
                  BlocProvider<GuessTheWordQuizCubit>(
                    create: (_) => GuessTheWordQuizCubit(QuizRepository()),
                  ),
                  BlocProvider<UpdateBookmarkCubit>(
                      create: (_) => UpdateBookmarkCubit(BookmarkRepository())),
                ],
                child: BookmarkQuizScreen(
                  quizType: routeSettings.arguments as QuizTypes,
                )));
  }
}

class _BookmarkQuizScreenState extends State<BookmarkQuizScreen>
    with TickerProviderStateMixin {
  late AnimationController questionAnimationController;
  late AnimationController questionContentAnimationController;
  late AnimationController timerAnimationController = AnimationController(
      vsync: this, duration: Duration(seconds: questionDurationInSeconds))
    ..addStatusListener(currentUserTimerAnimationStatusListener);
  late Animation<double> questionSlideAnimation;
  late Animation<double> questionScaleUpAnimation;
  late Animation<double> questionScaleDownAnimation;
  late Animation<double> questionContentAnimation;
  late AnimationController animationController;
  late AnimationController topContainerAnimationController;
  int currentQuestionIndex = 0;

  bool completedQuiz = false;

  //to track if setting dialog is open
  bool isSettingDialogOpen = false;

  bool isExitDialogOpen = false;

  late List<GlobalKey<GuessTheWordQuestionContainerState>>
      guessTheWordQuestionContainerKeys = [];

  late List<GlobalKey<AudioQuestionContainerState>> audioQuestionContainerKeys =
      [];

  late AnimationController showOptionAnimationController =
      AnimationController(vsync: this, duration: Duration(milliseconds: 500));

  void _getQuestions() {
    Future.delayed(Duration.zero, () {
      //emitting success as we do not need to fetch questios from cloud and here only questions is important
      //other parameters can be ignored
      //other parameters need to pass so cubit functionlity does not break

      if (widget.quizType == QuizTypes.audioQuestions) {
        context.read<QuestionsCubit>().updateState(QuestionsFetchSuccess(
            questions: List.from(
                context.read<AudioQuestionBookmarkCubit>().questions()),
            currentPoints: 0,
            quizType: QuizTypes.bookmarkQuiz));

        context
            .read<AudioQuestionBookmarkCubit>()
            .questions()
            .forEach((element) {
          audioQuestionContainerKeys
              .add(GlobalKey<AudioQuestionContainerState>());
        });
      } else if (widget.quizType == QuizTypes.quizZone) {
        context.read<QuestionsCubit>().updateState(QuestionsFetchSuccess(
            questions: List.from(context.read<BookmarkCubit>().questions()),
            currentPoints: 0,
            quizType: QuizTypes.bookmarkQuiz));
        timerAnimationController.forward();
      } else {
        context
            .read<GuessTheWordQuizCubit>()
            .updateState(GuessTheWordQuizFetchSuccess(
              questions: List.from(
                  context.read<GuessTheWordBookmarkCubit>().questions()),
              currentPoints: 0,
            ));

        context.read<GuessTheWordQuizCubit>().getQuestions().forEach((element) {
          guessTheWordQuestionContainerKeys
              .add(GlobalKey<GuessTheWordQuestionContainerState>());
        });
        timerAnimationController.forward();
      }
    });
  }

  @override
  void initState() {
    initializeAnimation();
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

  void toggleSettingDialog() {
    isSettingDialogOpen = !isSettingDialogOpen;
  }

  //change to next Question
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

  //if user has submitted the answer for current question
  bool hasSubmittedAnswerForCurrentQuestion() {
    return widget.quizType == QuizTypes.guessTheWord
        ? false
        : context
            .read<QuestionsCubit>()
            .questions()[currentQuestionIndex]
            .attempted;
  }

  void submitAnswer(String submittedAnswer) async {
    timerAnimationController.stop();
    if (!context
        .read<QuestionsCubit>()
        .questions()[currentQuestionIndex]
        .attempted) {
      context.read<QuestionsCubit>().updateQuestionWithAnswerAndLifeline(
          context.read<QuestionsCubit>().questions()[currentQuestionIndex].id,
          submittedAnswer,
          context.read<UserDetailsCubit>().getUserFirebaseId());
      //change question
      await Future.delayed(Duration(seconds: inBetweenQuestionTimeInSeconds));
      if (currentQuestionIndex !=
          (context.read<QuestionsCubit>().questions().length - 1)) {
        changeQuestion();
        if (widget.quizType == QuizTypes.quizZone) {
          timerAnimationController.forward(from: 0.0);
        } else {
          timerAnimationController.value = 0.0;
        }
      } else {
        setState(() {
          completedQuiz = true;
        });
      }
    }
  }

  void submitGuessTheWordAnswer(List<String> submittedAnswer) async {
    timerAnimationController.stop();
    final guessTheWordQuizCubit = context.read<GuessTheWordQuizCubit>();
    //if answer not submitted then submit answer
    if (!guessTheWordQuizCubit
        .getQuestions()[currentQuestionIndex]
        .hasAnswered) {
      //submitted answer
      guessTheWordQuizCubit.submitAnswer(
          guessTheWordQuizCubit.getQuestions()[currentQuestionIndex].id,
          submittedAnswer);
      //wait for some seconds
      await Future.delayed(Duration(seconds: inBetweenQuestionTimeInSeconds));
      //if currentQuestion is last then complete quiz to result screen
      if (currentQuestionIndex ==
          (guessTheWordQuizCubit.getQuestions().length - 1)) {
        //
        setState(() {
          completedQuiz = true;
        });
      } else {
        //change question
        changeQuestion();
        timerAnimationController.forward(from: 0.0);
      }
    }
  }

  //listener for current user timer
  void currentUserTimerAnimationStatusListener(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      submitAnswer("-1");
    }
  }

  @override
  void dispose() {
    timerAnimationController
        .removeStatusListener(currentUserTimerAnimationStatusListener);
    timerAnimationController.dispose();
    questionAnimationController.dispose();
    questionContentAnimationController.dispose();
    showOptionAnimationController.dispose();
    super.dispose();
  }

  void onTapBackButton() {
    isExitDialogOpen = true;
    showDialog(context: context, builder: (context) => ExitGameDailog())
        .then((value) => isExitDialogOpen = false);
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
                if (completedQuiz) {
                  Navigator.of(context).pop();
                  return;
                }

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

  Widget _buildQuestions() {
    if (widget.quizType == QuizTypes.guessTheWord) {
      return BlocConsumer<GuessTheWordQuizCubit, GuessTheWordQuizState>(
          bloc: context.read<GuessTheWordQuizCubit>(),
          listener: (context, state) {},
          builder: (context, state) {
            if (state is GuessTheWordQuizFetchInProgress ||
                state is GuessTheWordQuizIntial) {
              return Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor)),
              );
            }
            if (state is GuessTheWordQuizFetchFailure) {
              return Center(
                child: ErrorContainer(
                  showBackButton: true,
                  errorMessage: AppLocalization.of(context)!
                      .getTranslatedValues(
                          convertErrorCodeToLanguageKey(state.errorMessage)),
                  onTapRetry: () {
                    _getQuestions();
                  },
                  showErrorImage: true,
                ),
              );
            }
            final questions = (state as GuessTheWordQuizFetchSuccess).questions;

            return Align(
                alignment: Alignment.topCenter,
                child: QuestionsContainer(
                  showGuessTheWordHint: false,
                  timerAnimationController: timerAnimationController,
                  quizType: widget.quizType,
                  topPadding: MediaQuery.of(context).size.height *
                      UiUtils.getQuestionContainerTopPaddingPercentage(
                          MediaQuery.of(context).size.height),
                  showAnswerCorrectness: true,
                  lifeLines: {},
                  hasSubmittedAnswerForCurrentQuestion: () {},
                  questions: [],
                  submitAnswer: () {},
                  questionContentAnimation: questionContentAnimation,
                  questionScaleDownAnimation: questionScaleDownAnimation,
                  questionScaleUpAnimation: questionScaleUpAnimation,
                  questionSlideAnimation: questionSlideAnimation,
                  currentQuestionIndex: currentQuestionIndex,
                  questionAnimationController: questionAnimationController,
                  questionContentAnimationController:
                      questionContentAnimationController,
                  guessTheWordQuestions: questions,
                  guessTheWordQuestionContainerKeys:
                      guessTheWordQuestionContainerKeys,
                ));
          });
    }
    return BlocConsumer<QuestionsCubit, QuestionsState>(
        bloc: context.read<QuestionsCubit>(),
        listener: (context, state) {},
        builder: (context, state) {
          if (state is QuestionsFetchInProgress || state is QuestionsIntial) {
            return Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor)),
            );
          }
          if (state is QuestionsFetchFailure) {
            return Center(
              child: ErrorContainer(
                showBackButton: true,
                errorMessage: AppLocalization.of(context)!.getTranslatedValues(
                    convertErrorCodeToLanguageKey(state.errorMessage)),
                onTapRetry: () {
                  _getQuestions();
                },
                showErrorImage: true,
              ),
            );
          }
          final questions = (state as QuestionsFetchSuccess).questions;

          return Align(
              alignment: Alignment.topCenter,
              child: QuestionsContainer(
                audioQuestionContainerKeys: audioQuestionContainerKeys,
                timerAnimationController: timerAnimationController,
                quizType: widget.quizType,
                topPadding: MediaQuery.of(context).size.height *
                    UiUtils.getQuestionContainerTopPaddingPercentage(
                        MediaQuery.of(context).size.height),
                showAnswerCorrectness: true,
                lifeLines: {},
                hasSubmittedAnswerForCurrentQuestion:
                    hasSubmittedAnswerForCurrentQuestion,
                questions: questions,
                submitAnswer: submitAnswer,
                questionContentAnimation: questionContentAnimation,
                questionScaleDownAnimation: questionScaleDownAnimation,
                questionScaleUpAnimation: questionScaleUpAnimation,
                questionSlideAnimation: questionSlideAnimation,
                currentQuestionIndex: currentQuestionIndex,
                questionAnimationController: questionAnimationController,
                questionContentAnimationController:
                    questionContentAnimationController,
                guessTheWordQuestions: [],
                guessTheWordQuestionContainerKeys: [],
              ));
        });
  }

  Widget _buildBottomButton() {
    if (widget.quizType == QuizTypes.guessTheWord) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height * (0.025)),
          child: CustomRoundedButton(
            widthPercentage: 0.5,
            backgroundColor: Theme.of(context).primaryColor,
            buttonTitle: AppLocalization.of(context)!
                .getTranslatedValues("submitBtn")!
                .toUpperCase(),
            elevation: 5.0,
            shadowColor: Colors.black45,
            titleColor: Theme.of(context).backgroundColor,
            fontWeight: FontWeight.bold,
            onTap: () {
              submitGuessTheWordAnswer(
                  guessTheWordQuestionContainerKeys[currentQuestionIndex]
                      .currentState!
                      .getSubmittedAnswer());
            },
            radius: 10.0,
            showBorder: false,
            height: 45,
          ),
        ),
      );
    }
    if (widget.quizType == QuizTypes.audioQuestions) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: SlideTransition(
          position: Tween<Offset>(begin: Offset.zero, end: Offset(0.0, 1.5))
              .animate(CurvedAnimation(
                  parent: showOptionAnimationController,
                  curve: Curves.easeInOut)),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height * (0.025),
              left: MediaQuery.of(context).size.width * (0.2),
              right: MediaQuery.of(context).size.width * (0.2),
            ),
            child: CustomRoundedButton(
              widthPercentage: MediaQuery.of(context).size.width * (0.5),
              backgroundColor: Theme.of(context).primaryColor,
              buttonTitle: AppLocalization.of(context)!
                  .getTranslatedValues(showOptionsKey)!,
              radius: 5,
              onTap: () {
                if (!showOptionAnimationController.isAnimating) {
                  showOptionAnimationController.reverse();
                  audioQuestionContainerKeys[currentQuestionIndex]
                      .currentState!
                      .changeShowOption();
                  timerAnimationController.forward(from: 0.0);
                }
              },
              titleColor: Theme.of(context).backgroundColor,
              showBorder: false,
              height: 40.0,
              elevation: 5.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }
    return SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          if (completedQuiz) {
            return Future.value(true);
          }
          onTapBackButton();
          return Future.value(false);
        },
        child: Scaffold(
          body: Stack(
            children: [
              PageBackgroundGradientContainer(),
              Align(
                alignment: Alignment.topCenter,
                child: QuizPlayAreaBackgroundContainer(),
              ),
              AnimatedSwitcher(
                duration: Duration(milliseconds: 500),
                child: completedQuiz
                    ? Align(
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AppLocalization.of(context)!.getTranslatedValues(
                                      "completeAllQueLbl")! +
                                  " (:",
                              style: TextStyle(
                                color: Theme.of(context).backgroundColor,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal:
                                      MediaQuery.of(context).size.width *
                                          (0.3)),
                              child: CustomRoundedButton(
                                widthPercentage:
                                    MediaQuery.of(context).size.width * (0.3),
                                backgroundColor:
                                    Theme.of(context).backgroundColor,
                                buttonTitle: AppLocalization.of(context)!
                                    .getTranslatedValues("goBAckLbl")!,
                                titleColor: Theme.of(context).primaryColor,
                                radius: 5.0,
                                showBorder: false,
                                elevation: 5.0,
                                onTap: () {
                                  if (isSettingDialogOpen) {
                                    Navigator.of(context).pop();
                                  }
                                  if (isExitDialogOpen) {
                                    Navigator.of(context).pop();
                                  }

                                  Navigator.of(context).pop();
                                },
                                height: 35.0,
                              ),
                            ),
                          ],
                        ),
                      )
                    : _buildQuestions(),
              ),
              _buildBottomButton(),
              _buildTopMenu(),
            ],
          ),
        ));
  }
}
