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

/// المحافظات لإضافتها مناطقَ توصيل بلمسة (كما في اللوحة: src/lib/shop/regions.ts)
const _regions = <String, (String, List<String>)>{
  'YE': ('محافظات اليمن', ['أمانة العاصمة', 'صنعاء', 'عدن', 'تعز', 'إب', 'الحديدة', 'ذمار', 'حضرموت', 'المهرة', 'شبوة', 'أبين', 'لحج', 'الضالع', 'البيضاء', 'مأرب', 'الجوف', 'حجة', 'صعدة', 'عمران', 'المحويت', 'ريمة', 'سقطرى']),
  'SA': ('مناطق السعودية', ['الرياض', 'مكة المكرمة', 'المدينة المنورة', 'القصيم', 'المنطقة الشرقية', 'عسير', 'تبوك', 'حائل', 'الحدود الشمالية', 'جازان', 'نجران', 'الباحة', 'الجوف']),
};

class StoreZonesScreen extends StatelessWidget {
  const StoreZonesScreen({super.key});

  Future<void> _addRegions(BuildContext context, ShopStore store, List<String> missing, Future<void> Function() reload) async {
    final api = ProviderScope.containerOf(context).read(storeDataApiProvider);
    await _run(context, () async {
      for (final n in missing) {
        await api.addZone(store.id, {'name': n, 'fee': store.deliveryFee, 'freeOver': store.deliveryFreeOver});
      }
      await reload();
    }, 'أُضيفت ${missing.length} منطقة — المس أي منطقة لتعديل رسمها');
  }

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
        if (_regions[store.country] case final r?)
          if (r.$2.where((n) => !list.any((z) => '${z['name']}'.trim() == n)).toList() case final missing when missing.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: OutlinedButton.icon(
                onPressed: () => _addRegions(context, store, missing, reload),
                icon: const Icon(Icons.playlist_add_rounded),
                label: Text('أضف ${r.$1} (${missing.length})'),
              ),
            ),
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
// قسائم الخصم
// ═══════════════════════════════════════════════════════════

/// رموز خصم يكتبها العميل في سلة المتجر — نسبة بسقف، أو مبلغ، أو توصيل مجاني.
/// الخادم يحسبها ويحجزها عند كل طلب؛ الشاشة تعرض أثر كل قسيمة.
class StoreCouponsScreen extends StatelessWidget {
  const StoreCouponsScreen({super.key});

  static const _green = Color(0xFF16A34A);

  static (String, Color) _status(Map c, Color faint) {
    if (c['active'] != true) return ('موقوفة', faint);
    final now = DateTime.now();
    final ends = DateTime.tryParse('${c['endsAt'] ?? ''}');
    final starts = DateTime.tryParse('${c['startsAt'] ?? ''}');
    final limit = (c['usageLimit'] as num?) ?? 0;
    if (ends != null && ends.isBefore(now)) return ('منتهية', faint);
    if (limit > 0 && ((c['used'] as num?) ?? 0) >= limit) return ('نفدت', Rv.gold);
    if (starts != null && starts.isAfter(now)) return ('مجدولة', const Color(0xFF2F6FB3));
    return ('نشطة', _green);
  }

