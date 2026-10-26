import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class AudioRecorderService {
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _playbackPlayer = AudioPlayer();

  bool _isRecording = false;
  String? _lastRecordedPath;

  bool get isRecording => _isRecording;
  String? get lastRecordedPath => _lastRecordedPath;

  Future<bool> startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final dir = await getTemporaryDirectory();
        final filePath = '${dir.path}/my_voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

        await _audioRecorder.start(
          const RecordConfig(encoder: AudioEncoder.aacLc),
          path: filePath,
        );

        _isRecording = true;
        _lastRecordedPath = filePath;
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Error starting recording: $e");
      return false;
    }
  }

  Future<String?> stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      _isRecording = false;
      _lastRecordedPath = path ?? _lastRecordedPath;
      return _lastRecordedPath;
    } catch (e) {
      debugPrint("Error stopping recording: $e");
      _isRecording = false;
      return null;
    }
  }

  Future<void> playRecording({double playbackRate = 1.0}) async {
    if (_lastRecordedPath == null) return;
    try {
      await _playbackPlayer.stop();
      await _playbackPlayer.setPlaybackRate(playbackRate);
      await _playbackPlayer.play(DeviceFileSource(_lastRecordedPath!));
    } catch (e) {
      debugPrint("Error playing recording: $e");
    }
  }

  void dispose() {
    _audioRecorder.dispose();
    _playbackPlayer.dispose();
  }
}
