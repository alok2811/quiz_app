import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';

abstract class MusicPlayerState {}

class MusicPlayerInitial extends MusicPlayerState {}

class MusicPlayerLoaded extends MusicPlayerState {
  final Duration audioDuration;

  MusicPlayerLoaded({
    required this.audioDuration,
  });
}

class MusicPlayerFailure extends MusicPlayerState {
  final String errorMessage;

  MusicPlayerFailure(this.errorMessage);
}

class MusicPlayerLoading extends MusicPlayerState {}

class MusicPlayerCubit extends Cubit<MusicPlayerState> {
  MusicPlayerCubit() : super(MusicPlayerInitial());
  AudioPlayer _audioPlayer = AudioPlayer();

  AudioPlayer get audioPlayer => _audioPlayer;

  void initPlayer(String url) async {
    try {
      emit(MusicPlayerLoading());

      var result = await _audioPlayer.setUrl(url);

      emit(MusicPlayerLoaded(
        audioDuration: result!,
      ));
    } catch (e) {
      print(e.toString());
      emit(MusicPlayerFailure("Error while plyaing music"));
    }
  }

  void playAudio() {}

  @override
  Future<void> close() async {
    print("Dispose this audio player");
    _audioPlayer.dispose();
    super.close();
  }
}
