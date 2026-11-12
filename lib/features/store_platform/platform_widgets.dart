import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/design/azm_tokens.dart';
import '../../core/theme/app_typography.dart';
import '../store_app/kit.dart';
import '../store_tools/store_tools_api.dart' show storefrontUrl;
import 'platform_catalog.dart';

/// مكوّنات منصة المتاجر في التطبيق: بطاقات القوالب والباقات وحسابات الدفع وزر واتساب.

const waGreen = Color(0xFF1FAF5A);

/// لقطة القالب على الجوال، بإطار هاتف رفيع وتحميل متدرّج بألوان القالب.
class TemplateShot extends StatelessWidget {
  const TemplateShot(this.t, {super.key, this.radius = 18, this.frame = true});
  final StoreTemplate t;
  final double radius;
  final bool frame;

  @override
  Widget build(BuildContext context) {
    final bg = t.palette.first;
    final img = Image.network(
      t.shot,
      fit: BoxFit.cover,
      alignment: Alignment.topCenter,
      filterQuality: FilterQuality.medium,
      frameBuilder: (context, child, frame, sync) => AnimatedOpacity(
        opacity: frame == null && !sync ? 0 : 1,
        duration: const Duration(milliseconds: 350),
        child: child,
      ),
      errorBuilder: (_, _, _) => _Fallback(t),
    );
    final inner = ClipRRect(
      borderRadius: BorderRadius.circular(frame ? radius - 5 : radius),
      child: DecoratedBox(
        decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [bg, t.palette.length > 1 ? t.palette[1].withValues(alpha: .35) : bg])),
        child: SizedBox.expand(child: img),
      ),
    );
    if (!frame) return inner;
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFF17110F),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .18), blurRadius: 18, offset: const Offset(0, 8))],
      ),
      child: inner,
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback(this.t);
  final StoreTemplate t;
  @override
  Widget build(BuildContext context) => Container(
        color: t.palette.first,
        alignment: Alignment.center,
        child: Text(t.name, style: TextStyle(fontFamily: 'Zain', fontSize: 28, fontWeight: FontWeight.w800, color: t.palette.length > 2 ? t.palette[2] : Colors.black54)),
      );
}

/// شارة الطبقة والسعر فوق القالب.
class TierBadge extends StatelessWidget {
  const TierBadge(this.t, {super.key, this.price, this.currency = 'USD', this.owned = false});
  final StoreTemplate t;
  final num? price;
  final String currency;
  final bool owned;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, text) = owned
        ? (const Color(0xFF0F766E), Colors.white, 'مملوك')
        : t.isFree
            ? (Colors.white, const Color(0xFF0F766E), 'مجاني')
            : price == 0
                ? (Colors.white, const Color(0xFF0F766E), 'مشمول')
                : t.tier == 'signature'
                    ? (const Color(0xFF1C1712), Rv.gold, '${currencyLabel(currency)}${fmtMoney(price ?? t.basePrice)}')
                    : (Rv.red, Colors.white, '${currencyLabel(currency)}${fmtMoney(price ?? t.basePrice)}');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(99), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .15), blurRadius: 8)]),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (t.tier == 'signature' && !owned && price != 0) ...[Icon(Icons.auto_awesome, size: 12, color: fg), const SizedBox(width: 3)],
        Text(text, style: TextStyle(color: fg, fontSize: 11.5, fontWeight: FontWeight.w800)),
      ]),
    );
  }
}

