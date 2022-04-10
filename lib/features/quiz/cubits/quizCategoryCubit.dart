import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ayuprep/features/quiz/models/category.dart';
import '../quizRepository.dart';

@immutable
abstract class QuizCategoryState {}

class QuizCategoryInitial extends QuizCategoryState {}

class QuizCategoryProgress extends QuizCategoryState {}

class QuizCategorySuccess extends QuizCategoryState {
  final List<Category> categories;
  QuizCategorySuccess(this.categories);
}

class QuizCategoryFailure extends QuizCategoryState {
  final String errorMessage;
  QuizCategoryFailure(this.errorMessage);
}

class QuizCategoryCubit extends Cubit<QuizCategoryState> {
  final QuizRepository _quizRepository;
  QuizCategoryCubit(this._quizRepository) : super(QuizCategoryInitial());

  void getQuizCategory(
      {required String languageId,
      required String type,
      required String userId}) async {
    emit(QuizCategoryProgress());
    _quizRepository
        .getCategory(languageId: languageId, type: type, userId: userId)
        .then(
          (val) => emit(QuizCategorySuccess(val)),
        )
        .catchError((e) {
      emit(QuizCategoryFailure(e.toString()));
    });
  }

  void updateState(QuizCategoryState updatedState) {
    emit(updatedState);
  }

  getCat() {
    if (state is QuizCategorySuccess) {
      return (state as QuizCategorySuccess).categories;
    }
    return "";
  }
}
