import 'package:flutter/material.dart';
import '../store_app/store_help.dart';
import '../../shared/widgets/help_tips.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/design/azm_tokens.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_typography.dart';
import '../shop/data/shop_models.dart';
import '../shop/providers/shop_providers.dart';
import '../store_app/kit.dart';
import '../store_app/store_api.dart';
import '../store_app/store_gate.dart';
import 'payment_methods_screen.dart';
import 'platform_api.dart';
import 'platform_catalog.dart';
import 'platform_widgets.dart';
import 'store_templates_screen.dart';

/// الباقة والاشتراك: باقتك وأيامها، والترقية بخطوة (فاتورة + رسالة واتساب للفريق)،
/// والفواتير مع رفع الإيصال من الجوال، وحسابات الدفع.
class StorePlanScreen extends ConsumerWidget {
  const StorePlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = AzmPalette.of(context);
    return Scaffold(
      backgroundColor: p.ground,
      appBar: AppBar(backgroundColor: p.ground, title: const Text('الباقة والاشتراك'), actions: const [HelpButton(StoreHelp.plan)]),
      body: StoreGate(builder: (context, store, _) => WithHelp(tip: StoreHelp.plan, child: _PlanBody(store: store))),
    );
  }
}

class _PlanBody extends ConsumerStatefulWidget {
  const _PlanBody({required this.store});
  final ShopStore store;
  @override
  ConsumerState<_PlanBody> createState() => _PlanBodyState();
}

class _PlanBodyState extends ConsumerState<_PlanBody> {
  late Future<(Map<String, dynamic>, List<Map<String, dynamic>>)> _load = _fetch();
  bool _yearly = false;
  PlanId? _target;
  bool _busy = false;

  Future<(Map<String, dynamic>, List<Map<String, dynamic>>)> _fetch() async {
    final api = ref.read(platformApiProvider);
    final r = await Future.wait([api.subscription(widget.store.id), api.invoices(widget.store.id)]);
    return (r[0] as Map<String, dynamic>, r[1] as List<Map<String, dynamic>>);
  }

  Future<void> _reload() async {
    setState(() => _load = _fetch());
    ref.invalidate(storeListProvider);
  }

