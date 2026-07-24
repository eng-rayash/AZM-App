import 'package:flutter/material.dart';

/// Executive Neumorphism Design System — Spacing Tokens
///
/// Consistent spacing scale used across the entire application.
/// All margins, paddings, and gaps reference these constants.
class AppSpacing {
  AppSpacing._();

  // ─────────────────────────────────────────────
  // Spacing Scale
  // ─────────────────────────────────────────────

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double xxxxl = 40.0;
  static const double huge = 48.0;
  static const double massive = 64.0;

  // ─────────────────────────────────────────────
  // Padding Presets
  // ─────────────────────────────────────────────

  /// Screen horizontal padding
  static const EdgeInsets screenH =
      EdgeInsets.symmetric(horizontal: lg);

  /// Screen padding with vertical
  static const EdgeInsets screen =
      EdgeInsets.symmetric(horizontal: lg, vertical: md);

  /// Card internal padding
  static const EdgeInsets card =
      EdgeInsets.all(lg);

  /// Card compact padding
  static const EdgeInsets cardCompact =
      EdgeInsets.all(md);

  /// Section padding (between major sections)
  static const EdgeInsets section =
      EdgeInsets.symmetric(vertical: xxl);

  /// List item padding
  static const EdgeInsets listItem =
      EdgeInsets.symmetric(horizontal: lg, vertical: md);

  /// Button internal padding
  static const EdgeInsets button =
      EdgeInsets.symmetric(horizontal: xxl, vertical: md);

  /// Input field padding
  static const EdgeInsets input =
      EdgeInsets.symmetric(horizontal: lg, vertical: md);

  // ─────────────────────────────────────────────
  // Gap Helpers (for Column/Row spacing)
  // ─────────────────────────────────────────────

  static const SizedBox gapXs = SizedBox(height: xs);
  static const SizedBox gapSm = SizedBox(height: sm);
  static const SizedBox gapMd = SizedBox(height: md);
  static const SizedBox gapLg = SizedBox(height: lg);
  static const SizedBox gapXl = SizedBox(height: xl);
  static const SizedBox gapXxl = SizedBox(height: xxl);
  static const SizedBox gapXxxl = SizedBox(height: xxxl);

  static const SizedBox gapHXs = SizedBox(width: xs);
  static const SizedBox gapHSm = SizedBox(width: sm);
  static const SizedBox gapHMd = SizedBox(width: md);
  static const SizedBox gapHLg = SizedBox(width: lg);
  static const SizedBox gapHXl = SizedBox(width: xl);
  static const SizedBox gapHXxl = SizedBox(width: xxl);
}