import 'package:flutter/material.dart';

import 'neu_colors.dart';

/// Brand Typography System
///
/// الخطوط بأدوارها:
/// - Zain:     العناوين العربية الضخمة والعلامة اللفظية العربية
/// - Panorama: النص العربي العام وواجهة الاستخدام (ثمانية Serif Text)
/// - Yapari:   العناوين الإنجليزية الكبيرة والعلامة اللاتينية
///
/// عائلة `Panorama` أُبقيت باسمها رغم تغيّر الملف تحتها: الاسم مذكور
/// نصّياً في ١٤٤ موضعاً عبر ٢٧ ملفاً، وتغييره تعديلٌ واسع بلا مقابل.
class AppTypography {
  AppTypography._();

  // ─────────────────────────────────────────────
  // Font Family Constants
  // ─────────────────────────────────────────────

  /// ثمانية Serif Text — النص العربي العام (متن، واجهة، تسميات).
  static const String fontFamilyPanorama = 'Panorama';

  /// زين — العناوين العربية الضخمة والعلامة اللفظية العربية.
  static const String fontFamilyZain = 'Zain';

  /// يابار — العناوين الإنجليزية الكبيرة والعلامة اللاتينية.
  static const String fontFamilyYapari = 'Yapari';

  /// أسماء بديلة — مُبقاة للتوافق مع الكود القائم.
  static const String fontFamilyGivonic = fontFamilyPanorama;
  static const String fontFamilyRTLMaghfira = fontFamilyZain;

  /// احتياط رموز — ثمانية Serif Text يغطّي العربية واللاتينية معًا.
  static const List<String> fontFamilyFallback = [fontFamilyPanorama];

  // Default font families for body and headings
  static const String fontFamilyBody = fontFamilyPanorama;
  static const String fontFamilyHeading = fontFamilyPanorama;

  // ─────────────────────────────────────────────
  // Wordmark — علامة عزم اللفظية
  // ─────────────────────────────────────────────

  /// العلامة اللفظية العربية — زين
  static const TextStyle wordmarkAr = TextStyle(
    fontFamily: fontFamilyZain,
    fontSize: 28,
    fontWeight: FontWeight.w400,
    height: 1.2,
    color: NeuColors.primary,
  );

  /// العلامة اللفظية اللاتينية — Yapari Bold
  static const TextStyle wordmarkEn = TextStyle(
    fontFamily: fontFamilyYapari,
    fontSize: 26,
    fontWeight: FontWeight.w700,
    letterSpacing: 2.0,
    color: NeuColors.primary,
  );

  /// سطر الوصف تحت العلامة
  static const TextStyle wordmarkTagline = TextStyle(
    fontFamily: fontFamilyPanorama,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 1.2,
    color: NeuColors.textHint,
  );

  // أسماء بديلة — مُبقاة للتوافق مع الكود القائم
  static const TextStyle brandTitleEn = wordmarkEn;
  static const TextStyle brandTitleAr = wordmarkAr;

  // ─────────────────────────────────────────────
  // Heading Styles — زين للعناوين الضخمة، ثمانية للباقي
  // ─────────────────────────────────────────────

  /// Page title — large, bold (خط زين)
  static const TextStyle h1 = TextStyle(
    fontFamily: fontFamilyZain,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.4,
    color: NeuColors.textPrimary,
  );

  /// Section title (خط زين)
  static const TextStyle h2 = TextStyle(
    fontFamily: fontFamilyZain,
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
  // Body Styles (ثمانية Serif Text — Panorama)
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

  /// English body text (Yapari للعناوين، ثمانية للنصوص العامة)
  static const TextStyle bodyEn = TextStyle(
    fontFamily: fontFamilyPanorama,
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
  ///
  /// أرقام جدولية إلزامية: المؤشرات تُقرأ في أعمدة، والأرقام المتناسبة
  /// تجعل الخانات ترقص بين صفّ وآخر.
  static const TextStyle statNumber = TextStyle(
    fontFamily: fontFamilyHeading,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.15,
    letterSpacing: -0.5,
    fontFeatures: [FontFeature.tabularFigures()],
    color: NeuColors.textPrimary,
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