import 'dart:convert';

import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart' as fcm;
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:ayuprep/features/auth/auhtException.dart';
import 'package:ayuprep/features/auth/cubits/authCubit.dart';
import 'package:ayuprep/utils/apiBodyParameterLabels.dart';
import 'package:ayuprep/utils/apiUtils.dart';
import 'package:ayuprep/utils/constants.dart';
import 'package:ayuprep/utils/errorMessageKeys.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:apple_sign_in_safety/apple_sign_in.dart';

class AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final _facebookSignin = FacebookLogin();
  /*
  data part of addUser response
  {id: 11, firebase_id: G1thaSiA43WYx29dOXmUd6jqUWS2, name: RAHUL HIRANI,
  email: rahulhiraniphotoshop@gmail.com, mobile: , type: gmail,
  profile: https://lh3.googleusercontent.com/a/AATXAJyzUAfJwUFTV3yE6tM9KdevDnX2rcM8vm3GKHFz=s96-c, fcm_id: eU3Pq3lKSvChPKZPRXyTUq:APA91bFLf408jQFZxjWq6iG8Kz5ouUEGLecgQX-WQOghVPEjjgnAUzl1zkNg9CHPRAPyU9YbpGzw5qPKarFt7edWJ9iQ_tBo8VKWhIgfrOLtfimcL78b4MzkLCWsw9iPL-2jFGQKDU3S, 
  coins: 0, refer_code: , friends_code: , ip_address: , status: 1, date_registered: 2021-06-07 15:27:59}  
  */

  //to addUser
  Future<Map<String, dynamic>> addUser(
      {String? firebaseId,
      String? type,
      String? name,
      String? profile,
      String? mobile,
      String? email,
      String? referCode,
      String? friendCode}) async {
    try {
      String fcmToken = await getFCMToken();
      //body of post request
      final body = {
        accessValueKey: accessValue,
        firebaseIdKey: firebaseId,
        typeKey: type,
        nameKey: name,
        emailKey: email ?? "",
        profileKey: profile ?? "",
        mobileKey: mobile ?? "",
        fcmIdKey: fcmToken,
        friendCodeKey: friendCode ?? ""
      };

      final response = await http.post(Uri.parse(addUserUrl), body: body);
      final responseJson = jsonDecode(response.body);

      if (responseJson['error']) {
        throw AuthException(errorMessageCode: responseJson['message']);
      }
      return Map<String, dynamic>.from(responseJson['data']);
    } on SocketException catch (_) {
      throw AuthException(errorMessageCode: noInternetCode);
    } on AuthException catch (e) {
      throw AuthException(errorMessageCode: e.toString());
    } catch (e) {
      //print(e.toString());
      throw AuthException(errorMessageCode: defaultErrorMessageCode);
    }
  }

  //to addUser
  Future<String> getJWTTokenOfUser({
    required String firebaseId,
    required String type,
  }) async {
    try {
      //body of post request
      final body = {
        accessValueKey: accessValue,
        firebaseIdKey: firebaseId,
        typeKey: type,
      };

      final response = await http.post(Uri.parse(addUserUrl), body: body);
      final responseJson = jsonDecode(response.body);

      if (responseJson['error']) {
        throw AuthException(errorMessageCode: responseJson['message']);
      }
      return (responseJson['data']['api_token']).toString();
    } on SocketException catch (_) {
      throw AuthException(errorMessageCode: noInternetCode);
    } on AuthException catch (e) {
      throw AuthException(errorMessageCode: e.toString());
    } catch (e) {
      throw AuthException(errorMessageCode: defaultErrorMessageCode);
    }
  }

  Future<bool> isUserExist(String firebaseId) async {
    try {
      final body = {
        accessValueKey: accessValue,
        firebaseIdKey: firebaseId,
      };
      final response =
          await http.post(Uri.parse(checkUserExistUrl), body: body);
      final responseJson = jsonDecode(response.body);

      if (responseJson['error']) {
        throw AuthException(errorMessageCode: responseJson['message']);
      }

      return responseJson['message'].toString() == "130";
    } on SocketException catch (_) {
      throw AuthException(errorMessageCode: noInternetCode);
    } on AuthException catch (e) {
      throw AuthException(errorMessageCode: e.toString());
    } catch (e) {
      throw AuthException(errorMessageCode: defaultErrorMessageCode);
    }
  }

  Future<void> updateFcmId(
      {required String firebaseId, required bool userLoggingOut}) async {
    try {
      final String fcmId = userLoggingOut
          ? "empty"
          : await fcm.FirebaseMessaging.instance.getToken() ?? "empty";
      final body = {
        accessValueKey: accessValue,
        fcmIdKey: fcmId,
        firebaseIdKey: firebaseId.isNotEmpty ? firebaseId : "firebaseId"
      };
      final response = await http.post(Uri.parse(updateFcmIdUrl),
          body: body, headers: await ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);

      if (responseJson['error']) {
        //throw AuthException(errorMessageCode: responseJson['message']);
      }
    } catch (e) {
      //throw AuthException(errorMessageCode: defaultErrorMessageCode);
    }
  }

