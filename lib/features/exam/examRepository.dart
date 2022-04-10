import 'package:ayuprep/features/exam/examException.dart';
import 'package:ayuprep/features/exam/examLocalDataSource.dart';
import 'package:ayuprep/features/exam/examRemoteDataSource.dart';
import 'package:ayuprep/features/exam/models/exam.dart';
import 'package:ayuprep/features/exam/models/examResult.dart';
import 'package:ayuprep/features/quiz/models/question.dart';

class ExamRepository {
  static final ExamRepository _examRepository = ExamRepository._internal();
  late ExamRemoteDataSource _examRemoteDataSource;
  late ExamLocalDataSource _examLocalDataSource;

  factory ExamRepository() {
    _examRepository._examRemoteDataSource = ExamRemoteDataSource();
    _examRepository._examLocalDataSource = ExamLocalDataSource();
    return _examRepository;
  }

  ExamRepository._internal();

  ExamLocalDataSource get examLocalDataSource => _examLocalDataSource;

  Future<List<Exam>> getExams({required String userId, required String languageId}) async {
    try {
      final result = (await _examRemoteDataSource.getExams(limit: "", offset: "", userId: userId, languageId: languageId, type: "1"))['data'] as List;
      return result.map((e) => Exam.fromJson(e)).toList();
    } catch (e) {
      throw ExamException(errorMessageCode: e.toString());
    }
  }

  Future<Map<String, dynamic>> getCompletedExams({required String userId, required String languageId, required String offset, required String limit}) async {
    try {
      final result = await _examRemoteDataSource.getExams(
        userId: userId,
        languageId: languageId,
        type: "2",
        limit: limit,
        offset: offset,
      );
      return {
        "total": result['total'],
        "results": (result['data'] as List).map((e) => ExamResult.fromJson(e)).toList(),
      };
    } catch (e) {
      throw ExamException(errorMessageCode: e.toString());
    }
  }

  Future<List<Question>> getExamMouduleQuestions({required String examModuleId}) async {
    try {
      final result = await _examRemoteDataSource.getQuestionForExam(examModuleId: examModuleId);
      return result.map((e) => Question.fromJson(Map.from(e))).toList();
    } catch (e) {
      throw ExamException(errorMessageCode: e.toString());
    }
  }

  Future<void> updateExamStatusToInExam({required String examModuleId, required String userId}) async {
    try {
      await _examRemoteDataSource.updateExamStatusToInExam(examModuleId: examModuleId, userId: userId);
    } catch (e) {
      throw ExamException(errorMessageCode: e.toString());
    }
  }

  Future<void> submitExamResult({
    required String obtainedMarks,
    required String examModuleId,
    required String userId,
    required String totalDuration,
    required List<Map<String, dynamic>> statistics,
    required bool rulesViolated,
    required List<String> capturedQuestionIds,
  }) async {
    try {
      await _examRemoteDataSource.submitExamResult(capturedQuestionIds: capturedQuestionIds, rulesViolated: rulesViolated, examModuleId: examModuleId, userId: userId, totalDuration: totalDuration, statistics: statistics, obtainedMarks: obtainedMarks);
    } catch (e) {
      print(e.toString());
      //throw ExamException(errorMessageCode: e.toString());
    }
  }

  Future<void> completePendingExams({required String userId}) async {
    //
    List<String> pendingExamIds = _examLocalDataSource.getAllExamModuleIds();
    pendingExamIds.forEach((element) {
      submitExamResult(examModuleId: element, userId: userId, totalDuration: "0", statistics: [], obtainedMarks: "0", rulesViolated: false, capturedQuestionIds: []);
    });

    //delete exams
    pendingExamIds.forEach((element) {
      _examLocalDataSource.removeExamModuleId(element);
    });
  }
}
