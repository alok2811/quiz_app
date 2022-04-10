import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ayuprep/features/statistic/statisticRepository.dart';

@immutable
abstract class UpdateStatisticState {}

class UpdateStatisticInitial extends UpdateStatisticState {}

class UpdateStatisticFetchInProgress extends UpdateStatisticState {}

class UpdateStatisticSuccess extends UpdateStatisticState {
  UpdateStatisticSuccess();
}

class UpdateStatisticFailure extends UpdateStatisticState {
  final String errorMessageCode;
  UpdateStatisticFailure(this.errorMessageCode);
}

class UpdateStatisticCubit extends Cubit<UpdateStatisticState> {
  final StatisticRepository _statisticRepository;
  UpdateStatisticCubit(this._statisticRepository)
      : super(UpdateStatisticInitial());

  void updateStatistic(
      {String? userId,
      int? answeredQuestion,
      int? correctAnswers,
      double? winPercentage,
      String? categoryId}) async {
    emit(UpdateStatisticFetchInProgress());
    try {
      await _statisticRepository.updateStatistic(
        answeredQuestion: answeredQuestion,
        categoryId: categoryId,
        correctAnswers: correctAnswers,
        userId: userId,
        winPercentage: winPercentage,
      );
      emit(UpdateStatisticSuccess());
    } catch (e) {
      emit(UpdateStatisticFailure(e.toString()));
    }
  }

  void updateBattleStatistic({
    required String userId1,
    required String userId2,
    required String winnerId,
  }) {
    emit(UpdateStatisticFetchInProgress());
    _statisticRepository
        .updateBattleStatistic(
            userId1: userId1, userId2: userId2, winnerId: winnerId)
        .then((value) {
      emit(UpdateStatisticSuccess());
    }).catchError((e) {
      emit(UpdateStatisticFailure(e.toString()));
    });
  }
}
