import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ayuprep/features/auth/authRepository.dart';
import 'package:ayuprep/features/auth/cubits/authCubit.dart';
import 'package:ayuprep/features/profileManagement/models/userProfile.dart';

//State
@immutable
abstract class ReferAndEarnState {}

class ReferAndEarnInitial extends ReferAndEarnState {}

class ReferAndEarnProgress extends ReferAndEarnState {}

class ReferAndEarnSuccess extends ReferAndEarnState {
  final UserProfile userProfile;

  ReferAndEarnSuccess({required this.userProfile});
}

class ReferAndEarnFailure extends ReferAndEarnState {
  final String errorMessage;
  ReferAndEarnFailure(this.errorMessage);
}

class ReferAndEarnCubit extends Cubit<ReferAndEarnState> {
  final AuthRepository _authRepository;
  ReferAndEarnCubit(this._authRepository) : super(ReferAndEarnInitial());

  void getReward(
      {required UserProfile userProfile,
      required String name,
      required String friendReferralCode,
      required AuthProvider authType}) {
    //emitting signInProgress state
    emit(ReferAndEarnProgress());

    //signIn user with given provider and also add user detials in api
    _authRepository
        .addUserData(
            email: userProfile.email,
            firebaseId: userProfile.firebaseId,
            friendCode: friendReferralCode,
            mobile: userProfile.mobileNumber,
            name: name,
            type: _authRepository.getAuthTypeString(authType),
            profile: userProfile.profileUrl)
        .then((result) {
      emit(ReferAndEarnSuccess(userProfile: UserProfile.fromJson(result)));
    }).catchError((e) {
      //failure
      emit(ReferAndEarnFailure(e.toString()));
    });
  }
}
