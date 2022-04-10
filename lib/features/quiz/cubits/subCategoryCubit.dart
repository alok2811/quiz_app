import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ayuprep/features/quiz/models/subcategory.dart';
import '../quizRepository.dart';

@immutable
abstract class SubCategoryState {}

class SubCategoryInitial extends SubCategoryState {}

class SubCategoryFetchInProgress extends SubCategoryState {}

class SubCategoryFetchSuccess extends SubCategoryState {
  final List<Subcategory> subcategoryList;
  final String? categoryId;
  SubCategoryFetchSuccess(this.categoryId, this.subcategoryList);
}

class SubCategoryFetchFailure extends SubCategoryState {
  final String errorMessage;
  SubCategoryFetchFailure(this.errorMessage);
}

class SubCategoryCubit extends Cubit<SubCategoryState> {
  final QuizRepository _quizRepository;
  SubCategoryCubit(this._quizRepository) : super(SubCategoryInitial());

  void fetchSubCategory(String category, String userId) async {
    emit(SubCategoryFetchInProgress());
    _quizRepository
        .getSubCategory(category, userId)
        .then(
          (val) => emit(SubCategoryFetchSuccess(category, val)),
        )
        .catchError((e) {
      emit(SubCategoryFetchFailure(e.toString()));
    });
  }

  void updateState(SubCategoryState updatedState) {
    emit(updatedState);
  }
}
