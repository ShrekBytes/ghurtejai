import 'package:flutter/material.dart';

/// Semantic colors and layout tokens — prefer these over raw [GJ] in new UI.
abstract final class GJTokens {
  static const Color surface = Color(0xFFF7F4EE);
  static const Color surfaceElevated = Color(0xFFFAFAF7);
  static const Color accent = Color(0xFFE07830);
  static const Color onAccent = Color(0xFF111111);
  static const Color onSurface = Color(0xFF111111);
  static const Color danger = Color(0xFFC23B22);
  static const Color outline = Color(0xFF111111);

  /// Subtle wash behind primary tab content (warm, minimal).
  static const Color tabCanvas = Color(0xFFF5EFE6);

  static const double radiusSm = 10;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double maxContentWidth = 520;

  static const List<Color> authGradient = [
    Color(0xFFFFF6ED),
    Color(0xFFE8F4FC),
    surface,
  ];
}
