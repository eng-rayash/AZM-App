import 'package:flutter/material.dart';

import 'neu_colors.dart';

/// Executive Design System — Decorations
///
/// Core BoxDecoration presets for cards, inputs and pressed states.
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
  // Modern Enterprise UI Soft Cards
  // ─────────────────────────────────────────────

  /// Standard Enterprise flat card decoration (Soft Premium Elevation)
  static BoxDecoration neuFlat({
    double radius = 16,
    bool isDark = false,
    Color? color,
  }) =>
      BoxDecoration(
        color: color ?? (isDark ? NeuColors.surfaceDark : NeuColors.surface),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: isDark ? NeuColors.borderDark : NeuColors.border,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.04),
            offset: const Offset(0, 4),
            blurRadius: 16,
            spreadRadius: 0,
          ),
        ],
      );

  /// Soft flat — lighter elevation for sub-components and lists
  static BoxDecoration neuFlatSoft({
    double radius = 12,
    bool isDark = false,
    Color? color,
  }) =>
      BoxDecoration(
        color: color ?? (isDark ? NeuColors.surfaceDark : NeuColors.surface),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: isDark ? NeuColors.borderDark : NeuColors.border,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.02),
            offset: const Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      );

  // ─────────────────────────────────────────────
  // Pressed — Active/Selected state
  // ─────────────────────────────────────────────

  /// Pressed state — subtle active highlight
  static BoxDecoration neuPressed({
    double radius = 16,
    bool isDark = false,
    Color? color,
  }) =>
      BoxDecoration(
        color: color ??
            (isDark
                ? NeuColors.surfaceDark.withValues(alpha: 0.8)
                : NeuColors.primaryTint.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: isDark ? NeuColors.goldAccent : NeuColors.primary,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? NeuColors.goldAccent.withValues(alpha: 0.15)
                : NeuColors.primary.withValues(alpha: 0.1),
            offset: const Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      );

  // ─────────────────────────────────────────────
  // Concave / Inputs — Enterprise Input Fields
  // ─────────────────────────────────────────────

  /// Enterprise input decoration — clean container with focus border support
  static BoxDecoration neuConcave({
    double radius = 12,
    bool isDark = false,
  }) =>
      BoxDecoration(
        color: isDark ? NeuColors.surfaceDark : NeuColors.surfaceElevated,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: isDark ? NeuColors.borderDark : NeuColors.border,
          width: 1,
        ),
      );

  // ─────────────────────────────────────────────
  // Special — With accent border
  // ─────────────────────────────────────────────

  /// Enterprise decoration tinted by an accent (Crimson in light, Gold in dark).
  ///
  /// A `Border` whose sides differ in colour or width is illegal together with
  /// a `borderRadius` — Flutter throws on every paint. So the accent is carried
  /// by a uniform tinted border plus a matching glow instead of a single thick
  /// side. For a genuine edge stripe use [AccentStripe] as an overlay.
  static BoxDecoration neuFlatWithGoldTop({
    double radius = 16,
    bool isDark = false,
  }) {
    final accent = isDark ? NeuColors.goldAccent : NeuColors.primary;
    return neuFlatWithAccent(
      accentColor: accent,
      radius: radius,
      isDark: isDark,
    );
  }

  /// Enterprise decoration carrying a status colour.
  static BoxDecoration neuFlatWithStatusBar({
    required Color statusColor,
    double radius = 16,
    bool isDark = false,
  }) =>
      neuFlatWithAccent(
        accentColor: statusColor,
        radius: radius,
        isDark: isDark,
      );

  /// Card decoration whose outline and glow take an accent colour.
  ///
  /// Border and shadow stay uniform, so it is safe to combine with any
  /// [BorderRadius].
  static BoxDecoration neuFlatWithAccent({
    required Color accentColor,
    double radius = 16,
    bool isDark = false,
    Color? color,
  }) =>
      BoxDecoration(
        color: color ?? (isDark ? NeuColors.surfaceDark : NeuColors.surface),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: accentColor.withValues(alpha: isDark ? 0.32 : 0.22),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: isDark ? 0.16 : 0.10),
            offset: const Offset(0, 4),
            blurRadius: 16,
          ),
        ],
      );
}

/// A rounded accent stripe pinned to the leading edge of a card.
///
/// Drop it into a [Stack] above a rounded container. This is the supported way
/// to show a status/priority edge on a card: `BoxDecoration` cannot combine a
/// single thick [Border] side with a [BorderRadius] — that combination throws
/// `A borderRadius can only be given on borders with uniform colors` on every
/// paint.
class AccentStripe extends StatelessWidget {
  const AccentStripe({
    super.key,
    required this.color,
    this.width = 4,
    this.inset = 12,
  });

  /// Stripe colour — usually a status or priority colour.
  final Color color;

  /// Stripe thickness.
  final double width;

  /// Gap left above and below the stripe so it reads as a deliberate pill
  /// rather than a clipped border.
  final double inset;

  @override
  Widget build(BuildContext context) {
    return PositionedDirectional(
      start: 0,
      top: inset,
      bottom: inset,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(width / 2),
        ),
      ),
    );
  }
}
