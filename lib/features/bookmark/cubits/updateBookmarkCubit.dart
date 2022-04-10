import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ayuprep/features/bookmark/bookmarkRepository.dart';

@immutable
abstract class UpdateBookmarkState {}

class UpdateBookmarkIntial extends UpdateBookmarkState {}

class UpdateBookmarkInProgress extends UpdateBookmarkState {}

class UpdateBookmarkSuccess extends UpdateBookmarkState {}

class UpdateBookmarkFailure extends UpdateBookmarkState {
  final String errorMessageCode;
  final String failedStatus;
  UpdateBookmarkFailure(this.errorMessageCode, this.failedStatus);
}

class UpdateBookmarkCubit extends Cubit<UpdateBookmarkState> {
  final BookmarkRepository _bookmarkRepository;
  UpdateBookmarkCubit(this._bookmarkRepository) : super(UpdateBookmarkIntial());

  void updateBookmark(
      String userId, String questionId, String status, String type) async {
    emit(UpdateBookmarkInProgress());
    try {
      await _bookmarkRepository.updateBookmark(
          userId, questionId, status, type);
      emit(UpdateBookmarkSuccess());
    } catch (e) {
      print(e.toString());
      emit(UpdateBookmarkFailure(e.toString(), status));
    }
  }
}
