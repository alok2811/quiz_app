class NotificationException implements Exception {
  final String errorMessageCode;

  NotificationException({required this.errorMessageCode, errorMessageKey});

  @override
  String toString() => errorMessageCode;
}
