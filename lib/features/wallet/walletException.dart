class WalletException implements Exception {
  final String errorMessageCode;

  WalletException({required this.errorMessageCode});
  @override
  String toString() => errorMessageCode;
}
