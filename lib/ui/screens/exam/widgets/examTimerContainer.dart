import 'dart:async';

import 'package:flutter/material.dart';

class ExamTimerContainer extends StatefulWidget {
  final int examDurationInMinutes;
  final Function navigateToResultScreen;
  ExamTimerContainer({Key? key, required this.examDurationInMinutes, required this.navigateToResultScreen}) : super(key: key);

  @override
  ExamTimerContainerState createState() => ExamTimerContainerState();
}

class ExamTimerContainerState extends State<ExamTimerContainer> {
  late int minutesLeft = widget.examDurationInMinutes - 1;
  late int secondsLeft = 59;

  void startTimer() {
    examTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (minutesLeft == 0) {
        timer.cancel();
        widget.navigateToResultScreen();
      } else {
        if (secondsLeft == 0) {
          secondsLeft = 59;
          minutesLeft--;
        } else {
          secondsLeft--;
        }
        setState(() {});
      }
    });
  }

  Timer? examTimer;

  int getCompletedExamDuration() {
    print("Exam completed in ${(widget.examDurationInMinutes - minutesLeft)}");
    return (widget.examDurationInMinutes - minutesLeft);
  }

  void cancelTimer() {
    print("Cancel timer");
    examTimer?.cancel();
  }

  @override
  void dispose() {
    cancelTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String hours = (minutesLeft ~/ 60).toString().length == 1 ? "0${(minutesLeft ~/ 60)}" : (minutesLeft ~/ 60).toString();

    String minutes = (minutesLeft % 60).toString().length == 1 ? "0${(minutesLeft % 60)}" : (minutesLeft % 60).toString();
    hours = hours == "00" ? "" : hours;

    String seconds = secondsLeft < 10 ? "0$secondsLeft" : "$secondsLeft";
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.5),
      child: Text(
        hours.isEmpty ? "$minutes:$seconds" : "$hours:$minutes:$seconds",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
