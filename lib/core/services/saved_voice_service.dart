import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavedVoiceModel {
  final String id;
  final String title;
  final String filePath;
  final DateTime createdAt;
  final int durationSeconds;

  SavedVoiceModel({
    required this.id,
    required this.title,
    required this.filePath,
    required this.createdAt,
    required this.durationSeconds,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'filePath': filePath,
    'createdAt': createdAt.toIso8601String(),
    'durationSeconds': durationSeconds,
  };

  factory SavedVoiceModel.fromMap(Map<String, dynamic> map) => SavedVoiceModel(
    id: map['id'] as String,
    title: map['title'] as String,
    filePath: map['filePath'] as String,
    createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
    durationSeconds: (map['durationSeconds'] as num?)?.toInt() ?? 0,
  );
}

class SavedVoiceService extends ChangeNotifier {
  static final SavedVoiceService _instance = SavedVoiceService._internal();
  factory SavedVoiceService() => _instance;
  SavedVoiceService._internal();

  static const String _storageKey = 'saved_voice_recordings_list';
  List<SavedVoiceModel> _recordings = [];
  bool _isLoaded = false;

  List<SavedVoiceModel> get recordings => List.unmodifiable(_recordings);
  bool get isLoaded => _isLoaded;

  Future<void> loadRecordings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(jsonString);
        _recordings = decoded
            .map((item) => SavedVoiceModel.fromMap(Map<String, dynamic>.from(item as Map)))
            .where((rec) => File(rec.filePath).existsSync())
            .toList();
        _recordings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      } else {
        _recordings = [];
      }
      _isLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading saved voice recordings: $e");
    }
  }

  Future<SavedVoiceModel?> saveRecording({
    required String sourcePath,
    required String title,
    required int durationSeconds,
  }) async {
    try {
      final sourceFile = File(sourcePath);
      if (!sourceFile.existsSync()) return null;

      final docsDir = await getApplicationDocumentsDirectory();
      final voicesFolder = Directory('${docsDir.path}/saved_voices');
      if (!voicesFolder.existsSync()) {
        await voicesFolder.create(recursive: true);
      }

      final ext = sourcePath.endsWith('.m4a') ? '.m4a' : '.wav';
      final id = 'voice_${DateTime.now().millisecondsSinceEpoch}';
      final destinationPath = '${voicesFolder.path}/$id$ext';

      await sourceFile.copy(destinationPath);

      final formattedTitle = title.trim().isNotEmpty
          ? title.trim()
          : 'Suaraku ${_recordings.length + 1}';

      final newRecording = SavedVoiceModel(
        id: id,
        title: formattedTitle,
        filePath: destinationPath,
        createdAt: DateTime.now(),
        durationSeconds: durationSeconds,
      );

      _recordings.insert(0, newRecording);
      await _persist();
      notifyListeners();
      return newRecording;
    } catch (e) {
      debugPrint("Error saving recording: $e");
      return null;
    }
  }

  Future<void> deleteRecording(String id) async {
    try {
      final index = _recordings.indexWhere((r) => r.id == id);
      if (index != -1) {
        final recording = _recordings[index];
        final file = File(recording.filePath);
        if (file.existsSync()) {
          await file.delete();
        }
        _recordings.removeAt(index);
        await _persist();
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error deleting saved recording: $e");
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_recordings.map((r) => r.toMap()).toList());
    await prefs.setString(_storageKey, encoded);
  }
}
