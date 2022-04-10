import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ayuprep/features/quiz/models/question.dart';
import 'package:ayuprep/features/tournament/model/tournamentBattle.dart';
import 'package:ayuprep/features/tournament/model/tournamentPlayerDetails.dart';
import 'package:ayuprep/features/tournament/tournamentRepository.dart';

abstract class TournamentBattleState {}

class TournamentBattleInitial extends TournamentBattleState {}

class TournamentBattleSearchInProgress extends TournamentBattleState {}

class TournamentBattleCreationInProgress extends TournamentBattleState {
  final TournamentBattleType tournamentBattleType;
  TournamentBattleCreationInProgress(this.tournamentBattleType);
}

class TournamentBattleJoinInProgress extends TournamentBattleState {
  final TournamentBattleType tournamentBattleType;
  TournamentBattleJoinInProgress(this.tournamentBattleType);
}

class TournamentBattleJoinSuccess extends TournamentBattleState {
  final TournamentBattle tournamentBattle;
  TournamentBattleJoinSuccess(this.tournamentBattle);
}

class TournamentBattleCreationSuccess extends TournamentBattleState {
  final TournamentBattle tournamentBattle;
  TournamentBattleCreationSuccess(this.tournamentBattle);
}

class TournamentBattleCreationFailure extends TournamentBattleState {
  final String errorCode;
  TournamentBattleCreationFailure(this.errorCode);
}

class TournamentBattleJoinFailure extends TournamentBattleState {
  final String errorCode;
  TournamentBattleJoinFailure(this.errorCode);
}

class TournamentBattleFailure extends TournamentBattleState {
  final String errorCode;
  TournamentBattleFailure(this.errorCode);
}

class TournamentBattleStarted extends TournamentBattleState {
  final TournamentBattle tournamentBattle;
  final bool hasLeft;
  final List<Question> questions;
  TournamentBattleStarted({required this.tournamentBattle, required this.hasLeft, required this.questions});
}

class TournamentBattleCubit extends Cubit<TournamentBattleState> {
  final TournamentRepository _tournamentRepository;
  TournamentBattleCubit(this._tournamentRepository) : super(TournamentBattleInitial());

  StreamSubscription<DocumentSnapshot>? _tournamentBattleSubscription;

  void _subscribeTournamentBattle({required String tournamentBattleId, required String uid}) {
    _tournamentBattleSubscription = _tournamentRepository.listenToTournamentBattleUpdates(tournamentBattleId).listen((event) {
      if (event.exists) {
        TournamentBattle tournamentBattle = TournamentBattle.fromDocumentSnapshot(event);

        //if tournament battle is quater final
        if (tournamentBattle.battleType == TournamentBattleType.quaterFinal) {
          //need to check if question is available or not
          //person who creates the tournament battle will fetch the question

          //Initially readyToPlay is false once other user will join the tournament battle
          //he/she will start tournament battle
          //
          //if it is not ready to play
          //
          if (!tournamentBattle.readyToPlay) {
            // start tournament battle or quater final
            if (tournamentBattle.createdBy != uid) {
              _tournamentRepository.startTournamentBattle(tournamentBattleId);
            }
          } else {
            //

            emit(TournamentBattleStarted(
              hasLeft: false,
              tournamentBattle: tournamentBattle,
              //Since we are storing questions in firebase document so only assign
              //question first time

              //if state is TournamentBattleStarted means questions already been assigned
              //else assign question from tournament battle (from firebase document)
              questions: state is TournamentBattleStarted ? (state as TournamentBattleStarted).questions : tournamentBattle.questions,
            ));
          }
        } else if (tournamentBattle.battleType == TournamentBattleType.semiFinal) {
          //
          if (tournamentBattle.readyToPlay) {
            //start the tournament
            emit(TournamentBattleStarted(
              hasLeft: false,
              tournamentBattle: tournamentBattle,
              //Since we are storing questions in firebase document so only assign
              //question first time

              //if state is TournamentBattleStarted means questions already been assigned
              //else assign question from tournament battle (from firebase document)
              questions: state is TournamentBattleStarted ? (state as TournamentBattleStarted).questions : tournamentBattle.questions,
            ));
          } else {
            //user joined the semi final
            if (tournamentBattle.user2.uid.isNotEmpty) {
              //if user is joining then update state to tournament battle join success
              if (tournamentBattle.createdBy != uid) {
                //or state is TournamentBattleCreationSuccess
                emit(TournamentBattleJoinSuccess(tournamentBattle));
              } else {
                //means user has created the tournament battle
                if (tournamentBattle.createdBy == uid) {
                  //state is TournamentBattleCreationSuccess

                  //add semi final details
                  _tournamentRepository.addSemiFinalDetails(
                    tournamentId: tournamentBattle.tournamentId,
                    semiFinalBattleId: tournamentBattleId,
                    user1Uid: tournamentBattle.user1.uid,
                    user2Uid: tournamentBattle.user2.uid,
                  );

                  //start the tournament
                  _tournamentRepository.startTournamentBattle(tournamentBattleId);
                }
              }
            } else {
              emit(TournamentBattleCreationSuccess(tournamentBattle));
            }
          }
        }
      }
    });
  }

