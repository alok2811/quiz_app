import 'package:ayuprep/utils/apiBodyParameterLabels.dart';

class LeaderBoardAllTime {
  final String? userId, score, userRank, email, name, profile;
  //final MyRank myRank;

  LeaderBoardAllTime({/*this.myRank,*/ this.userId, this.score, this.userRank, this.email, this.name, this.profile});
  factory LeaderBoardAllTime.fromJson(Map<String, dynamic> jsonData) {
    //List<MyRank> myRank = (jsonData["my_rank"] as List).map((xyz) => new MyRank.fromJson(xyz)).toList();
    return LeaderBoardAllTime(
      userId: jsonData[userIdKey] as String?,
      score: jsonData["score"] as String?,
      userRank: jsonData["user_rank"] as String?,
      email: jsonData[emailKey] as String?,
      name: jsonData["name"] as String?,
      profile: jsonData[profileKey] as String?,
      //myRank:jsonData["my_rank"]
    );
  }
}
