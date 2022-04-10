import 'package:ayuprep/features/quiz/models/answerOption.dart';
import 'package:ayuprep/features/quiz/models/correctAnswer.dart';

import 'answerOption.dart';
import 'correctAnswer.dart';

class Question {
  final String? question;
  final String? id;
  final String? categoryId;
  final String? subcategoryId;
  final String? imageUrl;
  final String? level;
  final CorrectAnswer? correctAnswer;
  final String? note;
  final String? languageId;
  final String submittedAnswerId;
  final String?
      questionType; //multiple option if type is 1, binary options type 2
  final List<AnswerOption>? answerOptions;
  final bool attempted;
  final String? audio;
  final String? audioType;
  final String? marks;

  Question(
      {this.questionType,
      this.answerOptions,
      this.correctAnswer,
      this.id,
      this.languageId,
      this.level,
      this.note,
      this.question,
      this.categoryId,
      this.imageUrl,
      this.subcategoryId,
      this.audio,
      this.audioType,
      this.attempted = false,
      this.submittedAnswerId = "",
      this.marks});

  static Question fromJson(Map questionJson) {
    //answer options is fix up to e and correct answer
    //identified this optionId (ex. a)
    List<String> optionIds = ["a", "b", "c", "d", "e"];
    List<AnswerOption> options = [];

    //creating answerOption model
    optionIds.forEach((optionId) {
      String optionTitle = questionJson["option$optionId"].toString();
      if (optionTitle.isNotEmpty) {
        options.add(AnswerOption(id: optionId, title: optionTitle));
      }
    });
    options.shuffle();

    return Question(
        id: questionJson['id'],
        categoryId: questionJson['category'] ?? "",
        imageUrl: questionJson['image'],
        languageId: questionJson['language_id'],
        subcategoryId: questionJson['subcategory'] ?? "",
        correctAnswer: CorrectAnswer.fromJson(questionJson['answer']),
        level: questionJson['level'] ?? "",
        question: questionJson['question'],
        note: questionJson['note'] ?? "",
        questionType: questionJson['question_type'] ?? "",
        audio: questionJson['audio'] ?? "",
        audioType: questionJson['audio_type'] ?? "",
        marks: questionJson['marks'] ?? "",
        answerOptions: options);
  }

  static Question fromBookmarkJson(Map questionJson) {
    //answer options is fix up to e and correct answer
    //identified this optionId (ex. a)
    List<String> optionIds = ["a", "b", "c", "d", "e"];
    List<AnswerOption> options = [];

    //creating answerOption model
    optionIds.forEach((optionId) {
      String optionTitle = questionJson["option$optionId"].toString();
      if (optionTitle.isNotEmpty) {
        options.add(AnswerOption(id: optionId, title: optionTitle));
      }
    });
    options.shuffle();

    return Question(
        id: questionJson['question_id'],
        categoryId: questionJson['category'] ?? "",
        imageUrl: questionJson['image'],
        languageId: questionJson['language_id'],
        subcategoryId: questionJson['subcategory'] ?? "",
        correctAnswer: CorrectAnswer.fromJson(questionJson['answer']),
        level: questionJson['level'] ?? "",
        question: questionJson['question'],
        note: questionJson['note'] ?? "",
        questionType: questionJson['question_type'] ?? "",
        audio: questionJson['audio'] ?? "",
        audioType: questionJson['audio_type'] ?? "",
        marks: questionJson['marks'] ?? "",
        answerOptions: options);
  }

  Question updateQuestionWithAnswer({required String submittedAnswerId}) {
    return Question(
        marks: this.marks,
        submittedAnswerId: submittedAnswerId,
        audio: this.audio,
        audioType: this.audioType,
        answerOptions: this.answerOptions,
        attempted: submittedAnswerId.isEmpty ? false : true,
        categoryId: this.categoryId,
        correctAnswer: this.correctAnswer,
        id: this.id,
        imageUrl: this.imageUrl,
        languageId: this.languageId,
        level: this.level,
        note: this.note,
        question: this.question,
        questionType: this.questionType,
        subcategoryId: this.subcategoryId);
  }

  Question copyWith({String? submittedAnswer, bool? attempted}) {
    return Question(
        marks: this.marks,
        submittedAnswerId: submittedAnswer ?? this.submittedAnswerId,
        answerOptions: this.answerOptions,
        audio: this.audio,
        audioType: this.audioType,
        attempted: attempted ?? this.attempted,
        categoryId: this.categoryId,
        correctAnswer: this.correctAnswer,
        id: this.id,
        imageUrl: this.imageUrl,
        languageId: this.languageId,
        level: this.level,
        note: this.note,
        question: this.question,
        questionType: this.questionType,
        subcategoryId: this.subcategoryId);
  }
}
