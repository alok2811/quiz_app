import 'package:ayuprep/utils/apiBodyParameterLabels.dart';

class LeaderBoardDaily {
  final String? userId, score, userRank, email, name, profile;
//final List<MyRank> myRank;

  LeaderBoardDaily({/*this.myRank,*/ this.userId, this.score, this.userRank, this.email, this.name, this.profile});
  factory LeaderBoardDaily.fromJson(Map<String, dynamic> jsonData) {
    /* List<MyRank> myRank = (jsonData["my_rank"] as List)
        .map((data) => new MyRank.fromJson(data))
        .toList();*/
    return LeaderBoardDaily(
      userId: jsonData[userIdKey] as String?,
      score: jsonData["score"] as String?,
      userRank: jsonData["user_rank"] as String?,
      email: jsonData[emailKey] as String?,
      name: jsonData["name"] as String?,
      profile: jsonData[profileKey] as String?,
      // myRank:myRank
    );
  }
}
