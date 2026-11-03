import 'package:flutter/material.dart';

import '../../core/design/azm_tokens.dart';
import '../../core/theme/app_typography.dart';

/// AZM — بدائل القوائم
///
/// اللغة البصرية للقوائم في عزم: صفوف يفصلها خطّ شعري، لا بطاقات.
/// البطاقة تقول «كيان منفصل قابل للسحب أو الاختيار»؛ وبند تنقّل ليس كذلك.
/// إغراق الشاشة ببطاقات يسطّح التسلسل البصري بدل أن يبنيه.
///
/// المكوّنات:
/// - [AzmSectionHeader] رأس قسم بخط علوي قوي
/// - [AzmNavRow]        صفّ تنقّل بفاصل شعري
/// - [AzmRowGroup]      يجمع صفوفًا ويحذف الفاصل الأخير

// ─────────────────────────────────────────────────────────────
// Section Header
// ─────────────────────────────────────────────────────────────

/// رأس قسم — خطّ حبريّ قوي يعلو عنوانًا صغيرًا.
///
/// الخط العلوي هو ما يفصل الأقسام، لا الفراغ وحده ولا حاوية ملوّنة.
class AzmSectionHeader extends StatelessWidget {
  const AzmSectionHeader({
    super.key,
    required this.title,
    this.caption,
    this.trailing,
  });

  final String title;

  /// وصف قصير يشرح ما يجمع بنود القسم
  final String? caption;

