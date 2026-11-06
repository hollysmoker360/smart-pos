import 'package:flutter/material.dart';

import 'scanflow_colors.dart';

abstract final class ScanFlowTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: ScanFlowColors.forest,
          primary: ScanFlowColors.emerald,
          secondary: ScanFlowColors.forest,
          surface: ScanFlowColors.surface,
          error: ScanFlowColors.error,
        ).copyWith(surfaceContainerHighest: ScanFlowColors.mint),
        scaffoldBackgroundColor: ScanFlowColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: ScanFlowColors.forest,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        cardTheme: CardThemeData(
          color: ScanFlowColors.surface,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: ScanFlowColors.line),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: ScanFlowColors.emerald,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: ScanFlowColors.surface,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: ScanFlowColors.line),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: ScanFlowColors.line),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide:
                const BorderSide(color: ScanFlowColors.emerald, width: 1.5),
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: ScanFlowColors.line,
          thickness: 1,
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: ScanFlowColors.ink, fontSize: 14),
          bodySmall: TextStyle(color: ScanFlowColors.muted, fontSize: 12),
          titleLarge: TextStyle(
            color: ScanFlowColors.ink,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
          titleMedium: TextStyle(
            color: ScanFlowColors.ink,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
}
