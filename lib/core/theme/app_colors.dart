import 'package:flutter/material.dart';

/// Central color tokens for the app. Flat, solid colors only — no gradients.
/// Orange stays the single brand/accent color; everything else is neutral
/// or a semantic status color so screens stop inventing their own palettes.
class AppColors {
  AppColors._();

  // Brand (Cloudora Orange)
  static const Color primary = Color(0xFFFF6B00);
  static const Color primaryDark = Color(0xFFE65100);
  static const Color primaryLight = Color(0xFFFFB74D);
  static const Color primarySurface = Color(0xFFFFF1E5);

  // Light surfaces & neutrals
  static const Color background = Color(0xFFF7F8FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE7E9EC);
  static const Color textPrimary = Color(0xFF1C2126);
  static const Color textSecondary = Color(0xFF667085);
  static const Color textMuted = Color(0xFF9AA2AF);

  // Dark surfaces & neutrals
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color borderDark = Color(0xFF2D3036);
  static const Color textPrimaryDark = Color(0xFFF2F3F5);
  static const Color textSecondaryDark = Color(0xFFAEB4BE);
  static const Color textMutedDark = Color(0xFF7D848F);

  // Status
  static const Color success = Color(0xFF15803D);
  static const Color successSurface = Color(0xFFE7F6EC);
  static const Color warning = Color(0xFFB45309);
  static const Color warningSurface = Color(0xFFFFF3E0);
  static const Color danger = Color(0xFFB91C1C);
  static const Color dangerSurface = Color(0xFFFCEAEA);
  static const Color info = Color(0xFF1D4ED8);
  static const Color infoSurface = Color(0xFFEAF0FE);

  // Fixed palette used for category/series charts so colors stay consistent
  // wherever a chart legend is drawn.
  static const List<Color> chartSeries = [
    info,
    success,
    primary,
    Color(0xFF7C3AED),
    danger,
    Color(0xFF0D9488),
    Color(0xFF4338CA),
    Color(0xFFDB2777),
  ];

  static Color backgroundOf(Brightness b) =>
      b == Brightness.dark ? backgroundDark : background;
  static Color surfaceOf(Brightness b) =>
      b == Brightness.dark ? surfaceDark : surface;
  static Color borderOf(Brightness b) =>
      b == Brightness.dark ? borderDark : border;
  static Color textPrimaryOf(Brightness b) =>
      b == Brightness.dark ? textPrimaryDark : textPrimary;
  static Color textSecondaryOf(Brightness b) =>
      b == Brightness.dark ? textSecondaryDark : textSecondary;
}
