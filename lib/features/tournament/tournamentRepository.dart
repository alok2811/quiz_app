import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ayuprep/features/tournament/model/tournament.dart';
import 'package:ayuprep/features/tournament/model/tournamentBattle.dart';
import 'package:ayuprep/features/tournament/model/tournamentDetails.dart';
import 'package:ayuprep/features/tournament/model/tournamentPlayerDetails.dart';
import 'package:ayuprep/features/tournament/tournamentException.dart';
import 'package:ayuprep/features/tournament/tournamentRemoteDataSource.dart';

class TournamentRepository {
  static final TournamentRepository _tournamentRepository = TournamentRepository._internal();
  late TournamentRemoteDataSource _tournamentRemoteDataSource;

  factory TournamentRepository() {
    _tournamentRepository._tournamentRemoteDataSource = TournamentRemoteDataSource();
    return _tournamentRepository;
  }

  TournamentRepository._internal();

  Future<List<TournamentDetails>> getTournaments() async {
    _tournamentRemoteDataSource.getTournaments();
    return [];
  }

  Future<List<Tournament>> searchTournament({required String questionLanguageId, required String title}) async {
    try {
      final result = await _tournamentRemoteDataSource.searchTournament(questionLanguageId: questionLanguageId, title: title);
      return result.map((e) => Tournament.fromDocumentSnapshot(e)).toList();
    } catch (e) {
      throw TournamentException(errorMessageCode: e.toString());
    }
  }

  Future<void> removeUserFromTournament({required String uid, required Tournament tournament}) async {
    if (tournament.totalPlayers == 1) {
      //remove tournament
      await _tournamentRemoteDataSource.removeTournament(tournamentId: tournament.id);
    } else {
      //remove user from tournament
      String createdBy = tournament.createdBy;

      if (uid == createdBy) {
        createdBy = tournament.players[1].uid;
      }
      List<TournamentPlayerDetails> players = List.from(tournament.players);
      players.removeWhere((element) => element.uid == uid);
      await _tournamentRemoteDataSource.updateTournament(tournamentId: tournament.id, data: {
        "totalPlayers": tournament.totalPlayers - 1,
        "createdBy": createdBy,
        "players": players.map((e) => TournamentPlayerDetails.toTournamentPlayerDetailsJson(e)).toList(),
      });
    }
  }

  Stream<DocumentSnapshot> listenToTournamentUpdates(String tournamentId) {
    return _tournamentRemoteDataSource.listenToTournamentUpdates(tournamentId);
  }

  Stream<DocumentSnapshot> listenToTournamentBattleUpdates(String tournamentBattleId) {
    return _tournamentRemoteDataSource.listenToTournamentBattleUpdates(tournamentBattleId);
  }

  Future<void> removeTournamentBattle({required String tournamentBattleId}) async {
    try {
      await _tournamentRemoteDataSource.removeTournamentBattle(tournamentBattleId);
    } catch (e) {}
  }

  Future<void> updateTournamentBattlesResult({required String tournamentId, required String winnerId, required String tournamentBattleId}) async {
    _tournamentRemoteDataSource.updateTournament(tournamentId: tournamentId, data: {
      "battlesResult": FieldValue.arrayUnion([
        {
          "id": tournamentBattleId,
          "winnerId": winnerId,
        }
      ]),
    });
  }

  Future<bool> joinTournament({
    required String name,
    required String uid,
    required String profileUrl,
    required String tournamentId,
  }) async {
    try {
      return await _tournamentRemoteDataSource.joinTournament(tournamentId: tournamentId, name: name, uid: uid, profileUrl: profileUrl);
    } catch (e) {
      throw TournamentException(errorMessageCode: e.toString());
    }
  }