/// بطاقة قالب في المعرض.
class TemplateCard extends StatelessWidget {
  const TemplateCard({
    super.key,
    required this.t,
    required this.onTap,
    required this.onPreview,
    this.selected = false,
    this.price,
    this.currency = 'USD',
    this.owned = false,
    this.current = false,
  });
  final StoreTemplate t;
  final VoidCallback onTap;
  final VoidCallback onPreview;
  final bool selected;
  final num? price;
  final String currency;
  final bool owned;
  final bool current;

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: selected ? Rv.red.withValues(alpha: .07) : p.surfaceRaised,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: selected ? Rv.red : p.hairline, width: selected ? 2 : 1),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Expanded(
            child: Stack(children: [
              Positioned.fill(child: TemplateShot(t)),
              PositionedDirectional(top: 10, start: 10, child: TierBadge(t, price: price, currency: currency, owned: owned)),
              if (selected || current)
                PositionedDirectional(
                  top: 8,
                  end: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Rv.red, shape: BoxShape.circle),
                    child: Icon(current && !selected ? Icons.storefront_rounded : Icons.check_rounded, color: Colors.white, size: 16),
                  ),
                ),
              PositionedDirectional(
                bottom: 10,
                end: 10,
                start: 10,
                child: Center(
                  child: Material(
                    color: Colors.black.withValues(alpha: .62),
                    borderRadius: BorderRadius.circular(99),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(99),
                      onTap: onPreview,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.play_circle_outline_rounded, color: Colors.white, size: 15),
                          SizedBox(width: 4),
                          Text('معاينة حية', style: TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w700)),
                        ]),
                      ),
                    ),
                  ),
                ),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 9, 6, 3),
            child: Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(t.name, style: TextStyle(fontFamily: 'Zain', fontSize: 19, fontWeight: FontWeight.w800, color: p.ink, height: 1.1)),
                  Text(current ? 'قالب متجرك الآن' : t.sector, style: AppTypography.caption.copyWith(color: current ? Rv.red : p.inkMuted, fontSize: 11.5)),
                ]),
              ),
              for (final c in t.palette.take(3))
                Container(width: 11, height: 11, margin: const EdgeInsetsDirectional.only(start: 2), decoration: BoxDecoration(color: c, shape: BoxShape.circle, border: Border.all(color: p.hairline))),
            ]),
          ),
        ]),
      ),
    );
  }
}

/// مبدّل شهري / سنوي.
class BillingToggle extends StatelessWidget {
  const BillingToggle({super.key, required this.yearly, required this.onChanged, this.monthsFree = 2});
  final bool yearly;
  final ValueChanged<bool> onChanged;
  final int monthsFree;

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);
    Widget seg(String label, bool v, {String? badge}) => Expanded(
          child: GestureDetector(
            onTap: () => onChanged(v),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(color: yearly == v ? Rv.red : Colors.transparent, borderRadius: BorderRadius.circular(14)),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(label, style: TextStyle(fontWeight: FontWeight.w800, color: yearly == v ? Colors.white : p.inkMuted)),
                if (badge != null) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(color: yearly == v ? Colors.white : Rv.gold.withValues(alpha: .25), borderRadius: BorderRadius.circular(99)),
                    child: Text(badge, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: yearly == v ? Rv.red : const Color(0xFF8A5A00))),
                  ),
                ],
              ]),
            ),
          ),
        );
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: p.surfaceSunken, borderRadius: BorderRadius.circular(18), border: Border.all(color: p.hairline)),
      child: Row(children: [seg('شهري', false), seg('سنوي', true, badge: '$monthsFree شهر مجانًا')]),
    );
  }
}