  Future<void> _edit(BuildContext context, ShopStore store, Future<void> Function() reload, [Map? c]) async {
    final locked = c != null && ((c['used'] as num?) ?? 0) > 0;
    final code = TextEditingController(text: '${c?['code'] ?? ''}');
    String txt(String k) => c == null || ((c[k] as num?) ?? 0) == 0 ? '' : '${c[k]}';
    final value = TextEditingController(text: txt('value'));
    final cap = TextEditingController(text: txt('maxDiscount'));
    final min = TextEditingController(text: txt('minSubtotal'));
    final limit = TextEditingController(text: txt('usageLimit'));
    final per = TextEditingController(text: txt('perCustomer'));
    var kind = '${c?['kind'] ?? 'percent'}';
    var active = c?['active'] ?? true;
    var ends = DateTime.tryParse('${c?['endsAt'] ?? ''}')?.toLocal();
    final cur = store.currency;

    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheet) => StatefulBuilder(
        builder: (sheet, set) => Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + MediaQuery.of(sheet).viewInsets.bottom),
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text(c == null ? 'قسيمة خصم جديدة' : 'تعديل القسيمة', style: AppTypography.h3),
              const SizedBox(height: 12),
              TextField(
                controller: code,
                enabled: !locked,
                textDirection: TextDirection.ltr,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9_-]')), LengthLimitingTextInputFormatter(24)],
                decoration: InputDecoration(labelText: 'الرمز', hintText: 'EID15', helperText: locked ? 'استُخدم في طلبات فلا يُغيَّر' : null),
              ),
              const SizedBox(height: 12),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'percent', label: Text('نسبة')),
                  ButtonSegment(value: 'amount', label: Text('مبلغ')),
                  ButtonSegment(value: 'ship', label: Text('توصيل مجاني')),
                ],
                selected: {kind},
                onSelectionChanged: (v) => set(() => kind = v.first),
              ),
              const SizedBox(height: 12),
              if (kind != 'ship')
                Row(children: [
                  Expanded(
                    child: TextField(
                      controller: value,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(labelText: kind == 'percent' ? 'النسبة ٪' : 'المبلغ ($cur)'),
                    ),
                  ),
                  if (kind == 'percent') ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: cap,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: InputDecoration(labelText: 'أقصى خصم ($cur)', hintText: 'بلا سقف'),
                      ),
                    ),
                  ],
                ]),
              if (kind != 'ship') const SizedBox(height: 10),
              TextField(
                controller: min,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(labelText: 'حد أدنى للطلب ($cur)', hintText: 'بلا حد'),
              ),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(
                  child: TextField(
                    controller: limit,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(labelText: 'مرات الاستخدام', hintText: 'بلا حد'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: per,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(labelText: 'لكل عميل', hintText: 'بلا حد'),
                  ),
                ),
              ]),
              const SizedBox(height: 6),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event_rounded),
                title: Text(ends == null ? 'بلا تاريخ انتهاء' : 'تنتهي ${ends!.year}/${ends!.month}/${ends!.day}'),
                trailing: ends == null ? const Icon(Icons.add_rounded) : IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => set(() => ends = null)),
                onTap: () async {
                  final now = DateTime.now();
                  final d = await showDatePicker(context: sheet, firstDate: now, lastDate: DateTime(now.year + 3), initialDate: ends ?? now.add(const Duration(days: 7)));
                  if (d != null) set(() => ends = d);
                },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: active == true,
                activeThumbColor: Rv.red,
                title: const Text('مفعّلة'),
                subtitle: const Text('الموقوفة تبقى محفوظة ولا يقبلها المتجر'),
                onChanged: (v) => set(() => active = v),
              ),
              const SizedBox(height: 8),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Rv.red, minimumSize: const Size(0, 48)),
                onPressed: () => Navigator.pop(sheet, true),
                child: Text(c == null ? 'إنشاء القسيمة' : 'حفظ'),
              ),
            ]),
          ),
        ),
      ),
    );
    if (ok != true || !context.mounted) return;
    int n(TextEditingController t) => int.tryParse(t.text.trim()) ?? 0;
    final e = ends;
    final body = <String, Object?>{
      if (!locked) 'code': code.text.trim().toUpperCase(),
      'kind': kind,
      'value': kind == 'ship' ? 0 : n(value),
      'maxDiscount': kind == 'percent' ? n(cap) : 0,
      'minSubtotal': n(min),
      'usageLimit': n(limit),
      'perCustomer': n(per),
      // آخر اليوم المختار بتوقيت الجهاز
      'endsAt': e == null ? null : DateTime(e.year, e.month, e.day, 23, 59, 59).toUtc().toIso8601String(),
      'active': active == true,
    };
    final api = ProviderScope.containerOf(context).read(storeDataApiProvider);
    await _run(context, () async {
      c == null ? await api.addCoupon(store.id, body) : await api.editCoupon(store.id, '${c['id']}', body);
      await reload();
    }, c == null ? 'أُنشئت القسيمة — شارك رمزها مع عملائك' : 'حُفظت القسيمة');
  }

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);
    return _ModuleScaffold<Map<String, dynamic>>(
      title: 'قسائم الخصم',
      load: (api, s) => api.coupons(s.id),
      actions: (context, store, reload) => [IconButton(icon: const Icon(Icons.add_circle_rounded, color: Rv.red), onPressed: () => _edit(context, store, reload))],
      builder: (context, d, store, reload) {
        final list = ((d['coupons'] as List?) ?? const []).cast<Map>();
        final cur = '${d['currency'] ?? store.currency}';
        num sum(String k) => list.fold<num>(0, (a, c) => a + ((c[k] as num?) ?? 0));
        final limit = d['limit'] as num?;
        final activeCount = list.where((c) => c['active'] == true).length;
        return ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 40), children: [
          RvHero(
            child: Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('ما خصمته لعملائك', style: TextStyle(color: Colors.white70)),
                  Text('${Rv.money(sum('discounted'))} $cur', style: const TextStyle(fontFamily: 'Zain', fontSize: 30, fontWeight: FontWeight.w800, color: Colors.white)),
                  Text('${Rv.money(sum('orders'))} طلب بقسيمة · مبيعاتها ${Rv.money(sum('revenue'))} $cur', style: const TextStyle(color: Colors.white70, fontSize: 12.5)),
                ]),
              ),
              const Icon(Icons.local_offer_rounded, color: Rv.gold, size: 40),
            ]),
          ),
          const SizedBox(height: 10),
          if (limit != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text('باقة ${d['planName'] ?? ''}: حتى ${limit.toInt()} قسائم مفعّلة معًا ($activeCount الآن). الباقات المدفوعة بلا حد.',
                  style: AppTypography.caption.copyWith(color: p.inkMuted)),
            ),
          if (list.isEmpty)
            RvEmpty(
              icon: Icons.local_offer_outlined,
              title: 'لا قسائم بعد',
              body: 'أنشئ رمزًا مثل WELCOME10 لأول طلب، أو FREESHIP للتوصيل المجاني، وشاركه في حساباتك.',
              action: 'أنشئ قسيمة',
              onAction: () => _edit(context, store, reload),
            ),
          for (final c in list)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Builder(builder: (context) {
                final (st, color) = _status(c, p.inkFaint);
                final used = (c['used'] as num?) ?? 0;
                final lim = (c['usageLimit'] as num?) ?? 0;
                return RvCard(
                  onTap: () => _edit(context, store, reload, c),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: _green.withValues(alpha: .08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _green.withValues(alpha: .35)),
                        ),
                        child: Text('${c['code']}', textDirection: TextDirection.ltr, style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: .8, color: _green)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text('${c['label'] ?? ''}', style: AppTypography.body.copyWith(color: p.ink, fontWeight: FontWeight.w700))),
                      RvChip(st, color: color),
                    ]),
                    const SizedBox(height: 8),
                    Text(
                      [
                        'استُخدمت ${Rv.money(used)}${lim > 0 ? ' من ${Rv.money(lim)}' : ''}',
                        if (((c['minSubtotal'] as num?) ?? 0) > 0) 'من ${Rv.money(c['minSubtotal'] as num)} $cur',
                        if (((c['perCustomer'] as num?) ?? 0) > 0) '${c['perCustomer']} لكل عميل',
                        'خُصم ${Rv.money((c['discounted'] as num?) ?? 0)} $cur',
                      ].join(' · '),
                      style: AppTypography.caption.copyWith(color: p.inkFaint),
                    ),
                    if (lim > 0) ...[
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(9),
                        child: LinearProgressIndicator(value: (used / lim).clamp(0, 1).toDouble(), minHeight: 5, color: _green, backgroundColor: p.hairline),
                      ),
                    ],
                    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      TextButton.icon(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: '${c['code']}'));
                          _snack(context, 'نُسخ الرمز ${c['code']}');
                        },
                        icon: const Icon(Icons.copy_rounded, size: 18),
                        label: const Text('نسخ'),
                      ),
                      TextButton.icon(
                        onPressed: () => _run(context, () async {
                          await ProviderScope.containerOf(context).read(storeDataApiProvider).editCoupon(store.id, '${c['id']}', {'active': c['active'] != true});
                          await reload();
                        }, c['active'] == true ? 'أُوقفت القسيمة' : 'فُعّلت القسيمة'),
                        icon: Icon(c['active'] == true ? Icons.pause_circle_outline : Icons.play_circle_outline, size: 18),
                        label: Text(c['active'] == true ? 'إيقاف' : 'تفعيل'),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: p.danger),
                        onPressed: () async {
                          final yes = await showDialog<bool>(
                            context: context,
                            builder: (dc) => AlertDialog(
                              title: Text('حذف ${c['code']}؟'),
                              content: const Text('الطلبات السابقة تحتفظ بخصمها كما هو.'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(dc, false), child: const Text('إلغاء')),
                                TextButton(onPressed: () => Navigator.pop(dc, true), child: Text('حذف', style: TextStyle(color: p.danger))),
                              ],
                            ),
                          );
                          if (yes != true || !context.mounted) return;
                          await _run(context, () async {
                            await ProviderScope.containerOf(context).read(storeDataApiProvider).removeCoupon(store.id, '${c['id']}');
                            await reload();
                          }, 'حُذفت القسيمة');
                        },
                      ),
                    ]),
                  ]),
                );
              }),
            ),
        ]);
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════
// أسئلة العملاء
// ═══════════════════════════════════════════════════════════

