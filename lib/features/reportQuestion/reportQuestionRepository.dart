import 'package:ayuprep/features/reportQuestion/reportQuestionException.dart';
import 'package:ayuprep/features/reportQuestion/reportQuestionRemoteDataSource.dart';

class ReportQuestionRepository {
  static final ReportQuestionRepository _reportQuestionRepository = ReportQuestionRepository._internal();
  late ReportQuestionRemoteDataSource _reportQuestionRemoteDataSource;

  factory ReportQuestionRepository() {
    _reportQuestionRepository._reportQuestionRemoteDataSource = ReportQuestionRemoteDataSource();
    return _reportQuestionRepository;
  }

  ReportQuestionRepository._internal();

  Future<void> reportQuestion({required String questionId, required String message, required String userId}) async {
    try {
      await _reportQuestionRemoteDataSource.reportQuestion(message: message, questionId: questionId, userId: userId);
    } catch (e) {
      throw ReportQuestionException(errorMessageCode: e.toString());
    }
  }
}
