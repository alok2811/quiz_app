import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ayuprep/features/tournament/model/tournamentPlayerDetails.dart';

enum TournamentStatus { notStarted, started, completed }

class Tournament {
  final String title;
  final int entryFee;
  final String createdAt;
  final String id;
  final String createdBy;
  final TournamentStatus status;
  final List<TournamentPlayerDetails> players;
  final int totalPlayers;
  final String languageId;

  //
  //ids of quaterfinals,user1 and user2
  // {"id" : battle document id,"user1" : uid, "user2" : uid}
  final List quaterFinals;
  //
  //ids of semifinals,user1 and user2
  //{"id" : battle document id,"user1" : uid, "user2" : uid}
  final List semiFinals;

  //[{"id" : battle document id,"winnerId" : uid}]
  final List quaterFinalsResult;

  //[{"id" : battle document id,"winnerId" : uid}]
  final List semiFinalsResult;

  //{"id" : battle document id,"winnerId" : uid}
  final Map<String, dynamic> finalBattleResult;

  //
  //{"id" : battle document id,"user1" : uid, "user2" : uid}
  final Map<String, dynamic> finalBattle; //id of final battle,user1 and user2

  Tournament({
    required this.createdAt,
    required this.entryFee,
    required this.finalBattleResult,
    required this.quaterFinalsResult,
    required this.semiFinalsResult,
    required this.title,
    required this.id,
    required this.createdBy,
    required this.status,
    required this.players,
    required this.totalPlayers,
    required this.languageId,
    required this.finalBattle,
    required this.quaterFinals,
    required this.semiFinals,
  });

  static Tournament fromJson(Map<String, dynamic> data) {
    return Tournament(
      createdAt: data['createdAt'] ?? "",
      entryFee: int.parse(data['entryFee'] ?? "0"),
      totalPlayers: data['totalPlayers'] ?? 1,
      title: data['title'] ?? "",
      id: data['id'] ?? "",
      finalBattleResult: data['finalBattleResult'] ?? {},
      quaterFinalsResult: data['quaterFinalsResult'] ?? [],
      semiFinalsResult: data['semiFinalsResult'] ?? [],
      finalBattle: Map.from(data['finalBattle'] ?? {}),
      quaterFinals: data['quaterFinals'] ?? [],
      semiFinals: data['semiFinals'] ?? [],
      createdBy: data['createdBy'] ?? "",
      status: convertStatusFromStringToEnum(data['status'] ?? ""),
      languageId: data['languageId'] ?? "",
      players: data['players'] == null ? ([] as List<TournamentPlayerDetails>) : (data['players'] as List).map((e) => TournamentPlayerDetails.fromJson(Map.from(e))).toList(),
    );
  }

  static Tournament fromDocumentSnapshot(DocumentSnapshot documentSnapshot) {
    final data = documentSnapshot.data() as Map<String, dynamic>;

    return Tournament(
      finalBattleResult: data['finalBattleResult'] ?? {},
      quaterFinalsResult: data['quaterFinalsResult'] ?? [],
      semiFinalsResult: data['semiFinalsResult'] ?? [],
      finalBattle: Map.from(data['finalBattle'] ?? {}),
      quaterFinals: data['quaterFinals'] ?? [],
      semiFinals: data['semiFinals'] ?? [],
      createdAt: data['createdAt'] == null ? "" : data['createdAt'].toString(),
      entryFee: int.parse(data['entryFee'] ?? "0"),
      totalPlayers: data['totalPlayers'] ?? 1,
      title: data['title'] ?? "",
      id: documentSnapshot.id,
      createdBy: data['createdBy'] ?? "",
      status: convertStatusFromStringToEnum(data['status'] ?? ""),
      languageId: data['languageId'] ?? "",
      players: data['players'] == null ? ([] as List<TournamentPlayerDetails>) : (data['players'] as List).map((e) => TournamentPlayerDetails.fromJson(Map.from(e))).toList(),
    );
  }

  static String convertStatusFromEnumToString(TournamentStatus tournamentStatus) {
    if (tournamentStatus == TournamentStatus.notStarted) {
      return "notStarted";
    }
    if (tournamentStatus == TournamentStatus.started) {
      return "started";
    }
    return "completed";
  }

  static TournamentStatus convertStatusFromStringToEnum(String tournamentStatus) {
    if (tournamentStatus == "notStarted") {
      return TournamentStatus.notStarted;
    }
    if (tournamentStatus == "started") {
      return TournamentStatus.started;
    }
    return TournamentStatus.completed;
  }
}
