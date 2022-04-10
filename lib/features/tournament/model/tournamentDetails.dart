class TournamentDetails {
  final String title;
  final int entryFee;
  final int winAmount;
  final String createdAt;
  final String id;
  final Duration questionDuration;

  TournamentDetails({required this.questionDuration, required this.createdAt, required this.entryFee, required this.title, required this.winAmount, required this.id});

  static TournamentDetails fromJson(Map<String, dynamic> json) {
    return TournamentDetails(
      questionDuration: Duration(seconds: json['question_duration'] ?? 0),
      createdAt: json['created_at'] ?? "",
      id: json['id'] ?? "",
      entryFee: int.parse(json['entry_fee'] ?? "0"),
      title: json['title'] ?? "",
      winAmount: int.parse(json['entry_fee'] ?? "0") * 8,
    );
  }
}
