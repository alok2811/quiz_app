import 'package:flutter/material.dart';
import 'package:ayuprep/app/appLocalization.dart';
import 'package:ayuprep/app/routes.dart';

import 'package:ayuprep/features/bookmark/bookmarkRepository.dart';
import 'package:ayuprep/features/bookmark/cubits/audioQuestionBookmarkCubit.dart';
import 'package:ayuprep/features/bookmark/cubits/bookmarkCubit.dart';
import 'package:ayuprep/features/bookmark/cubits/guessTheWordBookmarkCubit.dart';
import 'package:ayuprep/features/bookmark/cubits/updateBookmarkCubit.dart';
import 'package:ayuprep/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:ayuprep/features/quiz/models/guessTheWordQuestion.dart';
import 'package:ayuprep/features/quiz/models/question.dart';
import 'package:ayuprep/features/quiz/models/quizType.dart';
import 'package:ayuprep/features/systemConfig/cubits/systemConfigCubit.dart';
import 'package:ayuprep/ui/widgets/customBackButton.dart';

import 'package:ayuprep/ui/widgets/customListTile.dart';
import 'package:ayuprep/ui/widgets/customRoundedButton.dart';
import 'package:ayuprep/ui/widgets/errorContainer.dart';
import 'package:ayuprep/ui/widgets/pageBackgroundGradientContainer.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ayuprep/utils/answerEncryption.dart';
import 'package:ayuprep/utils/errorMessageKeys.dart';
import 'package:ayuprep/utils/stringLabels.dart';
import 'package:ayuprep/utils/uiUtils.dart';

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({Key? key}) : super(key: key);

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  int _currentSelectedTab = 1;

  void openBottomSheet(
      {required String question,
      required String correctAnswer,
      required String yourAnswer}) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.0),
          topRight: Radius.circular(25.0),
        )),
        backgroundColor: Theme.of(context).backgroundColor,
        isScrollControlled: true,
        context: context,
        builder: (_) {
          return SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 15.0,
                ),
                Container(
                  width: MediaQuery.of(context).size.width * (0.9),
                  child: Text(
                    "$question",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                        color: Theme.of(context).primaryColor),
                  ),
                ),
                Divider(),
                SizedBox(
                  height: 10.0,
                ),
                Container(
                  width: MediaQuery.of(context).size.width * (0.9),
                  child: Text(
                    AppLocalization.of(context)!
                            .getTranslatedValues("yourAnsLbl")! +
                        ":" +
                        " $yourAnswer",
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15.0,
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                ),
                SizedBox(
                  height: 7.5,
                ),
                Container(
                  width: MediaQuery.of(context).size.width * (0.9),
                  child: Text(
                    AppLocalization.of(context)!
                            .getTranslatedValues("correctAndLbl")! +
                        ":" +
                        " $correctAnswer",
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15.0,
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                ),
                SizedBox(
                  height: 25.0,
                ),
              ],
            ),
          );
        });
  }

  Widget _buildTabContainer(String title, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentSelectedTab = index;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Text(
          title,
          style: TextStyle(
            color: Theme.of(context)
                .primaryColor
                .withOpacity(_currentSelectedTab == index ? 1.0 : 0.5),
            fontSize: 15.5,
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.only(bottom: 5),
      child: Stack(
        children: [
          Align(
            alignment: AlignmentDirectional.bottomStart,
            child: Padding(
              padding: EdgeInsetsDirectional.only(start: 25.0, bottom: 40.0),
              child: CustomBackButton(
                removeSnackBars: false,
                iconColor: Theme.of(context).primaryColor,
              ),
            ),
          ),
          Align(
            alignment: AlignmentDirectional.bottomCenter,
            child: Padding(
              padding: EdgeInsetsDirectional.only(bottom: 42.5),
              child: Text(
                  AppLocalization.of(context)!
                      .getTranslatedValues(bookmarkLbl)!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 21.0, color: Theme.of(context).primaryColor)),
            ),
          ),
          Align(
            alignment: AlignmentDirectional.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height *
                  (UiUtils.appBarHeightPercentage) *
                  (0.25),
              child: ListView(
                padding: EdgeInsets.only(left: 30.0, right: 25.0),
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                children: [
                  _buildTabContainer(
                      AppLocalization.of(context)!
                          .getTranslatedValues(quizZone)!,
                      1),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.015,
                  ),
                  context.read<SystemConfigCubit>().getIsGuessTheWordAvailable()
                      ? _buildTabContainer(
                          AppLocalization.of(context)!
                              .getTranslatedValues(guessTheWord)!,
                          2)
                      : SizedBox(),
                  context.read<SystemConfigCubit>().getIsGuessTheWordAvailable()
                      ? SizedBox(
                          width: MediaQuery.of(context).size.width * 0.015,
                        )
                      : SizedBox(),
                  context
                          .read<SystemConfigCubit>()
                          .getIsAudioQuestionAvailable()
                      ? _buildTabContainer(
                          AppLocalization.of(context)!
                              .getTranslatedValues(audioQuestionsKey)!,
                          3)
                      : SizedBox(),
                ],
              ),
            ),
          ),
        ],
      ),
      height:
          MediaQuery.of(context).size.height * (UiUtils.appBarHeightPercentage),
      decoration: BoxDecoration(
          boxShadow: [UiUtils.buildAppbarShadow()],
          color: Theme.of(context).backgroundColor,
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20.0),
              bottomRight: Radius.circular(20.0))),
    );
  }

  Widget _buildQuizZoneQuestions() {
    final bookmarkCubit = context.read<BookmarkCubit>();
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        child: BlocBuilder<BookmarkCubit, BookmarkState>(
            builder: (context, state) {
          if (state is BookmarkFetchSuccess) {
            if (state.questions.isEmpty) {
              return Center(
                child: Text(
                  AppLocalization.of(context)!
                      .getTranslatedValues("noBookmarkQueLbl")!,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 20.0,
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsetsDirectional.only(
                  top: 25.0,
                  start: MediaQuery.of(context).size.width * (0.075),
                  end: MediaQuery.of(context).size.width * (0.075),
                  bottom: 100),
              itemBuilder: (context, index) {
                Question question = state.questions[index];

                //providing updateBookmarkCubit to every bookmarekd question
                return BlocProvider<UpdateBookmarkCubit>(
                  create: (context) =>
                      UpdateBookmarkCubit(BookmarkRepository()),
                  //using builder so we can access the recently provided cubit
                  child: Builder(
                    builder: (context) =>
                        BlocConsumer<UpdateBookmarkCubit, UpdateBookmarkState>(
                      bloc: context.read<UpdateBookmarkCubit>(),
                      listener: (context, state) {
                        if (state is UpdateBookmarkSuccess) {
                          bookmarkCubit.removeBookmarkQuestion(question.id,
                              context.read<UserDetailsCubit>().getUserId());
                        }
                        if (state is UpdateBookmarkFailure) {
                          UiUtils.setSnackbar(
                              AppLocalization.of(context)!.getTranslatedValues(
                                  convertErrorCodeToLanguageKey(
                                      updateBookmarkFailureCode))!,
                              context,
                              false);
                        }
                      },
                      builder: (context, state) {
                        return GestureDetector(
                          onTap: () {
                            openBottomSheet(
                              question: question.question!,
                              yourAnswer: context
                                  .read<BookmarkCubit>()
                                  .getSubmittedAnswerForQuestion(question.id),
                              correctAnswer: question
                                  .answerOptions![
                                      question.answerOptions!.indexWhere(
                                (element) =>
                                    element.id ==
                                    AnswerEncryption.decryptCorrectAnswer(
                                      rawKey: context
                                          .read<UserDetailsCubit>()
                                          .getUserFirebaseId(),
                                      correctAnswer: question.correctAnswer!,
                                    ),
                              )]
                                  .title!,
                            );
                          },
                          child: CustomListTile(
                            opacity:
                                state is UpdateBookmarkInProgress ? 0.5 : 1.0,
                            trailingButtonOnTap:
                                state is UpdateBookmarkInProgress
                                    ? () {}
                                    : () {
                                        context
                                            .read<UpdateBookmarkCubit>()
                                            .updateBookmark(
                                                context
                                                    .read<UserDetailsCubit>()
                                                    .getUserId(),
                                                question.id!,
                                                "0",
                                                "1");
                                      },
                            subtitle: AppLocalization.of(context)!
                                    .getTranslatedValues("yourAnsLbl")! +
                                ":" +
                                " ${context.read<BookmarkCubit>().getSubmittedAnswerForQuestion(question.id)}",
                            title: question.question,
                            leadingChild: Text(
                              "${index + 1}",
                              style: TextStyle(
                                color: Theme.of(context).backgroundColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
              itemCount: state.questions.length,
            );
          }
          if (state is BookmarkFetchFailure) {
            return ErrorContainer(
              errorMessage: AppLocalization.of(context)!.getTranslatedValues(
                  convertErrorCodeToLanguageKey(state.errorMessageCode)),
              showErrorImage: true,
              errorMessageColor: Theme.of(context).primaryColor,
              onTapRetry: () {
                context
                    .read<BookmarkCubit>()
                    .getBookmark(context.read<UserDetailsCubit>().getUserId());
              },
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        }),
        padding:
            EdgeInsets.only(top: MediaQuery.of(context).size.height * (0.16)),
      ),
    );
  }

  Widget _buildAudioQuestions() {
    final bookmarkCubit = context.read<AudioQuestionBookmarkCubit>();
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        child: BlocBuilder<AudioQuestionBookmarkCubit,
                AudioQuestionBookMarkState>(
            bloc: bookmarkCubit,
            builder: (context, state) {
              if (state is AudioQuestionBookmarkFetchSuccess) {
                if (state.questions.isEmpty) {
                  return Center(
                    child: Text(
                      AppLocalization.of(context)!
                          .getTranslatedValues("noBookmarkQueLbl")!,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 20.0,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsetsDirectional.only(
                      top: 25.0,
                      start: MediaQuery.of(context).size.width * (0.075),
                      end: MediaQuery.of(context).size.width * (0.075),
                      bottom: 100),
                  itemBuilder: (context, index) {
                    Question question = state.questions[index];

                    //providing updateBookmarkCubit to every bookmarekd question
                    return BlocProvider<UpdateBookmarkCubit>(
                      create: (context) =>
                          UpdateBookmarkCubit(BookmarkRepository()),
                      //using builder so we can access the recently provided cubit
                      child: Builder(
                        builder: (context) => BlocConsumer<UpdateBookmarkCubit,
                            UpdateBookmarkState>(
                          bloc: context.read<UpdateBookmarkCubit>(),
                          listener: (context, state) {
                            if (state is UpdateBookmarkSuccess) {
                              bookmarkCubit.removeBookmarkQuestion(question.id,
                                  context.read<UserDetailsCubit>().getUserId());
                            }
                            if (state is UpdateBookmarkFailure) {
                              UiUtils.setSnackbar(
                                  AppLocalization.of(context)!
                                      .getTranslatedValues(
                                          convertErrorCodeToLanguageKey(
                                              updateBookmarkFailureCode))!,
                                  context,
                                  false);
                            }
                          },
                          builder: (context, state) {
                            return GestureDetector(
                              onTap: () {
                                openBottomSheet(
                                  question: question.question!,
                                  yourAnswer: bookmarkCubit
                                      .getSubmittedAnswerForQuestion(
                                          question.id),
                                  correctAnswer: question
                                      .answerOptions![question.answerOptions!
                                          .indexWhere((element) =>
                                              element.id ==
                                              AnswerEncryption
                                                  .decryptCorrectAnswer(
                                                rawKey: context
                                                    .read<UserDetailsCubit>()
                                                    .getUserFirebaseId(),
                                                correctAnswer:
                                                    question.correctAnswer!,
                                              ))]
                                      .title!,
                                );
                              },
                              child: CustomListTile(
                                opacity: state is UpdateBookmarkInProgress
                                    ? 0.5
                                    : 1.0,
                                trailingButtonOnTap: state
                                        is UpdateBookmarkInProgress
                                    ? () {}
                                    : () {
                                        context
                                            .read<UpdateBookmarkCubit>()
                                            .updateBookmark(
                                                context
                                                    .read<UserDetailsCubit>()
                                                    .getUserId(),
                                                question.id!,
                                                "0",
                                                "4"); // type is 4 for audio questions
                                      },
                                subtitle: AppLocalization.of(context)!
                                        .getTranslatedValues("yourAnsLbl")! +
                                    ":" +
                                    " ${bookmarkCubit.getSubmittedAnswerForQuestion(question.id)}",
                                title: question.question,
                                leadingChild: Text(
                                  "${index + 1}",
                                  style: TextStyle(
                                    color: Theme.of(context).backgroundColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                  itemCount: state.questions.length,
                );
              }
              if (state is AudioQuestionBookmarkFetchFailure) {
                return ErrorContainer(
                  errorMessage: AppLocalization.of(context)!
                      .getTranslatedValues(convertErrorCodeToLanguageKey(
                          state.errorMessageCode)),
                  showErrorImage: true,
                  errorMessageColor: Theme.of(context).primaryColor,
                  onTapRetry: () {
                    context.read<AudioQuestionBookmarkCubit>().getBookmark(
                        context.read<UserDetailsCubit>().getUserId());
                  },
                );
              }
              return Center(
                child: CircularProgressIndicator(),
              );
            }),
        padding:
            EdgeInsets.only(top: MediaQuery.of(context).size.height * (0.16)),
      ),
    );
  }

  Widget _buildGuessTheWordQuestions() {
    final bookmarkCubit = context.read<GuessTheWordBookmarkCubit>();
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        child: BlocBuilder<GuessTheWordBookmarkCubit,
                GuessTheWordBookmarkState>(
            bloc: context.read<GuessTheWordBookmarkCubit>(),
            builder: (context, state) {
              if (state is GuessTheWordBookmarkFetchSuccess) {
                if (state.questions.isEmpty) {
                  return Center(
                    child: Text(
                      AppLocalization.of(context)!
                          .getTranslatedValues("noBookmarkQueLbl")!,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 20.0,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsetsDirectional.only(
                      top: 25.0,
                      start: MediaQuery.of(context).size.width * (0.075),
                      end: MediaQuery.of(context).size.width * (0.075),
                      bottom: 100),
                  itemBuilder: (context, index) {
                    GuessTheWordQuestion question = state.questions[index];

                    //providing updateBookmarkCubit to every bookmarekd question
                    return BlocProvider<UpdateBookmarkCubit>(
                      create: (context) =>
                          UpdateBookmarkCubit(BookmarkRepository()),
                      //using builder so we can access the recently provided cubit
                      child: Builder(
                        builder: (context) => BlocConsumer<UpdateBookmarkCubit,
                            UpdateBookmarkState>(
                          bloc: context.read<UpdateBookmarkCubit>(),
                          listener: (context, state) {
                            if (state is UpdateBookmarkSuccess) {
                              bookmarkCubit.removeBookmarkQuestion(question.id,
                                  context.read<UserDetailsCubit>().getUserId());
                            }
                            if (state is UpdateBookmarkFailure) {
                              UiUtils.setSnackbar(
                                  AppLocalization.of(context)!
                                      .getTranslatedValues(
                                          convertErrorCodeToLanguageKey(
                                              updateBookmarkFailureCode))!,
                                  context,
                                  false);
                            }
                          },
                          builder: (context, state) {
                            return GestureDetector(
                              onTap: () {
                                openBottomSheet(
                                    yourAnswer: context
                                        .read<GuessTheWordBookmarkCubit>()
                                        .getSubmittedAnswerForQuestion(
                                            question.id),
                                    question: question.question,
                                    correctAnswer: question.answer);
                              },
                              child: CustomListTile(
                                opacity: state is UpdateBookmarkInProgress
                                    ? 0.5
                                    : 1.0,
                                trailingButtonOnTap: state
                                        is UpdateBookmarkInProgress
                                    ? () {}
                                    : () {
                                        context
                                            .read<UpdateBookmarkCubit>()
                                            .updateBookmark(
                                                context
                                                    .read<UserDetailsCubit>()
                                                    .getUserId(),
                                                question.id,
                                                "0",
                                                "3");
                                      },
                                subtitle: AppLocalization.of(context)!
                                        .getTranslatedValues("yourAnsLbl")! +
                                    ":" +
                                    " ${context.read<GuessTheWordBookmarkCubit>().getSubmittedAnswerForQuestion(question.id)}",
                                title: question.question,
                                leadingChild: Text(
                                  "${index + 1}",
                                  style: TextStyle(
                                    color: Theme.of(context).backgroundColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                  itemCount: state.questions.length,
                );
              }
              if (state is GuessTheWordBookmarkFetchFailure) {
                return ErrorContainer(
                  errorMessage: AppLocalization.of(context)!
                      .getTranslatedValues(convertErrorCodeToLanguageKey(
                          state.errorMessageCode)),
                  showErrorImage: true,
                  errorMessageColor: Theme.of(context).primaryColor,
                  onTapRetry: () {
                    context.read<GuessTheWordBookmarkCubit>().getBookmark(
                        context.read<UserDetailsCubit>().getUserId());
                  },
                );
              }
              return Center(
                child: CircularProgressIndicator(),
              );
            }),
        padding:
            EdgeInsets.only(top: MediaQuery.of(context).size.height * (0.16)),
      ),
    );
  }

  Widget _buildPlayButton() {
    if (_currentSelectedTab == 1) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: EdgeInsets.only(bottom: 25.0),
          child: BlocBuilder<BookmarkCubit, BookmarkState>(
            builder: (context, state) {
              if (state is BookmarkFetchSuccess && state.questions.isNotEmpty) {
                return CustomRoundedButton(
                  widthPercentage: 0.85,
                  backgroundColor: Theme.of(context).primaryColor,
                  buttonTitle: AppLocalization.of(context)!
                      .getTranslatedValues("playBookmarkBtn")!,
                  radius: 5.0,
                  showBorder: false,
                  fontWeight: FontWeight.w500,
                  height: 50.0,
                  titleColor: Theme.of(context).backgroundColor,
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      Routes.bookmarkQuiz,
                      arguments: QuizTypes.quizZone,
                    );
                  },
                  elevation: 6.5,
                  textSize: 17.0,
                );
              }
              return Container();
            },
          ),
        ),
      );
    }
    if (_currentSelectedTab == 2) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: EdgeInsets.only(bottom: 25.0),
          child:
              BlocBuilder<GuessTheWordBookmarkCubit, GuessTheWordBookmarkState>(
            builder: (context, state) {
              if (state is GuessTheWordBookmarkFetchSuccess &&
                  state.questions.isNotEmpty) {
                return CustomRoundedButton(
                  widthPercentage: 0.85,
                  backgroundColor: Theme.of(context).primaryColor,
                  buttonTitle: AppLocalization.of(context)!
                      .getTranslatedValues("playBookmarkBtn")!,
                  radius: 5.0,
                  showBorder: false,
                  fontWeight: FontWeight.w500,
                  height: 50.0,
                  titleColor: Theme.of(context).backgroundColor,
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      Routes.bookmarkQuiz,
                      arguments: QuizTypes.guessTheWord,
                    );
                  },
                  elevation: 6.5,
                  textSize: 17.0,
                );
              }
              return Container();
            },
          ),
        ),
      );
    }
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.only(bottom: 25.0),
        child:
            BlocBuilder<AudioQuestionBookmarkCubit, AudioQuestionBookMarkState>(
          builder: (context, state) {
            if (state is AudioQuestionBookmarkFetchSuccess &&
                state.questions.isNotEmpty) {
              return CustomRoundedButton(
                widthPercentage: 0.85,
                backgroundColor: Theme.of(context).primaryColor,
                buttonTitle: AppLocalization.of(context)!
                    .getTranslatedValues("playBookmarkBtn")!,
                radius: 5.0,
                showBorder: false,
                fontWeight: FontWeight.w500,
                height: 50.0,
                titleColor: Theme.of(context).backgroundColor,
                onTap: () {
                  Navigator.of(context).pushNamed(
                    Routes.bookmarkQuiz,
                    arguments: QuizTypes.audioQuestions,
                  );
                },
                elevation: 6.5,
                textSize: 17.0,
              );
            }
            return Container();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageBackgroundGradientContainer(),
          Align(
            alignment: Alignment.topCenter,
            child: _currentSelectedTab == 1
                ? _buildQuizZoneQuestions()
                : _currentSelectedTab == 2
                    ? _buildGuessTheWordQuestions()
                    : _buildAudioQuestions(),
          ),
          _buildPlayButton(),
          Align(
            alignment: Alignment.topCenter,
            child: _buildAppBar(),
          ),
        ],
      ),
    );
  }
}