/// أسئلة زوار المتجر عن المنتجات — الإجابة تُنشر تحت المنتج، ولا يُنشر سؤال بلا إجابة.
class StoreQuestionsScreen extends StatefulWidget {
  const StoreQuestionsScreen({super.key});
  @override
  State<StoreQuestionsScreen> createState() => _StoreQuestionsScreenState();
}

class _StoreQuestionsScreenState extends State<StoreQuestionsScreen> {
  int? _status = 0;

  Future<void> _answer(BuildContext context, ShopStore store, Map q, Future<void> Function() reload) async {
    final c = TextEditingController(text: '${q['answer'] ?? ''}');
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (s) => Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + MediaQuery.of(s).viewInsets.bottom),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('${q['question']}', style: AppTypography.h4),
          const SizedBox(height: 12),
          TextField(controller: c, autofocus: true, maxLines: 4, maxLength: 1000, decoration: const InputDecoration(labelText: 'إجابتك — تظهر للجميع تحت المنتج')),
          const SizedBox(height: 8),
          FilledButton(style: FilledButton.styleFrom(backgroundColor: Rv.red, minimumSize: const Size(0, 48)), onPressed: () => Navigator.pop(s, true), child: const Text('إجابة ونشر')),
        ]),
      ),
    );
    if (ok != true || c.text.trim().isEmpty || !context.mounted) return;
    await _run(context, () async {
      await ProviderScope.containerOf(context).read(storeDataApiProvider).answerQuestion(store.id, '${q['id']}', answer: c.text.trim());
      await reload();
    }, 'نُشرت الإجابة في صفحة المنتج');
  }

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);
    return _ModuleScaffold<Map<String, dynamic>>(
      key: ValueKey(_status),
      title: 'أسئلة العملاء',
      load: (api, s) => api.questions(s.id, status: _status),
      builder: (context, d, store, reload) {
        final list = ((d['questions'] as List?) ?? const []).cast<Map>();
        final counts = (d['counts'] as Map?) ?? {};
        Widget chip(String label, int? v) => Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: ChoiceChip(
                label: Text(v == null ? label : '$label (${counts['$v'] ?? 0})'),
                selected: _status == v,
                onSelected: (_) => setState(() => _status = v),
              ),
            );
        return ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 40), children: [
          SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [chip('بانتظار الإجابة', 0), chip('منشور', 1), chip('مخفي', 2), chip('الكل', null)])),
          const SizedBox(height: 12),
          if (list.isEmpty)
            RvEmpty(icon: Icons.contact_support_outlined, title: _status == 0 ? 'لا أسئلة تنتظرك' : 'لا أسئلة هنا', body: 'يسأل الزائر من صفحة المنتج، ويصلك إشعار.'),
          for (final q in list)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: RvCard(
                onTap: () => _answer(context, store, q, reload),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text('${(q['product'] as Map?)?['name'] ?? ''}', style: AppTypography.caption.copyWith(color: p.inkFaint))),
                    RvChip(const ['بانتظار الإجابة', 'منشور', 'مخفي'][((q['status'] as num?) ?? 0).toInt().clamp(0, 2)],
                        color: [Rv.gold, const Color(0xFF0F766E), p.inkFaint][((q['status'] as num?) ?? 0).toInt().clamp(0, 2)]),
                  ]),
                  const SizedBox(height: 6),
                  Text('${q['question']}', style: AppTypography.body.copyWith(color: p.ink, fontWeight: FontWeight.w700)),
                  Text('${(q['name'] ?? '').toString().isEmpty ? 'زائر' : q['name']} · ${Rv.ago('${q['createdAt']}')}', style: AppTypography.caption.copyWith(color: p.inkFaint)),
                  if ('${q['answer'] ?? ''}'.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: p.hairline.withValues(alpha: .5), borderRadius: BorderRadius.circular(12)),
                      child: Text('${q['answer']}', style: AppTypography.bodySmall.copyWith(color: p.ink)),
                    ),
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    TextButton.icon(onPressed: () => _answer(context, store, q, reload), icon: const Icon(Icons.reply_rounded, size: 18), label: Text(q['status'] == 1 ? 'تعديل الإجابة' : 'أجب')),
                    if (q['status'] == 1)
                      TextButton(
                        onPressed: () => _run(context, () async {
                          await ProviderScope.containerOf(context).read(storeDataApiProvider).answerQuestion(store.id, '${q['id']}', status: 2);
                          await reload();
                        }, 'أُخفي من صفحة المنتج'),
                        child: const Text('إخفاء'),
                      ),
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: p.danger),
                      onPressed: () => _run(context, () async {
                        await ProviderScope.containerOf(context).read(storeDataApiProvider).removeQuestion(store.id, '${q['id']}');
                        await reload();
                      }, 'حُذف السؤال'),
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
// المرتجعات
// ═══════════════════════════════════════════════════════════