  void createTournamentBattle({
    required TournamentBattleType tournamentBattleType,
    required String tournamentId,
    required TournamentPlayerDetails user1,
    required TournamentPlayerDetails user2,
  }) {
    emit(TournamentBattleCreationInProgress(tournamentBattleType));
    _tournamentRepository.createTournamentBattle(tournamentBattleType: tournamentBattleType, tournamentId: tournamentId, user1: user1, user2: user2).then((tournamentBattleId) {
      //add quater final details
      if (tournamentBattleType == TournamentBattleType.quaterFinal) {
        //update quater final details
        _tournamentRepository.addQuaterFinalDetails(tournamentId: tournamentId, quaterFinalBattleId: tournamentBattleId, user1Uid: user1.uid, user2Uid: user2.uid);
      }

      _subscribeTournamentBattle(tournamentBattleId: tournamentBattleId, uid: user1.uid);
    }).catchError((e) {
      emit(TournamentBattleCreationFailure(e.toString()));
    });
  }

  //this will be call when user submit answer and marked questions attempted
  //if time expired for given question then default "-1" answer will be submitted
  void updateQuestionAnswer(String questionId, String submittedAnswerId) {
    if (state is TournamentBattleStarted) {
      List<Question> updatedQuestions = (state as TournamentBattleStarted).questions;
      //fetching index of question that need to update with submittedAnswer
      int questionIndex = updatedQuestions.indexWhere((element) => element.id == questionId);
      //update question at given questionIndex with submittedAnswerId
      updatedQuestions[questionIndex] = updatedQuestions[questionIndex].updateQuestionWithAnswer(submittedAnswerId: submittedAnswerId);
      emit(TournamentBattleStarted(
        hasLeft: (state as TournamentBattleStarted).hasLeft,
        tournamentBattle: (state as TournamentBattleStarted).tournamentBattle,
        questions: updatedQuestions,
      ));
    }
  }

  //submit anser
  void submitAnswer(String currentUserId, String submittedAnswer, bool isCorrectAnswer, int points) {
    if (state is TournamentBattleStarted) {
      TournamentBattle tournamentBattle = (state as TournamentBattleStarted).tournamentBattle;
      List<Question> questions = (state as TournamentBattleStarted).questions;

      //need to check submitting answer for user1 or user2

      if (currentUserId == tournamentBattle.user1.uid) {
        if (tournamentBattle.user1.answers.length != questions.length) {
          _tournamentRepository.submitAnswer(
            tournamentBattleId: tournamentBattle.tournamentBattleId,
            points: isCorrectAnswer ? (tournamentBattle.user1.points + points) : tournamentBattle.user1.points,
            forUser1: true,
            submittedAnswer: List.from(tournamentBattle.user1.answers)..add(submittedAnswer),
          );
        }
      } else {
        //submit answer for user2
        if (tournamentBattle.user2.answers.length != questions.length) {
          _tournamentRepository.submitAnswer(
            submittedAnswer: List.from(tournamentBattle.user2.answers)..add(submittedAnswer),
            tournamentBattleId: tournamentBattle.tournamentBattleId,
            points: isCorrectAnswer ? (tournamentBattle.user2.points + points) : tournamentBattle.user2.points,
            forUser1: false,
          );
        }
      }
    }
  }

  void deleteRoom() {
    if (state is TournamentBattleStarted) {
      //delete tournament battle room
      _tournamentRepository.removeTournamentBattle(
        tournamentBattleId: (state as TournamentBattleStarted).tournamentBattle.tournamentBattleId,
      );
    }
  }

  bool opponentLeftTheGame(String userId) {
    if (state is TournamentBattleStarted) {
      print((state as TournamentBattleStarted).hasLeft);
      print("User submitted answer ${getCurrentUserDetails(userId).answers.length}");
      return (state as TournamentBattleStarted).hasLeft && getCurrentUserDetails(userId).answers.length != (state as TournamentBattleStarted).questions.length;
    }
    return false;
  }

  String getRoomId() {
    if (state is TournamentBattleStarted) {
      return (state as TournamentBattleStarted).tournamentBattle.tournamentBattleId;
    }

    return "";
  }

