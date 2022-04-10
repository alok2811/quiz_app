import 'package:ayuprep/utils/apiBodyParameterLabels.dart';

class LeaderBoardMonthly {
  final String? userId, score, userRank, email, name, profile;

  LeaderBoardMonthly({this.userId, this.score, this.userRank, this.email, this.name, this.profile});
  factory LeaderBoardMonthly.fromJson(Map<String, dynamic> jsonData) {
    return LeaderBoardMonthly(
      userId: jsonData[userIdKey] as String?,
      score: jsonData["score"] as String?,
      userRank: jsonData["user_rank"] as String?,
      email: jsonData[emailKey] as String?,
      name: jsonData["name"] as String?,
      profile: jsonData[profileKey] as String?,
    );
  }
}

class MyRank {
  final String? userId, score, userRank, email, name, profile;
  MyRank({this.userId, this.score, this.userRank, this.email, this.name, this.profile});
  factory MyRank.fromJson(Map<dynamic, dynamic> jsonData) {
    return MyRank(userId: jsonData[userIdKey], score: jsonData["score"], userRank: jsonData["user_rank"], email: jsonData[emailKey], name: jsonData["name"], profile: jsonData[profileKey]);
  }
  /* Map<String, dynamic> toJson() => {
    userIdKey:userId,
    "score":score,
    "user_rank":userRank,
    emailKey:email,
    "name": name,
    profileKey:profile
  };*/
}
