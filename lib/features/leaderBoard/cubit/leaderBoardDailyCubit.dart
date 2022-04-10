import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ayuprep/utils/apiBodyParameterLabels.dart';
import 'package:ayuprep/utils/apiUtils.dart';
import 'package:ayuprep/utils/constants.dart';
import 'package:http/http.dart' as http;

import '../leaderboardException.dart';

@immutable
abstract class LeaderBoardDailyState {}

class LeaderBoardDailyInitial extends LeaderBoardDailyState {}

class LeaderBoardDailyProgress extends LeaderBoardDailyState {}

class LeaderBoardDailySuccess extends LeaderBoardDailyState {
  final List leaderBoardDetails;
  final int totalData;
  final bool hasMore;
  LeaderBoardDailySuccess(
      this.leaderBoardDetails, this.totalData, this.hasMore);
}

class LeaderBoardDailyFailure extends LeaderBoardDailyState {
  final String errorMessage;
  LeaderBoardDailyFailure(this.errorMessage);
}

class LeaderBoardDailyCubit extends Cubit<LeaderBoardDailyState> {
  static late String profileD, nameD, scoreD, rankD;
  LeaderBoardDailyCubit() : super(LeaderBoardDailyInitial());

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
      final response = await http.post(Uri.parse(getDailyLeaderboardUrl),
          body: body, headers: await ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);

      if (responseJson['error']) {
        throw LeaderBoardException(errorMessageCode: responseJson['message']);
      }
      nameD = responseJson["data"][0]["my_rank"]["name"].toString();
      rankD = responseJson["data"][0]["my_rank"]["user_rank"].toString();
      profileD = responseJson["data"][0]["my_rank"][profileKey].toString();
      scoreD = responseJson["data"][0]["my_rank"]["score"].toString();

      return Map.from(responseJson);
    } catch (e) {
      print(e.toString());
      throw LeaderBoardException(errorMessageCode: e.toString());
    }
  }

  void fetchLeaderBoard(String limit, String userId) {
    emit(LeaderBoardDailyProgress());
    _fetchData(limit: limit, userId: userId).then((value) {
      final usersDetails = value['data'] as List;
      final total = int.parse(value['total'].toString());

      emit(LeaderBoardDailySuccess(
        usersDetails,
        total,
        total > usersDetails.length,
      ));
    }).catchError((e) {
      print(e.toString());
      emit(LeaderBoardDailyFailure(e.toString()));
    });
  }

  void fetchMoreLeaderBoardData(String limit, String userId) {
    _fetchData(
            limit: limit,
            userId: userId,
            offset: (state as LeaderBoardDailySuccess)
                .leaderBoardDetails
                .length
                .toString())
        .then((value) {
      //
      final oldState = (state as LeaderBoardDailySuccess);
      final usersDetails = value['data'] as List;
      final updatedUserDetails = List.from(oldState.leaderBoardDetails);
      updatedUserDetails.addAll(usersDetails);
      emit(LeaderBoardDailySuccess(updatedUserDetails, oldState.totalData,
          oldState.totalData > updatedUserDetails.length));
    }).catchError((e) {
      emit(LeaderBoardDailyFailure(e.toString()));
    });
  }

  bool hasMoreData() {
    if (state is LeaderBoardDailySuccess) {
      return (state as LeaderBoardDailySuccess).hasMore;
    } else {
      return false;
    }
  }
}
