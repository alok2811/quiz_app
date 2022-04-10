class ProfileManagementException implements Exception {
  final String errorMessageCode;

  ProfileManagementException({required this.errorMessageCode});

  @override
  String toString() => errorMessageCode;
}
