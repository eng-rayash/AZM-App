/// AZM — Design Tokens
///
/// طبقة أدوار دلالية فوق ألوان العلامة في [NeuColors].
///
/// الفائدة هنا ليست لونًا جديدًا بل تسميةً بالدور: `ink` لا `textPrimary`،
/// و`ground` لا `bgColor`، و`hairline` لا `border`. الشاشات الجديدة تقرأ
/// الدور فينتقل أي تغيير في العلامة إليها من مكان واحد.
///
/// القيم كلها مشتقّة من هوية العلامة: قرمزي #9E2226، وذهبي #C8A45D،
/// وأرض عاجية فاتحة، وجرافيت داكنة.
///
/// الاستخدام:
/// ```dart
/// final p = AzmPalette.of(context);
/// Container(color: p.surface, child: Text('...', style: TextStyle(color: p.ink)));
/// ```
library;

import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────
// Palette
// ─────────────────────────────────────────────────────────────

/// لوحة ألوان محلولة لوضع سطوع واحد.
///
/// كل دور لوني له اسم دلالي لا وصفي: `ink` لا `black`، و`ground` لا `white` —
/// لأن القيمة تنقلب بين الوضعين بينما الدور يبقى ثابتًا.
@immutable
class AzmPalette {
  const AzmPalette({
    required this.brightness,
    required this.ink,
    required this.inkMuted,
    required this.inkFaint,
    required this.inkGhost,
    required this.ground,
    required this.surface,
    required this.surfaceRaised,
    required this.surfaceSunken,
    required this.hairline,
    required this.rule,
    required this.accent,
    required this.onAccent,
    required this.success,
    required this.successSubtle,
    required this.warning,
    required this.warningSubtle,
    required this.danger,
    required this.dangerSubtle,
    required this.info,
    required this.infoSubtle,
  });

  final Brightness brightness;

  // ── الحبر — النص والأيقونات ──────────────────────────────

  /// النص الأساسي · الأيقونات الفاعلة · الحدود القوية
  final Color ink;

  /// النص الثانوي · الوصف · التسميات الحاملة لمعنى
  final Color inkMuted;

  /// البيانات الوصفية · تسميات الحقول · النص المساعد
  final Color inkFaint;

  /// المعطَّل · العناصر النائمة · النص الشبحي
  final Color inkGhost;

  // ── الأسطح ───────────────────────────────────────────────

  /// خلفية الصفحة
  final Color ground;

  /// السطح الافتراضي — القوائم والصفوف
  final Color surface;

  /// السطح المرتفع — الحوارات والأوراق السفلية والقوائم المنبثقة
  final Color surfaceRaised;

  /// السطح الغائر — حقول الإدخال وخلفيات الأكواد
  final Color surfaceSunken;

  // ── الفواصل ──────────────────────────────────────────────

  /// الفاصل الشعري — بديل البطاقة في القوائم والجداول
  final Color hairline;

  /// الفاصل القوي — رأس القسم وحدّ الجدول العلوي
  final Color rule;

  // ── التمييز ──────────────────────────────────────────────

  /// الإجراء الأساسي والحالة المختارة — ينقلب بين الوضعين
  final Color accent;

  /// النص والأيقونة فوق [accent]
  final Color onAccent;

  // ── الحالة الوظيفية ──────────────────────────────────────

  final Color success;
  final Color successSubtle;
  final Color warning;
  final Color warningSubtle;
  final Color danger;
  final Color dangerSubtle;
  final Color info;
  final Color infoSubtle;

  bool get isDark => brightness == Brightness.dark;

  // ─────────────────────────────────────────────
  // الحل حسب السطوع
  // ─────────────────────────────────────────────

  /// اللوحة المطابقة لسطوع [context].
  static AzmPalette of(BuildContext context) =>
      resolve(Theme.of(context).brightness);