  //get questions in quiz battle
  List<Question> getQuestions() {
    if (state is TournamentBattleStarted) {
      return (state as TournamentBattleStarted).questions;
    }
    return [];
  }

  TournamentPlayerDetails getCurrentUserDetails(String currentUserId) {
    if (state is TournamentBattleStarted) {
      if (currentUserId == (state as TournamentBattleStarted).tournamentBattle.user1.uid) {
        return (state as TournamentBattleStarted).tournamentBattle.user1;
      } else {
        return (state as TournamentBattleStarted).tournamentBattle.user2;
      }
    }
    return TournamentPlayerDetails.fromJson({});
  }

  TournamentPlayerDetails getOpponentUserDetails(String currentUserId) {
    if (state is TournamentBattleStarted) {
      if (currentUserId == (state as TournamentBattleStarted).tournamentBattle.user1.uid) {
        return (state as TournamentBattleStarted).tournamentBattle.user2;
      } else {
        return (state as TournamentBattleStarted).tournamentBattle.user1;
      }
    }
    return TournamentPlayerDetails.fromJson({});
  }

  void joinTournamentBattle({required TournamentBattleType tournamentBattleType, required String tournamentBattleId, required TournamentPlayerDetails tournamentPlayerDetails}) {
    emit(TournamentBattleJoinInProgress(tournamentBattleType));
    _subscribeTournamentBattle(tournamentBattleId: tournamentBattleId, uid: tournamentPlayerDetails.uid);
    if (tournamentBattleType == TournamentBattleType.semiFinal) {
      //join semi final
    }
  }

  void cancelTournamentBattleSubscription() {
    _tournamentBattleSubscription?.cancel();
  }

  void resetTournamentBattleResource() {
    cancelTournamentBattleSubscription();
    emit(TournamentBattleInitial());
  }

  //search for semi final
  void searchSemiFinal({required String tournamentId, required TournamentPlayerDetails tournamentPlayerDetails}) async {
    emit(TournamentBattleSearchInProgress());
    try {
      final semiFinals = await _tournamentRepository.searchSemiFinals(tournamentId: tournamentId);
      if (semiFinals.isEmpty) {
        _createSemiFinal(
          tournamentId: tournamentId,
          tournamentPlayerDetails: tournamentPlayerDetails,
        );
      } else if (semiFinals.length == 1) {
        if (semiFinals.first.user2.uid.isEmpty) {
          _joinSemiFinal(
            tournamentId: tournamentId,
            tournamentBattleId: semiFinals.first.tournamentBattleId,
            tournamentPlayerDetails: tournamentPlayerDetails,
          );
        } else {
          _createSemiFinal(
            tournamentId: tournamentId,
            tournamentPlayerDetails: tournamentPlayerDetails,
          );
        }
      } else {
        _joinSemiFinal(
          tournamentId: tournamentId,
          tournamentBattleId: semiFinals.last.tournamentBattleId,
          tournamentPlayerDetails: tournamentPlayerDetails,
        );
      }
    } catch (e) {
      emit(TournamentBattleFailure(e.toString()));
    }
  }

  void _createSemiFinal({required String tournamentId, required TournamentPlayerDetails tournamentPlayerDetails}) async {
    try {
      emit(TournamentBattleCreationInProgress(TournamentBattleType.semiFinal));
      String tournamentBattleId = await _tournamentRepository.createTournamentBattle(
        tournamentBattleType: TournamentBattleType.semiFinal,
        tournamentId: tournamentId,
        user1: tournamentPlayerDetails,
        user2: TournamentPlayerDetails.fromJson({}),
      );
      _subscribeTournamentBattle(tournamentBattleId: tournamentBattleId, uid: tournamentPlayerDetails.uid);
    } catch (e) {
      emit(TournamentBattleCreationFailure(e.toString()));
    }
  }

  void _joinSemiFinal({required String tournamentId, required String tournamentBattleId, required TournamentPlayerDetails tournamentPlayerDetails}) async {
    emit(TournamentBattleJoinInProgress(TournamentBattleType.semiFinal));
    try {
      //add semi final details
      final searchAgain = await _tournamentRepository.joinTournamentBattle(tournamentBattleId: tournamentBattleId, tournamentPlayerDetails: tournamentPlayerDetails);
      if (searchAgain) {
        searchSemiFinal(tournamentId: tournamentId, tournamentPlayerDetails: tournamentPlayerDetails);
      } else {
        _subscribeTournamentBattle(tournamentBattleId: tournamentBattleId, uid: tournamentPlayerDetails.uid);
      }
    } catch (e) {
      emit(TournamentBattleJoinFailure(e.toString()));
    }
  }

  @override
  Future<void> close() async {
    _tournamentBattleSubscription?.cancel();
    return super.close();
  }
}
