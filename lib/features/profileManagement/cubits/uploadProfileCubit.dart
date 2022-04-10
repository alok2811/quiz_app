import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ayuprep/features/profileManagement/profileManagementRepository.dart';

@immutable
abstract class UploadProfileState {}

class UploadProfileInitial extends UploadProfileState {}

class UploadProfileInProgress extends UploadProfileState {}

class UploadProfileSuccess extends UploadProfileState {
  final String imageUrl;

  UploadProfileSuccess(this.imageUrl);
}

class UploadProfileFailure extends UploadProfileState {
  final String errorMessage;

  UploadProfileFailure(this.errorMessage);
}

class UploadProfileCubit extends Cubit<UploadProfileState> {
  final ProfileManagementRepository _profileManagementRepository;

  UploadProfileCubit(this._profileManagementRepository) : super(UploadProfileInitial());

  void uploadProfilePicture(File? file, String? userId) async {
    emit(UploadProfileInProgress());
    _profileManagementRepository.uploadProfilePicture(file, userId).then((imageUrl) {
      //success
      emit(UploadProfileSuccess(imageUrl));
    }).catchError((e) {
      print(e);
      //failure
      emit(UploadProfileFailure(e.toString()));
    });
  }
}
