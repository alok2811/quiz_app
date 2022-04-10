import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ayuprep/features/exam/examRepository.dart';
import 'package:ayuprep/features/exam/models/exam.dart';

abstract class ExamsState {}

class ExamsInitial extends ExamsState {}

class ExamsFetchInProgress extends ExamsState {}

class ExamsFetchSuccess extends ExamsState {
  final List exams;

  ExamsFetchSuccess(this.exams);
}

class ExamsFetchFailure extends ExamsState {
  final String errorMessage;

  ExamsFetchFailure(this.errorMessage);
}

class ExamsCubit extends Cubit<ExamsState> {
  final ExamRepository _examRepository;

  ExamsCubit(this._examRepository) : super(ExamsInitial());

  void getExams({required String userId, required String languageId}) async {
    emit(ExamsFetchInProgress());
    try {
      //today's all exam but unattempted
      //(status: 1-Not in Exam, 2-In exam, 3-Completed)
      List exams = (await _examRepository.getExams(userId: userId, languageId: languageId)).where((element) => element.examStatus == "1").toList(); //

      emit(ExamsFetchSuccess(exams));
    } catch (e) {
      emit(ExamsFetchFailure(e.toString()));
    }
  }
}
