class AuthException implements Exception {
  final String errorMessageCode;

  AuthException({required this.errorMessageCode});
  @override
  String toString() => errorMessageCode;
}
