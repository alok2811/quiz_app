class ExamException implements Exception {
  final String errorMessageCode;

  ExamException({required this.errorMessageCode});

  @override
  String toString() => errorMessageCode;
}
