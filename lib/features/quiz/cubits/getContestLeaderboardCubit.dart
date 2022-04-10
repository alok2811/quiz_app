import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ayuprep/features/quiz/models/contestLeaderboard.dart';
import '../quizRepository.dart';

@immutable
abstract class GetContestLeaderboardState {}

class GetContestLeaderboardInitial extends GetContestLeaderboardState {}

class GetContestLeaderboardProgress extends GetContestLeaderboardState {}

class GetContestLeaderboardSuccess extends GetContestLeaderboardState {
  final List<ContestLeaderboard> getContestLeaderboardList;
  GetContestLeaderboardSuccess(this.getContestLeaderboardList);
}

class GetContestLeaderboardFailure extends GetContestLeaderboardState {
  final String errorMessage;
  GetContestLeaderboardFailure(this.errorMessage);
}

class GetContestLeaderboardCubit extends Cubit<GetContestLeaderboardState> {
  final QuizRepository _quizRepository;
  GetContestLeaderboardCubit(this._quizRepository) : super(GetContestLeaderboardInitial());

   getContestLeaderboard({String? userId, String? contestId}) async {
    emit(GetContestLeaderboardProgress());
    _quizRepository.getContestLeaderboard(userId: userId,contestId: contestId).then((val) => emit(GetContestLeaderboardSuccess(val)),)
        .catchError((e) {
      print(e.toString());
      emit(GetContestLeaderboardFailure(e.toString()));
    });
  }
}