/// طلبات الاسترجاع: قبول، أو رفض بملاحظة، أو إتمام بمبلغ مُعاد وإعادة المخزون — الطلب يصير «مُرجَعًا».
class StoreReturnsScreen extends StatefulWidget {
  const StoreReturnsScreen({super.key});
  @override
  State<StoreReturnsScreen> createState() => _StoreReturnsScreenState();
}

class _StoreReturnsScreenState extends State<StoreReturnsScreen> {
  int? _status = 0;
  static const _labels = {0: 'جديدة', 1: 'مقبولة', 3: 'مكتملة', 2: 'مرفوضة'};

  Future<void> _act(BuildContext context, ShopStore store, Map r, Future<void> Function() reload) async {
    final order = (r['order'] as Map?) ?? {};
    final refund = TextEditingController(text: '${r['refund'] ?? order['total'] ?? 0}');
    final note = TextEditingController(text: '${r['note'] ?? ''}');
    var restock = r['restock'] != false;
    final choice = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (s) => StatefulBuilder(
        builder: (s, set) => Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + MediaQuery.of(s).viewInsets.bottom),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('مرتجع ${order['ref'] ?? ''}', style: AppTypography.h3),
            if ('${r['reason'] ?? ''}'.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 6), child: Text('${r['reason']}')),
            const SizedBox(height: 12),
            TextField(controller: refund, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly], decoration: InputDecoration(labelText: 'المبلغ المُعاد (${store.currency})')),
            const SizedBox(height: 10),
            TextField(controller: note, maxLength: 300, decoration: const InputDecoration(labelText: 'ملاحظة يراها العميل')),
            SwitchListTile(contentPadding: EdgeInsets.zero, activeThumbColor: Rv.red, value: restock, title: const Text('أعد الكميات للمخزون'), onChanged: (v) => set(() => restock = v)),
            const SizedBox(height: 4),
            FilledButton(style: FilledButton.styleFrom(backgroundColor: Rv.red, minimumSize: const Size(0, 48)), onPressed: () => Navigator.pop(s, 3), child: const Text('إتمام الاسترجاع')),
            if (r['status'] == 0) OutlinedButton(onPressed: () => Navigator.pop(s, 1), child: const Text('قبول — سأستلم المنتج لاحقًا')),
            TextButton(onPressed: () => Navigator.pop(s, 2), child: Text('رفض', style: TextStyle(color: AzmPalette.of(s).danger))),
          ]),
        ),
      ),
    );
    if (choice == null || !context.mounted) return;
    await _run(context, () async {
      await ProviderScope.containerOf(context).read(storeDataApiProvider).updateReturn(store.id, '${r['id']}', {
        'status': choice,
        'refund': int.tryParse(refund.text.trim()) ?? 0,
        'restock': restock,
        'note': note.text.trim(),
      });
      await reload();
    }, choice == 3 ? 'اكتمل الاسترجاع — الطلب صار «مُرجَعًا»' : choice == 1 ? 'قُبل الطلب' : 'رُفض الطلب');
  }

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);
    return _ModuleScaffold<Map<String, dynamic>>(
      key: ValueKey(_status),
      title: 'المرتجعات',
      load: (api, s) => api.returns(s.id, status: _status),
      builder: (context, d, store, reload) {
        final list = ((d['returns'] as List?) ?? const []).cast<Map>();
        final counts = (d['counts'] as Map?) ?? {};
        return ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 40), children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              for (final e in _labels.entries)
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: ChoiceChip(label: Text('${e.value} (${counts['${e.key}'] ?? 0})'), selected: _status == e.key, onSelected: (_) => setState(() => _status = e.key)),
                ),
              ChoiceChip(label: const Text('الكل'), selected: _status == null, onSelected: (_) => setState(() => _status = null)),
            ]),
          ),
          const SizedBox(height: 12),
          if (list.isEmpty) const RvEmpty(icon: Icons.assignment_return_outlined, title: 'لا مرتجعات هنا', body: 'يطلبها العميل من صفحة تتبّع طلب مكتمل خلال ١٤ يومًا.'),
          for (final r in list)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Builder(builder: (context) {
                final o = (r['order'] as Map?) ?? {};
                final st = ((r['status'] as num?) ?? 0).toInt();
                final open = st == 0 || st == 1;
                return RvCard(
                  onTap: open ? () => _act(context, store, r, reload) : null,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Text('${o['ref'] ?? ''}', textDirection: TextDirection.ltr, style: AppTypography.body.copyWith(color: p.ink, fontWeight: FontWeight.w800)),
                      const SizedBox(width: 8),
                      Expanded(child: Text('${o['custName'] ?? ''} · ${Rv.money((o['total'] as num?) ?? 0)} ${store.currency}', style: AppTypography.caption.copyWith(color: p.inkFaint))),
                      RvChip(_labels[st] ?? '', color: switch (st) { 0 => Rv.gold, 1 => const Color(0xFF2F6FB3), 3 => const Color(0xFF16A34A), _ => p.inkFaint }),
                    ]),
                    if ('${r['reason'] ?? ''}'.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 6), child: Text('${r['reason']}', style: AppTypography.bodySmall.copyWith(color: p.ink))),
                    if (st == 3) Text('أُعيد ${Rv.money((r['refund'] as num?) ?? 0)} ${store.currency}${r['restock'] == true ? ' وعادت الكميات للمخزون' : ''}', style: AppTypography.caption.copyWith(color: const Color(0xFF16A34A))),
                    if ('${r['note'] ?? ''}'.isNotEmpty) Text('ملاحظة: ${r['note']}', style: AppTypography.caption.copyWith(color: p.inkMuted)),
                    if (open) Align(alignment: AlignmentDirectional.centerEnd, child: TextButton(onPressed: () => _act(context, store, r, reload), child: const Text('معالجة'))),
                  ]),
                );
              }),
            ),
        ]);
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════
// سلة المحذوفات
// ═══════════════════════════════════════════════════════════

