class CoinHistoryException implements Exception {
  final String errorMessageCode;

  CoinHistoryException({required this.errorMessageCode});
  @override
  String toString() => errorMessageCode;
}
