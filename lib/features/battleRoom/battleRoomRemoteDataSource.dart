import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/services.dart';
import 'package:ayuprep/features/battleRoom/battleRoomExecption.dart';
import 'package:ayuprep/utils/apiBodyParameterLabels.dart';

import 'package:ayuprep/utils/apiUtils.dart';
import 'package:ayuprep/utils/constants.dart';
import 'package:ayuprep/utils/errorMessageKeys.dart';
import 'package:ayuprep/utils/internetConnectivity.dart';

import 'package:http/http.dart' as http;

class BattleRoomRemoteDataSource {
  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  //While starting app
  static Future<void> deleteBattleRoomCreatedByUser(
      String currentUserId) async {
    FirebaseFirestore.instance
        .collection(battleRoomCollection)
        .get()
        .then((value) => null);
  }

  /*
  access_key:8525
	match_id:your_match_id
	language_id:2   //{optional}
  category:1 
  */

  Future<List?> getQuestions(
      {required String languageId,
      required String categoryId,
      required String matchId,
      required String destroyRoom}) async {
    try {
      Map<String, String> body = {
        accessValueKey: accessValue,
        languageIdKey: languageId,
        matchIdKey: matchId,
        categoryKey: categoryId,
        destroyRoomKey: destroyRoom, //0 do not destroy and 1 destroy
      };
      if (categoryId.isEmpty) {
        body.remove(categoryKey);
      }
      if (languageId.isEmpty) {
        body.remove(languageIdKey);
      }

      final response = await http.post(Uri.parse(getQuestionForOneToOneBattle),
          body: body, headers: await ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);

      if (responseJson['error']) {
        throw BattleRoomException(
            errorMessageCode: responseJson['message']); //error
      }
      return responseJson['data'];
    } on SocketException catch (_) {
      throw BattleRoomException(errorMessageCode: noInternetCode);
    } on BattleRoomException catch (e) {
      throw BattleRoomException(errorMessageCode: e.toString());
    } catch (e) {
      throw BattleRoomException(errorMessageCode: defaultErrorMessageCode);
    }
  }

  Future<List?> getMultiUserBattleQuestions(String? roomCode) async {
    try {
      Map<String, String?> body = {
        accessValueKey: accessValue,
        roomIdKey: roomCode
      };

      final response = await http.post(Uri.parse(getQuestionForMultiUserBattle),
          body: body, headers: await ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);
      if (responseJson['error']) {
        throw BattleRoomException(
            errorMessageCode: responseJson['message']); //error
      }
      return responseJson['data'];
    } on SocketException catch (_) {
      throw BattleRoomException(errorMessageCode: noInternetCode);
    } on BattleRoomException catch (e) {
      throw BattleRoomException(errorMessageCode: e.toString());
    } catch (e) {
      throw BattleRoomException(errorMessageCode: defaultErrorMessageCode);
    }
  }

  //subscribe to battle room
  Stream<DocumentSnapshot> subscribeToBattleRoom(
      String? battleRoomDocumentId, bool forMultiUser) {
    if (forMultiUser) {
      return _firebaseFirestore
          .collection(multiUserBattleRoomCollection)
          .doc(battleRoomDocumentId)
          .snapshots();
    }
    return _firebaseFirestore
        .collection(battleRoomCollection)
        .doc(battleRoomDocumentId)
        .snapshots();
  }

  Future<void> removeOpponentFromBattleRoom(String roomId) async {
    try {
      await _firebaseFirestore
          .collection(battleRoomCollection)
          .doc(roomId)
          .update({
        "user2": {
          "name": "",
          "correctAnswers": 0,
          "answers": [],
          "uid": "",
          "profileUrl": ""
        },
      });
    } on SocketException catch (_) {
      throw BattleRoomException(errorMessageCode: noInternetCode);
    } on PlatformException catch (_) {
      throw BattleRoomException(errorMessageCode: defaultErrorMessageCode);
    } catch (_) {
      throw BattleRoomException(errorMessageCode: defaultErrorMessageCode);
    }
  }

