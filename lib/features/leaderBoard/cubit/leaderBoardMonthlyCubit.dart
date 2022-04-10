import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ayuprep/utils/apiBodyParameterLabels.dart';
import 'package:ayuprep/utils/apiUtils.dart';
import 'package:ayuprep/utils/constants.dart';
import 'package:ayuprep/utils/errorMessageKeys.dart';
import 'package:http/http.dart' as http;

import '../leaderboardException.dart';

@immutable
abstract class LeaderBoardMonthlyState {}

class LeaderBoardMonthlyInitial extends LeaderBoardMonthlyState {}

class LeaderBoardMonthlyProgress extends LeaderBoardMonthlyState {}

class LeaderBoardMonthlySuccess extends LeaderBoardMonthlyState {
  final List leaderBoardDetails;
  final int totalData;
  final bool hasMore;
  LeaderBoardMonthlySuccess(
      this.leaderBoardDetails, this.totalData, this.hasMore);
}

class LeaderBoardMonthlyFailure extends LeaderBoardMonthlyState {
  final String errorMessage;
  LeaderBoardMonthlyFailure(this.errorMessage);
}

/*class MonthlyList extends LeaderBoardMonthlyState {
  final List<LeaderBoardMonthly> monthlyList;
  MonthlyList({required this.monthlyList});
}*/

class LeaderBoardMonthlyCubit extends Cubit<LeaderBoardMonthlyState> {
  static late String profileM, nameM, scoreM, rankM;
  LeaderBoardMonthlyCubit() : super(LeaderBoardMonthlyInitial());

  Future<Map<String, dynamic>> _fetchData({
    required String limit,
    required String userId,
    String? offset,
  }) async {
    try {
      Map<String, String> body = {
        accessValueKey: accessValue,
        limitKey: limit,
        offsetKey: offset ?? "",
        userIdKey: userId,
      };
      if (offset == null) {
        body.remove(offset);
      }
      final response = await http.post(Uri.parse(getMonthlyLeaderboardUrl),
          body: body, headers: await ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);
      nameM = responseJson["data"][0]["my_rank"]["name"].toString();
      rankM = responseJson["data"][0]["my_rank"]["user_rank"].toString();
      profileM = responseJson["data"][0]["my_rank"][profileKey].toString();
      scoreM = responseJson["data"][0]["my_rank"]["score"].toString();
      if (responseJson['error']) {
        throw LeaderBoardException(errorMessageCode: responseJson['message']);
      }
      return Map.from(responseJson);
    } catch (e) {
      throw LeaderBoardException(errorMessageCode: e.toString());
    }
  }

  void fetchLeaderBoard(String limit, String userId) {
    emit(LeaderBoardMonthlyProgress());
    _fetchData(limit: limit, userId: userId).then((value) {
      final usersDetails = value['data'] as List;
      final total = int.parse(value['total'].toString());

      emit(LeaderBoardMonthlySuccess(
        usersDetails,
        total,
        total > usersDetails.length,
      ));
    }).catchError((e) {
      print(e.toString());
      emit(LeaderBoardMonthlyFailure(e.toString()));
    });
  }

  void fetchMoreLeaderBoardData(String limit, String userId) {
    _fetchData(
            limit: limit,
            userId: userId,
            offset: (state as LeaderBoardMonthlySuccess)
                .leaderBoardDetails
                .length
                .toString())
        .then((value) {
      //
      final oldState = (state as LeaderBoardMonthlySuccess);
      final usersDetails = value['data'] as List;
      final updatedUserDetails = List.from(oldState.leaderBoardDetails);
      updatedUserDetails.addAll(usersDetails);
      emit(LeaderBoardMonthlySuccess(updatedUserDetails, oldState.totalData,
          oldState.totalData > updatedUserDetails.length));
    }).catchError((e) {
      emit(LeaderBoardMonthlyFailure(defaultErrorMessageCode));
    });
  }

  bool hasMoreData() {
    if (state is LeaderBoardMonthlySuccess) {
      return (state as LeaderBoardMonthlySuccess).hasMore;
    } else {
      return false;
    }
  }
}
