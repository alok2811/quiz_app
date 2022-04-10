import 'dart:math';

import 'package:ayuprep/features/quiz/models/answerOption.dart';

class LifeLineOptions {
  static int getRandomAnswerIndex(int length, int correctAnswerIndex) {
    int index = Random.secure().nextInt(length);
    if (index == correctAnswerIndex) {
      return getRandomAnswerIndex(length, correctAnswerIndex);
    }
    return index;
  }

  static List<AnswerOption> getFiftyFiftyOptions(List<AnswerOption> answerOptions, String correctAnswerOptionId) {
    List<AnswerOption> updatedAnswerOptions = List<AnswerOption>.from(answerOptions);
    final correctAnswerOptionIndex = updatedAnswerOptions.indexWhere((element) => element.id == correctAnswerOptionId);

    //fetching random index for array
    int randomIndex = getRandomAnswerIndex(updatedAnswerOptions.length, correctAnswerOptionIndex);

    final otherOptionId = updatedAnswerOptions[randomIndex].id;

    //remove options
    updatedAnswerOptions.removeWhere((element) => element.id != otherOptionId && element.id != correctAnswerOptionId);

    return updatedAnswerOptions;
  }

  static List<int> numbersForAudiencePoll(int optionsLength) {
    List<int> numbers = [];
    int highest = Random.secure().nextInt(20) + 45;
    numbers.add(highest);

    for (int i = 1; i < (optionsLength - 1); i++) {
      int number = Random.secure().nextInt(100 - _sum(numbers));
      numbers.add(number);
    }
    numbers.add(100 - _sum(numbers));

    return numbers;
  }

  static int _sum(List<int> numbers) {
    int total = 0;

    numbers.forEach((e) {
      total = total + e;
    });

    return total;
  }

  static List<int> getAudiencePollPercentage(List<AnswerOption> answerOptions, String correctAnswerOptionId) {
    List<int> percentages = numbersForAudiencePoll(answerOptions.length);

    //correct percentage
    int correctAnswerPercentage = percentages.removeAt(0);

    //shuffle percentages
    percentages.shuffle();

    //get correctAnswer index
    final correctAnswerOptionIndex = answerOptions.indexWhere((element) => element.id == correctAnswerOptionId);

    //add audience percentage for correct answer
    if (correctAnswerOptionIndex == percentages.length) {
      percentages.add(correctAnswerPercentage);
    } else {
      percentages.insert(correctAnswerOptionIndex, correctAnswerPercentage);
    }

    return percentages;
  }
}
