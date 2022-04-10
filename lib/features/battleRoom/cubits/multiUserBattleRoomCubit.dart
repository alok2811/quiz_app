import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ayuprep/features/battleRoom/battleRoomRepository.dart';
import 'package:ayuprep/features/battleRoom/models/battleRoom.dart';
import 'package:ayuprep/features/quiz/models/question.dart';
import 'package:ayuprep/features/quiz/models/userBattleRoomDetails.dart';
import 'package:ayuprep/utils/constants.dart';

import 'package:ayuprep/utils/errorMessageKeys.dart';

@immutable
class MultiUserBattleRoomState {}

class MultiUserBattleRoomInitial extends MultiUserBattleRoomState {}

class MultiUserBattleRoomInProgress extends MultiUserBattleRoomState {}

class MultiUserBattleRoomSuccess extends MultiUserBattleRoomState {
  final BattleRoom battleRoom;

  final bool isRoomExist;
  final List<Question> questions;
  MultiUserBattleRoomSuccess({required this.battleRoom, required this.isRoomExist, required this.questions});
}

class MultiUserBattleRoomFailure extends MultiUserBattleRoomState {
  final String errorMessageCode;

  MultiUserBattleRoomFailure(this.errorMessageCode);
}

class MultiUserBattleRoomCubit extends Cubit<MultiUserBattleRoomState> {
  final BattleRoomRepository _battleRoomRepository;
  MultiUserBattleRoomCubit(this._battleRoomRepository) : super(MultiUserBattleRoomInitial());

  StreamSubscription<DocumentSnapshot>? _battleRoomStreamSubscription;

  Random _rnd = Random.secure();

  void updateState(MultiUserBattleRoomState newState) {
    emit(newState);
  }

  //subscribe battle room
  void subscribeToMultiUserBattleRoom(String battleRoomDocumentId, List<Question> questions) {
    //for realtimeness
    _battleRoomStreamSubscription = _battleRoomRepository.subscribeToBattleRoom(battleRoomDocumentId, true).listen((event) {
      //to check if room destroyed by owner
      if (event.exists) {
        emit(MultiUserBattleRoomSuccess(
          battleRoom: BattleRoom.fromDocumentSnapshot(event),
          isRoomExist: true,
          questions: questions,
        ));
      } else {
        //update state with room does not exist
        emit(
          MultiUserBattleRoomSuccess(battleRoom: (state as MultiUserBattleRoomSuccess).battleRoom, isRoomExist: false, questions: (state as MultiUserBattleRoomSuccess).questions),
        );
      }
    }, onError: (e) {
      emit(MultiUserBattleRoomFailure(defaultErrorMessageCode));
    }, cancelOnError: true);
  }

  //to create room for multiuser
  void createRoom({required String categoryId, String? name, String? profileUrl, String? uid, String? roomType, int? entryFee, String? questionLanguageId}) async {
    emit(MultiUserBattleRoomInProgress());
    try {
      String roomCode = generateRoomCode(6);
      final DocumentSnapshot documentSnapshot = await _battleRoomRepository.createMultiUserBattleRoom(
        categoryId: categoryId,
        name: name,
        profileUrl: profileUrl,
        uid: uid,
        roomCode: roomCode,
        roomType: "public",
        entryFee: entryFee,
        questionLanguageId: questionLanguageId,
      );
      final questions = await _battleRoomRepository.getQuestions(
        categoryId: "",
        forMultiUser: true,
        matchId: roomCode,
        roomDocumentId: documentSnapshot.id,
        roomCreater: true,
        languageId: questionLanguageId!,
      );
      subscribeToMultiUserBattleRoom(documentSnapshot.id, questions);
    } catch (e) {
      emit(MultiUserBattleRoomFailure(e.toString()));
    }
  }

  //to join multi user battle room
  void joinRoom({String? name, String? profileUrl, String? uid, String? roomCode, required String currentCoin}) async {
    emit(MultiUserBattleRoomInProgress());
    try {
      final result = await _battleRoomRepository.joinMultiUserBattleRoom(
        name: name,
        profileUrl: profileUrl,
        roomCode: roomCode,
        uid: uid,
        currentCoin: int.parse(currentCoin),
      );

      subscribeToMultiUserBattleRoom(result['roomId'], result['questions']);
    } catch (e) {
      emit(MultiUserBattleRoomFailure(e.toString()));
    }
  }

  //this will be call when user submit answer and marked questions attempted
  //if time expired for given question then default "-1" answer will be submitted
  void updateQuestionAnswer(String questionId, String submittedAnswerId) {
    if (state is MultiUserBattleRoomSuccess) {
      List<Question> updatedQuestions = (state as MultiUserBattleRoomSuccess).questions;
      //fetching index of question that need to update with submittedAnswer
      int questionIndex = updatedQuestions.indexWhere((element) => element.id == questionId);
      //update question at given questionIndex with submittedAnswerId
      updatedQuestions[questionIndex] = updatedQuestions[questionIndex].updateQuestionWithAnswer(submittedAnswerId: submittedAnswerId);
      emit(MultiUserBattleRoomSuccess(isRoomExist: (state as MultiUserBattleRoomSuccess).isRoomExist, battleRoom: (state as MultiUserBattleRoomSuccess).battleRoom, questions: updatedQuestions));
    }
  }

  //delete room after qutting the game or finishing the game
  void deleteMultiUserBattleRoom() {
    if (state is MultiUserBattleRoomSuccess) {
      _battleRoomRepository.deleteBattleRoom(
        (state as MultiUserBattleRoomSuccess).battleRoom.roomId,
        true,
        roomCode: (state as MultiUserBattleRoomSuccess).battleRoom.roomCode,
      );
    }
  }

