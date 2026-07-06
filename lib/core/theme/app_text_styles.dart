import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Central typography scale. Every screen should pull sizes/weights from
/// here instead of hand-rolling GoogleFonts.poppins(...) calls, so text
/// stays consistent across pages.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle _base({
    required double size,
    required FontWeight weight,
    required Color color,
    double? letterSpacing,
    double? height,
  }) {
    return GoogleFonts.poppins(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  /// Page-level heading, e.g. "Overview".
  static TextStyle h1({Color color = AppColors.textPrimary}) =>
      _base(size: 26, weight: FontWeight.w700, color: color);

  /// Section heading, e.g. card group titles.
  static TextStyle h2({Color color = AppColors.textPrimary}) =>
      _base(size: 20, weight: FontWeight.w600, color: color);

  /// Card/subsection heading.
  static TextStyle h3({Color color = AppColors.textPrimary}) =>
      _base(size: 16, weight: FontWeight.w600, color: color);

  /// Subtitle under a heading.
  static TextStyle subtitle({Color color = AppColors.textSecondary}) =>
      _base(size: 13.5, weight: FontWeight.w400, color: color);

  static TextStyle bodyMedium({Color color = AppColors.textPrimary}) =>
      _base(size: 14, weight: FontWeight.w500, color: color);

  static TextStyle bodyRegular({Color color = AppColors.textPrimary}) =>
      _base(size: 14, weight: FontWeight.w400, color: color);

  static TextStyle caption({Color color = AppColors.textSecondary}) =>
      _base(size: 12, weight: FontWeight.w500, color: color);

  /// Big number on a stat card.
  static TextStyle statValue({Color color = AppColors.textPrimary}) =>
      _base(size: 24, weight: FontWeight.w700, color: color);

  static TextStyle navLabel({Color color = AppColors.textSecondary}) =>
      _base(size: 13.5, weight: FontWeight.w500, color: color);

  static TextStyle buttonLabel({Color color = Colors.white}) =>
      _base(size: 14, weight: FontWeight.w600, color: color);
}
