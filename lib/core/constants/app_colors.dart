import 'package:flutter/material.dart';

class AppColors {
  static const Color primarySky = Color(0xFF60A5FA);
  static const Color skyLight = Color(0xFF93C5FD);
  static const Color grassGreen = Color(0xFF86EFAC);
  static const Color sunnyYellow = Color(0xFFFBBF24);
  static const Color warmAmber = Color(0xFFF59E0B);
  static const Color coralOrange = Color(0xFFFB923C);
  static const Color coralRed = Color(0xFFF43F5E);
  static const Color softPink = Color(0xFFF472B6);
  static const Color playfulPurple = Color(0xFFA855F7);
  static const Color emeraldGreen = Color(0xFF10B981);
  static const Color rubyRed = Color(0xFFEF4444);
  
  static const Color textDark = Color(0xFF1E293B);
  static const Color textMedium = Color(0xFF475569);
  static const Color cardBg = Colors.white;

  // Background Gradient
  static const LinearGradient mainGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF60A5FA),
      Color(0xFF93C5FD),
      Color(0xFF86EFAC),
    ],
    stops: [0.0, 0.55, 1.0],
  );

  static const LinearGradient cardAmberGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
  );

  static const LinearGradient cardSkyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE0F2FE), Color(0xFFBAE6FD)],
  );

  static const LinearGradient cardGreenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFD1FAE5), Color(0xFFA7F3D0)],
  );

  static const LinearGradient cardRoseGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFE4E6), Color(0xFFFECDD3)],
  );

  static const LinearGradient cardPurpleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF3E8FF), Color(0xFFE9D5FF)],
  );
}
