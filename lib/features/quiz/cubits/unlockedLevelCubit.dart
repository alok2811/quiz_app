import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ayuprep/features/quiz/quizRepository.dart';

@immutable
abstract class UnlockedLevelState {}

class UnlockedLevelInitial extends UnlockedLevelState {}

class UnlockedLevelFetchInProgress extends UnlockedLevelState {}

class UnlockedLevelFetchSuccess extends UnlockedLevelState {
  final int unlockedLevel;
  final String? categoryId;
  final String? subcategoryId;

  UnlockedLevelFetchSuccess(this.categoryId, this.subcategoryId, this.unlockedLevel);
}

class UnlockedLevelFetchFailure extends UnlockedLevelState {
  final String errorMessage;
  UnlockedLevelFetchFailure(this.errorMessage);
}

class UnlockedLevelCubit extends Cubit<UnlockedLevelState> {
  final QuizRepository _quizRepository;
  UnlockedLevelCubit(this._quizRepository) : super(UnlockedLevelInitial());

  void fetchUnlockLevel(String? userId, String? category, String? subCategory) async {
    emit(UnlockedLevelFetchInProgress());
    _quizRepository
        .getUnlockedLevel(userId, category, subCategory)
        .then(
          (val) => emit((UnlockedLevelFetchSuccess(category, subCategory, val))),
        )
        .catchError((e) {
      emit(UnlockedLevelFetchFailure(e.toString()));
    });
  }
}
