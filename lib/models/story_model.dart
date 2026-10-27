import 'dart:convert';
import 'package:flutter/services.dart';

/// Model untuk hotspot interaktif pada gambar halaman cerita.
class InteractiveHotspot {
  final String name;
  final double xPercent;
  final double yPercent;
  final double radius;
  final String sfxPath;

  InteractiveHotspot({
    required this.name,
    required this.xPercent,
    required this.yPercent,
    required this.radius,
    required this.sfxPath,
  });

  factory InteractiveHotspot.fromJson(Map<String, dynamic> json) {
    return InteractiveHotspot(
      name: json['name'] as String? ?? '',
      xPercent: (json['x_percent'] as num?)?.toDouble() ?? 0.0,
      yPercent: (json['y_percent'] as num?)?.toDouble() ?? 0.0,
      radius: (json['radius'] as num?)?.toDouble() ?? 40.0,
      sfxPath: json['sfx_path'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'x_percent': xPercent,
    'y_percent': yPercent,
    'radius': radius,
    'sfx_path': sfxPath,
  };
}

/// Token suku kata untuk sinkronisasi karaoke narasi audio & pelafalan TTS.
class SyllableToken {
  final String text;
  final int startMs;
  final int endMs;

  SyllableToken({
    required this.text,
    required this.startMs,
    required this.endMs,
  });

  factory SyllableToken.fromJson(Map<String, dynamic> json) {
    return SyllableToken(
      text: json['text'] as String? ?? '',
      startMs: (json['start_ms'] as num?)?.toInt() ?? 0,
      endMs: (json['end_ms'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'text': text,
    'start_ms': startMs,
    'end_ms': endMs,
  };
}

/// Model untuk setiap lembar halaman cerita.
class StoryPage {
  final int pageNumber;
  final String imagePath;
  final String audioPath;
  final String fullText;
  final List<SyllableToken> syllables;
  final List<InteractiveHotspot> hotspots;

  StoryPage({
    required this.pageNumber,
    required this.imagePath,
    required this.audioPath,
    required this.fullText,
    required this.syllables,
    required this.hotspots,
  });

  factory StoryPage.fromJson(Map<String, dynamic> json) {
    return StoryPage(
      pageNumber: (json['page_number'] as num?)?.toInt() ?? 1,
      imagePath: json['image_path'] as String? ?? '',
      audioPath: json['audio_path'] as String? ?? '',
      fullText: json['full_text'] as String? ?? '',
      syllables: (json['syllables'] as List<dynamic>?)
              ?.map((item) => SyllableToken.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      hotspots: (json['hotspots'] as List<dynamic>?)
              ?.map((item) => InteractiveHotspot.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'page_number': pageNumber,
    'image_path': imagePath,
    'audio_path': audioPath,
    'full_text': fullText,
    'syllables': syllables.map((s) => s.toJson()).toList(),
    'hotspots': hotspots.map((h) => h.toJson()).toList(),
  };
}

/// Model data buku cerita interaktif.
class StoryModel {
  final String id;
  final String title;
  final String theme;
  final String coverImage;
  final List<StoryPage> pages;

  StoryModel({
    required this.id,
    required this.title,
    required this.theme,
    required this.coverImage,
    required this.pages,
  });

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    return StoryModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      theme: json['theme'] as String? ?? '',
      coverImage: json['cover_image'] as String? ?? '',
      pages: (json['pages'] as List<dynamic>?)
              ?.map((item) => StoryPage.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// Membaca file cerita JSON dari rootBundle asset
  static Future<StoryModel> fromAsset(String assetPath) async {
    final jsonString = await rootBundle.loadString(assetPath);
    final dynamic decoded = jsonDecode(jsonString);
    if (decoded is Map<String, dynamic>) {
      return StoryModel.fromJson(decoded);
    }
    throw FormatException('Invalid JSON format for StoryModel in $assetPath');
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'theme': theme,
    'cover_image': coverImage,
    'pages': pages.map((p) => p.toJson()).toList(),
  };
}
