import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class SoundEngine {
  static final SoundEngine _instance = SoundEngine._internal();
  factory SoundEngine() => _instance;
  SoundEngine._internal();

  final AudioPlayer _sfxPlayer = AudioPlayer();
  final FlutterTts _tts = FlutterTts();
  bool _isTtsInitialized = false;

  Future<void> init() async {
    try {
      await _tts.setLanguage("id-ID");
      await _tts.setSpeechRate(0.38); // Sangat pelan & ramah balita
      await _tts.setPitch(1.25);      // Nada riang & manis
      _isTtsInitialized = true;
    } catch (e) {
      debugPrint("TTS init error: $e");
    }
  }

  /// Putar file SFX dari asset (misal: 'audio/sfx/pop.wav')
  Future<void> playAsset(String assetPath) async {
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource(assetPath));
    } catch (e) {
      debugPrint("Error playing audio asset $assetPath: $e");
    }
  }

  Future<void> playClick() => playAsset('audio/sfx/click.wav');
  Future<void> playPop() => playAsset('audio/sfx/pop.wav');
  Future<void> playWinStar() => playAsset('audio/sfx/win_star.wav');

  /// Bicara kata biasa
  Future<void> speakWord(String text, {double rate = 0.38}) async {
    if (!_isTtsInitialized) await init();
    try {
      await _tts.stop();
      await _tts.setSpeechRate(rate);
      await _tts.speak(text);
    } catch (e) {
      debugPrint("TTS speak error: $e");
    }
  }

  /// Eja suku kata satu per satu dengan jeda, lalu sebutkan kata lengkap
  Future<void> spellSyllables(List<String> syllables, String fullWord) async {
    if (!_isTtsInitialized) await init();
    try {
      await _tts.stop();
      await _tts.setSpeechRate(0.35); // Pelan saat mengeja

      for (final syl in syllables) {
        await _tts.speak(syl);
        await Future.delayed(const Duration(milliseconds: 650));
      }
      await Future.delayed(const Duration(milliseconds: 300));
      await _tts.setSpeechRate(0.40);
      await _tts.speak(fullWord);
    } catch (e) {
      debugPrint("TTS spell error: $e");
    }
  }
}
