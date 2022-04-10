import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ayuprep/utils/apiBodyParameterLabels.dart';
import 'package:ayuprep/utils/apiUtils.dart';
import 'package:ayuprep/utils/constants.dart';
import 'package:ayuprep/utils/errorMessageKeys.dart';
import 'package:http/http.dart' as http;
import '../notificationException.dart';

@immutable
abstract class NotificationState {}

class NotificationInitial extends NotificationState {}

class NotificationProgress extends NotificationState {}

class NotificationSuccess extends NotificationState {
  final List notificationList;
  final int totalData;
  final bool hasMore;
  NotificationSuccess(this.notificationList, this.totalData, this.hasMore);
}

class NotificationFailure extends NotificationState {
  final String errorMessageCode;
  NotificationFailure(this.errorMessageCode);
}

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit() : super(NotificationInitial());
  Future<Map<String, dynamic>> _fetchData({
    required String limit,
    String? offset,
  }) async {
    try {
      //
      //body of post request
      final body = {
        accessValueKey: accessValue,
        limitKey: limit,
        offsetKey: offset ?? "",
      };
      if (offset == null) {
        body.remove(offset);
      }
      final response = await http.post(Uri.parse(getNotificationUrl),
          body: body, headers: await ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);
      print(responseJson);

      if (responseJson['error']) {
        throw NotificationException(errorMessageCode: responseJson['message']);
      }
      return Map.from(responseJson);
    } on SocketException catch (_) {
      throw NotificationException(errorMessageCode: noInternetCode);
    } on NotificationException catch (e) {
      throw NotificationException(errorMessageCode: e.toString());
    } catch (e) {
      throw NotificationException(
          errorMessageKey: e.toString(), errorMessageCode: '');
    }
  }

/*  getNotification(String limit) async {
    emit(NotificationProgress());
    _notificationCubit.getNotification(limit).then((val) => emit(NotificationSuccess(val,)),).catchError((e) {
      emit(NotificationFailure(e.toString()));
    });
  }*/
  void fetchNotification(String limit) {
    emit(NotificationProgress());
    _fetchData(limit: limit).then((value) {
      final usersDetails = value['data'] as List;
      final total = int.parse(value['total'].toString());
      print(total);
      emit(NotificationSuccess(
        usersDetails,
        total,
        total > usersDetails.length,
      ));
    }).catchError((e) {
      print(e.toString());
      emit(NotificationFailure(defaultErrorMessageCode));
    });
  }

  void fetchMoreNotificationData(String limit) {
    _fetchData(
            limit: limit,
            offset: (state as NotificationSuccess)
                .notificationList
                .length
                .toString())
        .then((value) {
      //
      final oldState = (state as NotificationSuccess);
      final usersDetails = value['data'] as List;
      final updatedUserDetails = List.from(oldState.notificationList);
      updatedUserDetails.addAll(usersDetails);
      emit(NotificationSuccess(updatedUserDetails, oldState.totalData,
          oldState.totalData > updatedUserDetails.length));
    }).catchError((e) {
      emit(NotificationFailure(defaultErrorMessageCode));
    });
  }

  bool hasMoreData() {
    if (state is NotificationSuccess) {
      return (state as NotificationSuccess).hasMore;
    } else {
      return false;
    }
  }

  notificationList() {
    if (state is NotificationSuccess) {
      return (state as NotificationSuccess).notificationList;
    }
    return [];
  }
}
