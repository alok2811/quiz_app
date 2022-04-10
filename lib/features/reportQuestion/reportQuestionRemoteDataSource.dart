import 'dart:convert';
import 'dart:io';

import 'package:ayuprep/features/reportQuestion/reportQuestionException.dart';
import 'package:ayuprep/utils/apiBodyParameterLabels.dart';
import 'package:ayuprep/utils/apiUtils.dart';
import 'package:ayuprep/utils/constants.dart';
import 'package:ayuprep/utils/errorMessageKeys.dart';
import 'package:http/http.dart' as http;

class ReportQuestionRemoteDataSource {
  /*
   access_key:8525
        question_id:115
        user_id:1
        message: Any reporting message
  
  
   */
  Future<dynamic> reportQuestion(
      {required String questionId,
      required String message,
      required String userId}) async {
    try {
      Map<String, String> body = {
        accessValueKey: accessValue,
        questionIdKey: questionId,
        messageKey: message,
        userIdKey: userId
      };

      final response = await http.post(Uri.parse(reportQuestionUrl),
          body: body, headers: await ApiUtils.getHeaders());

      final responseJson = jsonDecode(response.body);

      if (responseJson['error']) {
        throw ReportQuestionException(
            errorMessageCode: responseJson['message']); //error
      }
      return responseJson['data'];
    } on SocketException catch (_) {
      throw ReportQuestionException(errorMessageCode: noInternetCode);
    } on ReportQuestionException catch (e) {
      throw ReportQuestionException(errorMessageCode: e.toString());
    } catch (e) {
      throw ReportQuestionException(errorMessageCode: defaultErrorMessageCode);
    }
  }
}
