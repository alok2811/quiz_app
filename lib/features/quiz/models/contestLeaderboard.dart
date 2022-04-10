import 'package:ayuprep/utils/apiBodyParameterLabels.dart';

class ContestLeaderboard {
  final String? userId, score, userRank, name, profile;

  ContestLeaderboard({this.userId, this.score, this.userRank, this.name, this.profile});
  factory ContestLeaderboard.fromJson(Map<String, dynamic> jsonData) {
    return ContestLeaderboard(userId: jsonData[userIdKey], score: jsonData["score"], userRank: jsonData["user_rank"], name: jsonData["name"], profile: jsonData[profileKey]);
  }
}
