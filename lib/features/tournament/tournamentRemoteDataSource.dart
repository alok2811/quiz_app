import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:ayuprep/features/tournament/model/tournament.dart';
import 'package:ayuprep/features/tournament/model/tournamentBattle.dart';
import 'package:ayuprep/features/tournament/model/tournamentPlayerDetails.dart';
import 'package:ayuprep/features/tournament/tournamentException.dart';
import 'package:ayuprep/utils/constants.dart';
import 'package:ayuprep/utils/errorMessageKeys.dart';
import 'package:ayuprep/utils/internetConnectivity.dart';

class TournamentRemoteDataSource {
  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  Future<dynamic> getTournaments() async {}

  Future<List<DocumentSnapshot>> searchTournament({required String questionLanguageId, required String title}) async {
    try {
      QuerySnapshot querySnapshot;
      if (await InternetConnectivity.isUserOffline()) {
        throw SocketException("");
      }

      querySnapshot = await _firebaseFirestore
          .collection(tournamentsCollection)
          .where("languageId", isEqualTo: questionLanguageId)
          .where("title", isEqualTo: title)
          .where(
            "totalPlayers",
            isNotEqualTo: numberOfPlayerForTournament,
          )
          .get();

      return querySnapshot.docs;
    } on SocketException catch (_) {
      throw TournamentException(errorMessageCode: noInternetCode);
    } on PlatformException catch (_) {
      throw TournamentException(errorMessageCode: unableToFindRoomCode);
    } catch (_) {
      throw TournamentException(errorMessageCode: defaultErrorMessageCode);
    }
  }

  Stream<DocumentSnapshot> listenToTournamentUpdates(String tournamentId) {
    return _firebaseFirestore.collection(tournamentsCollection).doc(tournamentId).snapshots();
  }

  Stream<DocumentSnapshot> listenToTournamentBattleUpdates(String tournamentBattleId) {
    return _firebaseFirestore.collection(battleRoomCollection).doc(tournamentBattleId).snapshots();
  }

  Future<String> createTournamentBattle({required Map<String, dynamic> data}) async {
    try {
      if (await InternetConnectivity.isUserOffline()) {
        throw SocketException("");
      }
      return (await _firebaseFirestore.collection(battleRoomCollection).add(data)).id;
    } on SocketException catch (_) {
      throw TournamentException(errorMessageCode: noInternetCode);
    } on PlatformException catch (_) {
      throw TournamentException(errorMessageCode: unableToFindRoomCode);
    } catch (_) {
      throw TournamentException(errorMessageCode: defaultErrorMessageCode);
    }
  }

  Future<List<DocumentSnapshot>> searchSemiFinal({required String tournamentId}) async {
    try {
      QuerySnapshot querySnapshot;
      if (await InternetConnectivity.isUserOffline()) {
        throw SocketException("");
      }

      querySnapshot = await _firebaseFirestore
          .collection(battleRoomCollection)
          .where(
            "tournamentId",
            isEqualTo: tournamentId,
          )
          .where(
            "battleType",
            isEqualTo: TournamentBattle.convertTournamentBattleTypeFromEnumToString(TournamentBattleType.semiFinal),
          )
          .get();

      return querySnapshot.docs;
    } on SocketException catch (_) {
      throw TournamentException(errorMessageCode: noInternetCode);
    } on PlatformException catch (_) {
      throw TournamentException(errorMessageCode: unableToFindRoomCode);
    } catch (_) {
      throw TournamentException(errorMessageCode: defaultErrorMessageCode);
    }
  }

  Future<void> removeTournamentBattle(String tournamentBattleId) async {
    try {
      if (await InternetConnectivity.isUserOffline()) {
        throw SocketException("");
      }

      await _firebaseFirestore.collection(battleRoomCollection).doc(tournamentBattleId).delete();
    } on SocketException catch (_) {
      throw TournamentException(errorMessageCode: noInternetCode);
    } on PlatformException catch (_) {
      throw TournamentException(errorMessageCode: unableToFindRoomCode);
    } catch (_) {
      throw TournamentException(errorMessageCode: defaultErrorMessageCode);
    }
  }

  Future<void> removeTournament({required String tournamentId}) async {
    try {
      if (await InternetConnectivity.isUserOffline()) {
        throw SocketException("");
      }

      await _firebaseFirestore.collection(tournamentsCollection).doc(tournamentId).delete();
    } on SocketException catch (_) {
      throw TournamentException(errorMessageCode: noInternetCode);
    } on PlatformException catch (_) {
      throw TournamentException(errorMessageCode: unableToFindRoomCode);
    } catch (_) {
      throw TournamentException(errorMessageCode: defaultErrorMessageCode);
    }
  }

