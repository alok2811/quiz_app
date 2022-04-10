import 'dart:math';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ayuprep/app/appLocalization.dart';
import 'package:ayuprep/features/ads/rewardedAdCubit.dart';
import 'package:ayuprep/features/profileManagement/cubits/updateScoreAndCoinsCubit.dart';
import 'package:ayuprep/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:ayuprep/features/quiz/models/guessTheWordQuestion.dart';
import 'package:ayuprep/features/settings/settingsCubit.dart';
import 'package:ayuprep/ui/widgets/circularProgressContainner.dart';
import 'package:ayuprep/ui/widgets/horizontalTimerContainer.dart';
import 'package:ayuprep/ui/widgets/watchRewardAdDialog.dart';
import 'package:ayuprep/utils/constants.dart';
import 'package:ayuprep/utils/errorMessageKeys.dart';
import 'package:ayuprep/utils/stringLabels.dart';
import 'package:ayuprep/utils/uiUtils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GuessTheWordQuestionContainer extends StatefulWidget {
  final BoxConstraints constraints;
  final int currentQuestionIndex;
  final List<GuessTheWordQuestion> questions;
  final Function submitAnswer;
  final AnimationController timerAnimationController;
  final bool showHint;
  GuessTheWordQuestionContainer(
      {Key? key,
      required this.currentQuestionIndex,
      required this.showHint,
      required this.questions,
      required this.constraints,
      required this.submitAnswer,
      required this.timerAnimationController})
      : super(key: key);

  @override
  GuessTheWordQuestionContainerState createState() =>
      GuessTheWordQuestionContainerState();
}

