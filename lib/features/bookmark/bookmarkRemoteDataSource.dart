import 'dart:convert';
import 'dart:io';

import 'package:ayuprep/features/bookmark/bookmarkException.dart';
import 'package:ayuprep/utils/apiBodyParameterLabels.dart';
import 'package:ayuprep/utils/apiUtils.dart';
import 'package:ayuprep/utils/constants.dart';
import 'package:ayuprep/utils/errorMessageKeys.dart';

import 'package:http/http.dart' as http;

class BookmarkRemoteDataSource {
  Future<List<dynamic>> getBookmark(String userId, String type) async {
    try {
      //type is 1 - Quiz zone 3- Guess the word 4 - Audio question
      //body of post request
      final body = {
        accessValueKey: accessValue,
        userIdKey: userId,
        typeKey: type
      };

      final response = await http.post(Uri.parse(getBookmarkUrl),
          body: body, headers: await ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);
      print("Response of bookmark : $responseJson");
      if (responseJson['error']) {
        throw BookmarkException(errorMessageCode: responseJson['message']);
      }
      return responseJson['data'];
    } on SocketException catch (_) {
      throw BookmarkException(errorMessageCode: noInternetCode);
    } on BookmarkException catch (e) {
      throw BookmarkException(errorMessageCode: e.toString());
    } catch (e) {
      throw BookmarkException(errorMessageCode: defaultErrorMessageCode);
    }
  }

  Future<dynamic> updateBookmark(
      String userId, String questionId, String status, String type) async {
    try {
      //body of post request
      final body = {
        accessValueKey: accessValue,
        userIdKey: userId,
        statusKey: status,
        questionIdKey: questionId,
        typeKey: type, //1 - Quiz zone 3 - Guess the word 4 - Audio quesitons
      };
      final response = await http.post(Uri.parse(updateBookmarkUrl),
          body: body, headers: await ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);

      if (responseJson['error']) {
        throw BookmarkException(errorMessageCode: responseJson['message']);
      }
      print(responseJson);
      return responseJson['data'];
    } on SocketException catch (_) {
      throw BookmarkException(errorMessageCode: noInternetCode);
    } on BookmarkException catch (e) {
      throw BookmarkException(errorMessageCode: e.toString());
    } catch (e) {
      throw BookmarkException(errorMessageCode: defaultErrorMessageCode);
    }
  }
}
