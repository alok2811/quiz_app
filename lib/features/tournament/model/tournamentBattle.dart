import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ayuprep/features/quiz/models/question.dart';
import 'package:ayuprep/features/tournament/model/tournamentPlayerDetails.dart';

enum TournamentBattleType { quaterFinal, semiFinal, finalBattle }

class TournamentBattle {
  final String tournamentBattleId;
  final String tournamentId;
  final TournamentBattleType battleType;
  final String createdBy;
  final TournamentPlayerDetails user1;
  final TournamentPlayerDetails user2;
  final String createdAt;
  final List<Question> questions;
  final bool readyToPlay;

  //
  TournamentBattle({
    required this.battleType,
    required this.createdAt,
    required this.createdBy,
    required this.user1,
    required this.user2,
    required this.tournamentBattleId,
    required this.tournamentId,
    required this.questions,
    required this.readyToPlay,
  });
  //

  static TournamentBattle fromDocumentSnapshot(DocumentSnapshot documentSnapshot) {
    final data = documentSnapshot.data() as Map<String, dynamic>;
    return TournamentBattle(
      readyToPlay: data['readyToPlay'] ?? false,
      questions: data['questions'] == null ? [] as List<Question> : (data['questions'] as List).map((e) => Question.fromJson(Map.from(e))).toList(),
      tournamentBattleId: documentSnapshot.id,
      battleType: convertTournamentBattleTypeFromStringToEnum(data['battleType']),
      createdAt: data['createdAt'] == null ? "" : data['createdAt'].toString(),
      createdBy: data['createdBy'],
      user1: TournamentPlayerDetails.fromJson(Map.from(data['user1'])),
      user2: TournamentPlayerDetails.fromJson(Map.from(data['user2'])),
      tournamentId: data['tournamentId'],
    );
  }

  static String convertTournamentBattleTypeFromEnumToString(TournamentBattleType tournamentBattleType) {
    if (tournamentBattleType == TournamentBattleType.quaterFinal) {
      return "quaterFinal";
    }
    if (tournamentBattleType == TournamentBattleType.semiFinal) {
      return "semiFinal";
    }
    return "final";
  }

  static TournamentBattleType convertTournamentBattleTypeFromStringToEnum(String tournamentBattleType) {
    if (tournamentBattleType == "quaterFinal") {
      return TournamentBattleType.quaterFinal;
    }
    if (tournamentBattleType == "semiFinal") {
      return TournamentBattleType.semiFinal;
    }
    return TournamentBattleType.finalBattle;
  }
}
