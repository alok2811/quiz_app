import 'dart:convert';
import 'dart:io';

import 'package:ayuprep/features/coinHistory/coinHistoryException.dart';
import 'package:ayuprep/utils/apiBodyParameterLabels.dart';
import 'package:ayuprep/utils/apiUtils.dart';
import 'package:ayuprep/utils/constants.dart';
import 'package:ayuprep/utils/errorMessageKeys.dart';
import 'package:http/http.dart' as http;

class CoinHistoryRemoteDataSource {
  Future<dynamic> getCoinHistory(
      {required String userId,
      required String limit,
      required String offset}) async {
    try {
      //body of post request
      final body = {
        accessValueKey: accessValue,
        userIdKey: userId,
        limitKey: limit,
        offsetKey: offset,
      };

      if (limit.isEmpty) {
        body.remove(limitKey);
      }

      if (offset.isEmpty) {
        body.remove(offsetKey);
      }

      final response = await http.post(Uri.parse(getCoinHistoryUrl),
          body: body, headers: await ApiUtils.getHeaders());

      final responseJson = jsonDecode(response.body);

      if (responseJson['error']) {
        throw CoinHistoryException(
          errorMessageCode: responseJson['message'],
        );
      }

      return responseJson;
    } on SocketException catch (_) {
      throw CoinHistoryException(errorMessageCode: noInternetCode);
    } on CoinHistoryException catch (e) {
      throw CoinHistoryException(errorMessageCode: e.toString());
    } catch (e) {
      throw CoinHistoryException(errorMessageCode: defaultErrorMessageCode);
    }
  }
}
