class BadgesException implements Exception {
  final String errorMessageCode;

  BadgesException({required this.errorMessageCode});

  @override
  String toString() => errorMessageCode;
}
