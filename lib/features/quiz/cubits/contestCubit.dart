import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ayuprep/features/quiz/models/contest.dart';

import '../quizRepository.dart';

@immutable
abstract class ContestState {}

class ContestInitial extends ContestState {}

class ContestProgress extends ContestState {}

class ContestSuccess extends ContestState {
  final Contests contestList;

  ContestSuccess(
    this.contestList,
  );
}

class ContestFailure extends ContestState {
  final String errorMessage;
  ContestFailure(this.errorMessage);
}

class ContestCubit extends Cubit<ContestState> {
  final QuizRepository _quizRepository;
  ContestCubit(this._quizRepository) : super(ContestInitial());

  getContest(String? userId) async {
    emit(ContestProgress());
    _quizRepository.getContest(userId).then((val) {
      emit(ContestSuccess(val));
    }).catchError((e) {
      emit(ContestFailure(e.toString()));
    });
  }
}
