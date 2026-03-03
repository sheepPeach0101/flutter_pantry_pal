import 'package:PantryPal/theme/light.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static final currentColors = Light();
  static const double radius_lg = 16.0;
  static const double spacing_base = 12.0;
  static ThemeData get lightTheme {
    final baseTheme = ThemeData.light();
    return baseTheme.copyWith(
      primaryColor: currentColors.ih_accent,
      scaffoldBackgroundColor: currentColors.ih_bg,
      colorScheme: ColorScheme.light(
        primary: currentColors.ih_accent,
        surface: currentColors.ih_surface,
        onSurface: currentColors.ih_text,
        error: currentColors.ih_negative,
      ),
      textTheme: GoogleFonts.interTextTheme(baseTheme.textTheme).copyWith(
        headlineMedium: GoogleFonts.inter(
          color: currentColors.ih_text,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic,
        ),
        bodyLarge:
            GoogleFonts.inter(color: currentColors.ih_text, fontSize: 18),
        bodyMedium: GoogleFonts.inter(
            color: currentColors.ih_text_secondary, fontSize: 14),
        labelSmall: GoogleFonts.inter(
            color: currentColors.ih_text_muted, fontSize: 11, letterSpacing: 2),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: currentColors.ih_accent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius_lg),
          ),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 48),
          textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: currentColors.ih_surface,
        contentPadding: const EdgeInsets.all(24),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius_lg),
          borderSide: BorderSide(color: currentColors.ih_border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius_lg),
          borderSide: BorderSide(color: currentColors.ih_border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius_lg),
          borderSide: BorderSide(color: currentColors.ih_accent, width: 2),
        ),
      ),
    );
  }
}
