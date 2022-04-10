import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ayuprep/features/auth/authModel.dart';
import 'package:ayuprep/features/auth/authRepository.dart';

//authentication provider
enum AuthProvider { gmail, fb, email, mobile, apple }

//State
@immutable
abstract class AuthState {}

class AuthInitial extends AuthState {}

class Authenticated extends AuthState {
  //to store authDetials
  final AuthModel authModel;

  Authenticated({required this.authModel});
}

class Unauthenticated extends AuthState {}

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  AuthCubit(this._authRepository) : super(AuthInitial()) {
    _checkAuthStatus();
  }

  AuthRepository get authRepository => _authRepository;

  String getUserFirebaseId() {
    if (state is Authenticated) {
      return (state as Authenticated).authModel.firebaseId;
    }
    return "";
  }

  bool getIsNewUser() {
    if (state is Authenticated) {
      return (state as Authenticated).authModel.isNewUser;
    }
    return false;
  }

  AuthProvider getAuthProvider() {
    if (state is Authenticated) {
      return (state as Authenticated).authModel.authProvider;
    }
    return AuthProvider.email;
  }

  void _checkAuthStatus() {
    //authDetails is map. keys are isLogin,userId,authProvider,jwtToken
    final authDetails = _authRepository.getLocalAuthDetails();

    if (authDetails['isLogin']) {
      emit(Authenticated(authModel: AuthModel.fromJson(authDetails)));
    } else {
      emit(Unauthenticated());
    }
  }

  //to update auth status
  void updateAuthDetails(
      {String? firebaseId,
      AuthProvider? authProvider,
      bool? authStatus,
      bool? isNewUser}) {
    //updating authDetails locally
    _authRepository.setLocalAuthDetails(
      jwtToken: "",
      firebaseId: firebaseId,
      authType: _authRepository.getAuthTypeString(authProvider!),
      authStatus: authStatus,
      isNewUser: isNewUser,
    );

    //emitting new state in cubit
    emit(
      Authenticated(
          authModel: AuthModel(
        jwtToken: "",
        firebaseId: firebaseId!,
        authProvider: authProvider,
        isNewUser: isNewUser!,
      )),
    );
  }

  //to signout
  void signOut() {
    if (state is Authenticated) {
      _authRepository.signOut((state as Authenticated).authModel.authProvider);
      emit(Unauthenticated());
      print("signoutSucessfull");
    }
  }
}
