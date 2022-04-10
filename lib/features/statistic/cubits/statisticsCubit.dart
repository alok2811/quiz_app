import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ayuprep/features/statistic/models/statisticModel.dart';
import 'package:ayuprep/features/statistic/statisticRepository.dart';

@immutable
abstract class StatisticState {}

class StatisticInitial extends StatisticState {}

class StatisticFetchInProgress extends StatisticState {}

class StatisticFetchSuccess extends StatisticState {
  final StatisticModel statisticModel;

  StatisticFetchSuccess(this.statisticModel);
}

class StatisticFetchFailure extends StatisticState {
  final String errorMessageCode;
  StatisticFetchFailure(this.errorMessageCode);
}

class StatisticCubit extends Cubit<StatisticState> {
  final StatisticRepository _statisticRepository;
  StatisticCubit(this._statisticRepository) : super(StatisticInitial());

  void getStatistic(String userId) async {
    emit(StatisticFetchInProgress());
    try {
      final result = await _statisticRepository.getStatistic(userId: userId, getBattleStatistics: false);

      emit(StatisticFetchSuccess(result));
    } catch (e) {
      emit(StatisticFetchFailure(e.toString()));
    }
  }

  void getStatisticWithBattle(String userId) async {
    emit(StatisticFetchInProgress());
    try {
      final result = await _statisticRepository.getStatistic(userId: userId, getBattleStatistics: true);

      emit(StatisticFetchSuccess(result));
    } catch (e) {
      emit(StatisticFetchFailure(e.toString()));
    }
  }

  StatisticModel getStatisticsDetails() {
    if (state is StatisticFetchSuccess) {
      return (state as StatisticFetchSuccess).statisticModel;
    }
    return StatisticModel.fromJson({}, {});
  }
}
