import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ayuprep/features/profileManagement/profileManagementException.dart';
import 'package:ayuprep/utils/apiBodyParameterLabels.dart';
import 'package:ayuprep/utils/apiUtils.dart';
import 'package:ayuprep/utils/constants.dart';
import 'package:ayuprep/utils/errorMessageKeys.dart';
import 'package:http/http.dart' as http;

class ProfileManagementRemoteDataSource {
  /*
  {id: 11, firebase_id: G1thaSiA43WYx29dOXmUd6jqUWS2,
  name: RAHUL HIRANI, email: rahulhiraniphotoshop@gmail.com, mobile: ,
  type: gmail, profile: https://lh3.googleusercontent.com/a/AATXAJyzUAfJwUFTV3yE6tM9KdevDnX2rcM8vm3GKHFz=s96-c, fcm_id: dwMNB7WrRbGJ_alB_moZbs:APA91bFuKIMzXGelNem5CqqWPyj2TQaFEB54glL_i-jSgmwERya9be4fZKyLrRwdt28vZWkIYKxXTl8pkWJAcqxWQG_yOvTwVpqB50-owcD9MBxRxzD5tPviMCl0AUJoq5ur1ZsDpnpY,
  coins: 0, refer_code: , friends_code: , ip_address: , status: 1,
  date_registered: 2021-06-07 15:27:59, all_time_score: 0, all_time_rank: 0}
  */

  Future<dynamic> getUserDetailsById(String firebaseId) async {
    try {
      //body of post request
      final body = {
        accessValueKey: accessValue,
        firebaseIdKey: firebaseId,
      };
      print(await ApiUtils.getHeaders());
      final response = await http.post(Uri.parse(getUserDetailsByIdUrl),
          body: body, headers: await ApiUtils.getHeaders());

      final responseJson = jsonDecode(response.body);

      if (responseJson['error']) {
        throw ProfileManagementException(
            errorMessageCode: responseJson['message']);
      }
      return responseJson['data'];
    } on SocketException catch (_) {
      throw ProfileManagementException(errorMessageCode: noInternetCode);
    } on ProfileManagementException catch (e) {
      throw ProfileManagementException(errorMessageCode: e.toString());
    } catch (e) {
      throw ProfileManagementException(
          errorMessageCode: defaultErrorMessageCode);
    }
  }

  /*response ********{"error":false,"message":"Profile uploaded successfully!","data":{profileKey:"http:\/\/ayuprep.thewrteam.in\/images\/profile\/1623326274.jpg"}}*/
  Future addProfileImage(File? images, String? userId) async {
    try {
      Map<String, String?> body = {
        userIdKey: userId,
        accessValueKey: accessValue
      };
      Map<String, File?> fileList = {
        imageKey: images,
      };
      var response = await postApiFile(
          Uri.parse(uploadProfileUrl), fileList, body, userId);
      final res = json.decode(response);
      if (res['error']) {
        throw ProfileManagementException(errorMessageCode: res['message']);
      }
      return res['data'];
    } on SocketException catch (_) {
      throw ProfileManagementException(errorMessageCode: noInternetCode);
    } on ProfileManagementException catch (e) {
      throw ProfileManagementException(errorMessageCode: e.toString());
    } catch (e) {
      throw ProfileManagementException(
          errorMessageCode: defaultErrorMessageCode);
    }
  }

  Future postApiFile(Uri url, Map<String, File?> fileList,
      Map<String, String?> body, String? userId) async {
    try {
      var request = http.MultipartRequest('POST', url);
      request.headers.addAll(await ApiUtils.getHeaders());

      body.forEach((key, value) {
        request.fields[key] = value!;
      });

      for (var key in fileList.keys.toList()) {
        var pic = await http.MultipartFile.fromPath(key, fileList[key]!.path);
        request.files.add(pic);
      }
      var res = await request.send();
      var responseData = await res.stream.toBytes();
      var response = String.fromCharCodes(responseData);
      if (res.statusCode == 200) {
        return response;
      } else {
        throw ProfileManagementException(
            errorMessageCode: defaultErrorMessageCode);
      }
    } on SocketException catch (_) {
      throw ProfileManagementException(errorMessageCode: noInternetCode);
    } on ProfileManagementException catch (e) {
      throw ProfileManagementException(errorMessageCode: e.toString());
    } catch (e) {
      throw ProfileManagementException(
          errorMessageCode: defaultErrorMessageCode);
    }
  }

