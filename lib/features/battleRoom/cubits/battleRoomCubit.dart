import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ayuprep/app/routes.dart';
import 'package:ayuprep/features/battleRoom/battleRoomRepository.dart';
import 'package:ayuprep/features/battleRoom/models/battleRoom.dart';
import 'package:ayuprep/features/quiz/models/question.dart';
import 'package:ayuprep/features/quiz/models/userBattleRoomDetails.dart';
import 'package:ayuprep/utils/constants.dart';

import 'package:ayuprep/utils/errorMessageKeys.dart';

@immutable
class BattleRoomState {}

class BattleRoomInitial extends BattleRoomState {}

class BattleRoomSearchInProgress extends BattleRoomState {}

class BattleRoomDeleted extends BattleRoomState {}

class BattleRoomJoining extends BattleRoomState {}

class BattleRoomCreating extends BattleRoomState {}

class BattleRoomCreated extends BattleRoomState {
  final BattleRoom battleRoom;
  BattleRoomCreated(this.battleRoom);
}

class BattleRoomUserFound extends BattleRoomState {
  final BattleRoom battleRoom;
  final bool hasLeft;
  final bool isRoomExist;
  final List<Question> questions;

  BattleRoomUserFound({required this.battleRoom, required this.hasLeft, required this.questions, required this.isRoomExist});
}

class BattleRoomFailure extends BattleRoomState {
  final String errorMessageCode;
  BattleRoomFailure(this.errorMessageCode);
}

class BattleRoomCubit extends Cubit<BattleRoomState> {
  final BattleRoomRepository _battleRoomRepository;
  BattleRoomCubit(this._battleRoomRepository) : super(BattleRoomInitial());

  StreamSubscription<DocumentSnapshot>? _battleRoomStreamSubscription;
  Random _rnd = Random.secure();

  void updateState(BattleRoomState newState) {
    emit(newState);
  }

  //subscribe battle room
  void subscribeToBattleRoom(String battleRoomDocumentId, List<Question> questions, bool type) {
    //for realtimeness
    _battleRoomStreamSubscription = _battleRoomRepository.subscribeToBattleRoom(battleRoomDocumentId, type).listen((event) {
      if (event.exists) {
        //emit new state
        BattleRoom battleRoom = BattleRoom.fromDocumentSnapshot(event);
        bool? userNotFound = battleRoom.user2?.uid.isEmpty;
        //if opponent userId is empty menas we have not found any user
        if (userNotFound == true) {
          //if currentRoute is not battleRoomOpponent and battle room created then we
          //have to delete the room so other user can not join the room

          //If roomCode is empty means room is created for playing random battle
          //else room is created for play with friend battle
          if (Routes.currentRoute != Routes.battleRoomFindOpponent && battleRoom.roomCode!.isEmpty) {
            deleteBattleRoom(false);
          }
          //if user not found yet
          emit(BattleRoomCreated(battleRoom));
        } else {
          emit(BattleRoomUserFound(
            battleRoom: battleRoom,
            isRoomExist: true,
            questions: questions,
            hasLeft: false,
          ));
        }
      } else {
        if (state is BattleRoomUserFound) {
          print("One of the user left the room");

          //if one of the user has left the game while playing
          emit(
            BattleRoomUserFound(battleRoom: (state as BattleRoomUserFound).battleRoom, hasLeft: true, isRoomExist: false, questions: (state as BattleRoomUserFound).questions),
          );
        }
      }
    }, onError: (e) {
      emit(BattleRoomFailure(defaultErrorMessageCode));
    }, cancelOnError: true);
  }

