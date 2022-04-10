import 'package:firebase_auth/firebase_auth.dart';
import 'package:ayuprep/features/auth/auhtException.dart';
import 'package:ayuprep/features/auth/authLocalDataSource.dart';
import 'package:ayuprep/features/auth/authRemoteDataSource.dart';
import 'package:ayuprep/features/auth/cubits/authCubit.dart';

class AuthRepository {
  static final AuthRepository _authRepository = AuthRepository._internal();
  late AuthLocalDataSource _authLocalDataSource;
  late AuthRemoteDataSource _authRemoteDataSource;

  factory AuthRepository() {
    _authRepository._authLocalDataSource = AuthLocalDataSource();
    _authRepository._authRemoteDataSource = AuthRemoteDataSource();
    return _authRepository;
  }

  AuthRepository._internal();

  //to get auth detials stored in hive box
  Map<String, dynamic> getLocalAuthDetails() {
    return {
      "isLogin": AuthLocalDataSource.checkIsAuth(),
      "jwtToken": AuthLocalDataSource.getJwtToken(),
      "firebaseId": AuthLocalDataSource.getUserFirebaseId(),
      "authProvider":
          getAuthProviderFromString(AuthLocalDataSource.getAuthType()),
    };
  }

  void setLocalAuthDetails(
      {String? jwtToken,
      String? firebaseId,
      String? authType,
      bool? authStatus,
      bool? isNewUser}) {
    _authLocalDataSource.changeAuthStatus(authStatus);

    _authLocalDataSource.setUserFirebaseId(firebaseId);
    _authLocalDataSource.setAuthType(authType);
  }

  //First we signin user with given provider then add user details
  Future<Map<String, dynamic>> signInUser(
    AuthProvider authProvider, {
    required String email,
    required String password,
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final result = await _authRemoteDataSource.signInUser(
        authProvider,
        email: email,
        password: password,
        smsCode: smsCode,
        verificationId: verificationId,
      );
      final user = result['user'] as User;
      bool isNewUser = result['isNewUser'] as bool;

      if (authProvider == AuthProvider.email) {
        //check if user exist or not
        final isUserExist = await _authRemoteDataSource.isUserExist(user.uid);
        //if user does not exist add in database
        if (!isUserExist) {
          isNewUser = true;
          final registeredUser = await _authRemoteDataSource.addUser(
            email: user.email ?? "",
            firebaseId: user.uid,
            mobile: user.phoneNumber ?? "",
            name: user.displayName ?? "",
            type: getAuthTypeString(authProvider),
            profile: user.photoURL ?? "",
          );
          print("JWT TOKEN is : ${registeredUser['api_token']}");

          //store jwt token
          await AuthLocalDataSource.setJwtToken(
              registeredUser['api_token'].toString());
        } else {
          //get jwt token of user
          final jwtToken = await _authRemoteDataSource.getJWTTokenOfUser(
              firebaseId: user.uid, type: getAuthTypeString(authProvider));

          //store jwt token
          await AuthLocalDataSource.setJwtToken(jwtToken);

          await _authRemoteDataSource.updateFcmId(
              firebaseId: user.uid, userLoggingOut: false);
        }
      } else {
        if (isNewUser) {
          //
          final registeredUser = await _authRemoteDataSource.addUser(
            email: user.email ?? "",
            firebaseId: user.uid,
            mobile: user.phoneNumber ?? "",
            name: user.displayName ?? "",
            type: getAuthTypeString(authProvider),
            profile: user.photoURL ?? "",
          );

          //store jwt token
          print("JWT TOKEN is : ${registeredUser['api_token']}");
          await AuthLocalDataSource.setJwtToken(registeredUser['api_token']);
        } else {
          //get jwt token of user
          final jwtToken = await _authRemoteDataSource.getJWTTokenOfUser(
              firebaseId: user.uid, type: getAuthTypeString(authProvider));

          print("Jwt token $jwtToken");
          //store jwt token
          await AuthLocalDataSource.setJwtToken(jwtToken);
          //
          await _authRemoteDataSource.updateFcmId(
              firebaseId: user.uid, userLoggingOut: false);
        }
      }
      return {
        "user": user,
        "isNewUser": isNewUser,
      };
    } catch (e) {
      print(e.toString());
      signOut(authProvider);
      throw AuthException(errorMessageCode: e.toString());
    }
  }

  //to signUp user
  Future<void> signUpUser(String email, String password) async {
    try {
      await _authRemoteDataSource.signUpUser(email, password);
    } catch (e) {
      signOut(AuthProvider.email);
      throw AuthException(errorMessageCode: e.toString());
    }
  }

  Future<void> signOut(AuthProvider? authProvider) async {
    //remove fcm token when user logout
    try {
      _authRemoteDataSource.updateFcmId(
          firebaseId: AuthLocalDataSource.getUserFirebaseId(),
          userLoggingOut: true);
      _authRemoteDataSource.signOut(authProvider);
      setLocalAuthDetails(
          authStatus: false,
          authType: "",
          jwtToken: "",
          firebaseId: "",
          isNewUser: false);
    } catch (e) {}
  }

  String getAuthTypeString(AuthProvider provider) {
    String authType;
    if (provider == AuthProvider.fb) {
      authType = "fb";
    } else if (provider == AuthProvider.gmail) {
      authType = "gmail";
    } else if (provider == AuthProvider.mobile) {
      authType = "mobile";
    } else if (provider == AuthProvider.apple) {
      authType = "apple";
    } else {
      authType = "email";
    }
    return authType;
  }

  //to add user's data to database. This will be in use when authenticating using phoneNumber
  Future<Map<String, dynamic>> addUserData(
      {String? firebaseId,
      String? type,
      String? name,
      String? profile,
      String? mobile,
      String? email,
      String? referCode,
      String? friendCode}) async {
    try {
      final result = await _authRemoteDataSource.addUser(
          email: email,
          firebaseId: firebaseId,
          friendCode: friendCode,
          mobile: mobile,
          name: name,
          profile: profile,
          referCode: referCode,
          type: type);

      //Update jwt token
      await AuthLocalDataSource.setJwtToken(result['api_token'].toString());

      return Map.from(result); //
    } catch (e) {
      signOut(AuthProvider.mobile);
      throw AuthException(errorMessageCode: e.toString());
    }
  }

  AuthProvider getAuthProviderFromString(String? value) {
    AuthProvider authProvider;
    if (value == "fb") {
      authProvider = AuthProvider.fb;
    } else if (value == "gmail") {
      authProvider = AuthProvider.gmail;
    } else if (value == "mobile") {
      authProvider = AuthProvider.mobile;
    } else if (value == "apple") {
      authProvider = AuthProvider.apple;
    } else {
      authProvider = AuthProvider.email;
    }
    return authProvider;
  }
}