  //to find room to play quiz
  Future<List<DocumentSnapshot>> searchBattleRoom(
      String categoryId, String questionLanguageId) async {
    try {
      QuerySnapshot querySnapshot;
      if (await InternetConnectivity.isUserOffline()) {
        throw SocketException("");
      }

      querySnapshot = await _firebaseFirestore
          .collection(battleRoomCollection)
          .where("languageId", isEqualTo: questionLanguageId)
          .where("categoryId", isEqualTo: categoryId)
          .where("roomCode", isEqualTo: "")
          .where(
            "user2.uid",
            isEqualTo: "",
          )
          .get();

      return querySnapshot.docs;
    } on SocketException catch (_) {
      throw BattleRoomException(errorMessageCode: noInternetCode);
    } on PlatformException catch (_) {
      throw BattleRoomException(errorMessageCode: unableToFindRoomCode);
    } catch (_) {
      throw BattleRoomException(errorMessageCode: defaultErrorMessageCode);
    }
  }

  //delete battle room
  Future<void> deleteBattleRoom(String? documentId, bool forMultiUser,
      {String? roomCode}) async {
    try {
      if (forMultiUser) {
        Map<String, String> body = {
          accessValueKey: accessValue,
          roomIdKey: roomCode!,
        };
        await _firebaseFirestore
            .collection(multiUserBattleRoomCollection)
            .doc(documentId)
            .delete();
        await http.post(Uri.parse(deleteMultiUserBattleRoom),
            body: body, headers: await ApiUtils.getHeaders());
        print("Room deleted successfully");
      } else {
        await _firebaseFirestore
            .collection(battleRoomCollection)
            .doc(documentId)
            .delete();
      }
    } on SocketException catch (_) {
      throw BattleRoomException(errorMessageCode: noInternetCode);
    } on PlatformException catch (_) {
      throw BattleRoomException(errorMessageCode: defaultErrorMessageCode);
    } catch (_) {
      throw BattleRoomException(errorMessageCode: defaultErrorMessageCode);
    }
  }

  //get battle room
  Future<Map<String, List<DocumentSnapshot>>> getRoomCreatedByUser(
      String userId) async {
    try {
      QuerySnapshot multiUserBattleQuerySnapshot = await _firebaseFirestore
          .collection(multiUserBattleRoomCollection)
          .where("createdBy", isEqualTo: userId)
          .get();
      QuerySnapshot battleQuerySnapshot = await _firebaseFirestore
          .collection(battleRoomCollection)
          .where("createdBy", isEqualTo: userId)
          .get();

      return {
        "battle": battleQuerySnapshot.docs,
        "groupBattle": multiUserBattleQuerySnapshot.docs
      };
    } on SocketException catch (_) {
      throw BattleRoomException(errorMessageCode: noInternetCode);
    } on PlatformException catch (_) {
      throw BattleRoomException(errorMessageCode: defaultErrorMessageCode);
    } catch (_) {
      throw BattleRoomException(errorMessageCode: defaultErrorMessageCode);
    }
  }

  //to create room to play quiz
  Future<DocumentSnapshot> createBattleRoom({
    required String categoryId,
    required String name,
    required String profileUrl,
    required String uid,
    String? roomCode,
    String? roomType,
    int? entryFee,
    required String questionLanguageId,
  }) async {
    try {
      //hasLeft,categoryId
      DocumentReference documentReference =
          await _firebaseFirestore.collection(battleRoomCollection).add({
        "createdBy": uid,
        "categoryId": categoryId,
        "languageId": questionLanguageId,
        "roomCode": roomCode ?? "",
        "entryFee": entryFee ?? 0,
        "readyToPlay": false,
        "user1": {
          "name": name,
          "points": 0,
          "answers": [],
          "uid": uid,
          "profileUrl": profileUrl
        },
        "user2": {
          "name": "",
          "points": 0,
          "answers": [],
          "uid": "",
          "profileUrl": ""
        },
        "createdAt": Timestamp.now(),
      });
      return await documentReference.get();
    } on SocketException catch (_) {
      throw BattleRoomException(errorMessageCode: noInternetCode);
    } on PlatformException catch (_) {
      throw BattleRoomException(errorMessageCode: unableToCreateRoomCode);
    } catch (_) {
      throw BattleRoomException(errorMessageCode: defaultErrorMessageCode);
    }
  }