  /*
    body of this post request
    access_key:8525
    user_id:1
    coins:10      //if deduct coin than set with minus sign -2
    score:2
   */
  Future<dynamic> updateCoinsAndScore({
    required String userId,
    required String score,
    required String coins,
    required String title,
    String? type,
  }) async {
    try {
      //body of post request
      Map<String, String> body = {
        accessValueKey: accessValue,
        userIdKey: userId,
        coinsKey: coins,
        scoreKey: score,
        typeKey: type ?? "",
        titleKey: title,
        statusKey: (int.parse(coins) < 0) ? "1" : "0",
      };

      if (body[typeKey]!.isEmpty) {
        body.remove(typeKey);
      }
      final response = await http.post(Uri.parse(updateUserCoinsAndScoreUrl),
          body: body, headers: await ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);

      if (responseJson['error']) {
        throw ProfileManagementException(
            errorMessageCode: responseJson['message']);
      }
      return responseJson['data'];
    } on SocketException catch (_) {
      throw ProfileManagementException(errorMessageCode: noInternetCode);
    } on ProfileManagementException catch (e) {
      throw ProfileManagementException(errorMessageCode: e.toString());
    } catch (e) {
      throw ProfileManagementException(
          errorMessageCode: defaultErrorMessageCode);
    }
  }

  /*
    body of this post request
    access_key:8525
    user_id:1
    coins:10      //if deduct coin than set with minus sign -2
    score:2
   */
  Future<dynamic> updateCoins({
    required String userId,
    required String coins,
    required String title,
    String? type, //dashing_debut, clash_winner
  }) async {
    try {
      Map<String, String> body = {
        accessValueKey: accessValue,
        userIdKey: userId,
        coinsKey: coins,
        titleKey: title,
        statusKey: (int.parse(coins) < 0) ? "1" : "0",
        typeKey: type ?? "",
      };
      if (body[typeKey]!.isEmpty) {
        body.remove(typeKey);
      }

      final response = await http.post(Uri.parse(updateUserCoinsAndScoreUrl),
          body: body, headers: await ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);

      if (responseJson['error']) {
        throw ProfileManagementException(
            errorMessageCode: responseJson['message']);
      }
      return responseJson['data'];
    } on SocketException catch (_) {
      throw ProfileManagementException(errorMessageCode: noInternetCode);
    } on ProfileManagementException catch (e) {
      throw ProfileManagementException(errorMessageCode: e.toString());
    } catch (e) {
      throw ProfileManagementException(
          errorMessageCode: defaultErrorMessageCode);
    }
  }

  /*
    body of this post request
    access_key:8525
    user_id:1
    coins:10      //if deduct coin than set with minus sign -2
    score:2
   */
  Future<dynamic> updateScore({
    required String userId,
    required String score,
    String? type,
  }) async {
    try {
      Map<String, String> body = {
        accessValueKey: accessValue,
        userIdKey: userId,
        scoreKey: score,
        typeKey: type ?? ""
      };
      if (body[typeKey]!.isEmpty) {
        body.remove(typeKey);
      }
      final response = await http.post(Uri.parse(updateUserCoinsAndScoreUrl),
          body: body, headers: await ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);

      if (responseJson['error']) {
        throw ProfileManagementException(
            errorMessageCode: responseJson['message']);
      }
      return responseJson['data'];
    } on SocketException catch (_) {
      throw ProfileManagementException(errorMessageCode: noInternetCode);
    } on ProfileManagementException catch (e) {
      throw ProfileManagementException(errorMessageCode: e.toString());
    } catch (e) {
      throw ProfileManagementException(
          errorMessageCode: defaultErrorMessageCode);
    }
  }

  Future<void> updateProfile(
      {required String userId,
      required String email,
      required String name,
      required String mobile}) async {
    try {
      //body of post request
      Map<String, String> body = {
        accessValueKey: accessValue,
        userIdKey: userId,
        emailKey: email,
        nameKey: name,
        mobileKey: mobile
      };

      final response = await http.post(Uri.parse(updateProfileUrl),
          body: body, headers: await ApiUtils.getHeaders());

      final responseJson = jsonDecode(response.body);
      if (responseJson['error']) {
        throw ProfileManagementException(
            errorMessageCode: responseJson['message']);
      }
    } on SocketException catch (_) {
      throw ProfileManagementException(errorMessageCode: noInternetCode);
    } on ProfileManagementException catch (e) {
      throw ProfileManagementException(errorMessageCode: e.toString());
    } catch (e) {
      throw ProfileManagementException(
          errorMessageCode: defaultErrorMessageCode);
    }
  }

  Future<void> deleteAccount({required String userId}) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      await currentUser?.delete();

      Map<String, String> body = {
        accessValueKey: accessValue,
        userIdKey: userId
      };

      await http.post(Uri.parse(deleteUserAccountUrl),
          body: body, headers: await ApiUtils.getHeaders());
    } on SocketException catch (_) {
      throw ProfileManagementException(errorMessageCode: noInternetCode);
    } on FirebaseAuthException catch (e) {
      throw ProfileManagementException(
          errorMessageCode: firebaseErrorCodeToNumber(e.code));
    } catch (e) {
      throw ProfileManagementException(
          errorMessageCode: defaultErrorMessageCode);
    }
  }
}
