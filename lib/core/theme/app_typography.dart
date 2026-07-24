import 'package:flutter/material.dart';

import 'neu_colors.dart';

/// RVIOS Brand Typography System
///
/// Fonts:
/// - Yapari: English Brand Title (RVIOS)
/// - RTLMaghfira: Arabic Brand Title (ريفيوس)
/// - Givonic: English Body & Subtitles
/// - Panorama: Arabic Body & UI Text
class AppTypography {
  AppTypography._();

  // ─────────────────────────────────────────────
  // Font Family Constants
  // ─────────────────────────────────────────────

  static const String fontFamilyMajallab = 'majallab';
  static const String fontFamilyPanorama = 'Panorama';
  static const String fontFamilyGivonic = 'Givonic';
  static const String fontFamilyYapari = 'Yapari';
  static const String fontFamilyRTLMaghfira = 'RTLMaghfira';

  // Default font families for body and headings
  static const String fontFamilyBody = fontFamilyMajallab;
  static const String fontFamilyHeading = fontFamilyMajallab;

  // ─────────────────────────────────────────────
  // Brand Specific Styles (Logo & Headers)
  // ─────────────────────────────────────────────

  /// English Logo/Brand Title (RVIOS) — Yapari Bold
  static const TextStyle brandTitleEn = TextStyle(
    fontFamily: fontFamilyYapari,
    fontSize: 26,
    fontWeight: FontWeight.w700,
    letterSpacing: 2.0,
    color: NeuColors.primary,
  );

  /// Arabic Logo/Brand Title (ريفيوس) — RTL Maghfira
  static const TextStyle brandTitleAr = TextStyle(
    fontFamily: fontFamilyRTLMaghfira,
    fontSize: 28,
    fontWeight: FontWeight.w400,
    height: 1.2,
    color: NeuColors.primary,
  );

  // ─────────────────────────────────────────────
  // Heading Styles (Panorama)
  // ─────────────────────────────────────────────

  /// Page title — large, bold
  static const TextStyle h1 = TextStyle(
    fontFamily: fontFamilyHeading,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.4,
    color: NeuColors.textPrimary,
  );

  /// Section title
  static const TextStyle h2 = TextStyle(
    fontFamily: fontFamilyHeading,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: NeuColors.textPrimary,
  );

  /// Subsection / card title
  static const TextStyle h3 = TextStyle(
    fontFamily: fontFamilyHeading,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: NeuColors.textPrimary,
  );

  /// Small heading / emphasis
  static const TextStyle h4 = TextStyle(
    fontFamily: fontFamilyHeading,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: NeuColors.textPrimary,
  );

  // ─────────────────────────────────────────────
  // Body Styles (Panorama & Givonic)
  // ─────────────────────────────────────────────

  /// Large body text
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.6,
    color: NeuColors.textPrimary,
  );

  /// Default body text
  static const TextStyle body = TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.6,
    color: NeuColors.textPrimary,
  );

  /// Small body text
  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: NeuColors.textSecondary,
  );

  /// English body text (Givonic)
  static const TextStyle bodyEn = TextStyle(
    fontFamily: fontFamilyGivonic,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: NeuColors.textPrimary,
  );

  // ─────────────────────────────────────────────
  // Utility Styles
  // ─────────────────────────────────────────────

  /// Caption / timestamp
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: NeuColors.textHint,
  );

  /// Label (form fields, chips)
  static const TextStyle label = TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: NeuColors.textSecondary,
  );

  /// Button text
  static const TextStyle button = TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: 0.5,
    color: NeuColors.textOnDark,
  );

  /// Navigation bar label
  static const TextStyle navLabel = TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.2,
    color: NeuColors.textSecondary,
  );

  /// Large number display (stats, counters)
  static const TextStyle statNumber = TextStyle(
    fontFamily: fontFamilyHeading,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: NeuColors.navyDeep,
  );

  /// Stat label
  static const TextStyle statLabel = TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: NeuColors.textSecondary,
  );

  // ─────────────────────────────────────────────
  // Dark Theme Variants
  // ─────────────────────────────────────────────

  static TextStyle h1Dark = h1.copyWith(color: NeuColors.textPrimaryDark);
  static TextStyle h2Dark = h2.copyWith(color: NeuColors.textPrimaryDark);
  static TextStyle h3Dark = h3.copyWith(color: NeuColors.textPrimaryDark);
  static TextStyle h4Dark = h4.copyWith(color: NeuColors.textPrimaryDark);
  static TextStyle bodyLargeDark =
      bodyLarge.copyWith(color: NeuColors.textPrimaryDark);
  static TextStyle bodyDark =
      body.copyWith(color: NeuColors.textPrimaryDark);
  static TextStyle bodySmallDark =
      bodySmall.copyWith(color: NeuColors.textSecondaryDark);
  static TextStyle captionDark =
      caption.copyWith(color: NeuColors.textHintDark);
  static TextStyle labelDark =
      label.copyWith(color: NeuColors.textSecondaryDark);
  static TextStyle statNumberDark =
      statNumber.copyWith(color: NeuColors.goldAccent);

  // ─────────────────────────────────────────────
  // Aliases (for backward compatibility)
  // ─────────────────────────────────────────────

  static TextStyle get headingMedium => h3;
  static TextStyle get headingSmall => h4;
  static TextStyle get buttonLabel => button;
  static TextStyle get bodyMedium => body;
  static TextStyle get bodySmallMedium => bodySmall;
  static TextStyle get labelMedium => label;
  static TextStyle get labelSmall => caption;
}