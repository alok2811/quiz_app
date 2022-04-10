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
abstract class LeaderBoardAllTimeState {}

class LeaderBoardAllTimeInitial extends LeaderBoardAllTimeState {}

class LeaderBoardAllTimeProgress extends LeaderBoardAllTimeState {}

class LeaderBoardAllTimeSuccess extends LeaderBoardAllTimeState {
  final List leaderBoardDetails;
  final int totalData;
  final bool hasMore;
  LeaderBoardAllTimeSuccess(
    this.leaderBoardDetails,
    this.totalData,
    this.hasMore,
  );
}

class LeaderBoardAllTimeFailure extends LeaderBoardAllTimeState {
  final String errorMessage;
  LeaderBoardAllTimeFailure(this.errorMessage);
}

class LeaderBoardAllTimeCubit extends Cubit<LeaderBoardAllTimeState> {
  static late String profileA, nameA, scoreA, rankA;
  LeaderBoardAllTimeCubit() : super(LeaderBoardAllTimeInitial());

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
      final response = await http.post(Uri.parse(getAllTimeLeaderboardUrl),
          body: body, headers: await ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);
      nameA = responseJson["data"][0]["my_rank"]["name"].toString();
      rankA = responseJson["data"][0]["my_rank"]["user_rank"].toString();
      profileA = responseJson["data"][0]["my_rank"][profileKey].toString();
      scoreA = responseJson["data"][0]["my_rank"]["score"].toString();
      if (responseJson['error']) {
        throw LeaderBoardException(errorMessageCode: responseJson['message']);
      }
      return Map.from(responseJson);
    } catch (e) {
      throw LeaderBoardException(errorMessageCode: e.toString());
    }
  }

  void fetchLeaderBoard(String limit, String userId) {
    emit(LeaderBoardAllTimeProgress());
    _fetchData(limit: limit, userId: userId).then((value) {
      final usersDetails = value['data'] as List;
      final total = int.parse(value['total'].toString());
      emit(LeaderBoardAllTimeSuccess(
        usersDetails,
        total,
        total > usersDetails.length,
      ));
    }).catchError((e) {
      print(e.toString());
      emit(LeaderBoardAllTimeFailure(e.toString()));
    });
  }

  void fetchMoreLeaderBoardData(String limit, String userId) {
    _fetchData(
            limit: limit,
            userId: userId,
            offset: (state as LeaderBoardAllTimeSuccess)
                .leaderBoardDetails
                .length
                .toString())
        .then((value) {
      //
      final oldState = (state as LeaderBoardAllTimeSuccess);
      final usersDetails = value['data'] as List;
      final updatedUserDetails = List.from(oldState.leaderBoardDetails);
      updatedUserDetails.addAll(usersDetails);
      emit(LeaderBoardAllTimeSuccess(updatedUserDetails, oldState.totalData,
          oldState.totalData > updatedUserDetails.length));
    }).catchError((e) {
      emit(LeaderBoardAllTimeFailure(defaultErrorMessageCode));
    });
  }

  bool hasMoreData() {
    if (state is LeaderBoardAllTimeSuccess) {
      return (state as LeaderBoardAllTimeSuccess).hasMore;
    } else {
      return false;
    }
  }
}