  //create mutliUserBattleRoom
  Future<DocumentSnapshot> createMutliUserBattleRoom(
      {required String categoryId,
      String? name,
      String? profileUrl,
      String? uid,
      String? roomCode,
      String? roomType,
      int? entryFee,
      String? questionLanguageId}) async {
    try {
      Map<String, String> body = {
        accessValueKey: accessValue,
        userIdKey: uid!,
        roomIdKey: roomCode!,
        roomTypeKey: roomType!,
        categoryKey: categoryId,
        numberOfQuestionsKey: "10",
        languageIdKey: questionLanguageId!
      };
      if (categoryId.isEmpty) {
        body.remove(categoryKey);
      }
      if (questionLanguageId.isEmpty) {
        body.remove(languageIdKey);
      }
      final response = await http.post(Uri.parse(createMultiUserBattleRoom),
          body: body, headers: await ApiUtils.getHeaders());

      final responseJson = jsonDecode(response.body);

      if (responseJson['error']) {
        throw BattleRoomException(
            errorMessageCode: responseJson['message']); //error
      }

      DocumentReference documentReference = await _firebaseFirestore
          .collection(multiUserBattleRoomCollection)
          .add({
        "createdBy": uid,
        "categoryId": categoryId,
        "roomCode": roomCode,
        "entryFee": entryFee,
        "readyToPlay": false,
        "user1": {
          "name": name,
          "correctAnswers": 0,
          "answers": [],
          "uid": uid,
          "profileUrl": profileUrl
        },
        "user2": {
          "name": "",
          "correctAnswers": 0,
          "answers": [],
          "uid": "",
          "profileUrl": ""
        },
        "user3": {
          "name": "",
          "correctAnswers": 0,
          "answers": [],
          "uid": "",
          "profileUrl": ""
        },
        "user4": {
          "name": "",
          "correctAnswers": 0,
          "answers": [],
          "uid": "",
          "profileUrl": ""
        },
        "createdAt": Timestamp.now(),
      });
      return documentReference.get();
    } on SocketException catch (_) {
      throw BattleRoomException(errorMessageCode: noInternetCode);
    } on PlatformException catch (_) {
      throw BattleRoomException(errorMessageCode: unableToCreateRoomCode);
    } on BattleRoomException catch (e) {
      throw BattleRoomException(errorMessageCode: e.toString());
    } catch (_) {
      throw BattleRoomException(errorMessageCode: defaultErrorMessageCode);
    }
  }

  //to create room to play quiz
  Future<bool> joinBattleRoom(
      {String? name,
      String? profileUrl,
      String? uid,
      String? battleRoomDocumentId}) async {
    try {
      DocumentReference documentReference = (await _firebaseFirestore
              .collection(battleRoomCollection)
              .doc(battleRoomDocumentId)
              .get())
          .reference;
      print("Join user here ");
      return FirebaseFirestore.instance.runTransaction((transaction) async {
        //get latest document
        DocumentSnapshot documentSnapshot = await documentReference.get();
        Map user2Details =
            Map.from(documentSnapshot.data() as Map<String, dynamic>)['user2'];
        print("User 2 : $user2Details");
        if (user2Details['uid'].toString().isEmpty) {
          //print("Join user");
          //join as user2
          transaction.update(documentReference, {
            "user2.name": name,
            "user2.uid": uid,
            "user2.profileUrl": profileUrl,
          });
          return false;
        }
        return true; //search for other room
      });
    } on SocketException catch (_) {
      throw BattleRoomException(errorMessageCode: noInternetCode);
    } on PlatformException catch (_) {
      throw BattleRoomException(errorMessageCode: unableToJoinRoomCode);
    } catch (_) {
      throw BattleRoomException(errorMessageCode: defaultErrorMessageCode);
    }
  }

