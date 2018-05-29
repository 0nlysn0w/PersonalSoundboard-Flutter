import 'dart:async';
import 'dart:io';

import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/services.dart';

import 'package:path_provider/path_provider.dart';

import 'main.dart';

class AudioplayerRamon {

  static Future<ByteData> loadAsset() async {
      return await rootBundle.load('sounds/roald.mp3');
  }

  static dynamic localPath() async {
    if(isPlaying) {
      audioPlayer.stop();
    }
    final file = new File('${(await getTemporaryDirectory()).path}/roald.mp3');
    await file.writeAsBytes((await loadAsset()).buffer.asUint8List());
    final result = await audioPlayer.play(file.path, isLocal: true);
    if (result == 1) {
       playerState = PlayerState.playing;
    }
  }

  static PlayerState playerState = PlayerState.stopped;
  static AudioPlayer audioPlayer;
  
  static get isPlaying => playerState == PlayerState.playing;
  static get isPaused => playerState == PlayerState.paused;

  static void initAudioPlayer() {
    audioPlayer = new AudioPlayer();
    audioPlayer.setCompletionHandler(() {
      onComplete();
    });

    audioPlayer.setErrorHandler((msg) {
        onComplete();
    });
  }


  static void playSound(final path) async {
    final result = await audioPlayer.play(path);
    if (result == 1) {
       playerState = PlayerState.playing;
    }
  }

  static void getSound(final path) async {
    if (isPlaying) {
      await audioPlayer.stop();
      playSound(path);
    } else {
      playSound(path);
    }
  }

  static void onComplete() {
    playerState = PlayerState.stopped;
  }
}