/// بطاقة باقة قابلة للاختيار.
class PlanCard extends StatelessWidget {
  const PlanCard({
    super.key,
    required this.plan,
    required this.price,
    required this.currency,
    required this.yearly,
    required this.selected,
    required this.onTap,
    this.lockedReason,
    this.current = false,
  });
  final PlanId plan;
  final num price;
  final String currency;
  final bool yearly;
  final bool selected;
  final VoidCallback? onTap;
  final String? lockedReason;
  final bool current;

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);
    final popular = plan == PlanId.pro;
    final dark = plan == PlanId.biz;
    final fg = dark ? Colors.white : p.ink;
    final muted = dark ? Colors.white70 : p.inkMuted;
    final locked = lockedReason != null;
    return Opacity(
      opacity: locked ? .55 : 1,
      child: GestureDetector(
        onTap: locked ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: dark ? const LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [Color(0xFF2A1714), Color(0xFF120B0A)]) : null,
            color: dark ? null : (selected ? Rv.red.withValues(alpha: .06) : p.surfaceRaised),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: selected ? Rv.red : (dark ? Colors.white12 : p.hairline), width: selected ? 2.2 : 1),
            boxShadow: selected ? [BoxShadow(color: Rv.red.withValues(alpha: .18), blurRadius: 22, offset: const Offset(0, 8))] : null,
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(color: (dark ? Rv.gold : Rv.red).withValues(alpha: .15), borderRadius: BorderRadius.circular(12)),
                child: Icon(plan.icon, color: dark ? Rv.gold : Rv.red, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(plan.label, style: TextStyle(fontFamily: 'Zain', fontSize: 24, fontWeight: FontWeight.w800, color: fg, height: 1.1)),
                  Text(plan.pitch, style: TextStyle(fontSize: 12, color: muted)),
                ]),
              ),
              if (current)
                _Badge('باقتك الآن', Colors.white, const Color(0xFF0F766E))
              else if (popular)
                _Badge('الأكثر اختيارًا', Rv.red, Colors.white),
              const SizedBox(width: 6),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded, key: ValueKey(selected), color: selected ? Rv.red : muted),
              ),
            ]),
            const SizedBox(height: 14),
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(plan.paid ? '${currencyLabel(currency)}${fmtMoney(price)}' : 'مجاني',
                  style: TextStyle(fontFamily: 'Zain', fontSize: 38, fontWeight: FontWeight.w800, color: dark ? Rv.gold : Rv.red, height: 1)),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(plan.paid ? (yearly ? '/ سنويًا' : '/ شهريًا') : 'للأبد', style: TextStyle(color: muted, fontWeight: FontWeight.w600)),
              ),
              const Spacer(),
              if (plan.paid && yearly)
                Padding(padding: const EdgeInsets.only(bottom: 5), child: Text('يعادل ${currencyLabel(currency)}${(price / 12).toStringAsFixed(2)} شهريًا', style: TextStyle(fontSize: 11.5, color: muted))),
            ]),
            const SizedBox(height: 12),
            for (final perk in plan.perks)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(children: [
                  Icon(Icons.check_circle_rounded, size: 17, color: dark ? Rv.gold : const Color(0xFF0F9D6B)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(perk, style: TextStyle(color: fg, fontSize: 13.5))),
                ]),
              ),
            if (locked)
              Container(
                margin: const EdgeInsets.only(top: 6),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: p.warningSubtle, borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  Icon(Icons.lock_outline_rounded, size: 16, color: p.warning),
                  const SizedBox(width: 6),
                  Expanded(child: Text(lockedReason!, style: TextStyle(fontSize: 12, color: p.warning, fontWeight: FontWeight.w600))),
                ]),
              ),
          ]),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.text, this.bg, this.fg);
  final String text;
  final Color bg;
  final Color fg;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(99)),
        child: Text(text, style: TextStyle(color: fg, fontSize: 10.5, fontWeight: FontWeight.w800)),
      );
}

/// حساب دفع: البنك أو المحفظة، والرقم بنسخة واحدة، والرمز يُكبَّر للمسح.
class PayAccountCard extends StatelessWidget {
  const PayAccountCard(this.a, {super.key});
  final Map<String, dynamic> a;

  Color get _c {
    final h = '${a['color'] ?? '#C1272D'}'.replaceAll('#', '');
    return Color(int.tryParse('FF$h', radix: 16) ?? 0xFFC1272D);
  }

