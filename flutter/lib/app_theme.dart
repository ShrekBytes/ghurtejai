import 'package:flutter/material.dart';

/// Dark Material 3 theme aligned with Explore / Experiences (`AppColors`).
ThemeData appDarkTheme() {
  const outline = AppColors.border;
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: AppColors.bg,
      secondary: AppColors.green,
      onSecondary: AppColors.bg,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      surfaceContainerHighest: AppColors.surfaceHigh,
      outline: outline,
      error: const Color(0xFFFF4D8D),
      onError: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bg,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      modalBarrierColor: Color(0x99000000),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
    ),
    dividerTheme: const DividerThemeData(color: AppColors.border),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.bg,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.border),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.primary),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.surfaceHigh,
      contentTextStyle: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 14,
      ),
      behavior: SnackBarBehavior.floating,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceHigh,
      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
      labelStyle: const TextStyle(color: AppColors.textSub),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    ),
  );
}

class AppColors {
  static const bg = Color(0xFF0F1117);
  static const surface = Color(0xFF1A1D26);
  static const surfaceHigh = Color(0xFF242837);
  static const primary = Color(0xFFE8A045);
  static const primarySoft = Color(0x33E8A045);
  static const green = Color(0xFF3EBF7A);
  static const greenSoft = Color(0x223EBF7A);
  static const textPrimary = Color(0xFFF0EDE6);
  static const textSub = Color(0xFF9097A8);
  static const textMuted = Color(0xFF5A6070);
  static const border = Color(0xFF2A2F3E);
  static const aiGlow = Color(0xFF7C6FE0);
  static const aiSoft = Color(0x337C6FE0);
}

class AppText {
  static const display = TextStyle(
    fontFamily: 'Georgia',
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );
  static const title = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0.1,
  );
  static const body = TextStyle(
    fontSize: 13,
    color: AppColors.textSub,
    height: 1.4,
  );
  static const label = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
    color: AppColors.textMuted,
  );
  static const chip = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );
}

final List<String> filterTags = [
  "All",
  "Beach",
  "Mountain",
  "Nature",
  "Adventure",
  "Food",
  "Cultural",
  "River",
];
