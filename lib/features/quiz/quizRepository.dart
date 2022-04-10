import 'package:ayuprep/features/quiz/models/guessTheWordQuestion.dart';
import 'package:ayuprep/features/quiz/models/leaderBoardMonthly.dart';
import 'package:ayuprep/features/quiz/quizException.dart';
import 'package:ayuprep/features/quiz/quizRemoteDataSoure.dart';

import 'models/category.dart';
import 'models/comprehension.dart';
import 'models/contest.dart';
import 'models/contestLeaderboard.dart';
import 'models/question.dart';
import 'models/quizType.dart';
import 'models/subcategory.dart';

class QuizRepository {
  static final QuizRepository _quizRepository = QuizRepository._internal();
  late QuizRemoteDataSource _quizRemoteDataSource;
  static List<LeaderBoardMonthly> leaderBoardMonthlyList = [];
  //QuizLocalDataSource _quizLocalDataSource;

  factory QuizRepository() {
    _quizRepository._quizRemoteDataSource = QuizRemoteDataSource();
    //_quizRepository._quizLocalDataSource = QuizLocalDataSource();
    return _quizRepository;
  }

  QuizRepository._internal();

  Future<List<Category>> getCategory(
      {required String languageId,
      required String type,
      required String userId}) async {
    try {
      List<Category> categoryList = [];
      List result = await _quizRemoteDataSource.getCategory(
        languageId: languageId,
        type: type,
        userId: userId,
      );
      categoryList = result
          .map((category) => Category.fromJson(Map.from(category)))
          .toList();

      return categoryList;
    } catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    }
  }

  Future<List<Subcategory>> getSubCategory(
      String category, String userId) async {
    try {
      List<Subcategory> subCategoryList = [];
      List result =
          await _quizRemoteDataSource.getSubCategory(category, userId);
      subCategoryList = result
          .map((subCategory) => Subcategory.fromJson(Map.from(subCategory)))
          .toList();
      return subCategoryList;
    } catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    }
  }

  Future<int> getUnlockedLevel(
      String? userId, String? category, String? subCategory) async {
    try {
      final result = await _quizRemoteDataSource.getUnlockedLevel(
          userId, category, subCategory);

      return int.parse(result['level'].toString());
    } catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    }
  }

  Future<void> updateLevel(
      {String? userId,
      String? category,
      String? subCategory,
      String? level}) async {
    try {
      print("Category Id : $category And Sub-category Id : $subCategory");
      await _quizRemoteDataSource.updateLevel(
          category: category,
          level: level,
          subCategory: subCategory,
          userId: userId);
    } catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    }
  }

  Future<List<Question>> getQuestions(
    QuizTypes? quizType, {
    String? userId, //will be in use for dailyQuiz
    String?
        languageId, // will be in use for dailyQuiz and self-challenge (quizType)
    String?
        categoryId, //will be in use for quizZone and self-challenge (quizType)
    String?
        subcategoryId, //will be in use for quizZone and self-challenge (quizType)
    String? numberOfQuestions, //will be in use forself-challenge (quizType),
    String? level, ////will be in use for quizZone (quizType)
    String? contestId, //will use to get contest id vise question
    String? funAndLearnId,
  }) async {
    try {
      List<Question> questions = [];
      List? result;
      if (quizType == QuizTypes.dailyQuiz) {
        result = await _quizRemoteDataSource.getQuestionsForDailyQuiz(
            languageId: languageId, userId: userId);
        questions = result!
            .map((question) => Question.fromJson(Map.from(question)))
            .toList();
      } else if (quizType == QuizTypes.selfChallenge) {
        result = await _quizRemoteDataSource.getQuestionsForSelfChallenge(
          languageId: languageId!,
          categoryId: categoryId!,
          numberOfQuestions: numberOfQuestions!,
          subcategoryId: subcategoryId!,
        );
        questions = result!
            .map((question) => Question.fromJson(Map.from(question)))
            .toList();
      } else if (quizType == QuizTypes.quizZone) {
        //if level is 0 means need to fetch questions by get_question api endpoint
        if (level! == "0") {
          String type = categoryId!.isNotEmpty ? "category" : "subcategory";
          String id = type == "category" ? categoryId : subcategoryId!;
          result =
              await _quizRemoteDataSource.getQuestionByCategoryOrSubcategory(
            type: type,
            id: id,
          );
        } else {
          result = await _quizRemoteDataSource.getQuestionsForQuizZone(
              languageId: languageId!,
              categoryId: categoryId!,
              subcategoryId: subcategoryId!,
              level: level);
        }

        questions = result!
            .map((question) => Question.fromJson(Map.from(question)))
            .toList();
      } else if (quizType == QuizTypes.trueAndFalse) {
        result = await _quizRemoteDataSource.getQuestionByType(languageId!);
        questions = result!
            .map((question) => Question.fromJson(Map.from(question)))
            .toList();
      } else if (quizType == QuizTypes.contest) {
        result = await _quizRemoteDataSource.getQuestionContest(contestId!);
        questions = result!
            .map((question) => Question.fromJson(Map.from(question)))
            .toList();
      } else if (quizType == QuizTypes.funAndLearn) {
        result = await (_quizRemoteDataSource.getComprehensionQuestion(
            funAndLearnId) /*as Future<List<dynamic>?>*/);
        questions = result!
            .map((question) => Question.fromJson(Map.from(question)))
            .toList();
      } else if (quizType == QuizTypes.audioQuestions) {
        String type = categoryId!.isNotEmpty ? "category" : "subcategory";
        String id = type == "category" ? categoryId : subcategoryId!;
        result =
            await _quizRemoteDataSource.getAudioQuestions(type: type, id: id);
        questions = result
            .map((question) => Question.fromJson(Map.from(question)))
            .toList();
      }

      return questions;
    } catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    }
  }

  Future<List<GuessTheWordQuestion>> getGuessTheWordQuestions({
    required String languageId,
    required String type, //category or subcategory
    required String typeId, //id of the category or subcategory
  }) async {
    try {
      final result = await _quizRemoteDataSource.getGuessTheWordQuestions(
        languageId: languageId,
        type: type,
        typeId: typeId,
      );
      return result
          .map((question) => GuessTheWordQuestion.fromJson(Map.from(question)))
          .toList();
    } catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    }
  }

  Future<Contests> getContest(String? userId) async {
    try {
      final result = await _quizRemoteDataSource.getContest(userId);
      return Contests.fromJson(Map.from(result));
    } catch (e) {
      print(e.toString());
      throw QuizException(errorMessageKey: e.toString(), errorMessageCode: '');
    }
  }

  Future<void> setContestLeaderboard(
      {String? userId,
      String? contestId,
      int? questionAttended,
      int? correctAns,
      int? score}) async {
    try {
      await _quizRemoteDataSource.setContestLeaderboard(
          userId: userId,
          contestId: contestId,
          questionAttended: questionAttended,
          correctAns: correctAns,
          score: score);
    } catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    }
  }

  Future getContestLeaderboard({String? userId, String? contestId}) async {
    try {
      List<ContestLeaderboard> contestLeaderboardList = [];
      List result = await _quizRemoteDataSource.getContestLeaderboard(
          contestId, userId /*as Future<List<dynamic>>*/);
      contestLeaderboardList = result
          .map((category) => ContestLeaderboard.fromJson(Map.from(category)))
          .toList();
      return contestLeaderboardList;
      // await _quizRemoteDataSource.getContestLeaderboard(userId,contestId,);
    } catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    }
  }

  Future getComprehension({
    required String languageId,
    required String type,
    required String typeId,
    required String userId,
  }) async {
    try {
      List<Comprehension> comprehensionList = [];
      List result = await _quizRemoteDataSource.getComprehension(
        userId: userId,
        languageId: languageId,
        type: type,
        typeId: typeId,
      ) /*as Future<dynamic>*/;
      comprehensionList = result
          .map((category) => Comprehension.fromJson(Map.from(category)))
          .toList();
      return comprehensionList;
      // await _quizRemoteDataSource.getContestLeaderboard(userId,contestId,);
    } catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    }
  }

  Future<void> setQuizCategoryPlayed(
      {required String type,
      required String userId,
      required String categoryId,
      required String subcategoryId,
      required String typeId}) async {
    try {
      await _quizRemoteDataSource.setQuizCategoryPlayed(
          type: type,
          userId: userId,
          categoryId: categoryId,
          subcategoryId: subcategoryId,
          typeId: typeId);
    } catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    }
  }
}
