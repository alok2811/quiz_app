import 'package:ayuprep/utils/constants.dart';
import 'package:hive/hive.dart';

class BookmarkLocalDataSource {
  Future<void> openBox(String boxName) async {
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox<String>(boxName);
    }
  }

  Future<void> setAnswerForBookmarkedQuestion(
      String submittedAnswerId, String questionId, String userId) async {
    //key will be questionId and value for this key will be submittedAsnwerId
    await openBox(bookmarkBox);
    final box = Hive.box<String>(bookmarkBox);
    await box.put("$userId-$questionId", submittedAnswerId);
  }

  Future<void> setAnswerForAudioBookmarkedQuestion(
      String submittedAnswerId, String questionId, String userId) async {
    //key will be questionId and value for this key will be submittedAsnwerId
    await openBox(audioBookmarkBox);
    final box = Hive.box<String>(audioBookmarkBox);
    await box.put("$userId-$questionId", submittedAnswerId);
  }

  Future<void> setAnswerForGuessTheWordBookmarkedQuestion(
      String submittedAnswer, String questionId, String userId) async {
    //key will be userId-questionId and value for this key will be submittedAsnwer
    await openBox(guessTheWordBookmarkBox);
    final box = Hive.box<String>(guessTheWordBookmarkBox);
    await box.put("$userId-$questionId", submittedAnswer);
  }

  Future<List<Map<String, String>>> getAnswerOfBookmarkedQuestion(
      List<String> ids) async {
    List<Map<String, String>> submittedAnswerIds = [];
    await openBox(bookmarkBox);
    final box = Hive.box<String>(bookmarkBox);

    //ids will be userId-questionId
    ids.forEach((element) {
      submittedAnswerIds.add({
        element.split("-").last: box.get(element, defaultValue: "")!,
      });
    });
    return submittedAnswerIds;
  }

  Future<List<Map<String, String>>> getAnswerOfAudioBookmarkedQuestion(
      List<String> ids) async {
    List<Map<String, String>> submittedAnswerIds = [];
    await openBox(audioBookmarkBox);
    final box = Hive.box<String>(audioBookmarkBox);

    //ids will be userId-questionId
    ids.forEach((element) {
      submittedAnswerIds.add({
        element.split("-").last: box.get(element, defaultValue: "")!,
      });
    });
    return submittedAnswerIds;
  }

  Future<List<Map<String, String>>> getAnswerOfGuessTheWordBookmarkedQuestion(
      List<String> ids) async {
    List<Map<String, String>> submittedAnswerIds = [];
    await openBox(guessTheWordBookmarkBox);
    final box = Hive.box<String>(guessTheWordBookmarkBox);

    //id will be userId-questionId
    ids.forEach((element) {
      submittedAnswerIds.add({
        element.split("-").last: box.get(element, defaultValue: "")!,
      });
    });
    return submittedAnswerIds;
  }

  Future<void> removeBookmarkedAnswer(String id) async {
    await openBox(bookmarkBox);
    final box = Hive.box<String>(bookmarkBox);
    await box.delete(id);
  }

  Future<void> removeAudioBookmarkedAnswer(String id) async {
    await openBox(audioBookmarkBox);
    final box = Hive.box<String>(audioBookmarkBox);
    await box.delete(id);
  }

  Future<void> removeGuessTheWordBookmarkedAnswer(String id) async {
    await openBox(bookmarkBox);
    final box = Hive.box<String>(guessTheWordBookmarkBox);
    await box.delete(id);
  }
}