/// المنتجات المحذوفة ٣٠ يومًا بصورها وخياراتها وتقييماتها — تُستعاد كما كانت.
class StoreTrashScreen extends StatelessWidget {
  const StoreTrashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);
    return _ModuleScaffold<List<Map<String, dynamic>>>(
      title: 'سلة المحذوفات',
      load: (api, s) => api.trash(s.id),
      builder: (context, list, store, reload) => ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 40), children: [
        Text('المنتج المحذوف يبقى هنا ٣٠ يومًا ثم يُحذف نهائيًا.', style: AppTypography.bodySmall.copyWith(color: p.inkMuted)),
        const SizedBox(height: 12),
        if (list.isEmpty) const RvEmpty(icon: Icons.delete_outline_rounded, title: 'السلة فارغة'),
        for (final t in list)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: RvCard(
              child: Row(children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: '${t['image'] ?? ''}'.isEmpty
                      ? Container(width: 48, height: 48, color: p.hairline)
                      : Image.network('${t['image']}', width: 48, height: 48, fit: BoxFit.cover, errorBuilder: (_, _, _) => Container(width: 48, height: 48, color: p.hairline)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${t['name'] ?? ''}', style: AppTypography.body.copyWith(color: p.ink, fontWeight: FontWeight.w700)),
                    Text('حُذف ${Rv.ago('${t['deletedAt']}')}', style: AppTypography.caption.copyWith(color: p.inkFaint)),
                  ]),
                ),
                TextButton(
                  onPressed: () => _run(context, () async {
                    await ProviderScope.containerOf(context).read(storeDataApiProvider).restoreTrash(store.id, '${t['id']}');
                    await reload();
                  }, 'استُعيد المنتج كما كان'),
                  child: const Text('استعادة'),
                ),
                IconButton(
                  icon: Icon(Icons.delete_forever_outlined, color: p.danger),
                  onPressed: () async {
                    final yes = await showDialog<bool>(
                      context: context,
                      builder: (dc) => AlertDialog(
                        title: Text('حذف «${t['name']}» نهائيًا؟'),
                        content: const Text('لا يمكن التراجع عن الحذف النهائي.'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(dc, false), child: const Text('إلغاء')),
                          TextButton(onPressed: () => Navigator.pop(dc, true), child: Text('حذف نهائي', style: TextStyle(color: p.danger))),
                        ],
                      ),
                    );
                    if (yes != true || !context.mounted) return;
                    await _run(context, () async {
                      await ProviderScope.containerOf(context).read(storeDataApiProvider).purgeTrash(store.id, '${t['id']}');
                      await reload();
                    }, 'حُذف نهائيًا');
                  },
                ),
              ]),
            ),
          ),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// أقسام الرئيسية
