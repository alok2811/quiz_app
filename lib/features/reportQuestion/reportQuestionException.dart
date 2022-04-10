class ReportQuestionException implements Exception {
  final String errorMessageCode;

  ReportQuestionException({required this.errorMessageCode});

  @override
  String toString() => errorMessageCode;
}
