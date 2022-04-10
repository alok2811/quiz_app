class SystemConfigException implements Exception {
  final String errorMessageCode;

  SystemConfigException({required this.errorMessageCode});

  @override
  String toString() => errorMessageCode;
}
