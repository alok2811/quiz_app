class QuizException implements Exception {
  final String errorMessageCode;

  QuizException({required this.errorMessageCode, errorMessageKey});

  @override
  String toString() => errorMessageCode;
}
