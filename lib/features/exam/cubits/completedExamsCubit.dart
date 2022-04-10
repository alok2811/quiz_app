import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ayuprep/features/exam/examRepository.dart';
import 'package:ayuprep/features/exam/models/examResult.dart';

abstract class CompletedExamsState {}

class CompletedExamsInitial extends CompletedExamsState {}

class CompletedExamsFetchInProgress extends CompletedExamsState {}

class CompletedExamsFetchSuccess extends CompletedExamsState {
  final List<ExamResult> completedExams;
  final int totalResultCount;
  final bool hasMoreFetchError;
  final bool hasMore;

  CompletedExamsFetchSuccess({
    required this.completedExams,
    required this.totalResultCount,
    required this.hasMoreFetchError,
    required this.hasMore,
  });
}

class CompletedExamsFetchFailure extends CompletedExamsState {
  final String errorMessage;

  CompletedExamsFetchFailure(this.errorMessage);
}

class CompletedExamsCubit extends Cubit<CompletedExamsState> {
  final ExamRepository _examRepository;

  CompletedExamsCubit(this._examRepository) : super(CompletedExamsInitial());

  final int limit = 15;

  void getCompletedExams({required String userId, required String languageId}) async {
    try {
      //
      final result = await _examRepository.getCompletedExams(userId: userId, languageId: languageId, limit: limit.toString(), offset: "0");
      emit(CompletedExamsFetchSuccess(
        completedExams: result['results'],
        totalResultCount: int.parse(result['total']),
        hasMoreFetchError: false,
        hasMore: (result['results'] as List<ExamResult>).length < int.parse(result['total']),
      ));
    } catch (e) {
      emit(CompletedExamsFetchFailure(e.toString()));
    }
  }

  bool hasMoreResult() {
    if (state is CompletedExamsFetchSuccess) {
      return (state as CompletedExamsFetchSuccess).hasMore;
    }
    return false;
  }

  void getMoreResult({required String userId, required String languageId}) async {
    if (state is CompletedExamsFetchSuccess) {
      try {
        //
        final result = await _examRepository.getCompletedExams(userId: userId, languageId: languageId, limit: limit.toString(), offset: (state as CompletedExamsFetchSuccess).completedExams.length.toString());
        List<ExamResult> updatedResults = (state as CompletedExamsFetchSuccess).completedExams;
        updatedResults.addAll(result['results'] as List<ExamResult>);
        emit(CompletedExamsFetchSuccess(
          completedExams: updatedResults,
          totalResultCount: int.parse(result['total']),
          hasMoreFetchError: false,
          hasMore: updatedResults.length < int.parse(result['total']),
        ));
        //
      } catch (e) {
        //in case of any error
        emit(CompletedExamsFetchSuccess(
          completedExams: (state as CompletedExamsFetchSuccess).completedExams,
          hasMoreFetchError: true,
          totalResultCount: (state as CompletedExamsFetchSuccess).totalResultCount,
          hasMore: (state as CompletedExamsFetchSuccess).hasMore,
        ));
      }
    }
  }
}
