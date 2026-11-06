import 'package:flutter/material.dart';

class TrolleyTheme {
	static const Color forest = Color(0xFF06382E);
	static const Color emerald = Color(0xFF08A66A);
	static const Color mint = Color(0xFFE6F4ED);
	static const Color background = Color(0xFFF4F7F5);
	static const Color line = Color(0xFFDCE7E1);
	static const Color ink = Color(0xFF17352C);
	static const Color muted = Color(0xFF72827B);

	static ThemeData get themeData => ThemeData(
				useMaterial3: true,
				colorScheme: ColorScheme.fromSeed(seedColor: forest).copyWith(
					primary: emerald,
					secondary: forest,
					surface: Colors.white,
					surfaceContainerHighest: mint,
				),
				scaffoldBackgroundColor: background,
				appBarTheme: const AppBarTheme(
					backgroundColor: forest,
					foregroundColor: Colors.white,
					elevation: 0,
					titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
				),
				cardTheme: CardThemeData(
					color: Colors.white,
					elevation: 0,
					margin: EdgeInsets.zero,
					shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: line)),
				),
				inputDecorationTheme: InputDecorationTheme(
					filled: true,
					fillColor: Colors.white,
					border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: line)),
					enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: line)),
					focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: emerald, width: 1.5)),
				),
				elevatedButtonTheme: ElevatedButtonThemeData(
					style: ElevatedButton.styleFrom(
						backgroundColor: emerald,
						foregroundColor: Colors.white,
						minimumSize: const Size.fromHeight(52),
						shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
						textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
					),
				),
			);
}
