import 'package:flutter/material.dart';
import '../store_app/store_help.dart';
import '../../shared/widgets/help_tips.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design/azm_tokens.dart';
import '../../core/network/api_exception.dart';
import '../shop/data/shop_models.dart';
import '../shop/providers/shop_providers.dart';
import '../store_app/kit.dart';
import '../store_app/store_gate.dart';
import 'platform_api.dart';
import 'platform_catalog.dart';
import 'platform_widgets.dart';
import 'store_plan_screen.dart';
import 'template_preview_screen.dart';

/// قوالب متجرك: المعرض كاملًا بمعاينة حية، والقالب يُطبَّق بنقرة إن كان مجانيًا أو
/// مشمولًا أو مملوكًا، أو يُشترى (فاتورة + واتساب)، أو يطلب ترقية الباقة.
class StoreTemplatesScreen extends ConsumerWidget {
  const StoreTemplatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = AzmPalette.of(context);
    return Scaffold(
      backgroundColor: p.ground,
      appBar: AppBar(backgroundColor: p.ground, title: const Text('قوالب المتجر'), actions: const [HelpButton(StoreHelp.templates)]),
      body: StoreGate(builder: (context, store, _) => WithHelp(tip: StoreHelp.templates, child: _Gallery(store: store))),
    );
  }
}

class _Gallery extends ConsumerStatefulWidget {
  const _Gallery({required this.store});
  final ShopStore store;
  @override
  ConsumerState<_Gallery> createState() => _GalleryState();
}

class _GalleryState extends ConsumerState<_Gallery> {
  String _tier = 'all';
  bool _busy = false;

  PlanId get _plan => PlanId.fromServer(widget.store.plan);

  void _snack(String m, {bool error = false}) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m), backgroundColor: error ? AzmPalette.of(context).danger : null));

  Future<void> _act(PlatformPricing pr, StoreTemplate t) async {
    final s = widget.store;
    final cost = pr.templateCost(t, _plan, owned: s.ownedTemplates);
    if (t.id == s.template) return _snack('هذا قالب متجرك الآن');
    if (cost == null) {
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const StorePlanScreen()));
      return _snack('قالب «${t.name}» يحتاج باقة مدفوعة — اختر باقتك أولًا');
    }
    setState(() => _busy = true);
    try {
      if (cost == 0) {
        await ref.read(platformApiProvider).update(s.id, {'template': t.id});
        HapticFeedback.mediumImpact();
        ref.invalidate(storeListProvider);
        _snack('طُبّق قالب «${t.name}» على متجرك ✓');
      } else {
        final inv = await ref.read(platformApiProvider).templateInvoice(s.id, t.id);
        await PlatformContact.whatsapp(
          PlatformContact.forPhone(s.whatsapp, country: s.country),
          [
            'مرحبًا فريق RVIOS 👋 أريد شراء قالب لمتجري:',
            '🏪 المتجر: ${s.name} (${s.slug}.rvios.store)',
            '🎨 القالب: ${t.name}',
            '🧾 الفاتورة: ${inv['invoiceNumber'] ?? ''}',
            '💰 المبلغ: ${fmtMoney((inv['amount'] as num?) ?? cost)} ${currencyLabel('${inv['currency'] ?? pr.currency}')}',
            '',
            'أرسلت الطلب من تطبيق RVIOS، وسأرسل إيصال التحويل هنا.',
          ].join('\n'),
        );
        _snack('أُنشئت فاتورة القالب — بعد الدفع يُضاف إلى قوالبك');
      }
    } on ApiException catch (e) {
      _snack(e.message, error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _label(PlatformPricing pr, StoreTemplate t) {
    final cost = pr.templateCost(t, _plan, owned: widget.store.ownedTemplates);
    if (t.id == widget.store.template) return 'هذا قالب متجرك';
    if (cost == null) return 'يحتاج باقة مدفوعة — رقِّ باقتك';
    if (cost == 0) return 'طبّق على متجري';
    return 'اشترِ القالب · ${currencyLabel(pr.currency)}${fmtMoney(cost)}';
  }

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);
    final s = widget.store;
    final pricing = ref.watch(pricingProvider);
    return pricing.when(
      loading: () => const Center(child: CircularProgressIndicator(color: Rv.red)),
      error: (e, _) => RvEmpty(icon: Icons.wifi_off_rounded, title: 'تعذّر التحميل', body: '$e', action: 'إعادة المحاولة', onAction: () => ref.invalidate(pricingProvider)),
      data: (pr) {
        final list = StoreTemplate.all.where((t) => _tier == 'all' || (_tier == 'mine' ? (t.id == s.template || s.ownedTemplates.contains(t.id) || pr.templateCost(t, _plan) == 0) : t.tier == _tier)).toList();
        final current = StoreTemplate.byId(s.template);
        return Stack(children: [
          CustomScrollView(slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              sliver: SliverToBoxAdapter(
                child: RvCard(
                  padding: const EdgeInsets.all(12),
                  child: Row(children: [
                    SizedBox(width: 64, height: 120, child: TemplateShot(current, radius: 12)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('قالب متجرك الآن', style: TextStyle(color: p.inkMuted, fontSize: 12.5)),
                        Text(current.name, style: TextStyle(fontFamily: 'Zain', fontSize: 30, fontWeight: FontWeight.w800, color: p.ink, height: 1.1)),
                        Text(current.tag, style: TextStyle(color: p.inkMuted, fontSize: 12.5)),
                        const SizedBox(height: 6),
                        Text('باقتك: ${_plan.label}${s.ownedTemplates.isNotEmpty ? ' · تملك ${s.ownedTemplates.length} قالبًا' : ''}', style: const TextStyle(color: Rv.red, fontWeight: FontWeight.w700, fontSize: 12.5)),
                      ]),
                    ),
                  ]),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 44,
                child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16), children: [
                  for (final (id, label) in const [('all', 'الكل'), ('mine', 'المتاحة لي'), ('standard', 'قياسي'), ('signature', 'توقيع ✦')])
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: 8),
                      child: ChoiceChip(
                        label: Text(label),
                        selected: _tier == id,
                        onSelected: (_) => setState(() => _tier = id),
                        selectedColor: Rv.red,
                        showCheckmark: false,
                        labelStyle: TextStyle(color: _tier == id ? Colors.white : p.ink, fontWeight: FontWeight.w700),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99), side: BorderSide(color: _tier == id ? Rv.red : p.hairline)),
                      ),
                    ),
                ]),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 40),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: .5),
                delegate: SliverChildBuilderDelegate((context, i) {
                  final t = list[i];
                  void preview() => TemplatePreviewScreen.open(
                        context,
                        templates: list,
                        initial: t,
                        currency: pr.currency,
                        priceOf: (x) => pr.templateCost(x, _plan, owned: s.ownedTemplates) ?? pr.templateBase(x),
                        pickLabelOf: (x) => _label(pr, x),
                        onPick: (x) => _act(pr, x),
                      );
                  return TemplateCard(
                    t: t,
                    current: t.id == s.template,
                    owned: s.ownedTemplates.contains(t.id),
                    currency: pr.currency,
                    price: pr.templateCost(t, _plan, owned: s.ownedTemplates) ?? pr.templateBase(t),
                    onTap: preview,
                    onPreview: preview,
                  );
                }, childCount: list.length),
              ),
            ),
          ]),
          if (_busy) const Positioned.fill(child: ColoredBox(color: Colors.black26, child: Center(child: CircularProgressIndicator(color: Rv.red)))),
        ]);
      },
    );
  }
}
