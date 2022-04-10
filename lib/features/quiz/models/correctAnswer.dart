class CorrectAnswer {
  final String cipherText;
  final String iv;

  CorrectAnswer({required this.cipherText, required this.iv});

  static CorrectAnswer fromJson(Map<String, dynamic> json) {
    return CorrectAnswer(
        cipherText: json['ciphertext'].toString(), iv: json['iv'].toString());
  }
}

/*
{ciphertext: rNr0MVI9dH6v/HWdK8KwpQ==, iv: 713a918470ed2fb47910c17e11d3d2b7}
 */