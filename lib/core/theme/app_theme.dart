import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color darkGreen = Color(0xFF1B5E20);
  static const Color lightGreen = Color(0xFFE8F5E8);
  static const Color offWhite = Color(0xFFF8F9FA);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF2C3E50);
  static const Color textLight = Color(0xFF7F8C8D);
  static const Color orange = Color(0xFFFF9800);
  static const Color red = Color(0xFFE74C3C);
  static const Color blue = Color(0xFF3498DB);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: offWhite,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        brightness: Brightness.light,
        primary: primaryGreen,
        secondary: darkGreen,
        surface: cardWhite,
        background: offWhite,
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        headlineLarge: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold, color: textDark),
        headlineMedium: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w600, color: textDark),
        headlineSmall: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: textDark),
        titleLarge: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: textDark),
        titleMedium: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, color: textDark),
        bodyLarge: GoogleFonts.inter(fontSize: 16, color: textDark),
        bodyMedium: GoogleFonts.inter(fontSize: 14, color: textLight),
        bodySmall: GoogleFonts.inter(fontSize: 12, color: textLight),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: cardWhite,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: cardWhite,
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
    );
  }
  
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: cardWhite,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.04),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );
}