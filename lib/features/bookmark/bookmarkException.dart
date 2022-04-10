class BookmarkException implements Exception {
  final String errorMessageCode;

  BookmarkException({required this.errorMessageCode});

  @override
  String toString() => errorMessageCode;
}
