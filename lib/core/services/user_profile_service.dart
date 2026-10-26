import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfileService extends ChangeNotifier {
  static final UserProfileService _instance = UserProfileService._internal();
  factory UserProfileService() => _instance;
  UserProfileService._internal();

  static const String _keyName = 'child_profile_name';
  static const String _keyPhoto = 'child_profile_photo';

  String _name = '';
  String _photoPath = '';
  bool _isLoaded = false;

  String get name => _name;
  String get photoPath => _photoPath;
  bool get isLoaded => _isLoaded;

  /// Cek apakah nama dan foto sudah di-set dua-duanya
  bool get isProfileComplete => _name.trim().isNotEmpty && _photoPath.trim().isNotEmpty;

  String get displayName => _name.trim().isNotEmpty ? _name.trim() : 'Bintang Kecil';

  Future<void> loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _name = prefs.getString(_keyName) ?? '';
      _photoPath = prefs.getString(_keyPhoto) ?? '';
      _isLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading user profile: $e");
    }
  }

  Future<void> saveProfile({required String name, required String photoPath}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _name = name.trim();
      _photoPath = photoPath.trim();
      await prefs.setString(_keyName, _name);
      await prefs.setString(_keyPhoto, _photoPath);
      notifyListeners();
    } catch (e) {
      debugPrint("Error saving user profile: $e");
    }
  }

  /// Preset avatar yang tersedia untuk dipilih langsung
  static const List<Map<String, String>> presetAvatars = [
    {'id': 'avatar_bear', 'emoji': '🐻', 'label': 'Beruang'},
    {'id': 'avatar_lion', 'emoji': '🦁', 'label': 'Singa'},
    {'id': 'avatar_cat', 'emoji': '🐱', 'label': 'Kucing'},
    {'id': 'avatar_rabbit', 'emoji': '🐰', 'label': 'Kelinci'},
    {'id': 'avatar_boy', 'emoji': '👦', 'label': 'Jagoan'},
    {'id': 'avatar_girl', 'emoji': '👧', 'label': 'Putri'},
    {'id': 'avatar_rocket', 'emoji': '🚀', 'label': 'Astronot'},
  ];

  /// Helper untuk mengecek apakah path adalah file gambar lokal
  static bool isLocalFile(String path) {
    if (path.isEmpty || path.startsWith('avatar_')) return false;
    try {
      return File(path).existsSync();
    } catch (_) {
      return false;
    }
  }

  /// Helper untuk mendapatkan emoji jika merupakan preset avatar
  static String? getPresetEmoji(String avatarId) {
    for (final p in presetAvatars) {
      if (p['id'] == avatarId) return p['emoji'];
    }
    return null;
  }
}