  /// إجراء أو عدّاد في نهاية السطر
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AzmSpace.screenGutter,
        AzmSpace.xl,
        AzmSpace.screenGutter,
        AzmSpace.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 1, color: p.rule),
          const SizedBox(height: AzmSpace.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.h4.copyWith(
                        color: p.ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (caption != null) ...[
                      const SizedBox(height: AzmSpace.xxs),
                      Text(
                        caption!,
                        style: AppTypography.caption.copyWith(
                          color: p.inkFaint,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Nav Row
// ─────────────────────────────────────────────────────────────

/// صفّ تنقّل — العنوان يحمل الوزن، والأيقونة تساعد ولا تعوّض.
class AzmNavRow extends StatelessWidget {
  const AzmNavRow({
    super.key,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.icon,
    this.badge,
    this.showDivider = true,
    this.enabled = true,
  });

  final String title;

  /// وصف صف واحد — ما يفعله هذا البند لا ما هو
  final String? subtitle;

  final IconData? icon;

  /// عدّاد أو حالة في نهاية الصف
  final Widget? badge;

  final VoidCallback onTap;
  final bool showDivider;

  /// معطَّل — يُعرض خافتًا ولا يستجيب
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);
    final titleColor = enabled ? p.ink : p.inkGhost;
    final iconColor = enabled ? p.inkFaint : p.inkGhost;

    return Semantics(
      button: true,
      enabled: enabled,
      label: subtitle == null ? title : '$title — $subtitle',
      child: InkWell(
        onTap: enabled ? onTap : null,
        splashColor: p.inkGhost.withValues(alpha: 0.10),
        highlightColor: p.inkGhost.withValues(alpha: 0.06),
        child: Container(
          // ٤٤ هو الحد الأدنى لهدف اللمس
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(
            horizontal: AzmSpace.screenGutter,
            vertical: AzmSpace.md,
          ),
          decoration: showDivider
              ? BoxDecoration(border: AzmElevation.rowDivider(p))
              : null,
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 19, color: iconColor),
                const SizedBox(width: AzmSpace.md),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: AppTypography.body.copyWith(
                        color: titleColor,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 1),
                      Text(
                        subtitle!,
                        style: AppTypography.caption.copyWith(
                          color: p.inkFaint,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: AzmSpace.sm),
                badge!,
              ],
              const SizedBox(width: AzmSpace.sm),
              // في RTL يشير سهم «ادخل» إلى اليسار. أيقونات Material
              // تُعكس تلقائيًا مع اتجاه النص، فـ`chevron_right` هو ما
              // يُرسم يسارًا هنا — الاسم يصف الرسم قبل العكس لا بعده.
              Icon(Icons.chevron_right_rounded, size: 20, color: p.inkGhost),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Row Group
// ─────────────────────────────────────────────────────────────

/// يجمع صفوفًا ويحذف الفاصل عن آخرها، فلا يتضاعف خطّان عند رأس القسم التالي.
class AzmRowGroup extends StatelessWidget {
  const AzmRowGroup({super.key, required this.rows});

  final List<AzmNavRow> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < rows.length; i++)
          AzmNavRow(
            title: rows[i].title,
            subtitle: rows[i].subtitle,
            icon: rows[i].icon,
            badge: rows[i].badge,
            onTap: rows[i].onTap,
            enabled: rows[i].enabled,
            showDivider: i != rows.length - 1,
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Count Badge
// ─────────────────────────────────────────────────────────────

/// عدّاد صامت في نهاية الصف — رقم بلا تعبئة ولا لون.
///
/// اللون محجوز لما يحمل حالة؛ والعدد وحده لا يحملها. حين يحمل العدد
/// إلحاحًا (متأخر، يحتاج اهتمامًا) يُمرّر [tone].
class AzmCount extends StatelessWidget {
  const AzmCount(this.value, {super.key, this.tone});

  final int value;

  /// لون الحالة حين يحمل العدد إلحاحًا — وإلا فالرمادي الخافت
  final Color? tone;

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);
    if (value <= 0) return const SizedBox.shrink();

    return Text(
      '$value',
      style: AppTypography.bodySmall.copyWith(
        color: tone ?? p.inkFaint,
        fontWeight: FontWeight.w600,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Switch Row
// ─────────────────────────────────────────────────────────────

/// صفّ مفتاح — نفس هندسة [AzmNavRow] ومفتاحٌ مكان السهم.
///
/// الصفّ كلّه هدف لمس لا المفتاح وحده: مفتاح Material عرضه ٤٠ بكسل،
/// وإصابته بالإبهام على شاشة ممسوكة بيد واحدة أصعب مما تبدو.
class AzmSwitchRow extends StatelessWidget {
  const AzmSwitchRow({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.icon,
    this.showDivider = true,
    this.enabled = true,
  });

  final String title;

  /// وصف صف واحد — ما يفعله التفعيل لا ما هو
  final String? subtitle;

  final IconData? icon;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool showDivider;

  /// معطَّل — يُعرض خافتًا ولا يستجيب (ميزة غير متاحة على هذا الجهاز)
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);
    final titleColor = enabled ? p.ink : p.inkGhost;
    final iconColor = enabled ? p.inkFaint : p.inkGhost;

    return Semantics(
      toggled: value,
      enabled: enabled,
      label: subtitle == null ? title : '$title — $subtitle',
      child: InkWell(
        onTap: enabled ? () => onChanged(!value) : null,
        splashColor: p.inkGhost.withValues(alpha: 0.10),
        highlightColor: p.inkGhost.withValues(alpha: 0.06),
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(
            horizontal: AzmSpace.screenGutter,
            vertical: AzmSpace.md,
          ),
          decoration: showDivider
              ? BoxDecoration(border: AzmElevation.rowDivider(p))
              : null,
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 19, color: iconColor),
                const SizedBox(width: AzmSpace.md),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: AppTypography.body.copyWith(
                        color: titleColor,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 1),
                      Text(
                        subtitle!,
                        style: AppTypography.caption.copyWith(
                          color: p.inkFaint,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AzmSpace.sm),
              // المفتاح يُعرض ولا يلتقط اللمس — الصفّ هو الهدف، فلا
              // يتضاعف الحدث حين يُضغط المفتاح نفسه.
              IgnorePointer(
                child: Switch(
                  value: value,
                  onChanged: enabled ? onChanged : null,
                  activeThumbColor: p.onAccent,
                  activeTrackColor: p.accent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Segmented Choice
// ─────────────────────────────────────────────────────────────

/// خيار من ثلاثة أو أربعة — معروضة كلها لا مخبوءة خلف قائمة.
///
/// القائمة المنسدلة تُخفي البدائل وتطلب ضغطتين؛ وحين تكون البدائل
/// ثلاثة فعرضها جميعًا أرخص من إخفائها.
class AzmSegmented<T> extends StatelessWidget {
  const AzmSegmented({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.showDivider = true,
  });

  /// ما الذي يُختار — يُقرأ فوق الخيارات لا داخلها
  final String label;

  final T value;

  /// البدائل بترتيب عرضها: القيمة ونصّها
  final List<(T, String)> options;

  final ValueChanged<T> onChanged;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AzmSpace.screenGutter,
        AzmSpace.md,
        AzmSpace.screenGutter,
        AzmSpace.lg,
      ),
      decoration: showDivider
          ? BoxDecoration(border: AzmElevation.rowDivider(p))
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.body.copyWith(
              color: p.ink,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
          const SizedBox(height: AzmSpace.md),
          Container(
            decoration: BoxDecoration(
              border: AzmElevation.hairline(p),
              borderRadius: AzmRadius.control,
            ),
            padding: const EdgeInsets.all(3),
            child: Row(
              children: [
                for (final (optionValue, optionLabel) in options)
                  Expanded(
                    child: Semantics(
                      button: true,
                      selected: optionValue == value,
                      label: optionLabel,
                      child: InkWell(
                        onTap: () => onChanged(optionValue),
                        borderRadius: AzmRadius.control,
                        child: AnimatedContainer(
                          duration: AzmMotion.standard,
                          curve: AzmMotion.enter,
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: optionValue == value
                                ? p.accent
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(
                              AzmRadius.sm - 3,
                            ),
                          ),
                          child: Text(
                            optionLabel,
                            style: AppTypography.bodySmall.copyWith(
                              color: optionValue == value
                                  ? p.onAccent
                                  : p.inkMuted,
                              fontWeight: optionValue == value
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
