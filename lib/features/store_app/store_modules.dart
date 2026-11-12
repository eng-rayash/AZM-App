import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/design/azm_tokens.dart';
import '../../core/theme/app_typography.dart';
import '../shop/data/shop_models.dart';
import 'kit.dart';
import 'store_api.dart';
import 'store_gate.dart';

/// هيكل موحّد لشاشات وحدات المتجر: شريط علوي بعنوان واسم المتجر، ومحمِّل
/// يجلب بيانات الوحدة بالمتجر المفتوح، وسحب للتحديث، وخطأ بإعادة المحاولة.
class _ModuleScaffold<T> extends ConsumerStatefulWidget {
  const _ModuleScaffold({super.key, required this.title, required this.load, required this.builder, this.actions});
  final String title;
  final Future<T> Function(StoreDataApi api, ShopStore store) load;
  final Widget Function(BuildContext context, T data, ShopStore store, Future<void> Function() reload) builder;
  final List<Widget> Function(BuildContext context, ShopStore store, Future<void> Function() reload)? actions;

  @override
  ConsumerState<_ModuleScaffold<T>> createState() => _ModuleScaffoldState<T>();
}

class _ModuleScaffoldState<T> extends ConsumerState<_ModuleScaffold<T>> {
  Future<T>? _future;
  String? _storeId;

  Future<void> _reload(ShopStore store) async {
    final f = widget.load(ref.read(storeDataApiProvider), store);
    setState(() => _future = f);
    await f.catchError((_) => null as T);
  }

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);
    return Scaffold(
      backgroundColor: p.ground,
      body: StoreGate(builder: (context, store, all) {
        if (_storeId != store.id) {
          _storeId = store.id;
          _future = widget.load(ref.read(storeDataApiProvider), store);
        }
        reload() => _reload(store);
        return NestedScrollView(
          headerSliverBuilder: (_, _) => [
            SliverAppBar(
              pinned: true,
              backgroundColor: p.ground,
              surfaceTintColor: Colors.transparent,
              title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(widget.title, style: AppTypography.h3.copyWith(color: p.ink, fontFamily: 'Zain', fontWeight: FontWeight.w800)),
                Text(store.name, style: AppTypography.caption.copyWith(color: p.inkFaint)),
              ]),
              actions: widget.actions?.call(context, store, reload),
            ),
          ],
          body: FutureBuilder<T>(
            future: _future,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done && !snap.hasData) {
                return const Center(child: CircularProgressIndicator(color: Rv.red));
              }
              if (snap.hasError) {
                return RvEmpty(icon: Icons.wifi_off_rounded, title: 'تعذّر التحميل', body: '${snap.error}', action: 'إعادة المحاولة', onAction: reload);
              }
              return RefreshIndicator(color: Rv.red, onRefresh: reload, child: widget.builder(context, snap.data as T, store, reload));
            },
          ),
        );
      }),
    );
  }
}

