import 'dart:convert';
import 'dart:io';

import 'package:ayuprep/features/exam/examException.dart';
import 'package:ayuprep/utils/apiBodyParameterLabels.dart';
import 'package:ayuprep/utils/apiUtils.dart';
import 'package:ayuprep/utils/constants.dart';
import 'package:ayuprep/utils/errorMessageKeys.dart';

import 'package:http/http.dart' as http;

class ExamRemoteDataSource {
  Future<dynamic> getExams(
      {required String userId,
      required String languageId,
      required String type,
      required String limit,
      required String offset}) async {
    try {
      //body of post request
      final body = {
        accessValueKey: accessValue,
        userIdKey: userId,
        languageIdKey: languageId,
        typeKey: type, // 1 for today , 2 for completed
        limitKey: limit,
        offsetKey: offset,
      };

      if (languageId.isEmpty) {
        body.remove(languageIdKey);
      }
      if (limit.isEmpty) {
        body.remove(limitKey);
      }

      if (offset.isEmpty) {
        body.remove(offsetKey);
      }

      final response = await http.post(Uri.parse(getExamModuleUrl),
          body: body, headers: await ApiUtils.getHeaders());

      final responseJson = jsonDecode(response.body);

      if (responseJson['error']) {
        throw ExamException(
          errorMessageCode: responseJson['message'].toString() == "102"
              ? type == "1"
                  ? noExamForTodayCode
                  : haveNotCompletedExamCode
              : responseJson['message'],
        );
      }

      return responseJson;
    } on SocketException catch (_) {
      throw ExamException(errorMessageCode: noInternetCode);
    } on ExamException catch (e) {
      throw ExamException(errorMessageCode: e.toString());
    } catch (e) {
      throw ExamException(errorMessageCode: defaultErrorMessageCode);
    }
  }

  Future<List<dynamic>> getQuestionForExam(
      {required String examModuleId}) async {
    try {
      //body of post request
      final body = {
        accessValueKey: accessValue,
        examModuleIdKey: examModuleId,
      };

      final response = await http.post(Uri.parse(getExamModuleQuestionsUrl),
          body: body, headers: await ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);

      if (responseJson['error']) {
        throw ExamException(errorMessageCode: responseJson['message']);
      }
      return responseJson['data'];
    } on SocketException catch (_) {
      throw ExamException(errorMessageCode: noInternetCode);
    } on ExamException catch (e) {
      throw ExamException(errorMessageCode: e.toString());
    } catch (e) {
      throw ExamException(errorMessageCode: defaultErrorMessageCode);
    }
  }

  Future<dynamic> updateExamStatusToInExam({
    required String examModuleId,
    required String userId,
  }) async {
    try {
      //body of post request
      final body = {
        accessValueKey: accessValue,
        examModuleIdKey: examModuleId,
        userIdKey: userId,
      };

      final response = await http.post(Uri.parse(setExamModuleResultUrl),
          body: body, headers: await ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);

      if (responseJson['error']) {
        print(responseJson);
        throw ExamException(
            errorMessageCode: responseJson['message'].toString() == "103"
                ? alreadyInExamCode
                : responseJson['message']);
      }
      return responseJson['data'];
    } on SocketException catch (_) {
      throw ExamException(errorMessageCode: noInternetCode);
    } on ExamException catch (e) {
      throw ExamException(errorMessageCode: e.toString());
    } catch (e) {
      throw ExamException(errorMessageCode: defaultErrorMessageCode);
    }
  }

  Future<dynamic> submitExamResult({
    required String examModuleId,
    required String userId,
    required String totalDuration,
    required List<Map<String, dynamic>> statistics,
    required String obtainedMarks,
    required bool rulesViolated,
    required List<String> capturedQuestionIds,
  }) async {
    try {
      //body of post request
      final body = {
        accessValueKey: accessValue,
        examModuleIdKey: examModuleId,
        userIdKey: userId,
        statisticsKey: json.encode(statistics),
        totalDurationKey: totalDuration,
        obtainedMarksKey: obtainedMarks,
        rulesViolatedKey: rulesViolated ? "1" : "0",
        capturedQuestionIdsKey: json.encode(capturedQuestionIds),
      };

      print(body);

      final response = await http.post(Uri.parse(setExamModuleResultUrl),
          body: body, headers: await ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);

      if (responseJson['error']) {
        throw ExamException(errorMessageCode: responseJson['message']);
      }
      return responseJson['message'];
    } on SocketException catch (_) {
      throw ExamException(errorMessageCode: noInternetCode);
    } on ExamException catch (e) {
      throw ExamException(errorMessageCode: e.toString());
    } catch (e) {
      print(e.toString());
      throw ExamException(errorMessageCode: defaultErrorMessageCode);
    }
  }
}
