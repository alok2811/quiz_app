class SupportedLanguage {
  final String id;
  final String language;
  final String languageCode;

  SupportedLanguage({required this.id, required this.language, required this.languageCode});

  static SupportedLanguage fromJson(Map<String, dynamic> json) {
    return SupportedLanguage(
      id: json['id'],
      language: json['language'],
      languageCode: json['code'],
    );
  }
}
