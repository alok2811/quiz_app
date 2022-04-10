import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ayuprep/features/exam/examRepository.dart';
import 'package:ayuprep/features/exam/models/exam.dart';
import 'package:ayuprep/features/exam/models/examResult.dart';
import 'package:ayuprep/features/quiz/models/question.dart';
import 'package:ayuprep/utils/answerEncryption.dart';

import '../../quiz/models/question.dart';

abstract class ExamState {}

class ExamInitial extends ExamState {}

class ExamFetchInProgress extends ExamState {}

class ExamFetchFailure extends ExamState {
  final String errorMessage;

  ExamFetchFailure(this.errorMessage);
}

class ExamFetchSuccess extends ExamState {
  final List<Question> questions;
  final Exam exam;

  ExamFetchSuccess({required this.exam, required this.questions});
}

class ExamCubit extends Cubit<ExamState> {
  final ExamRepository _examRepository;

  ExamCubit(this._examRepository) : super(ExamInitial());

  void updateState(ExamState newState) {
    emit(newState);
  }

  void startExam({required Exam exam, required String userId}) async {
    emit(ExamFetchInProgress());
    //
    try {
      //fetch question

      List<Question> questions =
          await _examRepository.getExamMouduleQuestions(examModuleId: exam.id);

      //

      //check if user can give exam or not
      //if user is in exam then it will throw 103 error means fill all data
      await _examRepository.updateExamStatusToInExam(
          examModuleId: exam.id, userId: userId);
      await _examRepository.examLocalDataSource.addExamModuleId(exam.id);
      emit(
          ExamFetchSuccess(exam: exam, questions: arrangeQuestions(questions)));
    } catch (e) {
      emit(ExamFetchFailure(e.toString()));
    }
  }

  List<Question> arrangeQuestions(List<Question> questions) {
    List<Question> arrangedQuestions = [];

    List<String> marks =
        questions.map((question) => question.marks!).toSet().toList();
    //sort marks
    marks.sort((first, second) => first.compareTo(second));

    //arrange questions from low to high mrak
    marks.forEach((questionMark) {
      arrangedQuestions.addAll(
          questions.where((element) => element.marks == questionMark).toList());
    });

    return arrangedQuestions;
  }

  int getQuetionIndexById(String questionId) {
    if (state is ExamFetchSuccess) {
      return (state as ExamFetchSuccess)
          .questions
          .indexWhere((element) => element.id == questionId);
    }
    return 0;
  }

  //submitted AnswerId will contain -1, 0 or optionId (a,b,c,d,e)
  void updateQuestionWithAnswer(String questionId, String submittedAnswerId) {
    if (state is ExamFetchSuccess) {
      //fethcing questions that need to update
      List<Question> updatedQuestions = (state as ExamFetchSuccess).questions;
      //fetching index of question that need to update with submittedAnswer
      int questionIndex =
          updatedQuestions.indexWhere((element) => element.id == questionId);
      //update question at given questionIndex with submittedAnswerId
      updatedQuestions[questionIndex] = updatedQuestions[questionIndex]
          .updateQuestionWithAnswer(submittedAnswerId: submittedAnswerId);

      emit(ExamFetchSuccess(
          exam: (state as ExamFetchSuccess).exam, questions: updatedQuestions));
    }
  }

  List<Question> getQuestions() {
    if (state is ExamFetchSuccess) {
      return (state as ExamFetchSuccess).questions;
    }
    return [];
  }

  Exam getExam() {
    if (state is ExamFetchSuccess) {
      return (state as ExamFetchSuccess).exam;
    }
    return Exam.fromJson({});
  }

  bool canUserSubmitAnswerAgainInExam() {
    return getExam().answerAgain == "1";
  }

  void submitResult({
    required String userId,
    required String totalDuration,
    required bool rulesViolated,
    required List<String> capturedQuestionIds,
  }) {
    if (state is ExamFetchSuccess) {
      List<Statistics> markStatistics = [];

      getUniqueQuestionMark().forEach((mark) {
        List<Question> questions = getQuestionsByMark(mark);
        int correctAnswers = questions
            .where((element) =>
                element.submittedAnswerId ==
                AnswerEncryption.decryptCorrectAnswer(
                    rawKey: userId, correctAnswer: element.correctAnswer!))
            .toList()
            .length;
        Statistics statistics = Statistics(
            mark: mark,
            correctAnswer: correctAnswers.toString(),
            incorrect: (questions.length - correctAnswers).toString());
        markStatistics.add(statistics);
      });

      //
      markStatistics.forEach((element) {
        print(element.toJson());
      });

      _examRepository.submitExamResult(
          capturedQuestionIds: capturedQuestionIds,
          rulesViolated: rulesViolated,
          obtainedMarks: obtainedMarks(userId).toString(),
          examModuleId: (state as ExamFetchSuccess).exam.id,
          userId: userId,
          totalDuration: totalDuration,
          statistics: markStatistics.map((e) => e.toJson()).toList());

      _examRepository.examLocalDataSource
          .removeExamModuleId((state as ExamFetchSuccess).exam.id);
    }
  }

  int correctAnswers(String userId) {
    if (state is ExamFetchSuccess) {
      return (state as ExamFetchSuccess)
          .questions
          .where((element) =>
              element.submittedAnswerId ==
              AnswerEncryption.decryptCorrectAnswer(
                  rawKey: userId, correctAnswer: element.correctAnswer!))
          .toList()
          .length;
    }
    return 0;
  }

  int incorrectAnswers(String userId) {
    if (state is ExamFetchSuccess) {
      return (state as ExamFetchSuccess).questions.length -
          correctAnswers(userId);
    }
    return 0;
  }

  int obtainedMarks(String userId) {
    if (state is ExamFetchSuccess) {
      final correctAnswers = (state as ExamFetchSuccess)
          .questions
          .where((element) =>
              element.submittedAnswerId ==
              AnswerEncryption.decryptCorrectAnswer(
                  rawKey: userId, correctAnswer: element.correctAnswer!))
          .toList();
      int obtainedMark = 0;

      correctAnswers.forEach((element) {
        obtainedMark = obtainedMark + int.parse(element.marks ?? "0");
      });

      return obtainedMark;
    }
    return 0;
  }

  List<Question> getQuestionsByMark(String questionMark) {
    if (state is ExamFetchSuccess) {
      return (state as ExamFetchSuccess)
          .questions
          .where((question) => question.marks == questionMark)
          .toList();
    }
    return [];
  }

  List<String> getUniqueQuestionMark() {
    if (state is ExamFetchSuccess) {
      return (state as ExamFetchSuccess)
          .questions
          .map((question) => question.marks!)
          .toSet()
          .toList();
    }
    return [];
  }

  void completePendingExams({required String userId}) {
    _examRepository.completePendingExams(userId: userId);
  }
}
