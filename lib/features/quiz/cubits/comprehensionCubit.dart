import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ayuprep/features/quiz/models/comprehension.dart';
import 'package:ayuprep/features/quiz/quizRepository.dart';

abstract class ComprehensionState {}

class ComprehensionInitial extends ComprehensionState {}

class ComprehensionProgress extends ComprehensionState {}

class ComprehensionSuccess extends ComprehensionState {
  final List<Comprehension> getComprehension;

  ComprehensionSuccess(this.getComprehension);
}

class ComprehensionFailure extends ComprehensionState {
  final String errorMessage;
  ComprehensionFailure(this.errorMessage);
}

class ComprehensionCubit extends Cubit<ComprehensionState> {
  final QuizRepository _quizRepository;
  ComprehensionCubit(this._quizRepository) : super(ComprehensionInitial());

  getComprehension({
    required String languageId,
    required String type,
    required String typeId,
    required String userId,
  }) async {
    emit(ComprehensionProgress());
    _quizRepository
        .getComprehension(
          languageId: languageId,
          type: type,
          userId: userId,
          typeId: typeId,
        )
        .then(
          (val) => emit(ComprehensionSuccess(val)),
        )
        .catchError((e) {
      print(e.toString());
      emit(ComprehensionFailure(e.toString()));
    });
  }
}