//signIn using phone number
  Future<UserCredential> signInWithPhoneNumber(
      {required String verificationId, required String smsCode}) async {
    PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: smsCode);

    final UserCredential userCredential =
        await _firebaseAuth.signInWithCredential(phoneAuthCredential);
    return userCredential;
  }

  //SignIn user will accept AuthProvider (enum)
  Future<Map<String, dynamic>> signInUser(
    AuthProvider authProvider, {
    String? email,
    String? password,
    String? verificationId,
    String? smsCode,
  }) async {
    //user creadential contains information of signin user and is user new or not
    Map<String, dynamic> result = {};

    try {
      if (authProvider == AuthProvider.gmail) {
        UserCredential userCredential = await signInWithGoogle();

        result['user'] = userCredential.user!;
        result['isNewUser'] = userCredential.additionalUserInfo!.isNewUser;
      } else if (authProvider == AuthProvider.mobile) {
        UserCredential userCredential = await signInWithPhoneNumber(
            verificationId: verificationId!, smsCode: smsCode!);

        result['user'] = userCredential.user!;
        result['isNewUser'] = userCredential.additionalUserInfo!.isNewUser;
      } else if (authProvider == AuthProvider.fb) {
        final faceBookAuthResult = await signInWithFacebook();
        if (faceBookAuthResult != null) {
          result['user'] = faceBookAuthResult.user!;
          result['isNewUser'] =
              faceBookAuthResult.additionalUserInfo!.isNewUser;
        } else {
          throw AuthException(errorMessageCode: defaultErrorMessageCode);
        }
      } else if (authProvider == AuthProvider.email) {
        UserCredential userCredential =
            await signInWithEmailAndPassword(email!, password!);

        result['user'] = userCredential.user!;
        result['isNewUser'] = userCredential.additionalUserInfo!.isNewUser;
      } else if (authProvider == AuthProvider.apple) {
        UserCredential userCredential = await signInWithApple();
        result['user'] = _firebaseAuth.currentUser!;
        result['isNewUser'] = userCredential.additionalUserInfo!.isNewUser;
      }
      return result;
    } on SocketException catch (_) {
      throw AuthException(errorMessageCode: noInternetCode);
    }
    //firebase auht errors
    on FirebaseAuthException catch (e) {
      throw AuthException(errorMessageCode: firebaseErrorCodeToNumber(e.code));
    } on AuthException catch (e) {
      throw AuthException(errorMessageCode: e.toString());
    } catch (e) {
      throw AuthException(errorMessageCode: defaultErrorMessageCode);
    }
  }

  //signIn using google account
  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw AuthException(errorMessageCode: defaultErrorMessageCode);
    }
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final UserCredential userCredential =
        await _firebaseAuth.signInWithCredential(credential);
    return userCredential;
  }

  Future<UserCredential?> signInWithFacebook() async {
    final res = await _facebookSignin.logIn(permissions: [
      FacebookPermission.publicProfile,
      FacebookPermission.email,
    ]);

// Check result status
    switch (res.status) {
      case FacebookLoginStatus.success:

        // Send access token to server for validation and auth
        final FacebookAccessToken? accessToken = res.accessToken;
        AuthCredential authCredential =
            FacebookAuthProvider.credential(accessToken!.token);
        final UserCredential userCredential =
            await _firebaseAuth.signInWithCredential(authCredential);
        return userCredential;
      case FacebookLoginStatus.cancel:
        return null;

      case FacebookLoginStatus.error:
        return null;
      default:
        return null;
    }
  }

  Future<UserCredential> signInWithApple() async {
    try {
      final AuthorizationResult appleResult =
          await AppleSignIn.performRequests([
        AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
      ]);

      if (appleResult.status == AuthorizationStatus.authorized) {
        final appleIdCredential = appleResult.credential!;
        final oAuthProvider = OAuthProvider('apple.com');
        final credential = oAuthProvider.credential(
          idToken: String.fromCharCodes(appleIdCredential.identityToken!),
          accessToken:
              String.fromCharCodes(appleIdCredential.authorizationCode!),
        );
        final UserCredential userCredential =
            await _firebaseAuth.signInWithCredential(credential);
        if (userCredential.additionalUserInfo!.isNewUser) {
          final user = userCredential.user!;
          final String givenName = appleIdCredential.fullName!.givenName ?? "";

          final String familyName =
              appleIdCredential.fullName!.familyName ?? "";
          await user.updateDisplayName("$givenName $familyName");
          await user.reload();
        }

        return userCredential;
      } else if (appleResult.status == AuthorizationStatus.error) {
        throw AuthException(errorMessageCode: defaultErrorMessageCode);
      } else {
        throw AuthException(errorMessageCode: defaultErrorMessageCode);
      }
    } catch (error) {
      throw AuthException(errorMessageCode: defaultErrorMessageCode);
    }
  }

  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    //sign in using email
    UserCredential userCredential = await _firebaseAuth
        .signInWithEmailAndPassword(email: email, password: password);
    if (userCredential.user!.emailVerified) {
      return userCredential;
    } else {
      throw AuthException(errorMessageCode: "135");
    }
  }

  Future<void> resetPassword(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  static Future<String> getFCMToken() async {
    try {
      return await fcm.FirebaseMessaging.instance.getToken() ?? "";
    } catch (e) {
      return "";
    }
  }

  //create user account
  Future<void> signUpUser(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      //verify email address
      await userCredential.user!.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw AuthException(errorMessageCode: firebaseErrorCodeToNumber(e.code));
    } on SocketException catch (_) {
      throw AuthException(errorMessageCode: noInternetCode);
    } catch (e) {
      throw AuthException(errorMessageCode: defaultErrorMessageCode);
    }
  }

  Future<void> signOut(AuthProvider? authProvider) async {
    _firebaseAuth.signOut();
    if (authProvider == AuthProvider.gmail) {
      _googleSignIn.signOut();
    } else if (authProvider == AuthProvider.fb) {
      _facebookSignin.logOut();
    } else if (AuthProvider.apple == AuthProvider.apple) {}
  }
}