  void searchRoom({required String categoryId, required String name, required String profileUrl, required String uid, required String questionLanguageId}) async {
    emit(BattleRoomSearchInProgress());
    try {
      List<DocumentSnapshot> documents = await _battleRoomRepository.searchBattleRoom(
        questionLanguageId: questionLanguageId,
        categoryId: categoryId,
        name: name,
        profileUrl: profileUrl,
        uid: uid,
      );

      if (documents.isNotEmpty) {
        //find any random room
        DocumentSnapshot room = documents[Random.secure().nextInt(documents.length)];
        emit(BattleRoomJoining());
        List<Question> questions = await _battleRoomRepository.getQuestions(
          categoryId: categoryId,
          matchId: room.id,
          forMultiUser: false,
          roomDocumentId: room.id,
          languageId: questionLanguageId,
          roomCreater: false,
          destroyBattleRoom: "0",
        );
        final searchAgain = await _battleRoomRepository.joinBattleRoom(battleRoomDocumentId: room.id, name: name, profileUrl: profileUrl, uid: uid);
        if (searchAgain) {
          //if user falis to join room then searchAgain
          searchRoom(categoryId: categoryId, name: name, profileUrl: profileUrl, uid: uid, questionLanguageId: questionLanguageId);
        } else {
          subscribeToBattleRoom(room.id, questions, false);
        }
      } else {
        createRoom(categoryId: categoryId, entryFee: randomBattleEntryCoins, name: name, profileUrl: profileUrl, shouldGenerateRoomCode: false, questionLanguageId: questionLanguageId, uid: uid);
      }
    } catch (e) {
      emit(BattleRoomFailure(e.toString()));
    }
  }

  String generateRoomCode(int length) => String.fromCharCodes(Iterable.generate(length, (_) => roomCodeGenerateCharacters.codeUnitAt(_rnd.nextInt(roomCodeGenerateCharacters.length))));
  //to create room for battle
  void createRoom({required String categoryId, String? name, String? profileUrl, String? uid, int? entryFee, String? questionLanguageId, required bool shouldGenerateRoomCode}) async {
    emit(BattleRoomCreating());
    try {
      String roomCode = "";
      if (shouldGenerateRoomCode) {
        roomCode = generateRoomCode(6);
      }
      final DocumentSnapshot documentSnapshot = await _battleRoomRepository.createBattleRoom(
        categoryId: categoryId,
        name: name!,
        profileUrl: profileUrl!,
        uid: uid!,
        roomCode: roomCode,
        roomType: "public",
        entryFee: entryFee,
        questionLanguageId: questionLanguageId!,
      );

      emit(BattleRoomCreated(BattleRoom.fromDocumentSnapshot(documentSnapshot)));
      final questions = await _battleRoomRepository.getQuestions(
        categoryId: categoryId,
        forMultiUser: false,
        matchId: shouldGenerateRoomCode ? roomCode : documentSnapshot.id,
        roomDocumentId: documentSnapshot.id,
        roomCreater: true,
        languageId: questionLanguageId,
        destroyBattleRoom: "0",
      );
      subscribeToBattleRoom(documentSnapshot.id, questions, false);
    } catch (e) {
      emit(BattleRoomFailure(e.toString()));
    }
  }

  //to join battle room
  void joinRoom({String? name, String? profileUrl, String? uid, String? roomCode, required String currentCoin}) async {
    emit(BattleRoomJoining());
    try {
      final result = await _battleRoomRepository.joinBattleRoomFrd(
        name: name,
        profileUrl: profileUrl,
        roomCode: roomCode,
        uid: uid,
        currentCoin: int.parse(currentCoin),
      );
      subscribeToBattleRoom(result['roomId'], result['questions'], false);
    } catch (e) {
      emit(BattleRoomFailure(e.toString()));
    }
  }

  //this will be call when user submit answer and marked questions attempted
  //if time expired for given question then default "-1" answer will be submitted
  void updateQuestionAnswer(String? questionId, String? submittedAnswerId) {
    if (state is BattleRoomUserFound) {
      List<Question> updatedQuestions = (state as BattleRoomUserFound).questions;
      //fetching index of question that need to update with submittedAnswer
      int questionIndex = updatedQuestions.indexWhere((element) => element.id == questionId);
      //update question at given questionIndex with submittedAnswerId
      updatedQuestions[questionIndex] = updatedQuestions[questionIndex].updateQuestionWithAnswer(submittedAnswerId: submittedAnswerId!);
      emit(BattleRoomUserFound(
        isRoomExist: (state as BattleRoomUserFound).isRoomExist,
        hasLeft: (state as BattleRoomUserFound).hasLeft,
        battleRoom: (state as BattleRoomUserFound).battleRoom,
        questions: updatedQuestions,
      ));
    }
  }

