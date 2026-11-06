import 'package:flutter/material.dart';

class TrixxTheme {
  static const Color primaryGreen = Color(0xFF06382E);
  static const Color offWhite = Color(0xFFF4F7F5);
  static const Color emerald = Color(0xFF08A66A);
  static const Color mint = Color(0xFFE6F4ED);
  static const Color line = Color(0xFFDCE7E1);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF17352C);
  static const Color textMuted = Color(0xFF72827B);
  static const Color errorRed = Color(0xFFDC2626);
  static const Color successGreen = Color(0xFF16A34A);

  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      primaryColor: primaryGreen,
      scaffoldBackgroundColor: offWhite,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        primary: emerald,
        secondary: primaryGreen,
        surface: cardWhite,
        error: errorRed,
      ).copyWith(
        surfaceContainerHighest: mint,
        surface: cardWhite,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
      ),
      cardTheme: CardThemeData(
        color: cardWhite,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: line),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: emerald,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: emerald, width: 1.5),
        ),
      ),
      dividerTheme: const DividerThemeData(color: line, thickness: 1),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: textDark, fontSize: 14),
        bodySmall: TextStyle(color: textMuted, fontSize: 12),
        titleLarge: TextStyle(color: textDark, fontSize: 22, fontWeight: FontWeight.w700),
        titleMedium: TextStyle(color: textDark, fontSize: 16, fontWeight: FontWeight.w700),
      ),
      fontFamily: 'Roboto',
    );
  }
}
