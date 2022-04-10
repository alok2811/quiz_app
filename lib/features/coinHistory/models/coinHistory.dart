class CoinHistory {
  CoinHistory({
    required this.id,
    required this.userId,
    required this.uid,
    required this.points,
    required this.type,
    required this.status,
    required this.date,
  });
  late final String id;
  late final String userId;
  late final String uid;
  late final String points;
  late final String type;
  late final String status;
  late final String date;

  CoinHistory.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? "";
    userId = json['user_id'] ?? "";
    uid = json['uid'] ?? "";
    points = json['points'] ?? "";
    type = json['type'] ?? "";
    status = json['status'] ?? "";
    date = json['date'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['user_id'] = userId;
    _data['uid'] = uid;
    _data['points'] = points;
    _data['type'] = type;
    _data['status'] = status;
    _data['date'] = date;
    return _data;
  }
}
