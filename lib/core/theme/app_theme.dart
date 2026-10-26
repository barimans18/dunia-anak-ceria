import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.fredokaTextTheme();
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.sunnyYellow,
        primary: AppColors.warmAmber,
        secondary: AppColors.primarySky,
        surface: AppColors.cardBg,
      ),
      scaffoldBackgroundColor: Colors.transparent,
      textTheme: baseTextTheme.copyWith(
        displayLarge: GoogleFonts.fredoka(fontWeight: FontWeight.w700, color: AppColors.textDark),
        displayMedium: GoogleFonts.fredoka(fontWeight: FontWeight.w700, color: AppColors.textDark),
        titleLarge: GoogleFonts.fredoka(fontWeight: FontWeight.w700, color: AppColors.textDark),
        titleMedium: GoogleFonts.fredoka(fontWeight: FontWeight.w600, color: AppColors.textDark),
        bodyLarge: GoogleFonts.fredoka(fontWeight: FontWeight.w500, color: AppColors.textDark),
        bodyMedium: GoogleFonts.fredoka(fontWeight: FontWeight.w500, color: AppColors.textMedium),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBg,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }
}