void _snack(BuildContext context, String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

Future<void> _run(BuildContext context, Future<void> Function() fn, String ok) async {
  try {
    await fn();
    if (context.mounted) _snack(context, ok);
  } catch (e) {
    if (context.mounted) _snack(context, '$e');
  }
}

// ═══════════════════════════════════════════════════════════
// العملاء
// ═══════════════════════════════════════════════════════════

class StoreCustomersScreen extends StatefulWidget {
  const StoreCustomersScreen({super.key});
  @override
  State<StoreCustomersScreen> createState() => _StoreCustomersScreenState();
}

class _StoreCustomersScreenState extends State<StoreCustomersScreen> {
  String _q = '';
  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);
    return _ModuleScaffold<Map<String, dynamic>>(
      title: 'العملاء',
      load: (api, s) => api.customers(s.id),
      builder: (context, d, store, reload) {
        final all = ((d['customers'] as List?) ?? const []).cast<Map>();
        final list = _q.isEmpty
            ? all
            : all.where((c) => '${c['name']} ${c['phone']}'.toLowerCase().contains(_q.toLowerCase())).toList();
        return ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 40), children: [
          Row(children: [
            Expanded(child: RvStat(label: 'كل العملاء', value: Rv.money((d['total'] as num?) ?? 0), icon: Icons.people_alt_outlined)),
            const SizedBox(width: 10),
            Expanded(child: RvStat(label: 'عادوا للشراء', value: Rv.money((d['returning'] as num?) ?? 0), icon: Icons.repeat_rounded, tone: const Color(0xFF0F766E))),
          ]),
          const SizedBox(height: 12),
          TextField(
            decoration: const InputDecoration(hintText: 'ابحث بالاسم أو الجوال', prefixIcon: Icon(Icons.search)),
            onChanged: (v) => setState(() => _q = v.trim()),
          ),
          const SizedBox(height: 10),
          if (list.isEmpty) const Padding(padding: EdgeInsets.only(top: 40), child: RvEmpty(icon: Icons.people_outline, title: 'لا عملاء بعد', body: 'كل من يطلب من متجرك يظهر هنا مع طلباته وما أنفقه.')),
          for (final c in list)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: RvCard(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(children: [
                  CircleAvatar(
                    backgroundColor: Rv.red.withValues(alpha: .1),
                    child: Text('${c['name'] ?? '؟'}'.characters.first, style: const TextStyle(color: Rv.red, fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('${c['name'] ?? ''}', style: AppTypography.body.copyWith(color: p.ink, fontWeight: FontWeight.w700)),
                      Text('${c['ordersCount'] ?? 0} طلب · ${Rv.money((c['spent'] as num?) ?? 0)} ${store.currency}', style: AppTypography.caption.copyWith(color: p.inkFaint)),
                    ]),
                  ),
                  if ('${c['phone'] ?? ''}'.isNotEmpty)
                    IconButton(
                      tooltip: 'واتساب',
                      icon: const Icon(Icons.chat_rounded, color: Color(0xFF16A34A)),
                      onPressed: () => launchUrl(Uri.parse('https://wa.me/${'${c['phone']}'.replaceAll(RegExp(r'\D'), '')}'), mode: LaunchMode.externalApplication),
                    ),
                ]),
              ),
            ),
        ]);
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════
// التقييمات
// ═══════════════════════════════════════════════════════════

