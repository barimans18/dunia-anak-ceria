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
      // 1. Pastikan speak completion di-await agar ejaan tidak bertabrakan
      await _tts.awaitSpeakCompletion(true);

      // 2. Pilih Google TTS engine di Android jika tersedia (memiliki suara bahasa Indonesia natural)
      try {
        final dynamic engines = await _tts.getEngines;
        if (engines is List && engines.contains("com.google.android.tts")) {
          await _tts.setEngine("com.google.android.tts");
        }
      } catch (e) {
        debugPrint("TTS engine selection warning: $e");
      }

      // 3. Set bahasa ke Bahasa Indonesia dengan pengecekan ketersediaan
      bool langSet = false;
      for (final lang in ["id-ID", "id_ID", "id", "in-ID"]) {
        try {
          final isAvail = await _tts.isLanguageAvailable(lang);
          if (isAvail == true || isAvail == 1) {
            await _tts.setLanguage(lang);
            langSet = true;
            break;
          }
        } catch (_) {}
      }
      if (!langSet) {
        await _tts.setLanguage("id-ID");
      }

      // 4. Cari dan pilih Voice Bahasa Indonesia native secara eksplisit
      try {
        final dynamic voices = await _tts.getVoices;
        if (voices is List) {
          Map<String, String>? indonesianVoice;
          for (final dynamic item in voices) {
            if (item is Map) {
              final locale = (item["locale"] ?? "").toString().toLowerCase();
              final name = (item["name"] ?? "").toString().toLowerCase();
              if (locale.contains("id") || locale.contains("ind") || name.contains("id-") || name.contains("indonesia")) {
                indonesianVoice = {
                  "name": item["name"].toString(),
                  "locale": item["locale"].toString(),
                };
                // Prioritaskan voice natural id-id jika ada
                if (name.contains("id-id") || name.contains("wavenet") || name.contains("neural")) {
                  break;
                }
              }
            }
          }
          if (indonesianVoice != null) {
            await _tts.setVoice(indonesianVoice);
            debugPrint("Selected authentic Indonesian TTS voice: $indonesianVoice");
          }
        }
      } catch (e) {
        debugPrint("TTS voice lookup warning: $e");
      }

      // 5. Parameter intonasi & kecepatan alami anak
      await _tts.setSpeechRate(0.38); // Kecepatan pelan & ramah balita
      await _tts.setPitch(1.0);       // Pitch natural (tidak cempreng/distorsi)
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

  /// Bicara kata biasa dengan aksen Indonesia
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

  /// Eja suku kata satu per satu dengan jeda natural ramah balita, lalu sebutkan kata lengkap
  Future<void> spellSyllables(List<String> syllables, String fullWord) async {
    if (!_isTtsInitialized) await init();
    try {
      await _tts.stop();
      await _tts.setSpeechRate(0.32); // Pelan & jelas saat mengeja suku kata

      for (final syl in syllables) {
        await _tts.speak(syl);
        await Future.delayed(const Duration(milliseconds: 250));
      }
      await Future.delayed(const Duration(milliseconds: 300));
      await _tts.setSpeechRate(0.38);
      await _tts.speak(fullWord);
    } catch (e) {
      debugPrint("TTS spell error: $e");
    }
  }
}
