import 'dart:math';

import 'package:ayuprep/features/auth/authLocalDataSource.dart';
import 'package:ayuprep/features/quiz/models/correctAnswer.dart';
import 'package:ayuprep/utils/answerEncryption.dart';

String getRandomAlphabet() {
  String alphabets = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  Random random = Random.secure();
  int randomIndex = random.nextInt(alphabets.length);
  return alphabets.substring(randomIndex, randomIndex + 1);
}

class GuessTheWordQuestion {
  late String id;
  late String languageId;
  late String image;
  late String question;
  late String answer;
  late String subcategory;

  late String category;

  //it store option letter index
  late List<String> submittedAnswer;
  late List<String> options; //to build options
  late bool hasAnswered;

  GuessTheWordQuestion({
    required this.id,
    required this.languageId,
    required this.image,
    required this.question,
    required this.answer,
    required this.submittedAnswer,
    required this.options,
    required this.hasAnswered,
    required this.subcategory,
    required this.category,
  });

  GuessTheWordQuestion.fromJson(Map<String, dynamic> json) {
    List<String> submittedAns = [];
    List<String> initialOptions = [];

    String correctAnswer = AnswerEncryption.decryptCorrectAnswer(
        rawKey: AuthLocalDataSource.getUserFirebaseId(),
        correctAnswer: CorrectAnswer.fromJson(Map.from(json['answer'])));

    print(correctAnswer);
    correctAnswer = correctAnswer.toUpperCase();
    for (int i = 0; i < correctAnswer.length; i++) {
      submittedAns.add("");
      initialOptions.add(correctAnswer.substring(i, i + 1));
    }
    initialOptions.shuffle();
    initialOptions.add("!");

    id = json['id'];
    languageId = json['language_id'];
    image = json['image'];
    question = json['question'];
    subcategory = json['subcategory'];
    category = json['category'];
    answer = correctAnswer;
    submittedAnswer = submittedAns;
    options = initialOptions;
    hasAnswered = false;
  }

  GuessTheWordQuestion.fromBookmarkJson(Map<String, dynamic> json) {
    List<String> submittedAns = [];
    List<String> initialOptions = [];
    String correctAnswer = json['answer'].toString().split(" ").join();
    correctAnswer = correctAnswer.toUpperCase();
    for (int i = 0; i < correctAnswer.length; i++) {
      submittedAns.add("");
      initialOptions.add(correctAnswer.substring(i, i + 1));
    }
    initialOptions.shuffle();
    initialOptions.add("!");

    id = json['question_id'];
    languageId = json['language_id'];
    image = json['image'];
    question = json['question'];
    subcategory = json['subcategory'];
    category = json['category'];
    answer = correctAnswer;
    submittedAnswer = submittedAns;
    options = initialOptions;
    hasAnswered = false;
  }

  GuessTheWordQuestion copyWith(
      {List<String>? updatedAnswer, bool? hasAnswerGiven}) {
    return GuessTheWordQuestion(
      category: this.category,
      subcategory: this.subcategory,
      answer: this.answer,
      id: this.id,
      image: this.image,
      languageId: this.languageId,
      question: this.question,
      submittedAnswer: updatedAnswer ?? this.submittedAnswer,
      options: this.options,
      hasAnswered: hasAnswerGiven ?? this.hasAnswered,
    );
  }
}
