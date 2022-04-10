class UserBattleRoomDetails {
  final String name;
  final String profileUrl;
  final String uid;
  final int correctAnswers;
  final List answers;
  final int points;

  UserBattleRoomDetails({required this.points, required this.answers, required this.correctAnswers, required this.name, required this.profileUrl, required this.uid});

  static UserBattleRoomDetails fromJson(Map json) {
    return UserBattleRoomDetails(
      answers: json['answers'] as List? ?? [],
      points: json['points'] ?? 0,
      correctAnswers: json['correctAnswers'] ?? 0,
      name: json['name'] ?? "",
      profileUrl: json['profileUrl'] ?? "",
      uid: json['uid'] ?? "",
    );
  }
}
