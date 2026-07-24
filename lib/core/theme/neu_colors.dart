import 'package:flutter/material.dart';

/// RVIOS Design System — Color Tokens
///
/// Primary   #9E2226  (Crimson Red — Executive Identity)
/// Ivory     #FAF8ED  (Light Background)
/// Graphite  #171717  (Dark Background)
/// Gray      #6B6B6B  (Secondary Text)
/// Gold      #C8A45D  (Premium Accent)
///
/// All colors are centralized here. No hardcoded colors anywhere else.
/// The system supports Light and Dark themes.
class NeuColors {
  NeuColors._();

  // ─────────────────────────────────────────────
  // Brand / Primary — Crimson Red Family (RVIOS Identity)
  // ─────────────────────────────────────────────

  /// Primary — Crimson Red (RVIOS executive identity)
  static const Color primary = Color(0xFF9E2226);

  /// Primary dark (pressed states, deep accents)
  static const Color primaryDark = Color(0xFF7A1A1D);

  /// Primary mid (hover, secondary states)
  static const Color primaryMid = Color(0xFFB52A2E);

  /// Primary light (tints, subtle highlights)
  static const Color primaryLight = Color(0xFFD45558);

  /// Primary tint (very subtle backgrounds, tags)
  static const Color primaryTint = Color(0xFFF5E0E1);

  // Legacy aliases — kept for backward compat during migration
  static const Color navyDeep = primary;
  static const Color navyMid = primaryMid;
  static const Color navyLight = primaryLight;
  static const Color navyTint = primaryTint;
  static const Color navyDark = primaryDark;

  // ─────────────────────────────────────────────
  // Brand / Gold — Premium Accent Family
  // ─────────────────────────────────────────────

  /// Gold — Premium accent (use sparingly, 1 per screen max)
  static const Color gold = Color(0xFFC8A45D);

  /// Gold light (backgrounds, subtle tints)
  static const Color goldLight = Color(0xFFE8D4A8);

  /// Gold dark (text on light backgrounds)
  static const Color goldDark = Color(0xFF9E7E3A);

  /// Gold tint (very subtle fills)
  static const Color goldTint = Color(0xFFFAF3E3);

  // Legacy alias
  static const Color goldAccent = gold;

  // ─────────────────────────────────────────────
  // Light Theme Colors — Ivory Foundation
  // ─────────────────────────────────────────────

  /// Main background — Ivory (RVIOS light foundation)
  static const Color bgColor = Color(0xFFF5F3E8);

  /// Card / surface — Lighter ivory
  static const Color surface = Color(0xFFFAF8ED);

  /// Elevated surface (modals, sheets, dialogs)
  static const Color surfaceElevated = Color(0xFFFFFFFF);

  /// Soft elevation border & shadow
  static const Color shadowDark = Color(0xFFE0DDD0);

  /// Light shadow (top-left — highlight)
  static const Color shadowLight = Color(0xFFFFFFFF);

  // ─────────────────────────────────────────────
  // Dark Theme Colors — Graphite Foundation
  // ─────────────────────────────────────────────

  /// Dark theme background — Graphite
  static const Color bgColorDark = Color(0xFF111315);

  /// Dark theme surface — Graphite Card
  static const Color surfaceDark = Color(0xFF1A1D20);

  /// Dark theme elevated surface
  static const Color surfaceElevatedDark = Color(0xFF24272C);

  /// Dark theme dark shadow
  static const Color shadowDarkDark = Color(0xFF08090A);

  /// Dark theme light shadow
  static const Color shadowLightDark = Color(0xFF22262B);

  // ─────────────────────────────────────────────
  // Status Colors
  // ─────────────────────────────────────────────

  /// Success / Completed
  static const Color success = Color(0xFF10B981);

  /// Warning / Pending / In Progress
  static const Color warning = Color(0xFFF59E0B);

  /// Danger / Overdue / Cancelled
  static const Color danger = Color(0xFFEF4444);

  /// Info / Scheduled / New
  static const Color info = Color(0xFF3B82F6);

  // ─────────────────────────────────────────────
  // Text Colors — Light Theme
  // ─────────────────────────────────────────────

  /// Primary text (headings, important content)
  static const Color textPrimary = Color(0xFF111315);

  /// Secondary text — Gray
  static const Color textSecondary = Color(0xFF6B6B6B);

  /// Hint / placeholder text
  static const Color textHint = Color(0xFF9E9E9E);

  /// Text on dark/colored backgrounds
  static const Color textOnDark = Color(0xFFFAF8ED);

  /// Text on accent backgrounds
  static const Color textOnAccent = Color(0xFFFFFFFF);

  // ─────────────────────────────────────────────
  // Text Colors — Dark Theme
  // ─────────────────────────────────────────────

  static const Color textPrimaryDark = Color(0xFFFAF8ED);
  static const Color textSecondaryDark = Color(0xFFA0A5AC);
  static const Color textHintDark = Color(0xFF6C727E);

  // ─────────────────────────────────────────────
  // Priority Colors
  // ─────────────────────────────────────────────

  /// عاجل جدًا — Critical
  static const Color priorityCritical = Color(0xFF9E2226);

  /// عالي — High
  static const Color priorityHigh = Color(0xFFF59E0B);

  /// متوسط — Medium
  static const Color priorityMedium = Color(0xFF3B82F6);

  /// منخفض — Low
  static const Color priorityLow = Color(0xFF9E9E9E);

  // ─────────────────────────────────────────────
  // Divider & Border
  // ─────────────────────────────────────────────

  static const Color divider = Color(0xFFE0DDD0);
  static const Color dividerDark = Color(0xFF2E2E2E);
  static const Color border = Color(0xFFE0DDD0);
  static const Color borderDark = Color(0xFF2E2E2E);

  // ─────────────────────────────────────────────
  // Helper — Get color by brightness
  // ─────────────────────────────────────────────

  /// Returns the appropriate background color based on brightness
  static Color background(Brightness brightness) =>
      brightness == Brightness.dark ? bgColorDark : bgColor;

  /// Returns the appropriate surface color based on brightness
  static Color surfaceColor(Brightness brightness) =>
      brightness == Brightness.dark ? surfaceDark : surface;

  /// Returns the dark shadow based on brightness
  static Color darkShadow(Brightness brightness) =>
      brightness == Brightness.dark ? shadowDarkDark : shadowDark;

  /// Returns the light shadow based on brightness
  static Color lightShadow(Brightness brightness) =>
      brightness == Brightness.dark ? shadowLightDark : shadowLight;

  /// Returns the appropriate text primary color
  static Color textPrimaryFor(Brightness brightness) =>
      brightness == Brightness.dark ? textPrimaryDark : textPrimary;

  /// Returns the appropriate text secondary color
  static Color textSecondaryFor(Brightness brightness) =>
      brightness == Brightness.dark ? textSecondaryDark : textSecondary;

  /// Returns the accent color for the theme
  static Color accentFor(Brightness brightness) =>
      brightness == Brightness.dark ? gold : primar