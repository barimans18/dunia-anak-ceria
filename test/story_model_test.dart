import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:dunia_anak_ceria/models/story_model.dart';

void main() {
  group('StoryModel Parser Tests', () {
    test('Parses somat_pisang.json successfully and verifies all fields', () {
      final file = File('assets/stories/somat_pisang.json');
      expect(file.existsSync(), isTrue);

      final jsonMap = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final story = StoryModel.fromJson(jsonMap);

      expect(story.id, 'somat_pisang_01');
      expect(story.title, 'Pisang Manis untuk Dudung');
      expect(story.theme, 'Keluarga Somat');
      expect(story.coverImage, 'assets/images/stories/somat_pisang/page_5.webp');
      expect(story.pages.length, 5);

      // Verifikasi Halaman 1
      final page1 = story.pages[0];
      expect(page1.pageNumber, 1);
      expect(page1.imagePath, 'assets/images/stories/somat_pisang/page_1.webp');
      expect(page1.audioPath, 'assets/audio/stories/somat_pisang/page_1.mp3');
      expect(page1.syllables.isNotEmpty, isTrue);

      final syllable1 = page1.syllables.first;
      expect(syllable1.text, 'Pa-gi');
      expect(syllable1.startMs, 0);
      expect(syllable1.endMs, 600);

      expect(page1.hotspots.length, 2);
      final hotspot = page1.hotspots.first;
      expect(hotspot.name, 'Kumis Pak Somat');
      expect(hotspot.xPercent, 64.0);
      expect(hotspot.yPercent, 36.5);
      expect(hotspot.radius, 36.0);
      expect(hotspot.sfxPath, 'assets/audio/sfx/laugh.wav');
    });

    test('Parses milo_kue_pisang.json successfully and verifies all fields', () {
      final file = File('assets/stories/milo_kue_pisang.json');
      expect(file.existsSync(), isTrue);

      final jsonMap = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final story = StoryModel.fromJson(jsonMap);

      expect(story.id, 'milo_kue_pisang');
      expect(story.title, 'Kue Pisang Milo yang Manis');
      expect(story.theme, 'Kebiasaan Baik & Empati');
      expect(story.coverImage, 'assets/images/stories/milo_kue_pisang/cover.webp');
      expect(story.pages.length, 5);

      // Verifikasi Halaman 1
      final page1 = story.pages[0];
      expect(page1.pageNumber, 1);
      expect(page1.imagePath, 'assets/images/stories/milo_kue_pisang/page_1.webp');
      expect(page1.audioPath, 'assets/audio/stories/milo_kue_pisang/page_1.mp3');
      expect(page1.syllables.isNotEmpty, isTrue);

      final syllable1 = page1.syllables.first;
      expect(syllable1.text, 'Mi-lo');
      expect(syllable1.startMs, 0);
      expect(syllable1.endMs, 550);

      expect(page1.hotspots.length, 2);
      final hotspot = page1.hotspots.first;
      expect(hotspot.name, 'Kue Pisang Harum');
      expect(hotspot.xPercent, 45.0);
      expect(hotspot.yPercent, 59.0);
      expect(hotspot.radius, 42.0);
      expect(hotspot.sfxPath, 'assets/audio/sfx/steam_sparkle.wav');
    });
  });
}
