import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ayuprep/features/coinHistory/coinHistoryRepository.dart';
import 'package:ayuprep/features/coinHistory/models/coinHistory.dart';

abstract class CoinHistoryState {}

class CoinHistoryInitial extends CoinHistoryState {}

class CoinHistoryFetchInProgress extends CoinHistoryState {}

class CoinHistoryFetchSuccess extends CoinHistoryState {
  final List<CoinHistory> coinHistory;
  final int totalCoinHistoryCount;
  final bool hasMoreFetchError;
  final bool hasMore;

  CoinHistoryFetchSuccess({
    required this.coinHistory,
    required this.totalCoinHistoryCount,
    required this.hasMoreFetchError,
    required this.hasMore,
  });
}

class CoinHistoryFetchFailure extends CoinHistoryState {
  final String errorMessage;

  CoinHistoryFetchFailure(this.errorMessage);
}

class CoinHistoryCubit extends Cubit<CoinHistoryState> {
  final CoinHistoryRepository _coinHistoryRepository;

  CoinHistoryCubit(this._coinHistoryRepository) : super(CoinHistoryInitial());

  final int limit = 15;

  void getCoinHistory({required String userId}) async {
    try {
      //
      final result = await _coinHistoryRepository.getCoinHistory(
          userId: userId, limit: limit.toString(), offset: "0");
      emit(CoinHistoryFetchSuccess(
        coinHistory: result['coinHistory'],
        totalCoinHistoryCount: int.parse(result['total']),
        hasMoreFetchError: false,
        hasMore: (result['coinHistory'] as List<CoinHistory>).length <
            int.parse(result['total']),
      ));
    } catch (e) {
      emit(CoinHistoryFetchFailure(e.toString()));
    }
  }

  bool hasMoreCoinHistory() {
    if (state is CoinHistoryFetchSuccess) {
      return (state as CoinHistoryFetchSuccess).hasMore;
    }
    return false;
  }

  void getMoreCoinHistory({required String userId}) async {
    if (state is CoinHistoryFetchSuccess) {
      try {
        //
        final result = await _coinHistoryRepository.getCoinHistory(
            userId: userId,
            limit: limit.toString(),
            offset: (state as CoinHistoryFetchSuccess)
                .coinHistory
                .length
                .toString());
        List<CoinHistory> updatedResults =
            (state as CoinHistoryFetchSuccess).coinHistory;
        updatedResults.addAll(result['coinHistory'] as List<CoinHistory>);
        emit(CoinHistoryFetchSuccess(
          coinHistory: updatedResults,
          totalCoinHistoryCount: int.parse(result['total']),
          hasMoreFetchError: false,
          hasMore: updatedResults.length < int.parse(result['total']),
        ));
        //
      } catch (e) {
        //in case of any error
        emit(CoinHistoryFetchSuccess(
          coinHistory: (state as CoinHistoryFetchSuccess).coinHistory,
          hasMoreFetchError: true,
          totalCoinHistoryCount:
              (state as CoinHistoryFetchSuccess).totalCoinHistoryCount,
          hasMore: (state as CoinHistoryFetchSuccess).hasMore,
        ));
      }
    }
  }
}