class StoreReviewsScreen extends StatelessWidget {
  const StoreReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);
    return _ModuleScaffold<Map<String, dynamic>>(
      title: 'التقييمات',
      load: (api, s) => api.reviews(s.id),
      builder: (context, d, store, reload) {
        final list = ((d['reviews'] as List?) ?? const []).cast<Map>();
        final counts = (d['counts'] as Map?) ?? {};
        return ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 40), children: [
          RvHero(
            child: Row(children: [
              Text('${d['average'] ?? 0}', style: const TextStyle(fontFamily: 'Zain', fontSize: 52, fontWeight: FontWeight.w800, color: Colors.white)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [for (var i = 1; i <= 5; i++) Icon(i <= ((d['average'] as num?) ?? 0).round() ? Icons.star_rounded : Icons.star_outline_rounded, color: Rv.gold)]),
                  Text('${counts['1'] ?? 0} منشور · ${counts['0'] ?? 0} بانتظار مراجعتك', style: const TextStyle(color: Colors.white70)),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 12),
          if (list.isEmpty) const RvEmpty(icon: Icons.star_outline_rounded, title: 'لا تقييمات بعد', body: 'يقيّم المشترون بعد اكتمال طلباتهم، وتراجع أنت التقييم قبل نشره.'),
          for (final r in list)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: RvCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    for (var i = 1; i <= 5; i++) Icon(i <= ((r['rating'] as num?) ?? 0) ? Icons.star_rounded : Icons.star_outline_rounded, size: 18, color: Rv.gold),
                    const SizedBox(width: 8),
                    Expanded(child: Text('${r['name'] ?? r['custName'] ?? 'مشترٍ'}', style: AppTypography.caption.copyWith(color: p.inkMuted))),
                    RvChip(const ['بانتظار المراجعة', 'منشور', 'مخفي'][((r['status'] as num?) ?? 0).toInt().clamp(0, 2)],
                        color: [Rv.gold, const Color(0xFF0F766E), p.inkFaint][((r['status'] as num?) ?? 0).toInt().clamp(0, 2)]),
                  ]),
                  if ((r['product'] as Map?)?['name'] != null) Text('${(r['product'] as Map)['name']}', style: AppTypography.caption.copyWith(color: p.inkFaint)),
                  if ('${r['body'] ?? r['comment'] ?? ''}'.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 6), child: Text('${r['body'] ?? r['comment']}', style: AppTypography.body.copyWith(color: p.ink))),
                  const SizedBox(height: 8),
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    if (r['status'] != 1)
                      TextButton.icon(
                        onPressed: () => _run(context, () async {
                          await ProviderScope.containerOf(context).read(storeDataApiProvider).setReview(store.id, '${r['id']}', status: 1);
                          await reload();
                        }, 'نُشر التقييم'),
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('نشر'),
                      ),
                    if (r['status'] != 2)
                      TextButton.icon(
                        onPressed: () => _run(context, () async {
                          await ProviderScope.containerOf(context).read(storeDataApiProvider).setReview(store.id, '${r['id']}', status: 2);
                          await reload();
                        }, 'أُخفي التقييم'),
                        icon: const Icon(Icons.visibility_off_outlined),
                        label: const Text('إخفاء'),
                      ),
                  ]),
                ]),
              ),
            ),
        ]);
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════
// مناطق التوصيل
// ═══════════════════════════════════════════════════════════

class StoreZonesScreen extends StatelessWidget {
  const StoreZonesScreen({super.key});

  Future<void> _edit(BuildContext context, ShopStore store, Future<void> Function() reload, [Map? z]) async {
    final name = TextEditingController(text: '${z?['name'] ?? ''}');
    final fee = TextEditingController(text: z == null ? '' : '${z['fee'] ?? 0}');
    final free = TextEditingController(text: z == null ? '' : '${z['freeOver'] ?? 0}');
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (c) => Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + MediaQuery.of(c).viewInsets.bottom),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(z == null ? 'منطقة توصيل جديدة' : 'تعديل المنطقة', style: AppTypography.h3),
          const SizedBox(height: 12),
          TextField(controller: name, decoration: const InputDecoration(labelText: 'اسم المنطقة أو المدينة')),
          const SizedBox(height: 10),
          TextField(controller: fee, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'رسم التوصيل (${store.currency})')),
          const SizedBox(height: 10),
          TextField(controller: free, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'مجاني للطلبات فوق (٠ = لا)')),
          const SizedBox(height: 16),
          FilledButton(style: FilledButton.styleFrom(backgroundColor: Rv.red, minimumSize: const Size(0, 48)), onPressed: () => Navigator.pop(c, true), child: const Text('حفظ')),
        ]),
      ),
    );
    if (ok != true || !context.mounted) return;
    final api = ProviderScope.containerOf(context).read(storeDataApiProvider);
    final body = {'name': name.text.trim(), 'fee': int.tryParse(fee.text.trim()) ?? 0, 'freeOver': int.tryParse(free.text.trim()) ?? 0};
    await _run(context, () async {
      z == null ? await api.addZone(store.id, body) : await api.editZone(store.id, '${z['id']}', body);
      await reload();
    }, 'حُفظت المنطقة');
  }

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);
    return _ModuleScaffold<List<Map<String, dynamic>>>(
      title: 'مناطق التوصيل',
      load: (api, s) => api.zones(s.id),
      actions: (context, store, reload) => [IconButton(icon: const Icon(Icons.add_circle_rounded, color: Rv.red), onPressed: () => _edit(context, store, reload))],
      builder: (context, list, store, reload) => ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 40), children: [
        Text('لكل مدينة أو حي رسمه، ويختار العميل منطقته عند الطلب. بلا مناطق يُطبَّق رسم التوصيل العام من إعدادات المتجر.',
            style: AppTypography.bodySmall.copyWith(color: p.inkMuted)),
        const SizedBox(height: 12),
        if (list.isEmpty) RvEmpty(icon: Icons.local_shipping_outlined, title: 'لا مناطق بعد', action: 'أضف منطقة', onAction: () => _edit(context, store, reload)),
        for (final z in list)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: RvCard(
              onTap: () => _edit(context, store, reload, z),
              child: Row(children: [
                const Icon(Icons.place_rounded, color: Rv.red),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${z['name']}', style: AppTypography.body.copyWith(color: p.ink, fontWeight: FontWeight.w700)),
                    Text(
                      '${Rv.money((z['fee'] as num?) ?? 0)} ${store.currency}${((z['freeOver'] as num?) ?? 0) > 0 ? ' · مجاني فوق ${Rv.money(z['freeOver'] as num)}' : ''}',
                      style: AppTypography.caption.copyWith(color: p.inkFaint),
                    ),
                  ]),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: p.danger),
                  onPressed: () => _run(context, () async {
                    await ProviderScope.containerOf(context).read(storeDataApiProvider).removeZone(store.id, '${z['id']}');
                    await reload();
                  }, 'حُذفت المنطقة'),
                ),
              ]),
            ),
          ),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// التحليلات