// ═══════════════════════════════════════════════════════════

/// أقسام منتجات تظهر في رئيسية المتجر تحت تصميم القالب. التطبيق يضيف الأقسام التلقائية
/// (الأكثر مبيعًا، الأحدث، العروض)؛ التصنيف والعلامة والاختيار اليدوي من «أقسام الرئيسية» في اللوحة.
class StoreSectionsScreen extends StatelessWidget {
  const StoreSectionsScreen({super.key});

  static const _sources = {'best': 'الأكثر مبيعًا', 'new': 'الأحدث', 'sale': 'العروض', 'category': 'تصنيف', 'brand': 'علامة تجارية', 'manual': 'اختيار يدوي'};

  Future<void> _add(BuildContext context, ShopStore store, Future<void> Function() reload) async {
    final title = TextEditingController();
    var source = 'best';
    var row = false;
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (s) => StatefulBuilder(
        builder: (s, set) => Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + MediaQuery.of(s).viewInsets.bottom),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('قسم جديد', style: AppTypography.h3),
            const SizedBox(height: 12),
            TextField(controller: title, maxLength: 60, decoration: const InputDecoration(labelText: 'العنوان', hintText: 'الأكثر طلبًا هذا الأسبوع')),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'best', label: Text('الأكثر مبيعًا')),
                ButtonSegment(value: 'new', label: Text('الأحدث')),
                ButtonSegment(value: 'sale', label: Text('العروض')),
              ],
              selected: {source},
              onSelectionChanged: (v) => set(() => source = v.first),
            ),
            SwitchListTile(contentPadding: EdgeInsets.zero, activeThumbColor: Rv.red, value: row, title: const Text('شريط يمرّ أفقيًا'), onChanged: (v) => set(() => row = v)),
            FilledButton(style: FilledButton.styleFrom(backgroundColor: Rv.red, minimumSize: const Size(0, 48)), onPressed: () => Navigator.pop(s, true), child: const Text('إضافة')),
          ]),
        ),
      ),
    );
    if (ok != true || title.text.trim().isEmpty || !context.mounted) return;
    await _run(context, () async {
      await ProviderScope.containerOf(context).read(storeDataApiProvider).addSection(store.id, {'title': title.text.trim(), 'source': source, 'layout': row ? 'row' : 'grid'});
      await reload();
    }, 'أُضيف القسم إلى رئيسية متجرك');
  }

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);
    return _ModuleScaffold<List<Map<String, dynamic>>>(
      title: 'أقسام الرئيسية',
      load: (api, s) => api.sections(s.id),
      actions: (context, store, reload) => [IconButton(icon: const Icon(Icons.add_circle_rounded, color: Rv.red), onPressed: () => _add(context, store, reload))],
      builder: (context, list, store, reload) {
        final api = ProviderScope.containerOf(context).read(storeDataApiProvider);
        Future<void> move(int i, int d) => _run(context, () async {
              final ids = list.map((s) => '${s['id']}').toList();
              final t = ids[i];
              ids[i] = ids[i + d];
              ids[i + d] = t;
              await api.reorderSections(store.id, ids);
              await reload();
            }, 'رُتّبت الأقسام');
        return ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 40), children: [
          Text('تظهر في رئيسية متجرك بترتيبها، والقسم بلا منتجات لا يظهر.', style: AppTypography.bodySmall.copyWith(color: p.inkMuted)),
          const SizedBox(height: 12),
          if (list.isEmpty) RvEmpty(icon: Icons.view_agenda_outlined, title: 'لا أقسام بعد', action: 'أضف قسمًا', onAction: () => _add(context, store, reload)),
          for (var i = 0; i < list.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: RvCard(
                padding: const EdgeInsets.fromLTRB(6, 6, 12, 6),
                child: Row(children: [
                  Column(children: [
                    IconButton(visualDensity: VisualDensity.compact, icon: const Icon(Icons.keyboard_arrow_up_rounded), onPressed: i == 0 ? null : () => move(i, -1)),
                    IconButton(visualDensity: VisualDensity.compact, icon: const Icon(Icons.keyboard_arrow_down_rounded), onPressed: i == list.length - 1 ? null : () => move(i, 1)),
                  ]),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('${list[i]['title']}', style: AppTypography.body.copyWith(color: p.ink, fontWeight: FontWeight.w700)),
                      Text('${_sources[list[i]['source']] ?? list[i]['source']} · ${list[i]['layout'] == 'row' ? 'شريط' : 'شبكة'}', style: AppTypography.caption.copyWith(color: p.inkFaint)),
                    ]),
                  ),
                  Switch(
                    value: list[i]['active'] == true,
                    activeThumbColor: Rv.red,
                    onChanged: (v) => _run(context, () async {
                      await api.editSection(store.id, '${list[i]['id']}', {'active': v});
                      await reload();
                    }, v ? 'ظهر القسم' : 'أُخفي القسم'),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: p.danger),
                    onPressed: () => _run(context, () async {
                      await api.removeSection(store.id, '${list[i]['id']}');
                      await reload();
                    }, 'حُذف القسم'),
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
          // ربح المنتجات من الأسطر معروفة التكلفة — يظهر حين يُدخل التاجر «سعر التكلفة»
          if (d['profit'] case {'coverage': final num cov, 'amount': final num amount, 'margin': final num margin} when cov > 0)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: RvStat(
                label: 'ربح المنتجات · هامش $margin%',
                value: '${Rv.money(amount)} ${store.currency}',
                icon: Icons.savings_outlined,
                tone: const Color(0xFF16A34A),
                hint: cov < 100 ? 'تغطي التكلفة $cov% من المبيعات — أضفها لبقية المنتجات' : null,
              ),
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