  void deleteUserFromRoom(String userId) {
    if (state is MultiUserBattleRoomSuccess) {
      BattleRoom battleRoom = (state as MultiUserBattleRoomSuccess).battleRoom;
      if (userId == battleRoom.user1!.uid) {
        _battleRoomRepository.deleteUserFromRoom(1, battleRoom);
      } else if (userId == battleRoom.user2!.uid) {
        _battleRoomRepository.deleteUserFromRoom(2, battleRoom);
      } else if (userId == battleRoom.user3!.uid) {
        _battleRoomRepository.deleteUserFromRoom(3, battleRoom);
      } else {
        _battleRoomRepository.deleteUserFromRoom(4, battleRoom);
      }
    }
  }

  void startGame() {
    if (state is MultiUserBattleRoomSuccess) {
      _battleRoomRepository.startMultiUserQuiz((state as MultiUserBattleRoomSuccess).battleRoom.roomId, "");
    }
  }

  //submit anser
  void submitAnswer(String currentUserId, String submittedAnswer, bool isCorrectAnswer) {
    if (state is MultiUserBattleRoomSuccess) {
      BattleRoom battleRoom = (state as MultiUserBattleRoomSuccess).battleRoom;
      List<Question> questions = (state as MultiUserBattleRoomSuccess).questions;

      //need to check submitting answer for user1
      if (currentUserId == battleRoom.user1!.uid) {
        if (battleRoom.user1!.answers.length != questions.length) {
          _battleRoomRepository.submitAnswerForMultiUserBattleRoom(
              battleRoomDocumentId: battleRoom.roomId,
              correctAnswers: isCorrectAnswer ? (battleRoom.user1!.correctAnswers + 1) : battleRoom.user1!.correctAnswers,
              userNumber: "1",
              submittedAnswer: List.from(battleRoom.user1!.answers)..add(submittedAnswer));
        }
      } else if (currentUserId == battleRoom.user2!.uid) {
        //submit answer for user2
        if (battleRoom.user2!.answers.length != questions.length) {
          _battleRoomRepository.submitAnswerForMultiUserBattleRoom(
              submittedAnswer: List.from(battleRoom.user2!.answers)..add(submittedAnswer),
              battleRoomDocumentId: battleRoom.roomId,
              correctAnswers: isCorrectAnswer ? (battleRoom.user2!.correctAnswers + 1) : battleRoom.user2!.correctAnswers,
              userNumber: "2");
        }
      } else if (currentUserId == battleRoom.user3!.uid) {
        //submit answer for user3
        if (battleRoom.user3!.answers.length != questions.length) {
          _battleRoomRepository.submitAnswerForMultiUserBattleRoom(
              submittedAnswer: List.from(battleRoom.user3!.answers)..add(submittedAnswer),
              battleRoomDocumentId: battleRoom.roomId,
              correctAnswers: isCorrectAnswer ? (battleRoom.user3!.correctAnswers + 1) : battleRoom.user3!.correctAnswers,
              userNumber: "3");
        }
      } else {
        //submit answer for user4
        if (battleRoom.user4!.answers.length != questions.length) {
          _battleRoomRepository.submitAnswerForMultiUserBattleRoom(
              submittedAnswer: List.from(battleRoom.user4!.answers)..add(submittedAnswer),
              battleRoomDocumentId: battleRoom.roomId,
              correctAnswers: isCorrectAnswer ? (battleRoom.user4!.correctAnswers + 1) : battleRoom.user4!.correctAnswers,
              userNumber: "4");
        }
      }
    }
  }

  //get questions in quiz battle
  List<Question> getQuestions() {
    if (state is MultiUserBattleRoomSuccess) {
      return (state as MultiUserBattleRoomSuccess).questions;
    }
    return [];
  }

  String getRoomCode() {
    if (state is MultiUserBattleRoomSuccess) {
      return (state as MultiUserBattleRoomSuccess).battleRoom.roomCode!;
    }
    return "";
  }

  String getRoomId() {
    if (state is MultiUserBattleRoomSuccess) {
      return (state as MultiUserBattleRoomSuccess).battleRoom.roomId!;
    }
    return "";
  }

  //get questions in quiz battle
  int getEntryFee() {
    if (state is MultiUserBattleRoomSuccess) {
      return (state as MultiUserBattleRoomSuccess).battleRoom.entryFee!;
    }
    return 0;
  }

  List<UserBattleRoomDetails?> getUsers() {
    if (state is MultiUserBattleRoomSuccess) {
      List<UserBattleRoomDetails?> users = [];
      BattleRoom battleRoom = (state as MultiUserBattleRoomSuccess).battleRoom;
      if (battleRoom.user1!.uid.isNotEmpty) {
        users.add(battleRoom.user1);
      }
      if (battleRoom.user2!.uid.isNotEmpty) {
        users.add(battleRoom.user2);
      }
      if (battleRoom.user3!.uid.isNotEmpty) {
        users.add(battleRoom.user3);
      }
      if (battleRoom.user4!.uid.isNotEmpty) {
        users.add(battleRoom.user4);
      }

      return users;
    }
    return [];
  }

  UserBattleRoomDetails? getUser(String userId) {
    final users = getUsers();
    return users[users.indexWhere((element) => element!.uid == userId)];
  }

  List<UserBattleRoomDetails?> getOpponentUsers(String userId) {
    final users = getUsers();
    users.removeWhere((element) => element!.uid == userId);
    return users;
  }

  String generateRoomCode(int length) => String.fromCharCodes(Iterable.generate(length, (_) => roomCodeGenerateCharacters.codeUnitAt(_rnd.nextInt(roomCodeGenerateCharacters.length))));

  //to close the stream subsciption
  @override
  Future<void> close() async {
    await _battleRoomStreamSubscription?.cancel();
    return super.close();
  }
}
