class Level {
  final String? level;

  Level({this.level});
  factory Level.fromJson(Map<String, dynamic> jsonData) {
    return Level(
      level: jsonData["level"]
    );}

}
