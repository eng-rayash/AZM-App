import 'package:flutter/material.dart';

/// Executive Neumorphism Design System — Border Radius Tokens
///
/// Consistent border radius values matching the Neumorphism spec.
/// Each component type has a designated radius.
class AppRadius {
  AppRadius._();

  // ─────────────────────────────────────────────
  // Raw Values
  // ─────────────────────────────────────────────

  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double xxl = 28.0;
  static const double round = 50.0;

  // ─────────────────────────────────────────────
  // Component-Specific BorderRadius
  // ─────────────────────────────────────────────

  /// Dashboard cards — large, prominent
  static final BorderRadius dashboardCard = BorderRadius.circular(xl);

  /// Meeting cards, task cards
  static final BorderRadius card = BorderRadius.circular(lg);

  /// Input fields
  static final BorderRadius input = BorderRadius.circular(md);

  /// Small chips, badges
  static final BorderRadius chip = BorderRadius.circular(sm);

  /// Buttons
  static final BorderRadius button = BorderRadius.circular(md);

  /// Bottom navigation
  static final BorderRadius bottomNav = BorderRadius.zero;

  /// Floating action button
  static final BorderRadius fab = BorderRadius.circular(round);

  /// Bottom sheet
  static final BorderRadius bottomSheet = BorderRadius.only(
    topLeft: Radius.circular(xl),
    topRight: Radius.circular(xl),
  );

  /// Dialog
  static final BorderRadius dialog = BorderRadius.circular(xl);

  /// Stats widget
  static final BorderRadius stats = BorderRadius.circular(lg);
}