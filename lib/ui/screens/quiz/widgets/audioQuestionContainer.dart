import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ayuprep/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:ayuprep/features/quiz/models/question.dart';
import 'package:ayuprep/ui/widgets/horizontalTimerContainer.dart';
import 'package:ayuprep/ui/widgets/optionContainer.dart';
import 'package:ayuprep/utils/answerEncryption.dart';
import 'package:just_audio/just_audio.dart';

class AudioQuestionContainer extends StatefulWidget {
  final BoxConstraints constraints;
  final int currentQuestionIndex;
  final List<Question> questions;
  final Function submitAnswer;
  final Function hasSubmittedAnswerForCurrentQuestion;
  final bool showAnswerCorrectness;

  final AnimationController timerAnimationController;
  AudioQuestionContainer({
    Key? key,
    required this.constraints,
    required this.showAnswerCorrectness,
    required this.currentQuestionIndex,
    required this.questions,
    required this.submitAnswer,
    required this.timerAnimationController,
    required this.hasSubmittedAnswerForCurrentQuestion,
  }) : super(key: key);

  @override
  AudioQuestionContainerState createState() => AudioQuestionContainerState();
}

class AudioQuestionContainerState extends State<AudioQuestionContainer> {
  double textSize = 14;
  late bool _showOption = false;
  late AudioPlayer _audioPlayer;
  late StreamSubscription<ProcessingState> _processingStateStreamSubscription;
  late bool _isPlaying = false;
  late Duration _audioDuration = Duration.zero;
  late bool _hasCompleted = false;
  late bool _hasError = false;
  late bool _isBuffering = false;
  late bool _isLoading = true;

  //
  @override
  void initState() {
    initializeAudio();
    super.initState();
  }

  void initializeAudio() async {
    _audioPlayer = AudioPlayer();

    try {
      var result = await _audioPlayer
          .setUrl(widget.questions[widget.currentQuestionIndex].audio!);
      _audioDuration = result ?? Duration.zero;
      _processingStateStreamSubscription =
          _audioPlayer.processingStateStream.listen(_processingStateListener);
    } catch (e) {
      print(e.toString());
      _hasError = true;
    }
    setState(() {});
  }

  void _processingStateListener(ProcessingState event) {
    print(event.toString());
    if (event == ProcessingState.ready) {
      if (_isLoading) {
        _isLoading = false;
      }

      _audioPlayer.play();
      _isPlaying = true;
      _isBuffering = false;
      _hasCompleted = false;
    } else if (event == ProcessingState.buffering) {
      _isBuffering = true;
    } else if (event == ProcessingState.completed) {
      if (!_showOption) {
        _showOption = true;
        widget.timerAnimationController.forward(from: 0.0);
      }
      _hasCompleted = true;
    }

    setState(() {});
  }

  Widget _buildPlayAudioContainer() {
    if (_hasError) {
      return IconButton(
          onPressed: () {
            //retry
          },
          icon: Icon(
            Icons.error,
            color: Theme.of(context).colorScheme.secondary,
          ));
    }
    if (_isLoading || _isBuffering) {
      return IconButton(
          onPressed: null,
          icon: Container(
              height: 20,
              width: 20,
              child: Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              )));
    }

    if (_hasCompleted) {
      return IconButton(
          onPressed: () {
            _audioPlayer.seek(Duration.zero);
          },
          icon: Icon(
            Icons.restart_alt,
            color: Theme.of(context).colorScheme.secondary,
          ));
    }
    if (_isPlaying) {
      return IconButton(
          onPressed: () {
            //

            _audioPlayer.pause();
            _isPlaying = false;
            setState(() {});
          },
          icon: Icon(
            Icons.pause,
            color: Theme.of(context).colorScheme.secondary,
          ));
    }

