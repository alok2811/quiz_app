import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../quizRepository.dart';

@immutable
abstract class SetContestLeaderboardState {}

class SetContestLeaderboardInitial extends SetContestLeaderboardState {}

class SetContestLeaderboardProgress extends SetContestLeaderboardState {}

class SetContestLeaderboardSuccess extends SetContestLeaderboardState {}

class SetContestLeaderboardFailure extends SetContestLeaderboardState {
  final String errorMessage;
  SetContestLeaderboardFailure(this.errorMessage);
}

class SetContestLeaderboardCubit extends Cubit<SetContestLeaderboardState> {
  final QuizRepository _quizRepository;
  SetContestLeaderboardCubit(this._quizRepository) : super(SetContestLeaderboardInitial());

  void setContestLeaderboard({String? userId, String? contestId, int? questionAttended, int? correctAns, int? score}) async {
    emit(SetContestLeaderboardProgress());
    try {
      await _quizRepository.setContestLeaderboard(userId: userId, contestId: contestId, questionAttended: questionAttended, correctAns: correctAns, score: score);
      emit(SetContestLeaderboardSuccess());
    } catch (e) {
      emit(SetContestLeaderboardFailure(e.toString()));
    }
  }
}