  /// اللوحة المطابقة لسطوع صريح.
  static AzmPalette resolve(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;

  // ─────────────────────────────────────────────
  // الوضع الفاتح — حبر على ورق دافئ
  // ─────────────────────────────────────────────

  static const AzmPalette light = AzmPalette(
    brightness: Brightness.light,
    ink: Color(0xFF111315),
    inkMuted: Color(0xFF6B6B6B),
    inkFaint: Color(0xFF9E9E9E),
    inkGhost: Color(0xFFC2C0B6),
    ground: Color(0xFFF5F3E8),
    surface: Color(0xFFFAF8ED),
    surfaceRaised: Color(0xFFFFFFFF),
    surfaceSunken: Color(0xFFF1EADF),
    hairline: Color(0xFFE0DDD0),
    rule: Color(0xFF9E2226),
    accent: Color(0xFF9E2226),
    onAccent: Color(0xFFFFFFFF),
    success: Color(0xFF10B981),
    successSubtle: Color(0xFFE3F5EE),
    warning: Color(0xFFF59E0B),
    warningSubtle: Color(0xFFFCF0DC),
    danger: Color(0xFFEF4444),
    dangerSubtle: Color(0xFFFBE6E6),
    info: Color(0xFF3B82F6),
    infoSubtle: Color(0xFFE6EEFC),
  );

  // ─────────────────────────────────────────────
  // الوضع الداكن — حبر فاتح على أرض سوداء
  // ─────────────────────────────────────────────

  static const AzmPalette dark = AzmPalette(
    brightness: Brightness.dark,
    ink: Color(0xFFFAF8ED),
    inkMuted: Color(0xFFA0A5AC),
    inkFaint: Color(0xFF6C727E),
    inkGhost: Color(0xFF4A4F57),
    ground: Color(0xFF111315),
    surface: Color(0xFF1A1D20),
    surfaceRaised: Color(0xFF24272C),
    surfaceSunken: Color(0xFF0C0E10),
    hairline: Color(0xFF2E2E2E),
    rule: Color(0xFFC8A45D),
    accent: Color(0xFFC8A45D),
    onAccent: Color(0xFF111315),
    success: Color(0xFF10B981),
    successSubtle: Color(0xFF12261F),
    warning: Color(0xFFF59E0B),
    warningSubtle: Color(0xFF2A2211),
    danger: Color(0xFFEF4444),
    dangerSubtle: Color(0xFF2C1615),
    info: Color(0xFF3B82F6),
    infoSubtle: Color(0xFF131D2C),
  );
}

// ─────────────────────────────────────────────────────────────
// Spacing
// ─────────────────────────────────────────────────────────────

/// سلّم المسافات — أساس ٤.
///
/// الفراغ هو أداة الارتفاع في عزم؛ لا ظلال، فالمسافة هي ما يفصل الطبقات.
class AzmSpace {
  AzmSpace._();

  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
  static const double huge = 64;

  /// الهامش الأفقي القياسي لمحتوى الشاشة على الجوال.
  static const double screenGutter = 20;

  /// المسافة الرأسية بين قسمين رئيسيين.
  static const double sectionGap = 32;
}

// ─────────────────────────────────────────────────────────────
// Radius
// ─────────────────────────────────────────────────────────────

/// سلّم الحواف — يطابق [AppRadius].
class AzmRadius {
  AzmRadius._();

  /// الأسطح والصفوف الممتدة عرض الشاشة
  static const double none = 0;

  /// الأزرار وحقول الإدخال والشارات
  static const double sm = 12;

  /// الأوراق السفلية والحوارات — الحافة العلوية فقط
  static const double lg = 24;

  /// الصور الرمزية ومؤشرات الحالة الدائرية
  static const double full = 999;

  static const BorderRadius zero = BorderRadius.zero;
  static const BorderRadius control = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius sheet =
      BorderRadius.vertical(top: Radius.circular(lg));
  static const BorderRadius pill = BorderRadius.all(Radius.circular(full));
}

// ─────────────────────────────────────────────────────────────
// Elevation
// ─────────────────────────────────────────────────────────────

/// أدوات الفصل بين الأسطح — حدود وفواصل.
///
/// للظلال استخدم [NeuDecorations]؛ هذه الأدوات للفواصل الشعرية في
/// القوائم والجداول حيث لا يناسبها الظل.
class AzmElevation {
  AzmElevation._();

  /// بلا ظل — للأسطح التي يفصلها الحدّ لا الارتفاع.
  static const List<BoxShadow> none = <BoxShadow>[];

  /// حدّ شعري كامل حول سطح.
  static Border hairline(AzmPalette p) =>
      Border.all(color: p.hairline, width: 1);

  /// فاصل سفلي بين صفّي قائمة.
  static Border rowDivider(AzmPalette p) =>
      Border(bottom: BorderSide(color: p.hairline, width: 1));

  /// خط قسم قوي — يعلو رأس القسم.
  static Border sectionRule(AzmPalette p) =>
      Border(top: BorderSide(color: p.rule, width: 1));
}

// ─────────────────────────────────────────────────────────────
// Breakpoints
// ─────────────────────────────────────────────────────────────

/// نقاط قياس التخطيط.
///
/// مركزية عمدًا: قيمة مبثوثة في الهيكل تنحرف عن قيمة في شاشة أخرى بلا
/// أن يلاحظ أحد. نُقلت هنا من `ResponsiveLayout` عند حذفه بعد أن حلّ
/// [AzmSidebar] محلّه.
class AzmBreakpoint {
  AzmBreakpoint._();

  /// دونها: جوال — درج وشريط سفلي
  static const double mobile = 600;

  /// عندها فأعلى: لوح جانبي ثابت بدل الدرج
  static const double sidebar = 900;

  /// عندها فأعلى: سطح مكتب
  static const double desktop = 1200;

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < mobile;

  /// هل يتّسع العرض للوح جانبي ثابت؟
  static bool hasSidebar(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= sidebar;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= desktop;
}

// ─────────────────────────────────────────────────────────────
// Motion
// ─────────────────────────────────────────────────────────────

/// الحركة وظيفية فقط — لا حركة زخرفية في عزم.
class AzmMotion {
  AzmMotion._();

  /// تغيّر حالة فوري — ضغط زر، تبديل مفتاح
  static const Duration instant = Duration(milliseconds: 120);

  /// الانتقال القياسي — ظهور، اختفاء، تمدد
  static const Duration standard = Duration(milliseconds: 180);

  /// انتقال صفحة أو ورقة سفلية
  static const Duration page = Duration(milliseconds: 240);

  static const Curve enter = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;
}