  String? get _qr {
    final q = '${a['qr'] ?? ''}';
    if (q.isEmpty) return null;
    return q.startsWith('http') ? q : '$storefrontUrl$q';
  }

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);
    final c = _c;
    final number = '${a['number'] ?? ''}';
    final holder = '${a['holder'] ?? ''}';
    final currency = '${a['currency'] ?? ''}';
    final wallet = a['kind'] == 'wallet';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: p.surfaceRaised, borderRadius: BorderRadius.circular(22), border: Border.all(color: p.hairline)),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(width: 6, color: c),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: c.withValues(alpha: .12), borderRadius: BorderRadius.circular(12)),
                    child: Icon(wallet ? Icons.account_balance_wallet_rounded : Icons.account_balance_rounded, color: c, size: 21),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('${a['providerName'] ?? ''}', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: p.ink)),
                      Text('${a['title'] ?? ''}', style: AppTypography.caption.copyWith(color: p.inkMuted)),
                    ]),
                  ),
                  if (currency.isNotEmpty) RvChip(currency, color: c),
                ]),
                const SizedBox(height: 12),
                InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: number));
                    HapticFeedback.lightImpact();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('نُسخ الرقم $number')));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(color: p.surfaceSunken, borderRadius: BorderRadius.circular(14), border: Border.all(color: p.hairline)),
                    child: Row(children: [
                      Expanded(
                        child: Text(number, textDirection: TextDirection.ltr, textAlign: TextAlign.start,
                            style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: p.ink, fontFamily: 'monospace')),
                      ),
                      Icon(Icons.copy_rounded, size: 18, color: c),
                      const SizedBox(width: 4),
                      Text('نسخ', style: TextStyle(color: c, fontWeight: FontWeight.w700, fontSize: 12.5)),
                    ]),
                  ),
                ),
                if (holder.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('باسم: $holder', style: AppTypography.caption.copyWith(color: p.inkMuted)),
                ],
                if ('${a['note'] ?? ''}'.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text('${a['note']}', style: AppTypography.caption.copyWith(color: p.inkFaint, height: 1.5)),
                ],
              ]),
            ),
          ),
          if (_qr != null)
            GestureDetector(
              onTap: () => showDialog<void>(
                context: context,
                builder: (_) => Dialog(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Text('امسح الرمز من تطبيق ${a['providerName'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.black87)),
                      const SizedBox(height: 14),
                      Image.network(_qr!, width: 260, height: 260, fit: BoxFit.contain),
                      const SizedBox(height: 8),
                      Text(number, textDirection: TextDirection.ltr, style: const TextStyle(fontSize: 18, letterSpacing: 2, fontWeight: FontWeight.w700, color: Colors.black87)),
                    ]),
                  ),
                ),
              ),
              child: Container(
                width: 92,
                margin: const EdgeInsets.fromLTRB(12, 12, 0, 12),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: p.hairline)),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Image.network(_qr!, fit: BoxFit.contain, errorBuilder: (_, _, _) => Icon(Icons.qr_code_2_rounded, size: 60, color: c)),
                  const SizedBox(height: 4),
                  const Text('تكبير', style: TextStyle(fontSize: 10.5, color: Colors.black54, fontWeight: FontWeight.w700)),
                ]),
              ),
            ),
        ]),
      ),
    );
  }
}

/// زر واتساب الأخضر الكبير.
class WhatsAppButton extends StatelessWidget {
  const WhatsAppButton({super.key, required this.label, required this.onPressed, this.busy = false});
  final String label;
  final VoidCallback? onPressed;
  final bool busy;
  @override
  Widget build(BuildContext context) => FilledButton(
        onPressed: busy ? null : onPressed,
        style: FilledButton.styleFrom(backgroundColor: waGreen, minimumSize: const Size(0, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
        child: busy
            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
            : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.chat_rounded, size: 20),
                const SizedBox(width: 8),
                Flexible(child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800))),
              ]),
      );
}

/// خطوات «كيف يتفعّل متجرك» — مرقّمة بخط عمودي.
class HowSteps extends StatelessWidget {
  const HowSteps(this.steps, {super.key});
  final List<(String, String)> steps;
  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);
    return Column(children: [
      for (var i = 0; i < steps.length; i++)
        IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Column(children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: Rv.red, shape: BoxShape.circle),
                child: Text('${i + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
              ),
              if (i < steps.length - 1) Expanded(child: Container(width: 2, color: Rv.red.withValues(alpha: .2))),
            ]),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16, top: 3),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(steps[i].$1, style: TextStyle(fontWeight: FontWeight.w800, color: p.ink)),
                  const SizedBox(height: 2),
                  Text(steps[i].$2, style: AppTypography.caption.copyWith(color: p.inkMuted, height: 1.5)),
                ]),
              ),
            ),
          ]),
        ),
    ]);
  }
}

/// صفّ في ملخص الطلب.
class SummaryRow extends StatelessWidget {
  const SummaryRow(this.label, this.value, {super.key, this.hint, this.strong = false});
  final String label;
  final String value;
  final String? hint;
  final bool strong;
  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: TextStyle(color: strong ? p.ink : p.inkMuted, fontWeight: strong ? FontWeight.w800 : FontWeight.w500)),
            if (hint != null) Text(hint!, style: AppTypography.caption.copyWith(color: p.inkFaint, fontSize: 11)),
          ]),
        ),
        Text(value,
            style: strong
                ? const TextStyle(fontFamily: 'Zain', fontSize: 30, fontWeight: FontWeight.w800, color: Rv.red, height: 1)
                : TextStyle(fontWeight: FontWeight.w800, color: p.ink)),
      ]),
    );
  }
}
