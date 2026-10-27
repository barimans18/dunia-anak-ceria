import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class AudioRecorderService {
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _playbackPlayer = AudioPlayer();

  bool _isRecording = false;
  String? _lastRecordedPath;
  StreamSubscription<void>? _onCompleteSubscription;
  final Map<String, String> _variantCache = {};

  bool get isRecording => _isRecording;
  String? get lastRecordedPath => _lastRecordedPath;
  AudioPlayer get player => _playbackPlayer;

  Future<bool> startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final dir = await getTemporaryDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final filePath = '${dir.path}/my_voice_$timestamp.wav';

        _variantCache.clear();

        // Rekam format WAV PCM: cepat, jernih, dan mendukung pitch shift instan
        await _audioRecorder.start(
          const RecordConfig(
            encoder: AudioEncoder.wav,
            sampleRate: 22050,
            numChannels: 1,
            audioInterruption: AudioInterruptionMode.none,
            androidConfig: AndroidRecordConfig(
              muteAudio: false,
            ),
          ),
          path: filePath,
        );

        _isRecording = true;
        _lastRecordedPath = filePath;
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Gagal rekam WAV, mencoba fallback AAC: $e");
      try {
        final dir = await getTemporaryDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final filePath = '${dir.path}/my_voice_$timestamp.m4a';
        await _audioRecorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            sampleRate: 22050,
            numChannels: 1,
            audioInterruption: AudioInterruptionMode.none,
            androidConfig: AndroidRecordConfig(
              muteAudio: false,
            ),
          ),
          path: filePath,
        );
        _isRecording = true;
        _lastRecordedPath = filePath;
        return true;
      } catch (e2) {
        debugPrint("Gagal rekam fallback: $e2");
        return false;
      }
    }
  }

  Future<String?> stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      _isRecording = false;
      final savedPath = path ?? _lastRecordedPath;
      if (savedPath != null) {
        final file = File(savedPath);
        if (await file.exists() && (await file.length()) > 500) {
          _lastRecordedPath = savedPath;
          return savedPath;
        }
      }
      _lastRecordedPath = null;
      return null;
    } catch (e) {
      debugPrint("Error saat stop recording: $e");
      _isRecording = false;
      return null;
    }
  }

  /// Memutar rekaman dengan varian pitch / efek suara tertentu
  Future<void> playRecording({
    required String variantId,
    double pitchFactor = 1.0,
    VoidCallback? onComplete,
  }) async {
    if (_lastRecordedPath == null) return;
    try {
      await stopPlayback();

      String pathToPlay = _lastRecordedPath!;
      if (pitchFactor != 1.0 && _lastRecordedPath!.endsWith('.wav')) {
        pathToPlay = await _getOrCreatePitchWav(_lastRecordedPath!, pitchFactor, variantId);
      }

      // Konfigurasi audio context agar output keluar kencang di speaker ponsel
      await _playbackPlayer.setAudioContext(
        AudioContext(
          android: const AudioContextAndroid(
            isSpeakerphoneOn: true,
            stayAwake: true,
            contentType: AndroidContentType.music,
            usageType: AndroidUsageType.media,
            audioFocus: AndroidAudioFocus.gain,
          ),
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
            options: {AVAudioSessionOptions.defaultToSpeaker},
          ),
        ),
      );

      await _playbackPlayer.setVolume(1.0);

      _onCompleteSubscription?.cancel();
      _onCompleteSubscription = _playbackPlayer.onPlayerComplete.listen((_) {
        onComplete?.call();
      });

      await _playbackPlayer.play(DeviceFileSource(pathToPlay));

      // Jika format non-wav, gunakan playbackRate player
      if (!pathToPlay.endsWith('.wav') && pitchFactor != 1.0) {
        await _playbackPlayer.setPlaybackRate(pitchFactor);
      }
    } catch (e) {
      debugPrint("Error playing recording: $e");
      onComplete?.call();
    }
  }

  Future<void> stopPlayback() async {
    try {
      _onCompleteSubscription?.cancel();
      _onCompleteSubscription = null;
      await _playbackPlayer.stop();
    } catch (e) {
      debugPrint("Error stopping playback: $e");
    }
  }

  /// Mengubah sample rate di header file WAV secara instan untuk efek pitch (kartun/robot)
  Future<String> _getOrCreatePitchWav(String originalWavPath, double pitchFactor, String variantId) async {
    if (_variantCache.containsKey(variantId)) {
      final cached = _variantCache[variantId]!;
      if (File(cached).existsSync()) return cached;
    }

    final file = File(originalWavPath);
    if (!file.existsSync()) return originalWavPath;

    final bytes = await file.readAsBytes();
    if (bytes.length < 44) return originalWavPath;

    final data = Uint8List.fromList(bytes);
    final byteData = ByteData.sublistView(data);

    // Cek header RIFF
    if (data[0] != 0x52 || data[1] != 0x49 || data[2] != 0x46 || data[3] != 0x46) {
      return originalWavPath;
    }

    int offset = 12;
    int fmtOffset = -1;

    while (offset + 8 < data.length) {
      final chunkId = String.fromCharCodes(data.sublist(offset, offset + 4));
      final chunkSize = byteData.getUint32(offset + 4, Endian.little);
      if (chunkId == 'fmt ') {
        fmtOffset = offset;
        final ch = byteData.getUint16(offset + 10, Endian.little);
        final sr = byteData.getUint32(offset + 12, Endian.little);
        final bits = byteData.getUint16(offset + 22, Endian.little);

        final newSr = (sr * pitchFactor).round();
        final newBr = (newSr * ch * bits) ~/ 8;

        byteData.setUint32(offset + 12, newSr, Endian.little);
        byteData.setUint32(offset + 16, newBr, Endian.little);
        break;
      }
      offset += 8 + chunkSize;
    }

    if (fmtOffset == -1 && data.length >= 44) {
      final ch = byteData.getUint16(22, Endian.little);
      final sr = byteData.getUint32(24, Endian.little);
      final bits = byteData.getUint16(34, Endian.little);
      final newSr = (sr * pitchFactor).round();
      final newBr = (newSr * ch * bits) ~/ 8;
      byteData.setUint32(24, newSr, Endian.little);
      byteData.setUint32(28, newBr, Endian.little);
    }

    final dir = await getTemporaryDirectory();
    final targetPath = '${dir.path}/variant_${variantId}_${file.uri.pathSegments.last}';
    await File(targetPath).writeAsBytes(data);
    _variantCache[variantId] = targetPath;
    return targetPath;
  }

  void dispose() {
    _onCompleteSubscription?.cancel();
    _audioRecorder.dispose();
    _playbackPlayer.dispose();
  }
}