  Future<void> startTournament(String tournamentId) async {
    try {
      await _tournamentRemoteDataSource.updateTournament(tournamentId: tournamentId, data: {
        "status": Tournament.convertStatusFromEnumToString(TournamentStatus.started),
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> startTournamentBattle(String tournamentBattleId) async {
    try {
      await _tournamentRemoteDataSource.updateTournamentBattle(tournamentBattleId: tournamentBattleId, data: {"readyToPlay": true});
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> addQuaterFinalDetails({required String tournamentId, required String quaterFinalBattleId, required String user1Uid, required String user2Uid}) async {
    try {
      await _tournamentRemoteDataSource.updateTournament(tournamentId: tournamentId, data: {
        "quaterFinals": FieldValue.arrayUnion([
          {
            "id": quaterFinalBattleId,
            "user1": user1Uid,
            "user2": user2Uid,
          }
        ])
      });
    } catch (e) {
      throw TournamentException(errorMessageCode: e.toString());
    }
  }

  Future<void> addSemiFinalDetails({required String tournamentId, required String semiFinalBattleId, required String user1Uid, required String user2Uid}) async {
    try {
      await _tournamentRemoteDataSource.updateTournament(tournamentId: tournamentId, data: {
        "semiFinals": FieldValue.arrayUnion([
          {
            "id": semiFinalBattleId,
            "user1": user1Uid,
            "user2": user2Uid,
          }
        ])
      });
    } catch (e) {
      throw TournamentException(errorMessageCode: e.toString());
    }
  }

  Future<List<TournamentBattle>> searchSemiFinals({required String tournamentId}) async {
    try {
      return (await _tournamentRemoteDataSource.searchSemiFinal(tournamentId: tournamentId)).map((e) => TournamentBattle.fromDocumentSnapshot(e)).toList();
    } catch (e) {
      throw TournamentException(errorMessageCode: e.toString());
    }
  }

  Future<bool> joinTournamentBattle({required String tournamentBattleId, required TournamentPlayerDetails tournamentPlayerDetails}) async {
    try {
      //join again
      return await _tournamentRemoteDataSource.joinTournamentBattle(tournamentBattleId: tournamentBattleId, tournamentPlayerDetails: tournamentPlayerDetails);
    } catch (e) {
      throw TournamentException(errorMessageCode: e.toString());
    }
  }

  Future<String> createTournamentBattle({
    required TournamentBattleType tournamentBattleType,
    required String tournamentId,
    required TournamentPlayerDetails user1,
    required TournamentPlayerDetails user2,
  }) async {
    try {
      //
      final questions = []; //fetch mix questions for tournament battle

      return await _tournamentRemoteDataSource.createTournamentBattle(data: {
        "createdBy": user1.uid,
        "createdAt": Timestamp.now(),
        "tournamentId": tournamentId,
        "questions": questions,
        "readyToPlay": false,
        "battleType": TournamentBattle.convertTournamentBattleTypeFromEnumToString(tournamentBattleType),
        "user1": TournamentPlayerDetails.toJson(user1),
        "user2": TournamentPlayerDetails.toJson(user2)
      });
    } catch (e) {
      throw TournamentException(errorMessageCode: e.toString());
    }
  }

  Future<String> createTournament({
    required String name,
    required String uid,
    required String profileUrl,
    required String languageId,
    required String title,
    required String entryFee,
  }) async {
    try {
      return await _tournamentRemoteDataSource.createTournament(data: {
        "totalPlayers": 1,
        "languageId": languageId,
        "createdAt": Timestamp.now(),
        "title": title,
        "entryFee": entryFee,
        "status": Tournament.convertStatusFromEnumToString(TournamentStatus.notStarted),
        "createdBy": uid,
        "finalBattle": {},
        "quaterFinals": [],
        "semiFinals": [],
        "finalBattleResult": {},
        "quaterFinalsResult": [],
        "semiFinalsResult": [],
        "players": [
          {
            "name": name,
            "profileUrl": profileUrl,
            "uid": uid,
          }
        ],
      });
    } catch (e) {
      throw TournamentException(errorMessageCode: e.toString());
    }
  }

  //submit answer and update correct answer count and points
  Future<void> submitAnswer({required bool forUser1, required List submittedAnswer, required String tournamentBattleId, required int points}) async {
    try {
      Map<String, dynamic> submitAnswer = {};
      if (forUser1) {
        submitAnswer.addAll({"user1.answers": submittedAnswer, "user1.points": points});
      } else {
        submitAnswer.addAll({"user2.answers": submittedAnswer, "user2.points": points});
      }
      await _tournamentRemoteDataSource.updateTournamentBattle(tournamentBattleId: tournamentBattleId, data: submitAnswer);
    } catch (e) {}
  }
}