// ═══════════════════════════════════════════════════════════

class StoreAnalyticsScreen extends StatefulWidget {
  const StoreAnalyticsScreen({super.key});
  @override
  State<StoreAnalyticsScreen> createState() => _StoreAnalyticsScreenState();
}

class _StoreAnalyticsScreenState extends State<StoreAnalyticsScreen> {
  int _days = 30;
  int _gen = 0;

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);
    return _ModuleScaffold<Map<String, dynamic>>(
      key: ValueKey(_gen),
      title: 'التحليلات',
      load: (api, s) => api.analytics(s.id, _days),
      builder: (context, d, store, reload) {
        final t = (d['totals'] as Map?) ?? {};
        final series = ((d['series'] as List?) ?? const []).cast<Map>();
        final top = ((d['topProducts'] as List?) ?? const []).cast<Map>();
        final status = (d['byStatus'] as Map?) ?? {};
        num v(String k) => (t[k] as num?) ?? 0;
        return ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 40), children: [
          SegmentedButton<int>(
            segments: const [ButtonSegment(value: 7, label: Text('٧ أيام')), ButtonSegment(value: 30, label: Text('٣٠ يومًا')), ButtonSegment(value: 90, label: Text('٩٠ يومًا'))],
            selected: {_days},
            onSelectionChanged: (s) => setState(() {
              _days = s.first;
              _gen++;
            }),
          ),
          const SizedBox(height: 12),
          RvHero(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('الإيرادات', style: TextStyle(color: Colors.white70)),
              Text('${Rv.money(v('revenue'))} ${store.currency}', style: const TextStyle(fontFamily: 'Zain', fontSize: 38, fontWeight: FontWeight.w800, color: Colors.white)),
              Text('متوسط الطلب ${Rv.money(v('averageOrder'))} · ${Rv.money(v('soldOrders'))} طلب مكتمل', style: const TextStyle(color: Colors.white70)),
            ]),
          ),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.6,
            children: [
              RvStat(label: 'كل الطلبات', value: Rv.money(v('orders')), icon: Icons.receipt_long_outlined),
              RvStat(label: 'الزيارات', value: Rv.money(v('visits')), icon: Icons.visibility_outlined, tone: const Color(0xFF2F6FB3)),
              RvStat(label: 'نسبة التحويل', value: '${v('conversion')}%', icon: Icons.trending_up_rounded, tone: const Color(0xFF0F766E)),
              RvStat(label: 'نسبة الإلغاء', value: '${v('cancelRate')}%', icon: Icons.cancel_outlined, tone: p.danger),
            ],
          ),
          const RvSection('الإيرادات يومًا بيوم'),
          RvCard(
            child: RvBars(
              values: [for (final s in series.length > 30 ? series.sublist(series.length - 30) : series) (s['revenue'] as num?) ?? 0],
              labels: [for (final s in series.length > 30 ? series.sublist(series.length - 30) : series) series.length <= 7 ? '${s['day']}'.substring(8) : ''],
            ),
          ),
          const RvSection('حالات الطلبات'),
          RvCard(
            child: Column(children: [
              for (final (k, l, c) in [('0', 'قيد التأكيد', Rv.red), ('1', 'مؤكد', const Color(0xFF2F6FB3)), ('2', 'مكتمل', const Color(0xFF0F766E)), ('3', 'ملغى', p.inkFaint)])
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(children: [
                    SizedBox(width: 90, child: Text(l, style: AppTypography.bodySmall.copyWith(color: p.ink))),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          value: v('orders') == 0 ? 0 : ((status[k] as num?) ?? 0) / v('orders'),
                          minHeight: 10,
                          color: c,
                          backgroundColor: c.withValues(alpha: .1),
                        ),
                      ),
                    ),
                    SizedBox(width: 40, child: Text('${status[k] ?? 0}', textAlign: TextAlign.end, style: AppTypography.bodySmall.copyWith(color: p.ink))),
                  ]),
                ),
            ]),
          ),
          if (top.isNotEmpty) ...[
            const RvSection('الأكثر مبيعًا'),
            for (final (i, pr) in top.indexed)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: RvCard(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(children: [
                    CircleAvatar(radius: 15, backgroundColor: Rv.red.withValues(alpha: .1), child: Text('${i + 1}', style: const TextStyle(color: Rv.red, fontWeight: FontWeight.w800))),
                    const SizedBox(width: 12),
                    Expanded(child: Text('${pr['name']}', maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTypography.body.copyWith(color: p.ink))),
                    Text('${pr['qty'] ?? pr['sold'] ?? ''} قطعة', style: AppTypography.caption.copyWith(color: p.inkFaint)),
                  ]),
                ),
              ),
          ],
        ]);
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════
// الباقة والفواتير
// ═══════════════════════════════════════════════════════════

