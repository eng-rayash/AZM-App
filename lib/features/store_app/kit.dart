import 'package:flutter/material.dart';

import '../../core/design/azm_tokens.dart';
import '../../core/theme/app_typography.dart';

/// عزم للمتاجر — مكوّنات الواجهة الجديدة
///
/// لغة واحدة لكل شاشات المتجر: بطاقة بطلة متدرّجة بلون RVIOS، وأرقام كبيرة
/// بخط زين، وبطاقات هادئة بحدّ شعري، وشرائح حالة ملوّنة. الألوان من
/// [AzmPalette] فتتبع الوضع الفاتح والداكن تلقائيًا.
class Rv {
  Rv._();
  static const red = Color(0xFFC1272D);
  static const redDeep = Color(0xFF7A1418);
  static const ember = Color(0xFFE2563B);
  static const gold = Color(0xFFE9B44C);
  static const cream = Color(0xFFFFF6EC);

  static const heroGradient = LinearGradient(
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
    colors: [Color(0xFFD12F36), Color(0xFF8E1A1F), Color(0xFF3B0B0D)],
    stops: [0, .55, 1],
  );

  static String money(num v) {
    final s = v.round().abs().toString();
    final out = StringBuffer(v < 0 ? '-' : '');
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) out.write(',');
      out.write(s[i]);
    }
    return out.toString();
  }

  static String ago(String? iso) {
    final d = iso == null ? null : DateTime.tryParse(iso)?.toLocal();
    if (d == null) return '';
    final s = DateTime.now().difference(d);
    if (s.inMinutes < 1) return 'الآن';
    if (s.inMinutes < 60) return 'قبل ${s.inMinutes} د';
    if (s.inHours < 24) return 'قبل ${s.inHours} س';
    if (s.inDays < 30) return 'قبل ${s.inDays} يوم';
    return '${d.year}/${d.month}/${d.day}';
  }
}

/// بطاقة البطل: تدرّج أحمر عميق بزخرفة دائرية، لرأس الشاشة.
class RvHero extends StatelessWidget {
  const RvHero({super.key, required this.child, this.padding = const EdgeInsets.all(20)});
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Container(
        decoration: const BoxDecoration(gradient: Rv.heroGradient),
        child: Stack(children: [
          PositionedDirectional(
            end: -60,
            top: -70,
            child: Container(width: 220, height: 220, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: .07))),
          ),
          PositionedDirectional(
            start: -40,
            bottom: -90,
            child: Container(width: 180, height: 180, decoration: BoxDecoration(shape: BoxShape.circle, color: Rv.gold.withValues(alpha: .10))),
          ),
          Padding(padding: padding, child: child),
        ]),
      ),
    );
  }
}

/// بطاقة هادئة: سطح مرتفع بحدّ شعري وزوايا ٢٠.
class RvCard extends StatelessWidget {
  const RvCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.onTap, this.color});
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);
    return Material(
      color: color ?? p.surfaceRaised,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: p.hairline)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(onTap: onTap, child: Padding(padding: padding, child: child)),
    );
  }
}

/// رقم كبير بعنوانه وأيقونته — لشبكة المؤشرات.
class RvStat extends StatelessWidget {
  const RvStat({super.key, required this.label, required this.value, required this.icon, this.tone, this.hint, this.onTap});
  final String label;
  final String value;
  final IconData icon;
  final Color? tone;
  final String? hint;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);
    final c = tone ?? p.accent;
    return RvCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        Row(children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(color: c.withValues(alpha: .13), borderRadius: BorderRadius.circular(11)),
            child: Icon(icon, size: 18, color: c),
          ),
          const Spacer(),
          if (onTap != null) Icon(Icons.chevron_left_rounded, size: 18, color: p.inkFaint),
        ]),
        const SizedBox(height: 12),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          child: Text(value, style: AppTypography.statNumber.copyWith(color: p.ink, fontSize: 26, height: 1.1)),
        ),
        const SizedBox(height: 2),
        Text(label, style: AppTypography.caption.copyWith(color: p.inkMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
        if (hint != null) Text(hint!, style: AppTypography.caption.copyWith(color: c, fontSize: 11), maxLines: 1),
      ]),
    );
  }
}

