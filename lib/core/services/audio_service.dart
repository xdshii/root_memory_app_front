import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  
  factory AudioService() {
    return _instance;
  }
  
  AudioService._internal();
  
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  Future<void> playAudio(String audioUrl) async {
    try {
      await _audioPlayer.stop();
      if (audioUrl.startsWith('http')) {
        // 远程音频
        await _audioPlayer.setUrl(audioUrl);
      } else {
        // 本地音频
        await _audioPlayer.setAsset(audioUrl);
      }
      await _audioPlayer.play();
    } catch (e) {
      if (kDebugMode) {
        print('Error playing audio: $e');
      }
    }
  }
  
  Future<void> stopAudio() async {
    await _audioPlayer.stop();
  }
  
  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}