  Future<void> updateTournament({
    required String tournamentId,
    required Map<String, dynamic> data,
  }) async {
    try {
      if (await InternetConnectivity.isUserOffline()) {
        throw SocketException("");
      }

      await _firebaseFirestore.collection(tournamentsCollection).doc(tournamentId).update(data);
    } on SocketException catch (_) {
      throw TournamentException(errorMessageCode: noInternetCode);
    } on PlatformException catch (_) {
      throw TournamentException(errorMessageCode: unableToFindRoomCode);
    } catch (_) {
      throw TournamentException(errorMessageCode: defaultErrorMessageCode);
    }
  }

  Future<void> updateTournamentBattle({
    required String tournamentBattleId,
    required Map<String, dynamic> data,
  }) async {
    try {
      if (await InternetConnectivity.isUserOffline()) {
        throw SocketException("");
      }

      await _firebaseFirestore.collection(battleRoomCollection).doc(tournamentBattleId).update(data);
    } on SocketException catch (_) {
      throw TournamentException(errorMessageCode: noInternetCode);
    } on PlatformException catch (_) {
      throw TournamentException(errorMessageCode: unableToFindRoomCode);
    } catch (_) {
      throw TournamentException(errorMessageCode: defaultErrorMessageCode);
    }
  }

  Future<String> createTournament({required Map<String, dynamic> data}) async {
    try {
      if (await InternetConnectivity.isUserOffline()) {
        throw SocketException("");
      }

      return (await _firebaseFirestore.collection(tournamentsCollection).add(data)).id;
    } on SocketException catch (_) {
      throw TournamentException(errorMessageCode: noInternetCode);
    } on PlatformException catch (_) {
      throw TournamentException(errorMessageCode: unableToFindRoomCode);
    } catch (_) {
      throw TournamentException(errorMessageCode: defaultErrorMessageCode);
    }
  }

  //join tournament
  Future<bool> joinTournament({
    required String tournamentId,
    required String name,
    required String uid,
    required String profileUrl,
  }) async {
    try {
      if (await InternetConnectivity.isUserOffline()) {
        throw SocketException("");
      }

      return FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance.collection(tournamentsCollection).doc(tournamentId).get();
        Tournament tournament = Tournament.fromDocumentSnapshot(documentSnapshot);
        //if tournament not started and players is less than 8
        if (tournament.totalPlayers != numberOfPlayerForTournament) {
          transaction.update(documentSnapshot.reference, {
            "totalPlayers": tournament.totalPlayers + 1,
            "players": FieldValue.arrayUnion([
              {
                "name": name,
                "profileUrl": profileUrl,
                "uid": uid,
              }
            ]),
          });
          //do not search again for tournament
          return false;
        } else {
          //to search again for tournament or not
          return true;
        }
      });
    } on SocketException catch (_) {
      throw TournamentException(errorMessageCode: noInternetCode);
    } on PlatformException catch (_) {
      throw TournamentException(errorMessageCode: unableToFindRoomCode);
    } catch (_) {
      throw TournamentException(errorMessageCode: defaultErrorMessageCode);
    }
  }

  //join tournament
  Future<bool> joinTournamentBattle({
    required String tournamentBattleId,
    required TournamentPlayerDetails tournamentPlayerDetails,
  }) async {
    try {
      if (await InternetConnectivity.isUserOffline()) {
        throw SocketException("");
      }

      return FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance.collection(battleRoomCollection).doc(tournamentBattleId).get();
        TournamentBattle tournamentBattle = TournamentBattle.fromDocumentSnapshot(documentSnapshot);

        if (tournamentBattle.user2.uid.isEmpty) {
          //
          transaction.update(documentSnapshot.reference, {
            "user2": TournamentPlayerDetails.toJson(tournamentPlayerDetails),
          });
          //do not search again for semi final
          return false;
          //
        } else {
          //to search again for semi final or not
          return true;
        }
      });
    } on SocketException catch (_) {
      throw TournamentException(errorMessageCode: noInternetCode);
    } on PlatformException catch (_) {
      throw TournamentException(errorMessageCode: unableToFindRoomCode);
    } catch (_) {
      throw TournamentException(errorMessageCode: defaultErrorMessageCode);
    }
  }
}