    return IconButton(
        onPressed: () {
          _audioPlayer.play();
          _isPlaying = true;
          setState(() {});
        },
        icon: Icon(
          Icons.play_arrow,
          color: Theme.of(context).colorScheme.secondary,
        ));
  }

  @override
  void dispose() {
    _processingStateStreamSubscription.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  bool get showOption => _showOption;

  void changeShowOption() {
    _showOption = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.questions[widget.currentQuestionIndex];
    return SingleChildScrollView(
        child: Column(
      children: [
        SizedBox(
          height: 17.5,
        ),
        HorizontalTimerContainer(
            timerAnimationController: widget.timerAnimationController),
        SizedBox(
          height: 12.5,
        ),
        Container(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.center,
                child: Text(
                  "${widget.currentQuestionIndex + 1} | ${widget.questions.length}",
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.secondary),
                ),
              ),
            ],
          ),
        ),

        Divider(
          color: Theme.of(context).colorScheme.secondary,
        ),
        SizedBox(
          height: 5.0,
        ),
        Container(
          alignment: Alignment.center,
          child: Text(
            "${question.question}",
            style: TextStyle(
                height: 1.125,
                fontSize: textSize,
                color: Theme.of(context).colorScheme.secondary),
          ),
        ),

        SizedBox(
          height: widget.constraints.maxHeight * (0.04),
        ),
        Container(
          width: widget.constraints.maxWidth * 1.2,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Theme.of(context).primaryColor.withOpacity(0.1)),
          padding: EdgeInsets.symmetric(
              horizontal: widget.constraints.maxWidth * (0.05), vertical: 10.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CurrentDurationContainer(audioPlayer: _audioPlayer),
                  Spacer(),
                  _buildPlayAudioContainer(),
                  Spacer(),
                  Container(
                    alignment: Alignment.centerRight,
                    //decoration: BoxDecoration(border: Border.all()),
                    width: MediaQuery.of(context).size.width * (0.1),
                    child: Text(
                      "${_audioDuration.inSeconds}s",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                ],
              ),
              Stack(
                children: [
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: BufferedDurationContainer(audioPlayer: _audioPlayer),
                  ),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: CurrentDurationSliderContainer(
                        audioPlayer: _audioPlayer,
                        duration: _audioDuration,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: widget.constraints.minHeight * (0.025),
              ),
            ],
          ),
        ),

        SizedBox(
          height: widget.constraints.maxHeight * (0.04),
        ),
        _showOption
            ? Column(
                children: question.answerOptions!.map((option) {
                  return OptionContainer(
                    submittedAnswerId: question.submittedAnswerId,
                    showAnswerCorrectness: widget.showAnswerCorrectness,
                    showAudiencePoll: false,
                    hasSubmittedAnswerForCurrentQuestion:
                        widget.hasSubmittedAnswerForCurrentQuestion,
                    constraints: widget.constraints,
                    answerOption: option,
                    correctOptionId: AnswerEncryption.decryptCorrectAnswer(
                        rawKey: context
                            .read<UserDetailsCubit>()
                            .getUserFirebaseId(),
                        correctAnswer: question.correctAnswer!),
                    submitAnswer: widget.submitAnswer,
                  );
                }).toList(),
              )
            : Column(
                children: question.answerOptions!
                    .map((e) => Container(
                          child: Center(
                            child: Text(
                              "-",
                              style: TextStyle(
                                  color: Theme.of(context).backgroundColor),
                            ),
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          margin: EdgeInsets.only(
                              top: widget.constraints.maxHeight * (0.015)),
                          height: widget.constraints.maxHeight * (0.105),
                          width: widget.constraints.maxWidth * (0.95),
                        ))
                    .toList(),
              ),

        //
      ],
    ));
  }
}

class CurrentDurationSliderContainer extends StatefulWidget {
  final AudioPlayer audioPlayer;
  final Duration duration;

  CurrentDurationSliderContainer(
      {Key? key, required this.audioPlayer, required this.duration})
      : super(key: key);

  @override
  _CurrentDurationSliderContainerState createState() =>
      _CurrentDurationSliderContainerState();
}

