class LeaderBoardException implements Exception {
  final String errorMessageCode;

  LeaderBoardException({required this.errorMessageCode});

  @override
  String toString() => errorMessageCode;
}
