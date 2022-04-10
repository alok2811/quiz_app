class TournamentException implements Exception {
  final String errorMessageCode;

  TournamentException({required this.errorMessageCode});

  @override
  String toString() => errorMessageCode;
}