/// عنوان قسم مع إجراء اختياري («الكل»).
class RvSection extends StatelessWidget {
  const RvSection(this.title, {super.key, this.action, this.onAction});
  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 22, 4, 10),
      child: Row(children: [
        Container(width: 4, height: 18, decoration: BoxDecoration(color: Rv.red, borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 8),
        Expanded(child: Text(title, style: AppTypography.h4.copyWith(color: p.ink))),
        if (action != null)
          TextButton(onPressed: onAction, style: TextButton.styleFrom(foregroundColor: Rv.red, visualDensity: VisualDensity.compact), child: Text(action!)),
      ]),
    );
  }
}

/// مربّع إجراء سريع: أيقونة ملوّنة فوق تسمية.
class RvAction extends StatelessWidget {
  const RvAction({super.key, required this.icon, required this.label, required this.onTap, this.color, this.badge});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final int? badge;

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);
    final c = color ?? Rv.red;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Badge(
            isLabelVisible: (badge ?? 0) > 0,
            label: Text('${badge ?? ''}'),
            backgroundColor: Rv.red,
            child: Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [c.withValues(alpha: .18), c.withValues(alpha: .06)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: c.withValues(alpha: .18)),
              ),
              child: Icon(icon, color: c, size: 24),
            ),
          ),
          const SizedBox(height: 8),
          Text(label, textAlign: TextAlign.center, maxLines: 2, style: AppTypography.caption.copyWith(color: p.ink, fontWeight: FontWeight.w600, height: 1.3)),
        ]),
      ),
    );
  }
}

/// شريحة حالة ملوّنة.
class RvChip extends StatelessWidget {
  const RvChip(this.text, {super.key, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(color: color.withValues(alpha: .13), borderRadius: BorderRadius.circular(99)),
        child: Text(text, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: color)),
      );
}

/// حالة فارغة بأيقونة ورسالة وإجراء.
class RvEmpty extends StatelessWidget {
  const RvEmpty({super.key, required this.icon, required this.title, this.body, this.action, this.onAction});
  final IconData icon;
  final String title;
  final String? body;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(shape: BoxShape.circle, color: Rv.red.withValues(alpha: .08)),
            child: Icon(icon, size: 38, color: Rv.red),
          ),
          const SizedBox(height: 16),
          Text(title, textAlign: TextAlign.center, style: AppTypography.h3.copyWith(color: p.ink)),
          if (body != null) ...[
            const SizedBox(height: 6),
            Text(body!, textAlign: TextAlign.center, style: AppTypography.bodySmall.copyWith(color: p.inkMuted)),
          ],
          if (action != null) ...[
            const SizedBox(height: 18),
            FilledButton(onPressed: onAction, style: FilledButton.styleFrom(backgroundColor: Rv.red, minimumSize: const Size(180, 46)), child: Text(action!)),
          ],
        ]),
      ),
    );
  }
}

/// مخطط أعمدة صغير بلا مكتبة: يكفي لسبعة أيام أو ثلاثين.
class RvBars extends StatelessWidget {
  const RvBars({super.key, required this.values, required this.labels, this.color = Rv.red, this.height = 120});
  final List<num> values;
  final List<String> labels;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);
    final max = values.fold<num>(0, (a, b) => b > a ? b : a);
    return SizedBox(
      height: height + 22,
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        for (var i = 0; i < values.length; i++)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                AnimatedContainer(
                  duration: Duration(milliseconds: 400 + i * 40),
                  curve: Curves.easeOutCubic,
                  height: max == 0 ? 3 : (values[i] / max * height).clamp(3, height).toDouble(),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [color.withValues(alpha: .55), color]),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 6),
                if (labels.length > i) Text(labels[i], style: TextStyle(fontSize: 10, color: p.inkFaint), maxLines: 1),
              ]),
            ),
          ),
      ]),
    );
  }
}
