import 'package:ayuprep/features/bookmark/bookmarkException.dart';
import 'package:ayuprep/features/bookmark/bookmarkLocalDataSource.dart';
import 'package:ayuprep/features/bookmark/bookmarkRemoteDataSource.dart';
import 'package:ayuprep/features/quiz/models/guessTheWordQuestion.dart';
import 'package:ayuprep/features/quiz/models/question.dart';

class BookmarkRepository {
  static final BookmarkRepository _bookmarkRepository =
      BookmarkRepository._internal();
  late BookmarkRemoteDataSource _bookmarkRemoteDataSource;
  late BookmarkLocalDataSource _bookmarkLocalDataSource;

  factory BookmarkRepository() {
    _bookmarkRepository._bookmarkRemoteDataSource = BookmarkRemoteDataSource();
    _bookmarkRepository._bookmarkLocalDataSource = BookmarkLocalDataSource();
    return _bookmarkRepository;
  }

  BookmarkRepository._internal();

  //to get bookmark questions
  Future<List> getBookmark(String userId, String type) async {
    try {
      List result = await _bookmarkRemoteDataSource.getBookmark(userId, type);
      if (type == "3") {
        return result
            .map((question) =>
                GuessTheWordQuestion.fromBookmarkJson(Map.from(question)))
            .toList();
      }
      return result
          .map((question) => Question.fromBookmarkJson(Map.from(question)))
          .toList();
    } catch (e) {
      throw BookmarkException(errorMessageCode: e.toString());
    }
  }

  //to update bookmark status (add(1) or remove(0))
  Future<void> updateBookmark(
      String userId, String questionId, String status, String type) async {
    try {
      await _bookmarkRemoteDataSource.updateBookmark(
          userId, questionId, status, type);
    } catch (e) {
      throw BookmarkException(errorMessageCode: e.toString());
    }
  }

  //get submitted answer for given question index which is store in hive box
  Future<List<Map<String, String>>> getSubmittedAnswerOfBookmarkedQuestions(
      List<String> questionIds, String userId) async {
    final List<String> ids = [];
    //key will be in hive box is "userId-questionId"
    questionIds.forEach((element) {
      ids.add("$userId-$element");
    });
    //
    return await _bookmarkLocalDataSource.getAnswerOfBookmarkedQuestion(ids);
  }

  //get submitted answer for given question index which is store in hive box
  Future<List<Map<String, String>>>
      getSubmittedAnswerOfAudioBookmarkedQuestions(
          List<String> questionIds, String userId) async {
    final List<String> ids = [];
    //key will be in hive box is "userId-questionId"
    questionIds.forEach((element) {
      ids.add("$userId-$element");
    });
    return await _bookmarkLocalDataSource
        .getAnswerOfAudioBookmarkedQuestion(ids);
  }

  //get submitted answer for given question index which is store in hive box
  Future<List<Map<String, String>>>
      getSubmittedAnswerOfGuessTheWordBookmarkedQuestions(
          List<String> questionIds, String userId) async {
    final List<String> ids = [];
    //key will be in hive box is "userId-questionId"
    questionIds.forEach((element) {
      ids.add("$userId-$element");
    });
    return await _bookmarkLocalDataSource
        .getAnswerOfGuessTheWordBookmarkedQuestion(ids);
  }

  //remove bookmark answer from hive box
  Future<void> removeBookmarkedAnswer(String id) async {
    _bookmarkLocalDataSource.removeBookmarkedAnswer(id);
  }

  //remove bookmark answer from hive box audio
  Future<void> removeAudioBookmarkedAnswer(String id) async {
    _bookmarkLocalDataSource.removeAudioBookmarkedAnswer(id);
  }

  //remove bookmark answer from hive box
  Future<void> removeGuessTheWordBookmarkedAnswer(String id) async {
    _bookmarkLocalDataSource.removeGuessTheWordBookmarkedAnswer(id);
  }

  //set submitted answer id for given question index
  Future<void> setAnswerForBookmarkedQuestion(
      String questionId, String submittedAnswerId, String userId) async {
    _bookmarkLocalDataSource.setAnswerForBookmarkedQuestion(
        submittedAnswerId, questionId, userId);
  }

  //set submitted answer id for given question index
  Future<void> setAnswerForAudioBookmarkedQuestion(
      String questionId, String submittedAnswerId, String userId) async {
    _bookmarkLocalDataSource.setAnswerForAudioBookmarkedQuestion(
        submittedAnswerId, questionId, userId);
  }

  //set submitted answer id for given question index
  Future<void> setAnswerForGuessTheWordBookmarkedQuestion(
      String questionId, String submittedAnswer, String userId) async {
    _bookmarkLocalDataSource.setAnswerForGuessTheWordBookmarkedQuestion(
        submittedAnswer, questionId, userId);
  }
}