  void _snack(String m, {bool error = false}) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m), backgroundColor: error ? AzmPalette.of(context).danger : null));

  Future<void> _upgrade(PlatformPricing pr, PlanId plan) async {
    setState(() => _busy = true);
    try {
      final inv = await ref.read(platformApiProvider).planInvoice(widget.store.id, plan, yearly: _yearly);
      final amount = (inv['amount'] as num?) ?? pr.price(plan, yearly: _yearly);
      await PlatformContact.whatsapp(
        PlatformContact.forPhone(widget.store.whatsapp, country: widget.store.country),
        [
          'مرحبًا فريق RVIOS 👋 أريد ترقية باقة متجري:',
          '🏪 المتجر: ${widget.store.name} (${widget.store.slug}.rvios.com)',
          '⭐ الباقة: ${plan.label} · ${_yearly ? 'سنوي' : 'شهري'}',
          '🧾 الفاتورة: ${inv['invoiceNumber'] ?? ''}',
          '💰 المبلغ: ${fmtMoney(amount)} ${currencyLabel('${inv['currency'] ?? pr.currency}')}',
          '',
          'أرسلت الطلب من تطبيق RVIOS، وسأرسل إيصال التحويل هنا.',
        ].join('\n'),
      );
      _snack('أُنشئت فاتورة الترقية وفُتح واتساب — أرسل الإيصال ليُفعَّل');
      setState(() => _target = null);
      await _reload();
    } on ApiException catch (e) {
      _snack(e.message, error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _proof(Map<String, dynamic> inv) async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80, maxWidth: 1800);
    if (img == null) return;
    setState(() => _busy = true);
    try {
      final url = await ref.read(storeDataApiProvider).uploadImage(widget.store.id, await img.readAsBytes(), img.name);
      await ref.read(platformApiProvider).submitProof('${inv['id']}', url);
      _snack('وصل الإيصال ✓ — يتفعّل طلبك بعد مراجعة الفريق');
      await _reload();
    } catch (e) {
      _snack(e is ApiException ? e.message : '$e', error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);
    final s = widget.store;
    final pricing = ref.watch(pricingProvider);
    return FutureBuilder(
      future: _load,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done || !pricing.hasValue) {
          return const Center(child: CircularProgressIndicator(color: Rv.red));
        }
        if (snap.hasError) {
          return RvEmpty(icon: Icons.wifi_off_rounded, title: 'تعذّر التحميل', body: '${snap.error}', action: 'إعادة المحاولة', onAction: _reload);
        }
        final (sub, invoices) = snap.data!;
        final pr = pricing.value!;
        final current = PlanId.fromServer('${sub['effectivePlan'] ?? s.plan}');
        final days = (sub['daysLeft'] as num?)?.toInt();
        final status = (sub['status'] as num?)?.toInt() ?? 0;
        final pending = s.status == 2;
        final open = invoices.where((i) => i['status'] == 0 || i['status'] == 1).toList();

        return RefreshIndicator(
          color: Rv.red,
          onRefresh: _reload,
          child: ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 40), children: [
            // ── البطل ──
            RvHero(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text('باقة متجرك', style: TextStyle(color: Colors.white.withValues(alpha: .75))),
                  const Spacer(),
                  if (pending)
                    _HeroPill('بانتظار التفعيل', const Color(0xFFFFD58A))
                  else if (current.paid)
                    _HeroPill(switch (status) { 1 => 'مهلة سماح', 2 => 'منتهية', _ => 'فعّالة' }, status == 0 ? const Color(0xFF8BF0C4) : const Color(0xFFFFD58A)),
                ]),
                const SizedBox(height: 4),
                Row(children: [
                  Icon(current.icon, color: Rv.gold, size: 30),
                  const SizedBox(width: 8),
                  Text(current.label, style: const TextStyle(fontFamily: 'Zain', fontSize: 42, fontWeight: FontWeight.w800, color: Colors.white, height: 1.1)),
                ]),
                const SizedBox(height: 6),
                Text(
                  pending
                      ? 'متجرك محجوز وينتظر الدفع — أرسل الإيصال فيتفعّل.'
                      : current.paid
                          ? (days == null ? 'اشتراك فعّال' : days >= 0 ? 'يتجدّد خلال $days يومًا' : 'انتهت الفترة منذ ${-days} يومًا — جدّد لتبقى الميزات')
                          : 'باقة مجانية للأبد — ترقَّ لمنتجات أكثر وقوالب مميزة ودومين خاص.',
                  style: TextStyle(color: Colors.white.withValues(alpha: .85), height: 1.5),
                ),
                if (current.paid && days != null && days >= 0) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: (days / (days > 31 ? 365 : 30)).clamp(0, 1).toDouble(),
                      minHeight: 6,
                      color: Rv.gold,
                      backgroundColor: Colors.white.withValues(alpha: .15),
                    ),
                  ),
                ],
              ]),
            ),

            // ── الفواتير المفتوحة ──
            if (open.isNotEmpty) ...[
              const RvSection('بانتظار الدفع'),
              for (final inv in open) _InvoiceCard(inv: inv, busy: _busy, onProof: () => _proof(inv)),
            ],

            // ── الترقية ──
            RvSection(current == PlanId.biz ? 'جدّد باقتك' : 'رقِّ باقتك'),
            BillingToggle(yearly: _yearly, monthsFree: pr.yearlyMonthsFree, onChanged: (v) => setState(() => _yearly = v)),
            const SizedBox(height: 12),
            for (final plan in [PlanId.pro, PlanId.biz])
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: PlanCard(
                  plan: plan,
                  price: pr.price(plan, yearly: _yearly),
                  currency: pr.currency,
                  yearly: _yearly,
                  current: plan == current,
                  selected: _target == plan,
                  onTap: () => setState(() => _target = plan),
                ),
              ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _target == null
                  ? Text('اختر باقة لتطلبها — تُنشأ فاتورتها ويُفتح واتساب برسالة جاهزة للفريق.', key: const ValueKey('h'), textAlign: TextAlign.center, style: AppTypography.caption.copyWith(color: p.inkMuted))
                  : WhatsAppButton(
                      key: ValueKey(_target),
                      busy: _busy,
                      label: '${_target == current ? 'جدّد' : 'اطلب'} ${_target!.label} · ${currencyLabel(pr.currency)}${fmtMoney(pr.price(_target!, yearly: _yearly))}',
                      onPressed: () => _upgrade(pr, _target!),
                    ),
            ),

            // ── اختصارات ──
            const SizedBox(height: 18),
            Row(children: [
              Expanded(
                child: _Shortcut(icon: Icons.palette_rounded, label: 'قوالب المتجر', onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const StoreTemplatesScreen()))),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Shortcut(
                  icon: Icons.account_balance_wallet_rounded,
                  label: 'طرق الدفع',
                  onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => PaymentMethodsScreen(whatsapp: s.whatsapp))),
                ),
              ),
            ]),

            // ── السجل ──
            if (invoices.any((i) => i['status'] == 2 || i['status'] == 3)) ...[
              const RvSection('سجل الفواتير'),
              for (final inv in invoices.where((i) => i['status'] == 2 || i['status'] == 3)) _InvoiceCard(inv: inv, busy: false),
            ],
          ]),
        );
      },
    );
  }
}

