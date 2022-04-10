class StatisticException implements Exception {
  final String errorMessageCode;

  StatisticException({required this.errorMessageCode});

  @override
  String toString() => errorMessageCode;
}