class _CurrentDurationSliderContainerState
    extends State<CurrentDurationSliderContainer> {
  double currentValue = 0.0;

  late StreamSubscription<Duration> streamSubscription;

  @override
  void initState() {
    streamSubscription =
        widget.audioPlayer.positionStream.listen(currentDurationListener);
    super.initState();
  }

  void currentDurationListener(Duration duration) {
    currentValue = duration.inSeconds.toDouble();
    setState(() {});
  }

  @override
  void dispose() {
    streamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: Theme.of(context).sliderTheme.copyWith(
            overlayShape: RoundSliderOverlayShape(overlayRadius: 0.0),
            trackHeight: 5,
            trackShape: CustomTrackShape(),
            thumbShape: RoundSliderThumbShape(
              enabledThumbRadius: 6.5,
            ),
          ),
      child: Container(
        height: 5.0,
        width: MediaQuery.of(context).size.width,
        child: Slider(
            min: 0.0,
            max: widget.duration.inSeconds.toDouble(),
            activeColor: Theme.of(context).primaryColor.withOpacity(0.6),
            inactiveColor: Theme.of(context).primaryColor.withOpacity(0.3),
            value: currentValue,
            thumbColor: Theme.of(context).colorScheme.secondary,
            onChanged: (value) {
              setState(() {
                currentValue = value;
              });
              widget.audioPlayer.seek(Duration(seconds: value.toInt()));
            }),
      ),
    );
  }
}

class BufferedDurationContainer extends StatefulWidget {
  final AudioPlayer audioPlayer;

  BufferedDurationContainer({Key? key, required this.audioPlayer})
      : super(key: key);

  @override
  _BufferedDurationContainerState createState() =>
      _BufferedDurationContainerState();
}

class _BufferedDurationContainerState extends State<BufferedDurationContainer> {
  late double bufferedPercentage = 0.0;

  late StreamSubscription<Duration> streamSubscription;

  @override
  void initState() {
    streamSubscription = widget.audioPlayer.bufferedPositionStream
        .listen(bufferedDurationListener);
    super.initState();
  }

  void bufferedDurationListener(Duration duration) {
    var audioDuration = widget.audioPlayer.duration ?? Duration.zero;
    bufferedPercentage = audioDuration.inSeconds == 0
        ? 0.0
        : (duration.inSeconds / audioDuration.inSeconds);
    setState(() {});
  }

  @override
  void dispose() {
    streamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2.5),
        color: Theme.of(context).primaryColor.withOpacity(0.6),
      ),
      width: MediaQuery.of(context).size.width * bufferedPercentage,
      height: 5.0,
    );
  }
}

class CurrentDurationContainer extends StatefulWidget {
  final AudioPlayer audioPlayer;
  CurrentDurationContainer({Key? key, required this.audioPlayer})
      : super(key: key);

  @override
  _CurrentDurationContainerState createState() =>
      _CurrentDurationContainerState();
}

class _CurrentDurationContainerState extends State<CurrentDurationContainer> {
  late StreamSubscription<Duration> currentAudioDurationStreamSubscription;
  late Duration currentDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    currentAudioDurationStreamSubscription =
        widget.audioPlayer.positionStream.listen(currentDurationListener);
  }

  void currentDurationListener(Duration duration) {
    setState(() {
      currentDuration = duration;
    });
  }

  @override
  void dispose() {
    currentAudioDurationStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      //decoration: BoxDecoration(border: Border.all()),
      width: MediaQuery.of(context).size.width * (0.1),
      child: Text(
        "${currentDuration.inSeconds}",
        style: TextStyle(
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
    );
  }
}

class CustomTrackShape extends RoundedRectSliderTrackShape {
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
    double additionalActiveTrackHeight = 0,
  }) {
    return Offset(offset.dx, offset.dy) &
        Size(parentBox.size.width, sliderTheme.trackHeight!);
  } //
}