class GuessTheWordQuestionContainerState
    extends State<GuessTheWordQuestionContainer> with TickerProviderStateMixin {
  final optionBoxContainerHeight = 40.0;
  double textSize = 14;
  //contains ontionIndex.. stroing index so we can lower down the opacity of selected index
  late List<int> submittedAnswer = [];
  late List<String> correctAnswerLetterList = [];

  //to controll the answer text
  late List<AnimationController> controllers = [];
  late List<Animation<double>> animations = [];
  //
  //to control the bottomBorder animation
  late List<AnimationController> bottomBorderAnimationControllers = [];
  late List<Animation<double>> bottomBorderAnimations = [];
  //
  //to control the topContainer animation
  late List<AnimationController> topContainerAnimationControllers = [];
  late List<Animation<double>> topContainerAnimations = [];

  late int currentSelectedIndex = 0;

  late AssetsAudioPlayer assetsAudioPlayer = AssetsAudioPlayer();
  //total how many times user can see hint per question
  late int hintsCounter = numberOfHintsPerGuessTheWordQuestion;

  @override
  void initState() {
    super.initState();
    initializeAnimation();
    initAds();
  }

  @override
  void dispose() {
    controllers.forEach((element) {
      element.dispose();
    });
    topContainerAnimationControllers.forEach((element) {
      element.dispose();
    });
    bottomBorderAnimationControllers.forEach((element) {
      element.dispose();
    });
    assetsAudioPlayer.dispose();
    super.dispose();
  }

  void initAds() {
    Future.delayed(Duration.zero, () {
      print("Load ads ${widget.currentQuestionIndex}");
      context.read<RewardedAdCubit>().createRewardedAd(context,
          onFbRewardAdCompleted: _addCoinsAfterRewardAd);
    });
  }

  List<String> getSubmittedAnswer() {
    return submittedAnswer
        .map((e) => e == -1
            ? ""
            : widget.questions[widget.currentQuestionIndex].options[e])
        .toList();
  }

  void initializeAnimation() {
    //initalize the animation
    for (int i = 0;
        i <
            widget
                .questions[widget.currentQuestionIndex].submittedAnswer.length;
        i++) {
      submittedAnswer.add(-1);
      controllers.add(AnimationController(
          vsync: this, duration: Duration(milliseconds: 150)));
      animations.add(Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
              parent: controllers[i],
              curve: Curves.linear,
              reverseCurve: Curves.linear)));
      topContainerAnimationControllers.add(AnimationController(
          vsync: this, duration: Duration(milliseconds: 150)));
      topContainerAnimations.add(Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
              parent: topContainerAnimationControllers[i],
              curve: Curves.linear)));
      bottomBorderAnimationControllers.add(AnimationController(
          vsync: this, duration: Duration(milliseconds: 150)));
      bottomBorderAnimations.add(Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
              parent: bottomBorderAnimationControllers[i],
              curve: Curves.linear)));
    }
    bottomBorderAnimationControllers.first.forward();
  }

  void changeCurrentSelectedAnswerBox(int answerBoxIndex) {
    setState(() {
      currentSelectedIndex = answerBoxIndex;
    });
    bottomBorderAnimationControllers[answerBoxIndex].forward();
    for (var controller in bottomBorderAnimationControllers) {
      if (controller.isCompleted) {
        controller.reverse();
        break;
      }
    }
  }

  void playSound(String trackName) {
    if (context.read<SettingsCubit>().getSettings().sound) {
      if (assetsAudioPlayer.isPlaying.value) {
        assetsAudioPlayer.stop();
      }
      assetsAudioPlayer.open(Audio("$trackName"));
      assetsAudioPlayer.play();
    }
  }

  void playVibrate() async {
    if (context.read<SettingsCubit>().getSettings().vibration) {
      UiUtils.vibrate();
    }
  }

  void _addCoinsAfterRewardAd() {
    //once user sees ad then add coins to user wallet
    context.read<UserDetailsCubit>().updateCoins(
          addCoin: true,
          coins: lifeLineDeductCoins,
        );

    context.read<UpdateScoreAndCoinsCubit>().updateCoins(
        context.read<UserDetailsCubit>().getUserId(),
        lifeLineDeductCoins,
        true,
        watchedRewardAdKey);
    widget.timerAnimationController
        .forward(from: widget.timerAnimationController.value);
  }

  void showAdDialog() {
    if (context.read<RewardedAdCubit>().state is! RewardedAdLoaded) {
      UiUtils.setSnackbar(
          AppLocalization.of(context)!.getTranslatedValues(
              convertErrorCodeToLanguageKey(notEnoughCoinsCode))!,
          context,
          false);
      return;
    }
    //stop timer
    widget.timerAnimationController.stop();
    showDialog<bool>(
        context: context,
        builder: (_) => WatchRewardAdDialog(
              onTapYesButton: () {
                //on tap of yes button show ad
                context.read<RewardedAdCubit>().showAd(
                    context: context,
                    onAdDismissedCallback: _addCoinsAfterRewardAd);
              },
              onTapNoButton: () {
                //pass true to start timer
                Navigator.of(context).pop(true);
              },
            )).then((startTimer) {
      //if user do not want to see ad
      if (startTimer != null && startTimer) {
        widget.timerAnimationController
            .forward(from: widget.timerAnimationController.value);
      }
    });
  }

  bool hasEnoughCoinsForLifeline(BuildContext context) {
    int currentCoins = int.parse(context.read<UserDetailsCubit>().getCoins()!);
    //cost of using lifeline is 5 coins
    if (currentCoins < lifeLineDeductCoins) {
      return false;
    }
    return true;
  }

  Widget _buildAnswerBox(int answerBoxIndex) {
    return GestureDetector(
      onTap: () {
        changeCurrentSelectedAnswerBox(answerBoxIndex);
      },
      child: AnimatedBuilder(
        animation: bottomBorderAnimationControllers[answerBoxIndex],
        builder: (context, child) {
          double border = bottomBorderAnimations[answerBoxIndex]
              .drive(Tween<double>(begin: 1.0, end: 2.5))
              .value;

          return Container(
            clipBehavior: Clip.hardEdge,
            alignment: Alignment.bottomCenter,
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        width: border,
                        color: currentSelectedIndex == answerBoxIndex
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).colorScheme.secondary))),
            margin: EdgeInsets.symmetric(horizontal: 5.0, vertical: 2.5),
            height: optionBoxContainerHeight,
            width: 35.0,
            child: AnimatedBuilder(
              animation: controllers[answerBoxIndex],
              builder: (context, child) {
                return controllers[answerBoxIndex].status ==
                        AnimationStatus.reverse
                    ? Opacity(
                        opacity: animations[answerBoxIndex].value,
                        child: FractionalTranslation(
                          translation: Offset(
                              0.0, 1.0 - animations[answerBoxIndex].value),
                          child: child,
                        ),
                      )
                    : FractionalTranslation(
                        translation:
                            Offset(0.0, 1.0 - animations[answerBoxIndex].value),
                        child: child,
                      );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: topContainerAnimationControllers[answerBoxIndex],
                    builder: (context, child) {
                      return Container(
                        height: 2.0,
                        width: 35.0 *
                            (1.0 -
                                topContainerAnimations[answerBoxIndex].value),
                        color: currentSelectedIndex == answerBoxIndex
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).colorScheme.secondary,
                      );
                    },
                  ),
                  Text(
                    //submitted answer contains the index of option
                    //length of answerbox is same as submittedAnswer
                    submittedAnswer[answerBoxIndex] == -1
                        ? ""
                        : widget.questions[widget.currentQuestionIndex]
                                    .options[submittedAnswer[answerBoxIndex]] ==
                                " "
                            ? "-"
                            : widget.questions[widget.currentQuestionIndex]
                                .options[submittedAnswer[answerBoxIndex]], //
                    //
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                        color: currentSelectedIndex == answerBoxIndex
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).colorScheme.secondary),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnswerBoxes() {
    List<Widget> children = [];
    for (var i = 0;
        i <
            widget
                .questions[widget.currentQuestionIndex].submittedAnswer.length;
        i++) {
      children.add(_buildAnswerBox(i));
    }
    return Wrap(
      children: children,
    );
  }

  Widget _optionContainer(String letter, int optionIndex) {
    return GestureDetector(
      onTap: submittedAnswer.contains(optionIndex)
          ? () {}
          : () async {
              playVibrate();
              //! menas we need to add back button
              if (letter == "!") {
                await topContainerAnimationControllers[currentSelectedIndex]
                    .reverse();
                await controllers[currentSelectedIndex].reverse();
                setState(() {
                  submittedAnswer[currentSelectedIndex] = -1;
                });
              } else {
                if (submittedAnswer[currentSelectedIndex] != -1) {
                  await topContainerAnimationControllers[currentSelectedIndex]
                      .reverse();
                  await controllers[currentSelectedIndex].reverse();
                }
                await Future.delayed(Duration(milliseconds: 25));

                //adding new letter
                setState(() {
                  submittedAnswer[currentSelectedIndex] = optionIndex;
                });

                await controllers[currentSelectedIndex].forward();
                await topContainerAnimationControllers[currentSelectedIndex]
                    .forward();
                //update currentAnswerBox

                if (currentSelectedIndex !=
                    widget.questions[widget.currentQuestionIndex]
                            .submittedAnswer.length -
                        1) {
                  changeCurrentSelectedAnswerBox(currentSelectedIndex + 1);
                }
              }
            },
      child: Opacity(
        opacity: submittedAnswer.contains(optionIndex) ? 0.5 : 1.0,
        child: Container(
          alignment: Alignment.center,
          margin: EdgeInsets.symmetric(horizontal: 5.0, vertical: 5),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
              color: Theme.of(context).primaryColor),
          height: optionBoxContainerHeight,
          width: optionBoxContainerHeight,
          padding: EdgeInsets.symmetric(
            horizontal:
                letter == " " ? optionBoxContainerHeight * (0.225) : 0.0,
          ),
          child: letter == "!"
              ? Icon(
                  Icons.arrow_back,
                  color: Theme.of(context).backgroundColor,
                )
              : letter == " "
                  ? SvgPicture.asset(
                      UiUtils.getImagePath("space.svg"),
                      color: Theme.of(context).backgroundColor,
                    )
                  : Text(
                      letter == " " ? "Space" : letter,
                      style: TextStyle(
                        color: Theme.of(context).backgroundColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
        ),
      ),
    );
  }

  Widget _buildOptions(List<String> answerOptions) {
    List<Widget> listOfWidgets = [];

    for (var i = 0; i < answerOptions.length; i++) {
      listOfWidgets.add(_optionContainer(answerOptions[i], i));
    }
    if (widget.showHint) {
      listOfWidgets.add(_buildHintButton());
    }

    return Wrap(
      children: listOfWidgets,
    );
  }

  int _getRandomIndexForHint() {
    //need to find all empty cells where user have not given answer yet
    List<int> emptyAnswerBoxIndexes = [];
    for (var i = 0; i < submittedAnswer.length; i++) {
      if (submittedAnswer[i] == -1) {
        emptyAnswerBoxIndexes.add(i);
      }
    }
    if (emptyAnswerBoxIndexes.isEmpty) {
      return -1;
    }
    //show hint on any empty answer box
    return emptyAnswerBoxIndexes[
        Random.secure().nextInt(emptyAnswerBoxIndexes.length)];
  }

  Widget _buildHintButton() {
    return GestureDetector(
      onTap: hintsCounter == 0 || !submittedAnswer.contains(-1)
          ? () {}
          : () async {
              if (hasEnoughCoinsForLifeline(context)) {
                //show hints
                String correctAnswer =
                    widget.questions[widget.currentQuestionIndex].answer;

                //build correct answer letter list
                if (correctAnswerLetterList.isEmpty) {
                  for (int i = 0; i < correctAnswer.length; i++) {
                    correctAnswerLetterList
                        .add(correctAnswer.substring(i, i + 1));
                  }
                }

                //get random index
                int hintIndex = _getRandomIndexForHint();

                //deduct coins for using hints
                context.read<UserDetailsCubit>().updateCoins(
                      addCoin: false,
                      coins: lifeLineDeductCoins,
                    );
                context.read<UpdateScoreAndCoinsCubit>().updateCoins(
                    context.read<UserDetailsCubit>().getUserId(),
                    lifeLineDeductCoins,
                    false,
                    usedHintLifelineKey);

                //change current selected answer box
                changeCurrentSelectedAnswerBox(hintIndex);

                //need to find index
                int indexToAdd = -1;
                for (var i = 0;
                    i <
                        widget.questions[widget.currentQuestionIndex].options
                            .length;
                    i++) {
                  //need to check this condition to get index for every letter
                  //ex. Cricket if first c is in submit answer list then index of second c will be consider
                  if (widget.questions[widget.currentQuestionIndex]
                              .options[i] ==
                          correctAnswer[hintIndex] &&
                      !submittedAnswer.contains(i)) {
                    indexToAdd = i;
                  }
                }

                //update submitted answer
                setState(() {
                  submittedAnswer[currentSelectedIndex] = indexToAdd;
                  hintsCounter--;
                });
                //start animation

                await controllers[currentSelectedIndex].forward();
                await topContainerAnimationControllers[currentSelectedIndex]
                    .forward();
              } else {
                showAdDialog();
              }
            },
      child: Opacity(
        opacity: hintsCounter == 0 || !submittedAnswer.contains(-1) ? 0.5 : 1.0,
        child: Container(
          height: optionBoxContainerHeight,
          width: optionBoxContainerHeight * 2,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
              color: Theme.of(context).primaryColor),
          margin: EdgeInsets.symmetric(horizontal: 5.0, vertical: 5),
          child: Text(
            AppLocalization.of(context)!.getTranslatedValues(hintKey)!,
            style: TextStyle(
              color: Theme.of(context).backgroundColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerCorrectness() {
    bool correctAnswer =
        UiUtils.buildGuessTheWordQuestionAnswer(getSubmittedAnswer()) ==
            widget.questions[widget.currentQuestionIndex].answer;
    if (correctAnswer) {
      playSound(correctAnswerSoundTrack);
    } else {
      playSound(wrongAnswerSoundTrack);
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          backgroundColor: correctAnswer
              ? Theme.of(context).primaryColor
              : Theme.of(context).colorScheme.secondary,
          radius: 20,
          child: Center(
            child: Icon(correctAnswer ? Icons.check : Icons.close,
                color: Theme.of(context).backgroundColor),
          ),
        ),
        SizedBox(
          height: 5.0,
        ),
        Text(
          UiUtils.buildGuessTheWordQuestionAnswer(getSubmittedAnswer()),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: correctAnswer
                ? Theme.of(context).primaryColor
                : Theme.of(context).colorScheme.secondary,
            fontSize: 20.0,
            letterSpacing: 1.0,
          ),
        )
      ],
    );
  }

  Widget _buildCurrentCoins() {
    return BlocBuilder<UserDetailsCubit, UserDetailsState>(
        bloc: context.read<UserDetailsCubit>(),
        builder: (context, state) {
          if (state is UserDetailsFetchSuccess) {
            return Text(
              AppLocalization.of(context)!.getTranslatedValues("coinsLbl")! +
                  " : ${state.userProfile.coins}",
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            );
          }
          return SizedBox();
        });
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.questions[widget.currentQuestionIndex];
    return BlocListener<SettingsCubit, SettingsState>(
        bloc: context.read<SettingsCubit>(),
        listener: (context, state) {
          if (state.settingsModel!.playAreaFontSize != textSize) {
            setState(() {
              textSize =
                  context.read<SettingsCubit>().getSettings().playAreaFontSize;
            });
          }
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 17.5,
              ),
              HorizontalTimerContainer(
                  timerAnimationController: widget.timerAnimationController),
              SizedBox(
                height: 12.5,
              ),
              Container(
                child: Stack(
                  children: [
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child:
                          widget.showHint ? _buildCurrentCoins() : SizedBox(),
                    ),
                    Align(
                      alignment: AlignmentDirectional.center,
                      child: Text(
                        "${widget.currentQuestionIndex + 1} | ${widget.questions.length}",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                color: Theme.of(context).colorScheme.secondary,
              ),
              SizedBox(
                height: 5.0,
              ),
              //
              Container(
                alignment: Alignment.center,
                child: Text(
                  "${question.question}",
                  style: TextStyle(
                      height: 1.125,
                      fontSize: textSize,
                      color: Theme.of(context).colorScheme.secondary),
                ),
              ),
              SizedBox(
                height: widget.constraints.maxHeight * (0.025),
              ),
              question.image.isNotEmpty
                  ? Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25.0)),
                      width: MediaQuery.of(context).size.width,
                      height: widget.constraints.maxHeight * (0.275),
                      alignment: Alignment.center,
                      child: CachedNetworkImage(
                        placeholder: (context, _) {
                          return Center(
                            child: CircularProgressContainer(
                              useWhiteLoader: false,
                            ),
                          );
                        },
                        imageUrl: question.image,
                        imageBuilder: (context, imageProvider) {
                          return Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: imageProvider, fit: BoxFit.cover),
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                          );
                        },
                        errorWidget: (context, image, _) => Center(
                          child: Icon(
                            Icons.error,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    )
                  : Container(),
              SizedBox(
                height: widget.constraints.maxHeight * (0.025),
              ),
              AnimatedSwitcher(
                  duration: Duration(milliseconds: 300),
                  child:
                      widget.questions[widget.currentQuestionIndex].hasAnswered
                          ? _buildAnswerCorrectness()
                          : _buildAnswerBoxes()),
              SizedBox(
                height: widget.constraints.maxHeight * (0.04),
              ),
              _buildOptions(question.options),
              SizedBox(
                height: 15.0,
              ),
            ],
          ),
        ));
  }
}
