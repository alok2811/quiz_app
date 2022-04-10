import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ayuprep/features/bookmark/bookmarkRepository.dart';
import 'package:ayuprep/features/quiz/models/question.dart';

@immutable
abstract class AudioQuestionBookMarkState {}

class AudioQuestionBookmarkInitial extends AudioQuestionBookMarkState {}

class AudioQuestionBookmarkFetchInProgress extends AudioQuestionBookMarkState {}

class AudioQuestionBookmarkFetchSuccess extends AudioQuestionBookMarkState {
  //bookmarked questions
  final List<Question> questions;
  final List<Map<String, String>> submittedAnswerIds;
  AudioQuestionBookmarkFetchSuccess(this.questions, this.submittedAnswerIds);
}

class AudioQuestionBookmarkFetchFailure extends AudioQuestionBookMarkState {
  final String errorMessageCode;
  AudioQuestionBookmarkFetchFailure(this.errorMessageCode);
}

class AudioQuestionBookmarkCubit extends Cubit<AudioQuestionBookMarkState> {
  final BookmarkRepository _bookmarkRepository;
  AudioQuestionBookmarkCubit(this._bookmarkRepository)
      : super(AudioQuestionBookmarkInitial());

  void getBookmark(String userId) async {
    emit(AudioQuestionBookmarkFetchInProgress());

    try {
      List<Question> questions = await _bookmarkRepository.getBookmark(
          userId, "4") as List<Question>; //type 4 is for audio questions

      //coming from local database (hive)
      List<Map<String, String>> submittedAnswerIds = await _bookmarkRepository
          .getSubmittedAnswerOfAudioBookmarkedQuestions(
              questions.map((e) => e.id!).toList(), userId);

      emit(AudioQuestionBookmarkFetchSuccess(questions, submittedAnswerIds));
    } catch (e) {
      emit(AudioQuestionBookmarkFetchFailure(e.toString()));
    }
  }

  bool hasQuestionBookmarked(String? questionId) {
    if (state is AudioQuestionBookmarkFetchSuccess) {
      final questions = (state as AudioQuestionBookmarkFetchSuccess).questions;
      return questions.indexWhere((element) => element.id == questionId) != -1;
    }
    return false;
  }

  void addBookmarkQuestion(Question question, String userId) {
    print(
        "Added question id ${question.id} and answer id is ${question.submittedAnswerId}");
    if (state is AudioQuestionBookmarkFetchSuccess) {
      final currentState = (state as AudioQuestionBookmarkFetchSuccess);
      //set submitted answer for given index initially submitted answer will be empty
      _bookmarkRepository.setAnswerForAudioBookmarkedQuestion(
          question.id!, question.submittedAnswerId, userId);
      emit(AudioQuestionBookmarkFetchSuccess(
        List.from(currentState.questions)
          ..insert(0, question.updateQuestionWithAnswer(submittedAnswerId: "")),
        List.from(currentState.submittedAnswerIds)
          ..insert(0, {question.id!: question.submittedAnswerId}),
      ));
    }
  }

  //we need to update submitted answer for given queston index
  //this will be call after user has given answer for question and question has been bookmarked
  void updateSubmittedAnswerId(Question question, String userId) {
    if (state is AudioQuestionBookmarkFetchSuccess) {
      final currentState = (state as AudioQuestionBookmarkFetchSuccess);
      print("Submitted AnswerId : ${question.submittedAnswerId}");
      _bookmarkRepository.setAnswerForAudioBookmarkedQuestion(
          question.id!, question.submittedAnswerId, userId);
      List<Map<String, String>> updatedSubmittedAnswerIds =
          List.from(currentState.submittedAnswerIds);
      //
      updatedSubmittedAnswerIds[updatedSubmittedAnswerIds
          .indexWhere((element) => element.keys.first == question.id)] = {
        question.id!: question.submittedAnswerId
      };
      emit(AudioQuestionBookmarkFetchSuccess(
        List.from(currentState.questions),
        updatedSubmittedAnswerIds,
      ));
    }
  }

  //remove bookmark question and respective submitted answer
  void removeBookmarkQuestion(String? questionId, String userId) {
    if (state is AudioQuestionBookmarkFetchSuccess) {
      final currentState = (state as AudioQuestionBookmarkFetchSuccess);
      List<Question> updatedQuestions = List.from(currentState.questions);
      List<Map<String, String>> submittedAnswerIds =
          List.from(currentState.submittedAnswerIds);

      updatedQuestions.removeWhere((element) => element.id == questionId);
      submittedAnswerIds
          .removeWhere((element) => element.keys.first == questionId);
      _bookmarkRepository.removeAudioBookmarkedAnswer("$userId-$questionId");
      emit(AudioQuestionBookmarkFetchSuccess(
        updatedQuestions,
        submittedAnswerIds,
      ));
    }
  }

  List<Question> questions() {
    if (state is AudioQuestionBookmarkFetchSuccess) {
      return (state as AudioQuestionBookmarkFetchSuccess).questions;
    }
    return [];
  }

  //to get submitted answer title for given quesiton
  String getSubmittedAnswerForQuestion(String? questionId) {
    if (state is AudioQuestionBookmarkFetchSuccess) {
      final currentState = (state as AudioQuestionBookmarkFetchSuccess);
      //submitted answer index based on question id
      int index = currentState.submittedAnswerIds
          .indexWhere((element) => element.keys.first == questionId);
      if (currentState.submittedAnswerIds[index][questionId]!.isEmpty ||
          currentState.submittedAnswerIds[index][questionId] == "-1" ||
          currentState.submittedAnswerIds[index][questionId] == "0") {
        return "Un-attempted";
      }

      Question question = currentState.questions
          .where((element) => element.id == questionId)
          .toList()
          .first;

      int submittedAnswerOptionIndex = question.answerOptions!.indexWhere(
          (element) =>
              element.id == currentState.submittedAnswerIds[index][questionId]);

      return question.answerOptions![submittedAnswerOptionIndex].title!;
    }
    return "";
  }

  void updateState(AudioQuestionBookMarkState updatedState) {
    emit(updatedState);
  }
}
