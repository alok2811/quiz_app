import 'package:ayuprep/features/statistic/statisticException.dart';
import 'package:ayuprep/features/statistic/models/statisticModel.dart';
import 'package:ayuprep/features/statistic/statisticRemoteDataSource.dart';

class StatisticRepository {
  static final StatisticRepository _statisticRepository = StatisticRepository._internal();
  late StatisticRemoteDataSource _statisticRemoteDataSource;

  factory StatisticRepository() {
    _statisticRepository._statisticRemoteDataSource = StatisticRemoteDataSource();

    return _statisticRepository;
  }

  StatisticRepository._internal();

  Future<StatisticModel> getStatistic({required String userId, required bool getBattleStatistics}) async {
    try {
      final result = await _statisticRemoteDataSource.getStatistic(userId);
      if (getBattleStatistics) {
        final battleResult = await _statisticRemoteDataSource.getBattleStatistic(userId: userId);
        Map<String, dynamic> battleStatistics = {};
        Map<String, dynamic> myReports = Map.from((battleResult['myreport'] as List).first);
        myReports.keys.forEach((element) {
          battleStatistics.addAll({
            element: myReports[element],
          });
        });
        battleStatistics['playedBattles'] = battleResult['data'] == null ? [] : (battleResult['data'] as List);
        return StatisticModel.fromJson(Map.from(result), battleStatistics);
      }
      return StatisticModel.fromJson(Map.from(result), {});
    } catch (e) {
      throw StatisticException(errorMessageCode: e.toString());
    }
  }

  Future<void> updateStatistic({String? userId, int? answeredQuestion, int? correctAnswers, double? winPercentage, String? categoryId}) async {
    try {
      await _statisticRemoteDataSource.updateStatistic(
        answeredQuestion: answeredQuestion.toString(),
        categoryId: categoryId,
        correctAnswers: correctAnswers.toString(),
        userId: userId,
        winPercentage: winPercentage!.toInt().toString(),
      );
    } catch (e) {
      throw StatisticException(errorMessageCode: e.toString());
    }
  }

  Future<void> updateBattleStatistic({
    required String userId1,
    required String userId2,
    required String winnerId,
  }) async {
    try {
      await _statisticRemoteDataSource.updateBattleStatistic(
        userId1: userId1,
        userId2: userId2,
        isDrawn: winnerId.isEmpty ? "1" : "0",
        winnerId: winnerId.isEmpty ? userId1 : winnerId,
      );
    } catch (e) {
      throw StatisticException(errorMessageCode: e.toString());
    }
  }
}
