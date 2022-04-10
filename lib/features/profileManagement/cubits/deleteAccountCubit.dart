import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ayuprep/features/profileManagement/profileManagementRepository.dart';

abstract class DeleteAccountState {}

class DeleteAccountInitial extends DeleteAccountState {}

class DeleteAccountInProgress extends DeleteAccountState {}

class DeleteAccountSuccess extends DeleteAccountState {}

class DeleteAccountFailure extends DeleteAccountState {
  final String errorMessage;
  DeleteAccountFailure(this.errorMessage);
}

class DeleteAccountCubit extends Cubit<DeleteAccountState> {
  final ProfileManagementRepository _profileManagementRepository;
  DeleteAccountCubit(this._profileManagementRepository)
      : super(DeleteAccountInitial());

  void deleteUserAccount({required String userId}) {
    //
    emit(DeleteAccountInProgress());
    _profileManagementRepository.deleteAccount(userId: userId).then((value) {
      //
      emit(DeleteAccountSuccess());
    }).catchError((e) {
      //
      emit(DeleteAccountFailure(e.toString()));
    });
  }
}
