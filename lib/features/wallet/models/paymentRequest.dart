class PaymentRequest {
  PaymentRequest({
    required this.id,
    required this.userId,
    required this.uid,
    required this.paymentType,
    required this.paymentAddress,
    required this.paymentAmount,
    required this.coinUsed,
    required this.details,
    required this.status,
    required this.date,
  });
  late final String id;
  late final String userId;
  late final String uid;
  late final String paymentType;
  late final String paymentAddress;
  late final String paymentAmount;
  late final String coinUsed;
  late final String details;
  late final String status;
  late final String date;

  PaymentRequest.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? "";
    userId = json['user_id'] ?? "";
    uid = json['uid'] ?? "";
    paymentType = json['payment_type'] ?? "";
    paymentAddress = json['payment_address'] ?? "";
    paymentAmount = json['payment_amount'] ?? "";
    coinUsed = json['coin_used'] ?? "";
    details = json['details'] ?? "";
    status = json['status'] ?? "";
    date = json['date'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['user_id'] = userId;
    _data['uid'] = uid;
    _data['payment_type'] = paymentType;
    _data['payment_address'] = paymentAddress;
    _data['payment_amount'] = paymentAmount;
    _data['coin_used'] = coinUsed;
    _data['details'] = details;
    _data['status'] = status;
    _data['date'] = date;
    return _data;
  }
}
