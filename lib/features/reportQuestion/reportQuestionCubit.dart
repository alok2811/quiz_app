import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ayuprep/features/reportQuestion/reportQuestionRepository.dart';

abstract class ReportQuestionState {}

class ReportQuestionInitial extends ReportQuestionState {}

class ReportQuestionInProgress extends ReportQuestionState {}

class ReportQuestionSuccess extends ReportQuestionState {}

class ReportQuestionFailure extends ReportQuestionState {
  final String errorMessageCode;
  ReportQuestionFailure(this.errorMessageCode);
}

class ReportQuestionCubit extends Cubit<ReportQuestionState> {
  ReportQuestionRepository reportQuestionRepository;
  ReportQuestionCubit(this.reportQuestionRepository) : super(ReportQuestionInitial());

  void reportQuestion({required String questionId, required String message, required String userId}) {
    emit(ReportQuestionInProgress());
    reportQuestionRepository.reportQuestion(message: message, questionId: questionId, userId: userId).then((value) {
      emit(ReportQuestionSuccess());
    }).catchError((e) {
      emit(ReportQuestionFailure(e.toString()));
    });
  }
}
