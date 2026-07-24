import 'package:flutter/material.dart';

import 'neu_colors.dart';

/// Executive Neumorphism Design System — Decorations
///
/// Core BoxDecoration presets for the Neumorphism effect.
/// Three states: Flat (default), Pressed (active), Concave (inputs).
class NeuDecorations {
  NeuDecorations._();

  // ─────────────────────────────────────────────
  // Animation Constants
  // ─────────────────────────────────────────────

  /// Standard press animation duration
  static const Duration pressDuration = Duration(milliseconds: 150);

  /// Standard animation curve
  static const Curve pressCurve = Curves.easeInOut;

  // ─────────────────────────────────────────────
  // Flat — Default raised surface
  // ─────────────────────────────────────────────

  /// Standard Neumorphic flat decoration (raised effect)
  static BoxDecoration neuFlat({
    double radius = 20,
    bool isDark = false,
    Color? color,
  }) =>
      BoxDecoration(
        color: color ?? (isDark ? NeuColors.bgColorDark : NeuColors.bgColor),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: isDark ? NeuColors.shadowDarkDark : NeuColors.shadowDark,
            offset: const Offset(5, 5),
            blurRadius: 12,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: isDark ? NeuColors.shadowLightDark : NeuColors.shadowLight,
            offset: const Offset(-5, -5),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      );

  /// Soft flat — lighter shadows for smaller components
  static BoxDecoration neuFlatSoft({
    double radius = 16,
    bool isDark = false,
    Color? color,
  }) =>
      BoxDecoration(
        color: color ?? (isDark ? NeuColors.bgColorDark : NeuColors.bgColor),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: isDark ? NeuColors.shadowDarkDark : NeuColors.shadowDark,
            offset: const Offset(3, 3),
            blurRadius: 8,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: isDark ? NeuColors.shadowLightDark : NeuColors.shadowLight,
            offset: const Offset(-3, -3),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      );

  // ─────────────────────────────────────────────
  // Pressed — Active/Selected state
  // ─────────────────────────────────────────────

  /// Pressed state — inset shadow effect
  static BoxDecoration neuPressed({
    double radius = 20,
    bool isDark = false,
    Color? color,
  }) =>
      BoxDecoration(
        color: color ?? (isDark ? NeuColors.bgColorDark : NeuColors.bgColor),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: isDark ? NeuColors.shadowDarkDark : NeuColors.shadowDark,
            offset: const Offset(2, 2),
            blurRadius: 5,
          ),
          BoxShadow(
            color: isDark ? NeuColors.shadowLightDark : NeuColors.shadowLight,
            offset: const Offset(-2, -2),
            blurRadius: 5,
          ),
        ],
      );

  // ─────────────────────────────────────────────
  // Concave — Input fields, search bars
  // ─────────────────────────────────────────────

  /// Concave decoration — sunken effect for input fields
  static BoxDecoration neuConcave({
    double radius = 16,
    bool isDark = false,
  }) =>
      BoxDecoration(
        color: isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  NeuColors.shadowDarkDark.withValues(alpha: 0.4),
                  NeuColors.bgColorDark,
                ]
              : [
                  NeuColors.shadowDark.withValues(alpha: 0.35),
                  NeuColors.bgColor,
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? NeuColors.shadowDarkDark : NeuColors.shadowDark,
            offset: const Offset(4, 4),
            blurRadius: 10,
          ),
          BoxShadow(
            color: isDark ? NeuColors.shadowLightDark : NeuColors.shadowLight,
            offset: const Offset(-4, -4),
            blurRadius: 10,
          ),
        ],
      );

  // ─────────────────────────────────────────────
  // Special — With accent border
  // ─────────────────────────────────────────────

  /// Flat decoration with accent top border (for dashboard cards)
  static BoxDecoration neuFlatWithGoldTop({
    double radius = 24,
    bool isDark = false,
  }) =>
      neuFlat(radius: radius, isDark: isDark).copyWith(
        border: Border(
          top: BorderSide(
            color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
            width: 3,
          ),
        ),
      );

  /// Flat decoration with status color left bar (for meeting/task cards)
  static BoxDecoration neuFlatWithStatusBar({
    required Color statusColor,
    double radius = 20,
    bool isDark = false,
  }) =>
      neuFlat(radius: radius, isDark: isDark).copyWith(
        border: Border(
          right: BorderSide(
            color: statusColor,
            width: 5,
          ),
        ),
      );
}