class StoreBillingScreen extends StatelessWidget {
  const StoreBillingScreen({super.key});

  Future<void> _attachProof(BuildContext context, ShopStore store, Map inv, Future<void> Function() reload) async {
    final link = TextEditingController();
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (c) => Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + MediaQuery.of(c).viewInsets.bottom),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('إيصال الفاتورة ${inv['invoiceNumber']}', style: AppTypography.h3),
          const SizedBox(height: 6),
          const Text('الصق رابط صورة الإيصال، أو أرسلها للفريق على واتساب ليُرفقها.'),
          const SizedBox(height: 12),
          TextField(controller: link, textDirection: TextDirection.ltr, decoration: const InputDecoration(labelText: 'رابط صورة الإيصال (https://…)')),
          const SizedBox(height: 14),
          FilledButton(style: FilledButton.styleFrom(backgroundColor: Rv.red, minimumSize: const Size(0, 48)), onPressed: () => Navigator.pop(c, true), child: const Text('إرسال للمراجعة')),
        ]),
      ),
    );
    if (ok != true || link.text.trim().isEmpty || !context.mounted) return;
    await _run(context, () async {
      await ProviderScope.containerOf(context).read(storeDataApiProvider).submitProof('${inv['id']}', proofKey: link.text.trim());
      await reload();
    }, 'وصل الإيصال — يتفعّل طلبك بعد المراجعة');
  }

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);
    return _ModuleScaffold<(Map<String, dynamic>, List<Map<String, dynamic>>)>(
      title: 'الباقة والفواتير',
      load: (api, s) async => (await api.pricing(), await api.invoices()),
      builder: (context, data, store, reload) {
        final (pricing, invoices) = data;
        final accounts = ((pricing['accounts'] as List?) ?? const []).cast<Map>();
        final mine = invoices.where((i) => i['storeRef'] == null || i['storeRef'] == store.id).toList();
        return ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 40), children: [
          RvHero(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('باقتك الحالية', style: TextStyle(color: Colors.white70)),
              Text(switch (store.plan) { 'pro' => 'الأعمال', 'plus' => 'الاحترافية', _ => 'المجانية' },
                  style: const TextStyle(fontFamily: 'Zain', fontSize: 36, fontWeight: FontWeight.w800, color: Colors.white)),
              const SizedBox(height: 6),
              const Text('الترقية وشراء القوالب من صفحة «الباقة» في عزم سمارت، والدفع بحوالة إلى أحد الحسابات أدناه.', style: TextStyle(color: Colors.white70, height: 1.6)),
            ]),
          ),
          RvSection('الفواتير', action: mine.isEmpty ? null : '${mine.length}'),
          if (mine.isEmpty) const RvEmpty(icon: Icons.receipt_outlined, title: 'لا فواتير', body: 'تظهر هنا فواتير الاشتراك والقوالب عند طلبها.'),
          for (final inv in mine)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: RvCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Text('${inv['invoiceNumber']}', textDirection: TextDirection.ltr, style: AppTypography.body.copyWith(color: p.ink, fontWeight: FontWeight.w700)),
                    const SizedBox(width: 8),
                    RvChip(const ['بانتظار الدفع', 'قيد المراجعة', 'مدفوعة', 'ملغاة'][((inv['status'] as num?) ?? 0).toInt().clamp(0, 3)],
                        color: [Rv.red, const Color(0xFF2F6FB3), const Color(0xFF0F766E), p.inkFaint][((inv['status'] as num?) ?? 0).toInt().clamp(0, 3)]),
                    const Spacer(),
                    Text('${inv['amount']} ${inv['currency']}', style: AppTypography.body.copyWith(color: p.ink, fontWeight: FontWeight.w800)),
                  ]),
                  if (inv['status'] == 0) ...[
                    const SizedBox(height: 8),
                    Text('اكتب رقم الفاتورة في ملاحظة التحويل، ثم أرسل الإيصال.', style: AppTypography.caption.copyWith(color: p.inkMuted)),
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: TextButton.icon(onPressed: () => _attachProof(context, store, inv, reload), icon: const Icon(Icons.upload_file), label: const Text('إرسال الإيصال')),
                    ),
                  ],
                ]),
              ),
            ),
          const RvSection('حسابات الدفع'),
          for (final a in accounts)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: RvCard(
                child: Row(children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Color(int.tryParse('FF${'${a['color'] ?? '#C1272D'}'.replaceAll('#', '')}', radix: 16) ?? 0xFFC1272D).withValues(alpha: .14),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(a['kind'] == 'wallet' ? Icons.account_balance_wallet_rounded : Icons.account_balance_rounded,
                        color: Color(int.tryParse('FF${'${a['color'] ?? '#C1272D'}'.replaceAll('#', '')}', radix: 16) ?? 0xFFC1272D)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('${a['providerName']}${'${a['currency'] ?? ''}'.isNotEmpty ? ' · ${a['currency']}' : ''}', style: AppTypography.body.copyWith(color: p.ink, fontWeight: FontWeight.w700)),
                      Text('${a['number']}', textDirection: TextDirection.ltr, style: AppTypography.h4.copyWith(color: p.ink, letterSpacing: 1.5)),
                      if ('${a['holder'] ?? ''}'.isNotEmpty) Text('باسم ${a['holder']}', style: AppTypography.caption.copyWith(color: p.inkFaint)),
                    ]),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy_rounded),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: '${a['number']}'));
                      _snack(context, 'نُسخ الرقم');
                    },
                  ),
                ]),
              ),
            ),
        ]);
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════
// الفريق
// ═══════════════════════════════════════════════════════════

