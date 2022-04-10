import 'dart:convert';
import 'dart:io';
import 'package:ayuprep/features/systemConfig/systemCongifException.dart';
import 'package:ayuprep/utils/apiBodyParameterLabels.dart';
import 'package:ayuprep/utils/apiUtils.dart';
import 'package:ayuprep/utils/constants.dart';
import 'package:ayuprep/utils/errorMessageKeys.dart';
import 'package:http/http.dart' as http;

class SystemConfigRemoteDataSource {
  Future<dynamic> getSystemConfing() async {
    try {
      final body = {accessValueKey: accessValue};
      final response =
          await http.post(Uri.parse(getSystemConfigUrl), body: body);
      final responseJson = jsonDecode(response.body);

      if (responseJson['error']) {
        print("Error message $responseJson");
        throw SystemConfigException(errorMessageCode: responseJson['message']);
      }
      return responseJson['data'];
    } on SocketException catch (_) {
      throw SystemConfigException(errorMessageCode: noInternetCode);
    } on SystemConfigException catch (e) {
      throw SystemConfigException(errorMessageCode: e.toString());
    } catch (e) {
      throw SystemConfigException(errorMessageCode: defaultErrorMessageCode);
    }
  }

  Future<List> getSupportedQuestionLanguages() async {
    try {
      final body = {accessValueKey: accessValue};

      final response = await http
          .post(Uri.parse(getSupportedQuestionLanguageUrl), body: body);
      final responseJson = jsonDecode(response.body);

      if (responseJson['error']) {
        throw SystemConfigException(errorMessageCode: responseJson['message']);
      }
      return responseJson['data'];
    } on SocketException catch (_) {
      throw SystemConfigException(errorMessageCode: noInternetCode);
    } on SystemConfigException catch (e) {
      throw SystemConfigException(errorMessageCode: e.toString());
    } catch (e) {
      throw SystemConfigException(errorMessageCode: defaultErrorMessageCode);
    }
  }

  Future<String> getAppSettings(String type) async {
    try {
      final body = {accessValueKey: accessValue, typeKey: type};
      final response = await http.post(Uri.parse(getAppSettingsUrl),
          body: body, headers: await ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);
      if (responseJson['error']) {
        throw SystemConfigException(errorMessageCode: responseJson['message']);
      }
      return responseJson['data'];
    } on SocketException catch (_) {
      throw SystemConfigException(errorMessageCode: noInternetCode);
    } on SystemConfigException catch (e) {
      throw SystemConfigException(errorMessageCode: e.toString());
    } catch (e) {
      throw SystemConfigException(errorMessageCode: defaultErrorMessageCode);
    }
  }
}
