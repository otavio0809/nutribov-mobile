import 'package:flutter/material.dart';

abstract final class FarmColors {
  static const forest = Color(0xFF193D2C);
  static const leaf = Color(0xFF396948);
  static const soil = Color(0xFF6C5139);
  static const canvas = Color(0xFFF6F5ED);
  static const straw = Color(0xFFF0DFAB);
  static const mist = Color(0xFFE4EDD9);
  static const ink = Color(0xFF202B21);
  static const mutedInk = Color(0xFF4D594F);
  static const outline = Color(0xFF758076);
  static const field = Color(0xFFF8F9F4);
}

abstract final class FarmSpace {
  static const small = 8.0;
  static const medium = 16.0;
  static const large = 24.0;
  static const radius = 20.0;
}

ThemeData farmTheme() {
  final colors =
  ColorScheme.fromSeed(
    seedColor: FarmColors.leaf,
    brightness: Brightness.light,
  ).copyWith(
    primary: FarmColors.forest,
    onPrimary: Colors.white,
    primaryContainer: FarmColors.mist,
    onPrimaryContainer: FarmColors.forest,
    secondary: FarmColors.soil,
    onSecondary: Colors.white,
    surface: FarmColors.canvas,
    onSurface: FarmColors.ink,
    surfaceContainerHighest: Colors.white,
    onSurfaceVariant: FarmColors.mutedInk,
    secondaryContainer: FarmColors.mist,
    onSecondaryContainer: FarmColors.forest,
    outline: FarmColors.outline,
    outlineVariant: const Color(0xFFBEC7BC),
  );
  final theme = ThemeData(
    useMaterial3: true,
    colorScheme: colors,
    scaffoldBackgroundColor: FarmColors.canvas,
  );
  final rounded = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(FarmSpace.radius),
  );
  return theme.copyWith(
    textTheme: theme.textTheme.copyWith(
      headlineMedium: theme.textTheme.headlineMedium?.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        height: 1.1,
        color: FarmColors.ink,
      ),
      titleLarge: theme.textTheme.titleLarge?.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: FarmColors.ink,
      ),
      titleMedium: theme.textTheme.titleMedium?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: FarmColors.ink,
      ),
      bodyLarge: theme.textTheme.bodyLarge?.copyWith(
        fontSize: 16,
        height: 1.4,
        color: FarmColors.ink,
      ),
      bodyMedium: theme.textTheme.bodyMedium?.copyWith(
        fontSize: 14,
        height: 1.4,
        color: FarmColors.ink,
      ),
      labelLarge: theme.textTheme.labelLarge?.copyWith(
        color: FarmColors.ink,
        fontWeight: FontWeight.w700,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: FarmColors.canvas,
      foregroundColor: FarmColors.forest,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        color: FarmColors.forest,
        fontSize: 22,
        fontWeight: FontWeight.w800,
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: rounded.copyWith(side: const BorderSide(color: Color(0xFFE5E8DB))),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: FarmColors.mist,
      iconTheme: WidgetStatePropertyAll(
        IconThemeData(color: FarmColors.forest),
      ),
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(color: FarmColors.ink, fontWeight: FontWeight.w600),
      ),
    ),
    listTileTheme: const ListTileThemeData(
      textColor: FarmColors.ink,
      iconColor: FarmColors.forest,
      titleTextStyle: TextStyle(
        color: FarmColors.ink,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
      subtitleTextStyle: TextStyle(
        color: FarmColors.mutedInk,
        fontSize: 14,
        height: 1.35,
      ),
    ),
    chipTheme: theme.chipTheme.copyWith(
      backgroundColor: Colors.white,
      selectedColor: FarmColors.mist,
      labelStyle: const TextStyle(
        color: FarmColors.ink,
        fontWeight: FontWeight.w600,
      ),
      secondaryLabelStyle: const TextStyle(
        color: FarmColors.forest,
        fontWeight: FontWeight.w700,
      ),
      checkmarkColor: FarmColors.forest,
      side: const BorderSide(color: FarmColors.outline),
    ),
    inputDecorationTheme: InputDecorationThemeData(
      filled: true,
      fillColor: FarmColors.field,
      labelStyle: const TextStyle(color: FarmColors.mutedInk),
      floatingLabelStyle: const TextStyle(
        color: FarmColors.forest,
        fontWeight: FontWeight.w700,
      ),
      hintStyle: const TextStyle(color: FarmColors.mutedInk),
      suffixStyle: const TextStyle(
        color: FarmColors.mutedInk,
        fontWeight: FontWeight.w600,
      ),
      prefixIconColor: FarmColors.forest,
      suffixIconColor: FarmColors.forest,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: FarmColors.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: FarmColors.forest, width: 2),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: FarmColors.forest,
        foregroundColor: Colors.white,
        disabledBackgroundColor: const Color(0xFFCBD2C9),
        disabledForegroundColor: const Color(0xFF59635B),
        minimumSize: const Size(48, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: FarmColors.forest,
        side: const BorderSide(color: FarmColors.forest),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    iconTheme: const IconThemeData(color: FarmColors.forest),
  );
}