class StoreTeamScreen extends StatelessWidget {
  const StoreTeamScreen({super.key});
  static const _roles = ['المالك', 'مدير عام', 'مدير', 'مشرف', 'موظف', 'موظف', 'موظف', 'محاسب', 'عضو', 'ضيف'];

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);
    return _ModuleScaffold<Map<String, dynamic>>(
      title: 'فريق المتجر',
      load: (api, s) => api.members(),
      builder: (context, d, store, reload) {
        final list = ((d['members'] as List?) ?? const []).cast<Map>();
        return ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 40), children: [
          Text('أعضاء شركتك في عزم سمارت. الإضافة وتغيير الأدوار من «الفريق» في لوحة الويب.', style: AppTypography.bodySmall.copyWith(color: p.inkMuted)),
          const SizedBox(height: 12),
          for (final m in list)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: RvCard(
                child: Row(children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFF0891B2).withValues(alpha: .12),
                    child: Text('${(m['user'] as Map?)?['displayName'] ?? '؟'}'.characters.first, style: const TextStyle(color: Color(0xFF0891B2), fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('${(m['user'] as Map?)?['displayName'] ?? ''}', style: AppTypography.body.copyWith(color: p.ink, fontWeight: FontWeight.w700)),
                      Text('${(m['user'] as Map?)?['email'] ?? ''}', style: AppTypography.caption.copyWith(color: p.inkFaint)),
                    ]),
                  ),
                  RvChip(_roles[((m['role'] as num?) ?? 8).toInt().clamp(0, 9)], color: m['isActive'] == false ? p.inkFaint : Rv.red),
                ]),
              ),
            ),
        ]);
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════
// الإشعارات
// ═══════════════════════════════════════════════════════════

