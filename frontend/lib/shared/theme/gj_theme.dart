import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'gj_palette.dart';
import 'gj_tokens.dart';

ThemeData buildGJTheme() {
  final colorScheme = ColorScheme.light(
    primary: GJTokens.accent,
    onPrimary: GJTokens.onAccent,
    secondary: GJ.orange,
    onSecondary: GJ.dark,
    surface: GJTokens.surfaceElevated,
    onSurface: GJTokens.onSurface,
    error: GJTokens.danger,
    onError: GJ.white,
  );

  final baseText = GoogleFonts.plusJakartaSansTextTheme();
  final textTheme = baseText.apply(
    bodyColor: GJTokens.onSurface,
    displayColor: GJTokens.onSurface,
  );

  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(GJTokens.radiusMd),
    borderSide: BorderSide(color: GJTokens.outline.withValues(alpha: 0.28), width: 1.5),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: GJTokens.surface,
    textTheme: textTheme,
    fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      backgroundColor: GJTokens.surface,
      foregroundColor: GJTokens.onSurface,
      titleTextStyle: GoogleFonts.plusJakartaSans(
        fontWeight: FontWeight.w700,
        fontSize: 18,
        color: GJTokens.onSurface,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: GJTokens.surfaceElevated,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(GJTokens.radiusMd),
        borderSide: const BorderSide(color: GJTokens.outline, width: 2),
      ),
      enabledBorder: border,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(GJTokens.radiusMd),
        borderSide: const BorderSide(color: GJTokens.outline, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: GJTokens.accent,
        foregroundColor: GJTokens.onAccent,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GJTokens.radiusMd),
          side: const BorderSide(color: GJTokens.outline, width: 2),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: GJTokens.onSurface,
        textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: GJTokens.surfaceElevated,
      indicatorColor: GJ.yellow.withValues(alpha: 0.45),
      labelTextStyle: WidgetStatePropertyAll(
        GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600),
      ),
    ),
  );
}