  //get room by roomCode (multiUserBattleRoom)
  Future<QuerySnapshot> getMultiUserBattleRoom(
      String? roomCode, String? type) async {
    try {
      QuerySnapshot querySnapshot = await _firebaseFirestore
          .collection(type == "battle"
              ? battleRoomCollection
              : multiUserBattleRoomCollection)
          .where("roomCode", isEqualTo: roomCode)
          .get();
      return querySnapshot;
    } on SocketException catch (_) {
      throw BattleRoomException(errorMessageCode: noInternetCode);
    } on PlatformException catch (_) {
      throw BattleRoomException(errorMessageCode: unableToFindRoomCode);
    } catch (_) {
      throw BattleRoomException(errorMessageCode: defaultErrorMessageCode);
    }
  }

  //submit answer
  Future<void> submitAnswer(
      {required Map<String, dynamic> submitAnswer,
      String? battleRoomDocumentId,
      required bool forMultiUser}) async {
    try {
      if (forMultiUser) {
        await _firebaseFirestore
            .collection(multiUserBattleRoomCollection)
            .doc(battleRoomDocumentId)
            .update(submitAnswer);
      } else {
        await _firebaseFirestore
            .collection(battleRoomCollection)
            .doc(battleRoomDocumentId)
            .update(submitAnswer);
      }
    } on SocketException catch (_) {
      throw BattleRoomException(errorMessageCode: noInternetCode);
    } on PlatformException catch (_) {
      throw BattleRoomException(errorMessageCode: unableToSubmitAnswerCode);
    } catch (_) {
      throw BattleRoomException(errorMessageCode: defaultErrorMessageCode);
    }
  }

  //delete user from multiple user room
  Future<void> updateMultiUserRoom(String? documentId,
      Map<String, dynamic> updatedData, String battle) async {
    try {
      _firebaseFirestore
          .collection(battle == "battle"
              ? battleRoomCollection
              : multiUserBattleRoomCollection)
          .doc(documentId)
          .update(updatedData);
    } on SocketException catch (_) {
      throw BattleRoomException(errorMessageCode: noInternetCode);
    } on PlatformException catch (_) {
      throw BattleRoomException(errorMessageCode: defaultErrorMessageCode);
    } catch (_) {
      throw BattleRoomException(errorMessageCode: defaultErrorMessageCode);
    }
  }

  //All the message related code start from here

  //subscribe to messages in room
  Stream<QuerySnapshot> subscribeToMessages({required String roomId}) {
    return _firebaseFirestore
        .collection(messagesCollection)
        .where("roomId", isEqualTo: roomId)
        .orderBy(
          "timestamp",
          descending: true,
        )
        .snapshots();
  }

  //add message
  Future<String> addMessage(Map<String, dynamic> data) async {
    try {
      DocumentReference documentReference =
          await _firebaseFirestore.collection(messagesCollection).add(data);

      return documentReference.id;
    } on SocketException catch (_) {
      throw BattleRoomException(errorMessageCode: noInternetCode);
    } on PlatformException catch (_) {
      throw BattleRoomException(errorMessageCode: defaultErrorMessageCode);
    } catch (_) {
      throw BattleRoomException(errorMessageCode: defaultErrorMessageCode);
    }
  }

  //delete message
  Future<void> deleteMessage(String messageId) async {
    try {
      _firebaseFirestore.collection(messagesCollection).doc(messageId).delete();
    } on SocketException catch (_) {
      throw BattleRoomException(errorMessageCode: noInternetCode);
    } on PlatformException catch (_) {
      throw BattleRoomException(errorMessageCode: defaultErrorMessageCode);
    } catch (_) {
      throw BattleRoomException(errorMessageCode: defaultErrorMessageCode);
    }
  }

  //to get all messages by it's roomId
  Future<List<DocumentSnapshot>> getMessagesByUserId(
      String roomId, String by) async {
    try {
      QuerySnapshot querySnapshot = await _firebaseFirestore
          .collection(messagesCollection)
          .where("roomId", isEqualTo: roomId)
          .where("by", isEqualTo: by)
          .get();
      return querySnapshot.docs;
    } on SocketException catch (_) {
      throw BattleRoomException(errorMessageCode: noInternetCode);
    } on PlatformException catch (_) {
      throw BattleRoomException(errorMessageCode: defaultErrorMessageCode);
    } catch (_) {
      throw BattleRoomException(errorMessageCode: defaultErrorMessageCode);
    }
  }
}