  //delete room after qutting the game or finishing the game
  void deleteBattleRoom(bool type) {
    if (state is BattleRoomUserFound) {
      final battleRoom = (state as BattleRoomUserFound).battleRoom;
      _battleRoomRepository.destroyBattleRoomInDatabase(
        languageId: battleRoom.languageId!,
        categoryId: battleRoom.categoryId!,
        matchId: battleRoom.roomCode!.isEmpty ? battleRoom.roomId! : battleRoom.roomCode!,
      );
      //
      _battleRoomRepository.deleteBattleRoom(battleRoom.roomId, type);
      emit(BattleRoomDeleted());
    } else if (state is BattleRoomCreated) {
      //

      final battleRoom = (state as BattleRoomCreated).battleRoom;
      _battleRoomRepository.destroyBattleRoomInDatabase(
        languageId: battleRoom.languageId!,
        categoryId: battleRoom.categoryId!,
        matchId: battleRoom.roomCode!.isEmpty ? battleRoom.roomId! : battleRoom.roomCode!,
      );
      _battleRoomRepository.deleteBattleRoom(battleRoom.roomId, type);
      emit(BattleRoomDeleted());
    }
  }

  void removeOpponentFromBattleRoom() {
    if (state is BattleRoomUserFound) {
      _battleRoomRepository.removeOpponentFromBattleRoom((state as BattleRoomUserFound).battleRoom.roomId!);
    }
  }

  void startGame() {
    if (state is BattleRoomUserFound) {
      _battleRoomRepository.startMultiUserQuiz((state as BattleRoomUserFound).battleRoom.roomId, "battle");
    }
  }

  //get questions in quiz battle
  int getEntryFee() {
    if (state is BattleRoomUserFound) {
      return (state as BattleRoomUserFound).battleRoom.entryFee!;
    }
    if (state is BattleRoomCreated) {
      return (state as BattleRoomCreated).battleRoom.entryFee!;
    }
    return 0;
  }

  //get questions in quiz battle
  String getRoomCode() {
    if (state is BattleRoomUserFound) {
      return (state as BattleRoomUserFound).battleRoom.roomCode!;
    }
    if (state is BattleRoomCreated) {
      return (state as BattleRoomCreated).battleRoom.roomCode!;
    }
    return "";
  }

  //submit anser
  void submitAnswer(String? currentUserId, String? submittedAnswer, bool isCorrectAnswer, int points) {
    if (state is BattleRoomUserFound) {
      BattleRoom battleRoom = (state as BattleRoomUserFound).battleRoom;
      List<Question>? questions = (state as BattleRoomUserFound).questions;

      //need to check submitting answer for user1 or user2
      if (currentUserId == battleRoom.user1!.uid) {
        if (battleRoom.user1!.answers.length != questions.length) {
          _battleRoomRepository.submitAnswer(
            battleRoomDocumentId: battleRoom.roomId,
            points: isCorrectAnswer ? (battleRoom.user1!.points + points) : battleRoom.user1!.points,
            forUser1: true,
            submittedAnswer: List.from(battleRoom.user1!.answers)..add(submittedAnswer),
          );
        }
      } else {
        //submit answer for user2
        if (battleRoom.user2!.answers.length != questions.length) {
          _battleRoomRepository.submitAnswer(
            submittedAnswer: List.from(battleRoom.user2!.answers)..add(submittedAnswer),
            battleRoomDocumentId: battleRoom.roomId,
            points: isCorrectAnswer ? (battleRoom.user2!.points + points) : battleRoom.user2!.points,
            forUser1: false,
          );
        }
      }
    }
  }