class _HeroPill extends StatelessWidget {
  const _HeroPill(this.text, this.color);
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: color.withValues(alpha: .2), borderRadius: BorderRadius.circular(99), border: Border.all(color: color.withValues(alpha: .5))),
        child: Text(text, style: TextStyle(color: color, fontSize: 11.5, fontWeight: FontWeight.w800)),
      );
}

class _Shortcut extends StatelessWidget {
  const _Shortcut({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);
    return RvCard(
      onTap: onTap,
      child: Row(children: [
        Icon(icon, color: Rv.red),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: TextStyle(fontWeight: FontWeight.w700, color: p.ink))),
        Icon(Icons.chevron_left_rounded, color: p.inkFaint),
      ]),
    );
  }
}

class _InvoiceCard extends StatelessWidget {
  const _InvoiceCard({required this.inv, required this.busy, this.onProof});
  final Map<String, dynamic> inv;
  final bool busy;
  final VoidCallback? onProof;

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);
    final st = ((inv['status'] as num?) ?? 0).toInt().clamp(0, 3);
    final kind = ((inv['kind'] as num?) ?? 0).toInt();
    final (label, color) = [
      ('بانتظار الدفع', Rv.red),
      ('قيد المراجعة', const Color(0xFF2F6FB3)),
      ('مدفوعة', const Color(0xFF0F766E)),
      ('ملغاة', p.inkFaint),
    ][st];
    final what = switch (kind) {
      0 => 'باقة ${PlanId.fromServer('${inv['plan']}').label} · ${inv['months'] == 12 ? 'سنوي' : 'شهري'}',
      4 => 'قالب ${StoreTemplate.byId('${inv['item'] ?? ''}').name}',
      2 => 'دومين خاص',
      3 => 'متجر إضافي',
      _ => 'بناء المتجر',
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: RvCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(12)),
              child: Icon(kind == 4 ? Icons.palette_outlined : Icons.receipt_long_rounded, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(what, style: TextStyle(fontWeight: FontWeight.w800, color: p.ink)),
                Text('${inv['invoiceNumber'] ?? ''} · ${Rv.ago('${inv['createdAt'] ?? ''}')}', textDirection: TextDirection.rtl, style: AppTypography.caption.copyWith(color: p.inkMuted)),
              ]),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('${currencyLabel('${inv['currency'] ?? 'USD'}')}${fmtMoney((inv['amount'] as num?) ?? num.tryParse('${inv['amount']}') ?? 0)}',
                  style: const TextStyle(fontFamily: 'Zain', fontSize: 22, fontWeight: FontWeight.w800, color: Rv.red, height: 1)),
              const SizedBox(height: 4),
              RvChip(label, color: color),
            ]),
          ]),
          if (st == 0 && onProof != null) ...[
            const SizedBox(height: 10),
            Text('حوّل المبلغ واكتب رقم الفاتورة في ملاحظة التحويل، ثم ارفع صورة الإيصال.', style: AppTypography.caption.copyWith(color: p.inkMuted)),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: busy ? null : onProof,
              icon: const Icon(Icons.upload_rounded, size: 18),
              label: const Text('ارفع صورة الإيصال'),
              style: FilledButton.styleFrom(backgroundColor: Rv.red, minimumSize: const Size(0, 46), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            ),
          ],
          if (st == 1) ...[
            const SizedBox(height: 8),
            Text('وصل الإيصال — الفريق يراجعه ويفعّل طلبك.', style: AppTypography.caption.copyWith(color: const Color(0xFF2F6FB3))),
          ],
        ]),
      ),
    );
  }
}