class StoreNotificationsScreen extends StatelessWidget {
  const StoreNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);
    return _ModuleScaffold<Map<String, dynamic>>(
      title: 'الإشعارات',
      load: (api, s) => api.notifications(),
      actions: (context, store, reload) => [
        IconButton(
          tooltip: 'تعليم الكل مقروءًا',
          icon: const Icon(Icons.done_all_rounded),
          onPressed: () => _run(context, () async {
            await ProviderScope.containerOf(context).read(storeDataApiProvider).readAllNotifications();
            await reload();
          }, 'عُلّمت كلها مقروءة'),
        ),
      ],
      builder: (context, d, store, reload) {
        final list = ((d['items'] as List?) ?? (d['notifications'] as List?) ?? const []).cast<Map>();
        if (list.isEmpty) return ListView(children: const [SizedBox(height: 80), RvEmpty(icon: Icons.notifications_none_rounded, title: 'لا إشعارات')]);
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
          itemCount: list.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final n = list[i];
            final unread = n['readAt'] == null;
            return RvCard(
              color: unread ? Rv.red.withValues(alpha: .05) : null,
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(unread ? Icons.circle : Icons.circle_outlined, size: 10, color: unread ? Rv.red : p.inkGhost),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${n['title']}', style: AppTypography.body.copyWith(color: p.ink, fontWeight: unread ? FontWeight.w700 : FontWeight.w400)),
                    if ('${n['body'] ?? ''}'.isNotEmpty) Text('${n['body']}', style: AppTypography.caption.copyWith(color: p.inkMuted)),
                    Text(Rv.ago(n['createdAt'] as String?), style: AppTypography.caption.copyWith(color: p.inkFaint, fontSize: 11)),
                  ]),
                ),
              ]),
            );
          },
        );
      },
    );
  }
}
