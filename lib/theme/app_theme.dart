import 'package:flutter/material.dart';

class AppTheme {
  // Brand accents matching the original app
  static const Color primaryBlue = Color(0xFF3860F4);
  static const Color prepCyan = Color(0xFF00B4D8);
  static const Color workGreen = Color(0xFF10B981);
  static const Color repRestPurple = Color(0xFF8B5CF6);
  static const Color restOrange = Color(0xFFF59E0B);

  static ThemeData lightTheme() {
    final baseColorScheme = ColorScheme.fromSeed(
      seedColor: primaryBlue,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: baseColorScheme,
      scaffoldBackgroundColor: baseColorScheme.surface,
      cardTheme: CardThemeData(
        elevation: 0,
        shape: roundedCornerShape(32),
        color: baseColorScheme.surfaceContainerLow,
      ),
      dialogTheme: DialogThemeData(
        shape: roundedCornerShape(32),
        elevation: 6,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
        ),
        showDragHandle: true,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: const StadiumBorder(),
          elevation: 2,
        ),
      ),
      chipTheme: ChipThemeData(
        shape: const StadiumBorder(),
        side: BorderSide.none,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: baseColorScheme.surface,
        foregroundColor: baseColorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      fontFamily: 'Roboto',
    );
  }

  static ThemeData darkTheme() {
    final baseColorScheme = ColorScheme.fromSeed(
      seedColor: primaryBlue,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: baseColorScheme,
      scaffoldBackgroundColor: baseColorScheme.surface,
      cardTheme: CardThemeData(
        elevation: 0,
        shape: roundedCornerShape(32),
        color: baseColorScheme.surfaceContainer,
      ),
      dialogTheme: DialogThemeData(
        shape: roundedCornerShape(32),
        elevation: 6,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
        ),
        showDragHandle: true,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: const StadiumBorder(),
          elevation: 2,
        ),
      ),
      chipTheme: ChipThemeData(
        shape: const StadiumBorder(),
        side: BorderSide.none,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: baseColorScheme.surface,
        foregroundColor: baseColorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      fontFamily: 'Roboto',
    );
  }

  static RoundedRectangleBorder roundedCornerShape([double radius = 32]) {
    return RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius));
  }
}
