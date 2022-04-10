import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ayuprep/features/quiz/models/guessTheWordQuestion.dart';

import 'package:ayuprep/features/quiz/quizRepository.dart';
import 'package:ayuprep/utils/constants.dart';
import 'package:ayuprep/utils/uiUtils.dart';

abstract class GuessTheWordQuizState {}

class GuessTheWordQuizIntial extends GuessTheWordQuizState {}

class GuessTheWordQuizFetchInProgress extends GuessTheWordQuizState {}

class GuessTheWordQuizFetchFailure extends GuessTheWordQuizState {
  final String errorMessage;
  GuessTheWordQuizFetchFailure(this.errorMessage);
}

class GuessTheWordQuizFetchSuccess extends GuessTheWordQuizState {
  final List<GuessTheWordQuestion> questions;
  final int currentPoints;

  GuessTheWordQuizFetchSuccess(
      {required this.questions, required this.currentPoints});
}

class GuessTheWordQuizCubit extends Cubit<GuessTheWordQuizState> {
  final QuizRepository _quizRepository;
  GuessTheWordQuizCubit(this._quizRepository) : super(GuessTheWordQuizIntial());

  void getQuestion({
    required String questionLanguageId,
    required String type, //category or subcategory
    required String typeId, //id of the category or subcategory
  }) {
    emit(GuessTheWordQuizFetchInProgress());
    _quizRepository
        .getGuessTheWordQuestions(
      languageId: questionLanguageId,
      type: type,
      typeId: typeId,
    )
        .then(
      (questions) {
        emit(GuessTheWordQuizFetchSuccess(
            questions: questions, currentPoints: 0));
      },
    ).catchError((e) {
      emit(GuessTheWordQuizFetchFailure(e.toString()));
    });
  }

  void updateAnswer(String answer, int answerIndex, String questionId) {
    if (state is GuessTheWordQuizFetchSuccess) {
      var questions = (state as GuessTheWordQuizFetchSuccess).questions;
      var questionIndex =
          questions.indexWhere((element) => element.id == questionId);
      var question = questions[questionIndex];
      var updatedAnswer = question.submittedAnswer;
      updatedAnswer[answerIndex] = answer;
      questions[questionIndex] =
          question.copyWith(updatedAnswer: updatedAnswer);

      emit(GuessTheWordQuizFetchSuccess(
          questions: questions,
          currentPoints:
              (state as GuessTheWordQuizFetchSuccess).currentPoints));
    }
  }

  List<GuessTheWordQuestion> getQuestions() {
    if (state is GuessTheWordQuizFetchSuccess) {
      return (state as GuessTheWordQuizFetchSuccess).questions;
    }
    return [];
  }

  int getCurrentPoints() {
    if (state is GuessTheWordQuizFetchSuccess) {
      return (state as GuessTheWordQuizFetchSuccess).currentPoints;
    }
    return 0;
  }

  void submitAnswer(String questionId, List<String> answer) {
    //update hasAnswer and current points

    if (state is GuessTheWordQuizFetchSuccess) {
      var currentState = (state as GuessTheWordQuizFetchSuccess);
      var questions = currentState.questions;
      var questionIndex =
          questions.indexWhere((element) => element.id == questionId);
      var question = questions[questionIndex];
      var updatedPoints = currentState.currentPoints;

      questions[questionIndex] =
          question.copyWith(hasAnswerGiven: true, updatedAnswer: answer);

      //check correctness of answer and update current points
      if (UiUtils.buildGuessTheWordQuestionAnswer(answer) == question.answer) {
        updatedPoints = updatedPoints + guessTheWordCorrectAnswerPoints;
      } else {
        updatedPoints = updatedPoints - guessTheWordWrongAnswerDeductPoints;
      }

      emit(GuessTheWordQuizFetchSuccess(
          questions: questions, currentPoints: updatedPoints));
    }
  }

  void updateState(GuessTheWordQuizState updatedState) {
    emit(updatedState);
  }
}
