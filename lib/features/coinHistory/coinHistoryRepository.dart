import 'package:ayuprep/features/coinHistory/coinHistoryRemoteDataSource.dart';
import 'package:ayuprep/features/coinHistory/models/coinHistory.dart';

class CoinHistoryRepository {
  static final CoinHistoryRepository _coinHistoryRepository =
      CoinHistoryRepository._internal();

  late CoinHistoryRemoteDataSource _coinHistoryRemoteDataSource;

  factory CoinHistoryRepository() {
    _coinHistoryRepository._coinHistoryRemoteDataSource =
        CoinHistoryRemoteDataSource();
    return _coinHistoryRepository;
  }

  CoinHistoryRepository._internal();

  Future<Map<String, dynamic>> getCoinHistory(
      {required String userId,
      required String offset,
      required String limit}) async {
    final result = await _coinHistoryRemoteDataSource.getCoinHistory(
        userId: userId, limit: limit, offset: offset);

    return {
      "total": result['total'],
      "coinHistory":
          (result['data'] as List).map((e) => CoinHistory.fromJson(e)).toList(),
    };
  }
}
