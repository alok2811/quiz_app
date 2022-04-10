import 'dart:convert';
import 'dart:io';
import 'package:ayuprep/utils/apiBodyParameterLabels.dart';
import 'package:http/http.dart' as http;
import 'package:ayuprep/features/quiz/quizException.dart';
import 'package:ayuprep/utils/apiUtils.dart';
import 'package:ayuprep/utils/constants.dart';
import 'package:ayuprep/utils/errorMessageKeys.dart';

class QuizRemoteDataSource {
  static late String profile, score, rank;

  Future<List?> getQuestionsForDailyQuiz(
      {String? languageId, String? userId}) async {
    try {
      Map<String, String> body = {
        accessValueKey: accessValue,
        languageIdKey: languageId!,
        userIdKey: userId!
      };

      if (languageId.isEmpty) {
        body.remove(languageIdKey);
      }

      final response = await http.post(Uri.parse(getQuestionForDailyQuizUrl),
          body: body, headers: await ApiUtils.getHeaders());

      final responseJson = jsonDecode(response.body);

      if (responseJson['error']) {
        print(responseJson['message']);
        throw QuizException(errorMessageCode: responseJson['message']); //error
      }
      return responseJson['data'];
    } on SocketException catch (_) {
      throw QuizException(errorMessageCode: noInternetCode);
    } on QuizException catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    } catch (e) {
      throw QuizException(errorMessageCode: defaultErrorMessageCode);
    }
  }

  Future<List?> getQuestionByType(String languageId) async {
    try {
      Map<String, String> body = {
        accessValueKey: accessValue,
        typeKey: "2",
        limitKey: "10",
        languageIdKey: languageId
      };
      if (languageId.isEmpty) {
        body.remove(languageIdKey);
      }

      final response = await http.post(Uri.parse(getQuestionByTypeUrl),
          body: body, headers: await ApiUtils.getHeaders());

      final responseJson = jsonDecode(response.body);
      if (responseJson['error']) {
        throw QuizException(errorMessageCode: responseJson['message']); //error
      }
      return responseJson['data'];
    } on SocketException catch (_) {
      throw QuizException(errorMessageCode: noInternetCode);
    } on QuizException catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    } catch (e) {
      throw QuizException(errorMessageCode: defaultErrorMessageCode);
    }
  }

  Future<List?> getQuestionContest(String contestId) async {
    try {
      Map<String, String> body = {
        accessValueKey: accessValue,
        contestIdKey: contestId,
      };

      final response = await http.post(Uri.parse(getQuestionContestUrl),
          body: body, headers: await ApiUtils.getHeaders());

      final responseJson = jsonDecode(response.body);
      if (responseJson['error']) {
        throw QuizException(errorMessageCode: responseJson['message']); //error
      }
      return responseJson['data'];
    } on SocketException catch (_) {
      throw QuizException(errorMessageCode: noInternetCode);
    } on QuizException catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    } catch (e) {
      throw QuizException(errorMessageCode: defaultErrorMessageCode);
    }
  }

  Future<List<dynamic>> getGuessTheWordQuestions(
      {required String languageId,
      required String type, //category or subcategory
      required String typeId}) //id of the category or subcategory)
  async {
    try {
      Map<String, String> body = {
        accessValueKey: accessValue,
        languageIdKey: languageId,
        typeKey: type,
        typeIdKey: typeId
      };

      if (languageId.isEmpty) {
        body.remove(languageIdKey);
      }

      final response = await http.post(Uri.parse(getGuessTheWordQuestionUrl),
          body: body, headers: await ApiUtils.getHeaders());

      final responseJson = jsonDecode(response.body);
      if (responseJson['error']) {
        throw QuizException(errorMessageCode: responseJson['message']); //error
      }
      return responseJson['data'];
    } on SocketException catch (_) {
      throw QuizException(errorMessageCode: noInternetCode);
    } on QuizException catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    } catch (e) {
      throw QuizException(errorMessageCode: defaultErrorMessageCode);
    }
  }

  /*
  get_questions_by_level
        access_key:8525
	level:2
	category:5 {or}
	subcategory:9
	language_id:2  
   */

  Future<List?> getQuestionsForQuizZone(
      {required String languageId,
      required String categoryId,
      required String subcategoryId,
      required String level}) async {
    try {
      Map<String, String> body = {
        accessValueKey: accessValue,
        languageIdKey: languageId,
        categoryKey: categoryId,
        subCategoryKey: subcategoryId,
        levelKey: level,
      };
      if (languageId.isEmpty) {
        body.remove(languageIdKey);
      }
      if (categoryId.isEmpty) {
        body.remove(categoryKey);
      }
      if (subcategoryId.isEmpty) {
        body.remove(subCategoryKey);
      }

      final response = await http.post(Uri.parse(getQuestionsByLevelUrl),
          body: body, headers: await ApiUtils.getHeaders());

      final responseJson = jsonDecode(response.body);

      print(responseJson);

      if (responseJson['error']) {
        throw QuizException(errorMessageCode: responseJson['message']);
      }
      return responseJson['data'];
    } on SocketException catch (_) {
      throw QuizException(errorMessageCode: noInternetCode);
    } on QuizException catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    } catch (e) {
      throw QuizException(errorMessageCode: defaultErrorMessageCode);
    }
  }

  Future<List?> getQuestionByCategoryOrSubcategory({
    required String type,
    required String id,
  }) async {
    try {
      Map<String, String> body = {
        accessValueKey: accessValue,
        typeKey: type,
        idKey: id,
      };

      final response = await http.post(
          Uri.parse(getQuestionsByCategoryOrSubcategory),
          body: body,
          headers: await ApiUtils.getHeaders());

      final responseJson = jsonDecode(response.body);

      if (responseJson['error']) {
        throw QuizException(errorMessageCode: responseJson['message']);
      }
      return responseJson['data'];
    } on SocketException catch (_) {
      throw QuizException(errorMessageCode: noInternetCode);
    } on QuizException catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    } catch (e) {
      throw QuizException(errorMessageCode: defaultErrorMessageCode);
    }
  }

  Future<List> getAudioQuestions(
      {required String type, required String id}) async {
    try {
      Map<String, String> body = {
        accessValueKey: accessValue,
        typeKey: type,
        typeIdKey: id,
      };

      final response = await http.post(Uri.parse(getAudioQuestionUrl),
          body: body, headers: await ApiUtils.getHeaders());

      final responseJson = jsonDecode(response.body);

      if (responseJson['error']) {
        throw QuizException(errorMessageCode: responseJson['message']);
      }
      return responseJson['data'];
    } on SocketException catch (_) {
      throw QuizException(errorMessageCode: noInternetCode);
    } on QuizException catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    } catch (e) {
      throw QuizException(errorMessageCode: defaultErrorMessageCode);
    }
  }

  Future<dynamic> getCategory(
      {required String languageId,
      required String type,
      required String userId}) async {
    try {
      //body of post request
      Map<String, String> body = {
        accessValueKey: accessValue,
        languageIdKey: languageId,
        userIdKey: userId,
        typeKey: type
      };
      if (languageId.isEmpty) {
        body.remove(languageIdKey);
      }
      final response = await http.post(Uri.parse(getCategoryUrl),
          body: body, headers: await ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);

      if (responseJson['error']) {
        throw QuizException(errorMessageCode: responseJson['message']);
      }
      return responseJson['data'];
    } on SocketException catch (_) {
      throw QuizException(errorMessageCode: noInternetCode);
    } on QuizException catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    } catch (e) {
      throw QuizException(errorMessageCode: defaultErrorMessageCode);
    }
  }

  Future<List?> getQuestionsForSelfChallenge(
      {required String languageId,
      required String categoryId,
      required String subcategoryId,
      required String numberOfQuestions}) async {
    try {
      Map<String, String> body = {
        accessValueKey: accessValue,
        languageIdKey: languageId,
        categoryKey: categoryId,
        subCategoryKey: subcategoryId,
        limitKey: numberOfQuestions
      };

      if (languageId.isEmpty) {
        body.remove(languageIdKey);
      }

      if (subcategoryId.isEmpty) {
        body.remove(subCategoryKey);
      }

      if (categoryId.isEmpty) {
        body.remove(categoryKey);
      }

      final response = await http.post(
          Uri.parse(getQuestionForSelfChallengeUrl),
          body: body,
          headers: await ApiUtils.getHeaders());

      final responseJson = jsonDecode(response.body);

      if (responseJson['error']) {
        throw QuizException(errorMessageCode: responseJson['message']);
      }
      return responseJson['data'];
    } on SocketException catch (_) {
      throw QuizException(errorMessageCode: noInternetCode);
    } on QuizException catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    } catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    }
  }

  Future<dynamic> getSubCategory(String? category, String userId) async {
    try {
      //body of post request
      final body = {
        accessValueKey: accessValue,
        categoryKey: category,
        userIdKey: userId,
      };
      final response = await http.post(Uri.parse(getSubCategoryUrl),
          body: body, headers: await ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);
      if (responseJson['error']) {
        throw QuizException(errorMessageCode: responseJson['message']);
      }
      return responseJson['data'];
    } on SocketException catch (_) {
      throw QuizException(errorMessageCode: noInternetCode);
    } on QuizException catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    } catch (e) {
      throw QuizException(errorMessageCode: defaultErrorMessageCode);
    }
  }

  Future<dynamic> getUnlockedLevel(
      String? userId, String? category, String? subCategory) async {
    try {
      //body of post request
      final body = {
        accessValueKey: accessValue,
        categoryKey: category,
        userIdKey: userId,
        subCategoryKey: subCategory
      };
      final response = await http.post(Uri.parse(getLevelUrl),
          body: body, headers: await ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);
      print(responseJson);
      if (responseJson['error']) {
        throw QuizException(errorMessageCode: responseJson['message']);
      }
      return responseJson['data'];
    } on SocketException catch (_) {
      throw QuizException(errorMessageCode: noInternetCode);
    } on QuizException catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    } catch (e) {
      throw QuizException(errorMessageCode: defaultErrorMessageCode);
    }
  }

  /*
        access_key:8525
        user_id:10
        category:1
        subcategory:2
        level:1
        */

  Future<dynamic> updateLevel(
      {String? userId,
      String? category,
      String? subCategory,
      String? level}) async {
    try {
      //body of post request
      final body = {
        accessValueKey: accessValue,
        categoryKey: category,
        userIdKey: userId,
        subCategoryKey: subCategory,
        levelKey: level
      };
      final response = await http.post(Uri.parse(updateLevelUrl),
          body: body, headers: await ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);
      print(responseJson);
      if (responseJson['error']) {
        throw QuizException(errorMessageCode: responseJson['message']);
      }
      return responseJson['data'];
    } on SocketException catch (_) {
      throw QuizException(errorMessageCode: noInternetCode);
    } on QuizException catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    } catch (e) {
      throw QuizException(errorMessageCode: defaultErrorMessageCode);
    }
  }

  Future getContest(String? userId) async {
    try {
      //body of post request
      final body = {
        accessValueKey: accessValue,
        "get_contest": "1",
        userIdKey: userId
      };
      final response = await http.post(Uri.parse(getContestUrl),
          body: body, headers: await ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);
      print(responseJson);
      return (responseJson);
      // return responseJson;
    } on SocketException catch (_) {
      throw QuizException(
          errorMessageKey: notPlayedContestKey,
          errorMessageCode: notPlayedContestKey);
    } catch (e) {
      throw QuizException(
          errorMessageKey: notPlayedContestKey,
          errorMessageCode: notPlayedContestKey);
    }
  }

  Future<dynamic> setContestLeaderboard(
      {String? userId,
      String? contestId,
      int? questionAttended,
      int? correctAns,
      int? score}) async {
    try {
      //body of post request
      final body = {
        accessValueKey: accessValue,
        userIdKey: userId,
        contestIdKey: contestId,
        questionAttendedKey: questionAttended.toString(),
        correctAnswersKey: correctAns.toString(),
        scoreKey: score.toString()
      };
      final response = await http.post(Uri.parse(setContestLeaderboardUrl),
          body: body, headers: await ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);
      if (responseJson['error']) {
        throw QuizException(errorMessageCode: responseJson['message']);
      }
      return responseJson['data'];
    } on SocketException catch (_) {
      throw QuizException(errorMessageCode: noInternetCode);
    } on QuizException catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    } catch (e) {
      throw QuizException(errorMessageCode: defaultErrorMessageCode);
    }
  }

  Future<dynamic> getContestLeaderboard(
      String? contestId, String? userId) async {
    try {
      //body of post request
      final body = {
        accessValueKey: accessValue,
        userIdKey: userId,
        contestIdKey: contestId,
      };
      final response = await http.post(Uri.parse(getContestLeaderboardUrl),
          body: body, headers: await ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);
      rank = responseJson["data"][0]["user_rank"].toString();
      profile = responseJson["data"][0][profileKey].toString();
      score = responseJson["data"][0]["score"].toString();
      if (responseJson['error']) {
        throw QuizException(errorMessageCode: responseJson['message']);
      }
      return responseJson['data'];
    } on SocketException catch (_) {
      throw QuizException(errorMessageCode: noInternetCode);
    } on QuizException catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    } catch (e) {
      throw QuizException(errorMessageCode: defaultErrorMessageCode);
    }
  }

  Future<dynamic> getComprehension(
      {required String languageId,
      required String userId,
      required String type,
      required String typeId}) async {
    try {
      //body of post request
      final body = {
        accessValueKey: accessValue,
        typeKey: type,
        typeIdKey: typeId,
        userIdKey: userId,
        languageIdKey: languageId
      };
      if (languageId.isEmpty) {
        body.remove(languageIdKey);
      }
      final response = await http.post(Uri.parse(getFunAndLearnUrl),
          body: body, headers: await ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);
      if (responseJson['error']) {
        throw QuizException(errorMessageCode: responseJson['message']);
      }
      return responseJson['data'];
    } on SocketException catch (_) {
      throw QuizException(errorMessageCode: noInternetCode);
    } on QuizException catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    } catch (e) {
      throw QuizException(errorMessageCode: defaultErrorMessageCode);
    }
  }

  Future<dynamic> getComprehensionQuestion(String? funAndLearnId) async {
    print(funAndLearnId);
    try {
      //body of post request
      final body = {accessValueKey: accessValue, funAndLearnKey: funAndLearnId};
      final response = await http.post(Uri.parse(getFunAndLearnQuestionsUrl),
          body: body, headers: await ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);
      if (responseJson['error']) {
        throw QuizException(errorMessageCode: responseJson['message']);
      }

      return responseJson['data'];
    } on SocketException catch (_) {
      throw QuizException(errorMessageCode: noInternetCode);
    } on QuizException catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    } catch (e) {
      throw QuizException(errorMessageCode: defaultErrorMessageCode);
    }
  }

  //This will be in use to mark category, subcategory and fun n learn para. played
  /*
  access_key:8525
        user_id:1
        type:3      // 2-fun_n_learn, 3-guess_the_word, 4-audio_question
        category:1
        subcategory:2   //{optional}
        type_id:1       // for fun_n_learn_id
  
   */
  Future<void> setQuizCategoryPlayed(
      {required String type,
      required String userId,
      required String categoryId,
      required String subcategoryId,
      required String typeId}) async {
    try {
      //body of post request
      final body = {
        accessValueKey: accessValue,
        typeKey: type,
        typeIdKey: typeId,
        userIdKey: userId,
        categoryKey: categoryId,
        subCategoryKey: subcategoryId,
      };
      if (subcategoryId.isEmpty) {
        body.remove(subCategoryKey);
      }
      if (typeId.isEmpty) {
        body.remove(typeIdKey);
      }

      print("Set quiz category body : $body");
      final response = await http.post(Uri.parse(setQuizCategoryPlayedUrl),
          body: body, headers: await ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);
      if (responseJson['error']) {
        print(responseJson);
        throw QuizException(errorMessageCode: responseJson['message']);
      }
    } on SocketException catch (_) {
      throw QuizException(errorMessageCode: noInternetCode);
    } on QuizException catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    } catch (e) {
      throw QuizException(errorMessageCode: defaultErrorMessageCode);
    }
  }
}
