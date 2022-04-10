import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ayuprep/features/quiz/cubits/questionsCubit.dart';
import 'package:ayuprep/features/quiz/models/quizType.dart';

class TimerContainer extends StatefulWidget {
  final Function setTimer; //to set timer of quizScreen
//need this to change question based on currentQuestionIndex
  final Function changeQuestion;
  final QuizTypes? quizType;
  final int? minutes;
  final String? data;

  TimerContainer({Key? key, required this.changeQuestion, required this.setTimer, required this.quizType, this.minutes, this.data}) : super(key: key);

  @override
  TimerContainerState createState() => TimerContainerState();
}

class TimerContainerState extends State<TimerContainer> {
  late int seconds;
  late int completedMinutes;

  @override
  void initState() {
    //using same timer container in every quiz screen
    if (widget.quizType == QuizTypes.selfChallenge) {
      //since we need to show minutes with seconds
      //that's why starting completedMinutes as 1
      completedMinutes = 1;
      seconds = 59;
    } else if (widget.quizType == QuizTypes.guessTheWord) {
      seconds = 40;
    } else if (widget.data == "data") {
      seconds = 5;
    } else {
      //time in seconds to solve one question
      seconds = 25;
    }

    super.initState();
  }

  //timercall back will be executed evrey one second
  void timerCallback(Timer timer) async {
    if (widget.quizType == QuizTypes.selfChallenge) {
      //decrease seconds
      if (seconds != 0) {
        if (mounted) {
          setState(() {
            seconds--;
          });
        }
      }
      //seconds is0 then increase completed minutes
      //and set seconds as 59 again
      else {
        //if completedMinutes is same as given minutes
        if (completedMinutes == widget.minutes) {
          timer.cancel();
          widget.changeQuestion();
          //navigate to result
        }
        //increase completed minutes and change seconds to 59
        else {
          if (mounted) {
            setState(() {
              completedMinutes++;
              seconds = 59;
            });
          }
        }
      }
    }
    //for other quizType
    else {
      //decrease seconds
      if (seconds != 0) {
        if (mounted)
          setState(() {
            seconds--;
          });
      } else {
        //cancel timer
        timer.cancel();

        if (widget.quizType == QuizTypes.battle || widget.quizType == QuizTypes.groupPlay) {
          print("User did not submit answer for this question");
          widget.changeQuestion("-1");
        } else if (widget.quizType == QuizTypes.guessTheWord) {
          //start timer and change question
          await Future.delayed(Duration(milliseconds: 500));
          widget.changeQuestion();
        } else if (widget.data == "data") {
          await Future.delayed(Duration(milliseconds: 500));
          widget.changeQuestion();
        } else {
          //if quizType is not battleQuiz or live battle
          //then deduct points

          //deduct points for skipping questions
          context.read<QuestionsCubit>().deductPointsForLeavingQuestion();
          await Future.delayed(Duration(milliseconds: 500));

          //start timer and change question
          widget.changeQuestion();
        }
      }
    }
  }

  //start timer for question
  startTimer() {
    //if quiztime is not self challenge then set seconds again
    if (widget.quizType != QuizTypes.selfChallenge) {
      //this will be execute when using reset time lifeline

      if (widget.quizType == QuizTypes.guessTheWord) {
        if (seconds != 40) {
          setState(() {
            seconds = 40;
          });
        }
      } else if (widget.quizType == QuizTypes.battle) {
        if (seconds != 25) {
          setState(() {
            seconds = 25;
          });
        }
      } else if (widget.data == "data") {
        if (seconds != 5) {
          seconds = 5;
        } else if (widget.data == "data") {
          if (seconds != 5) {
            seconds = 5;
          }
        } else {
          //if quizType is not guess the word

          if (seconds != 25) {
            setState(() {
              seconds = 25;
            });
          }
        }
      }
      //start timer
      widget.setTimer(Timer.periodic(Duration(seconds: 1), timerCallback));
    }
  }

  //to get time to display in text widget
  String getTime() {
    String secondsAsString = seconds < 10 ? "0$seconds" : seconds.toString();
    if (widget.quizType == QuizTypes.selfChallenge) {
      int minutes = widget.minutes! - completedMinutes;
      String minutesAsString = minutes < 10 ? "0$minutes" : minutes.toString();
      return "$minutesAsString:$secondsAsString";
    }
    return "$secondsAsString";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.quizType == QuizTypes.selfChallenge ? 45.0 : 35.0,
      width: widget.quizType == QuizTypes.selfChallenge ? 85.0 : 60.0,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Image.asset(
            "assets/images/time.png",
            fit: BoxFit.cover,
          ),
          Center(
            child: Padding(
              padding: widget.quizType == QuizTypes.selfChallenge ? EdgeInsets.only(right: 23, top: 15.0) : EdgeInsets.only(right: 3.5, top: 3.5),
              child: Text(
                getTime(),
                style: TextStyle(color: Theme.of(context).primaryColor, fontSize: widget.quizType == QuizTypes.selfChallenge ? 16.0 : 19.5),
              ),
            ),
          )
        ],
      ),
    );
  }
}