  //currentQuestionIndex will be same as given answers length(since index start with 0 in arrary)
  int getCurrentQuestionIndex() {
    if (state is BattleRoomUserFound) {
      final currentState = (state as BattleRoomUserFound);
      int currentQuestionIndex;

      //if both users has submitted answer means currentQuestionIndex will be
      //as (answers submitted by users) + 1
      if (currentState.battleRoom.user1!.answers.length == currentState.battleRoom.user2!.answers.length) {
        currentQuestionIndex = currentState.battleRoom.user1!.answers.length;
      } else if (currentState.battleRoom.user1!.answers.length < currentState.battleRoom.user2!.answers.length) {
        currentQuestionIndex = currentState.battleRoom.user1!.answers.length;
      } else {
        currentQuestionIndex = currentState.battleRoom.user2!.answers.length;
      }

      //need to decrease index by one in order to remove index out of range error
      //after game has finished
      if (currentQuestionIndex == currentState.questions.length) {
        currentQuestionIndex--;
      }
      return currentQuestionIndex;
    }

    return 0;
  }

  //get questions in quiz battle
  List<Question> getQuestions() {
    if (state is BattleRoomUserFound) {
      return (state as BattleRoomUserFound).questions;
    }
    return [];
  }

  String getRoomId() {
    if (state is BattleRoomUserFound) {
      return (state as BattleRoomUserFound).battleRoom.roomId!;
    }
    if (state is BattleRoomCreated) {
      return (state as BattleRoomCreated).battleRoom.roomId!;
    }
    return "";
  }

  UserBattleRoomDetails getCurrentUserDetails(String currentUserId) {
    if (state is BattleRoomUserFound) {
      if (currentUserId == (state as BattleRoomUserFound).battleRoom.user1?.uid) {
        print((state as BattleRoomUserFound).battleRoom.user1!);
        return (state as BattleRoomUserFound).battleRoom.user1!;
      } else {
        print((state as BattleRoomUserFound).battleRoom.user2!);
        return (state as BattleRoomUserFound).battleRoom.user2!;
      }
    }
    return UserBattleRoomDetails(answers: [], correctAnswers: 0, name: "name", profileUrl: "profileUrl", uid: "uid", points: 0);
  }

  UserBattleRoomDetails getOpponentUserDetails(String currentUserId) {
    if (state is BattleRoomUserFound) {
      if (currentUserId == (state as BattleRoomUserFound).battleRoom.user1?.uid) {
        print((state as BattleRoomUserFound).battleRoom.user2!);
        return (state as BattleRoomUserFound).battleRoom.user2!;
      } else {
        return (state as BattleRoomUserFound).battleRoom.user1!;
      }
    }
    return UserBattleRoomDetails(points: 0, answers: [], correctAnswers: 0, name: "name", profileUrl: "profileUrl", uid: "uid");
  }

  bool opponentLeftTheGame(String userId) {
    if (state is BattleRoomUserFound) {
      print((state as BattleRoomUserFound).hasLeft);
      print("User submitted answer ${getCurrentUserDetails(userId).answers.length}");
      return (state as BattleRoomUserFound).hasLeft && getCurrentUserDetails(userId).answers.length != (state as BattleRoomUserFound).questions.length;
    }
    print("State is not battle user found");
    return false;
  }

  List<UserBattleRoomDetails?> getUsers() {
    if (state is BattleRoomUserFound) {
      List<UserBattleRoomDetails?> users = [];
      BattleRoom battleRoom = (state as BattleRoomUserFound).battleRoom;
      if (battleRoom.user1!.uid.isNotEmpty) {
        users.add(battleRoom.user1);
      }
      if (battleRoom.user2!.uid.isNotEmpty) {
        users.add(battleRoom.user2);
      }

      return users;
    }
    return [];
  }

  //to close the stream subsciption
  @override
  Future<void> close() async {
    await _battleRoomStreamSubscription?.cancel();
    return super.close();
  }
}
