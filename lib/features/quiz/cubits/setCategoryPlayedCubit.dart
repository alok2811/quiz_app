import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ayuprep/features/quiz/models/quizType.dart';
import 'package:ayuprep/features/quiz/quizRepository.dart';

@immutable
abstract class SetCategoryPlayedState {}

class SetCategoryPlayedInitial extends SetCategoryPlayedState {}

class SetCategoryPlayedInProgress extends SetCategoryPlayedState {}

class SetCategoryPlayedSuccess extends SetCategoryPlayedState {}

class SetCategoryPlayedFailure extends SetCategoryPlayedState {
  final String errorMessage;
  SetCategoryPlayedFailure(this.errorMessage);
}

class SetCategoryPlayed extends Cubit<SetCategoryPlayedState> {
  final QuizRepository _quizRepository;
  SetCategoryPlayed(this._quizRepository) : super(SetCategoryPlayedInitial());

  //to update level
  void setCategoryPlayed(
      {required QuizTypes quizType,
      required String userId,
      required String categoryId,
      required String subcategoryId,
      required String typeId}) async {
    emit(SetCategoryPlayedInProgress());
    _quizRepository
        .setQuizCategoryPlayed(
            type: quizType == QuizTypes.funAndLearn
                ? "2"
                : quizType == QuizTypes.guessTheWord
                    ? "3"
                    : "4",
            userId: userId,
            categoryId: categoryId,
            subcategoryId: subcategoryId,
            typeId: typeId)
        .then(
          (val) => emit((SetCategoryPlayedSuccess())),
        )
        .catchError((e) {
      emit(SetCategoryPlayedFailure(e.toString()));
    });
  }
}
