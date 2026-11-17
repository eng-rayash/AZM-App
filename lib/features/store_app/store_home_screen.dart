import 'package:flutter/material.dart';
import 'store_help.dart';
import '../../shared/widgets/help_tips.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/design/azm_tokens.dart';
import '../../core/theme/app_typography.dart';
import '../auth/providers/auth_providers.dart';
import '../shop/data/shop_models.dart';
import '../shop/providers/shop_providers.dart';
import '../store_tools/ai_assistant_screen.dart';
import '../store_tools/store_settings_screen.dart';
import '../store_tools/store_tools_api.dart';
import 'kit.dart';
import 'store_api.dart';
import 'store_gate.dart';
import 'store_routes.dart';

/// «المتجر» — الشاشة الأولى لتطبيق عزم للتاجر: صحة المتجر اليوم في نظرة،
/// وما يحتاج تصرّفه الآن، وكل أدوات المتجر على بعد لمسة.
class StoreHomeScreen extends ConsumerWidget {
  const StoreHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StoreGate(builder: (context, store, all) => WithHelp(tip: StoreHelp.home, child: _Home(store: store, all: all)));
  }
}

class _Home extends ConsumerWidget {
  const _Home({required this.store, required this.all});
  final ShopStore store;
  final List<ShopStore> all;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = AzmPalette.of(context);
    final overview = ref.watch(storeOverviewProvider(store.id));
    final name = ref.watch(authStateNotifierProvider).user?.displayName.split(' ').first ?? '';
    final cur = store.currency;

    return RefreshIndicator(
      color: Rv.red,
      onRefresh: () async {
        ref.invalidate(storeOverviewProvider(store.id));
        ref.invalidate(storeReadinessProvider(store.id));
        ref.invalidate(storeListProvider);
      },
      child: ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 120), children: [
        // ── البطل: المتجر ومبيعات الشهر ──
        RvHero(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                child: Text(name.isEmpty ? 'أهلًا بك' : 'أهلًا $name 👋',
                    style: AppTypography.bodySmall.copyWith(color: Colors.white.withValues(alpha: .8))),
              ),
              _Pill(
                text: switch (store.plan) { 'pro' => 'باقة الأعمال', 'plus' => 'الاحترافية', _ => 'المجانية' },
              ),
            ]),
            const SizedBox(height: 6),
            InkWell(
              onTap: () => pickStore(context, ref, all, store.id),
              child: Row(children: [
                Flexible(
                  child: Text(store.name,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.h1.copyWith(color: Colors.white, fontFamily: 'Zain', fontWeight: FontWeight.w800, fontSize: 30)),
                ),
                const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white70),
              ]),
            ),
            Text('store.rvios.com/s/${store.slug}', textDirection: TextDirection.ltr,
                style: AppTypography.caption.copyWith(color: Colors.white.withValues(alpha: .65))),
            const SizedBox(height: 18),
            Text('مبيعات هذا الشهر', style: AppTypography.caption.copyWith(color: Colors.white.withValues(alpha: .75))),
            overview.when(
              loading: () => const SizedBox(height: 44, child: Align(alignment: AlignmentDirectional.centerStart, child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)))),
              error: (_, _) => const Text('—', style: TextStyle(color: Colors.white, fontSize: 34)),
              data: (o) => Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(Rv.money(o.kpis.confirmed),
                    style: const TextStyle(fontFamily: 'Zain', fontSize: 42, fontWeight: FontWeight.w800, color: Colors.white, height: 1.1)),
                const SizedBox(width: 6),
                Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(cur, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600))),
              ]),
            ),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(
                child: _HeroButton(
                  icon: Icons.open_in_new_rounded,
                  label: 'فتح المتجر',
                  onTap: () => launchUrl(Uri.parse('$storefrontUrl/s/${store.slug}'), mode: LaunchMode.externalApplication),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HeroButton(
                  icon: Icons.auto_awesome_rounded,
                  label: 'RVIOS AI',
                  filled: true,
                  onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => AiAssistantScreen(storeId: store.id, storeName: store.name))),
                ),
              ),
            ]),
          ]),
        ),

        if (store.isSuspended)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: RvCard(
              color: p.dangerSubtle,
              child: Row(children: [
                Icon(Icons.pause_circle_outline, color: p.danger),
                const SizedBox(width: 10),
                Expanded(child: Text('المتجر موقوف من فريق المنصة — لا يستقبل طلبات. تواصل مع RVIOS.', style: TextStyle(color: p.danger))),
              ]),
            ),
          ),

        if (store.status == 2)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: RvCard(
              color: const Color(0xFFFFF4E0),
              onTap: () => context.push(StoreRoutes.billing),
              child: Row(children: [
                const Icon(Icons.hourglass_top_rounded, color: Color(0xFFB45309)),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text('متجرك بانتظار التفعيل — أكمل الدفع وارفع الإيصال، فيظهر للعملاء.',
                      style: TextStyle(color: Color(0xFF92400E), fontWeight: FontWeight.w600)),
                ),
                const Icon(Icons.chevron_left_rounded, color: Color(0xFFB45309)),
              ]),
            ),
          ),

        // ── جاهزية المتجر: تختفي حين يكتمل كل شيء ──
        _Readiness(store: store),

        // ── منصة متجرك: التصميم والقوالب والباقة والدفع ──
        const SizedBox(height: 14),
        _PlatformStrip(store: store),

        // ── المؤشرات ──
        overview.when(
          loading: () => const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator(color: Rv.red))),
          error: (e, _) => Padding(padding: const EdgeInsets.all(24), child: Text('$e', textAlign: TextAlign.center)),
          data: (o) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const SizedBox(height: 14),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.45,
              children: [
                RvStat(
                  label: 'طلبات تنتظر التأكيد',
                  value: Rv.money(o.kpis.pending),
                  icon: Icons.notifications_active_outlined,
                  tone: o.kpis.pending > 0 ? Rv.red : null,
                  hint: o.kpis.pending > 0 ? 'سرعة الرد تصنع البيع' : null,
                  onTap: () => context.go(StoreRoutes.orders),
                ),
                RvStat(label: 'زيارات ٧ أيام', value: Rv.money(o.kpis.visits), icon: Icons.visibility_outlined, tone: const Color(0xFF2F6FB3)),
                RvStat(label: 'منتجات معروضة', value: Rv.money(o.kpis.products), icon: Icons.inventory_2_outlined, tone: const Color(0xFF0F766E), onTap: () => context.go(StoreRoutes.products)),
                RvStat(
                  label: 'سعة الباقة',
                  value: o.capacity.max == null ? '∞' : '${o.capacity.used}/${o.capacity.max}',
                  icon: Icons.donut_large_rounded,
                  tone: Rv.gold,
                  onTap: () => context.push(StoreRoutes.billing),
                ),
              ],
            ),
            const RvSection('الأسبوع في المتجر'),
            RvCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  _Legend(color: Rv.red, text: 'طلبات'),
                  const SizedBox(width: 14),
                  _Legend(color: p.inkFaint, text: 'زيارات ÷ ١٠'),
                  const Spacer(),
                  TextButton(onPressed: () => context.push(StoreRoutes.analytics), child: const Text('التحليلات')),
                ]),
                const SizedBox(height: 8),
                RvBars(
                  values: [for (final d in o.chart) d.orders + d.visits / 10],
                  labels: [for (final d in o.chart) _weekday(d.day)],
                ),
              ]),
            ),
            if (o.recent.isNotEmpty) ...[
              RvSection('أحدث الطلبات', action: 'الكل', onAction: () => context.go(StoreRoutes.orders)),
              for (final order in o.recent.take(5)) _OrderRow(order: order, currency: cur),
            ],
            if (o.lowStock.isNotEmpty) ...[
              RvSection('أوشكت على النفاد', action: 'المنتجات', onAction: () => context.go(StoreRoutes.products)),
              RvCard(
                padding: EdgeInsets.zero,
                child: Column(children: [
                  for (final pr in o.lowStock.take(5))
                    ListTile(
                      dense: true,
                      leading: const Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706)),
                      title: Text(pr.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                      trailing: RvChip('باقي ${pr.qty}', color: pr.qty == 0 ? p.danger : const Color(0xFFD97706)),
                    ),
                ]),
              ),
            ],
          ]),
        ),

        // ── أدوات المتجر ──
        const RvSection('أدر متجرك'),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: .78,
          children: [
            RvAction(icon: Icons.receipt_long_rounded, label: 'الطلبات', onTap: () => context.go(StoreRoutes.orders)),
            RvAction(icon: Icons.inventory_2_rounded, label: 'المنتجات', color: const Color(0xFF0F766E), onTap: () => context.go(StoreRoutes.products)),
            RvAction(icon: Icons.people_alt_rounded, label: 'العملاء', color: const Color(0xFF2F6FB3), onTap: () => context.push(StoreRoutes.customers)),
            RvAction(icon: Icons.insights_rounded, label: 'التحليلات', color: const Color(0xFF7C3AED), onTap: () => context.push(StoreRoutes.analytics)),
            RvAction(icon: Icons.star_rounded, label: 'التقييمات', color: Rv.gold, onTap: () => context.push(StoreRoutes.reviews)),
            RvAction(icon: Icons.local_shipping_rounded, label: 'التوصيل', color: const Color(0xFFD97706), onTap: () => context.push(StoreRoutes.zones)),
            RvAction(icon: Icons.local_offer_rounded, label: 'القسائم', color: const Color(0xFF16A34A), onTap: () => context.push(StoreRoutes.coupons)),
            RvAction(icon: Icons.contact_support_rounded, label: 'الأسئلة', color: const Color(0xFF0369A1), onTap: () => context.push(StoreRoutes.questions)),
            RvAction(
              icon: Icons.palette_rounded,
              label: 'تصميم المتجر',
              color: const Color(0xFFDB2777),
              onTap: () => context.push(StoreRoutes.design),
            ),
            RvAction(
              icon: Icons.tune_rounded,
              label: 'الإعدادات',
              color: p.inkMuted,
              onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => StoreSettingsScreen(store: store))),
            ),
            RvAction(icon: Icons.workspace_premium_rounded, label: 'الباقة', color: Rv.redDeep, onTap: () => context.push(StoreRoutes.billing)),
            RvAction(icon: Icons.dashboard_customize_rounded, label: 'القوالب', color: const Color(0xFF9333EA), onTap: () => context.push(StoreRoutes.templates)),
            RvAction(icon: Icons.account_balance_wallet_rounded, label: 'طرق الدفع', color: const Color(0xFF0E7C86), onTap: () => context.push(StoreRoutes.pay)),
            RvAction(icon: Icons.groups_rounded, label: 'الفريق', color: const Color(0xFF0891B2), onTap: () => context.push(StoreRoutes.team)),
            RvAction(icon: Icons.notifications_rounded, label: 'الإشعارات', color: const Color(0xFF475569), onTap: () => context.push(StoreRoutes.notifications)),
            RvAction(
              icon: Icons.auto_awesome_rounded,
              label: 'RVIOS AI',
              color: Rv.red,
              onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => AiAssistantScreen(storeId: store.id, storeName: store.name))),
            ),
          ],
        ),
      ]),
    );
  }

  static String _weekday(String ymd) {
    final d = DateTime.tryParse(ymd);
    if (d == null) return '';
    const n = ['اث', 'ثل', 'أر', 'خم', 'جم', 'سب', 'أح'];
    return n[(d.weekday - 1) % 7];
  }
}

/// «جاهزية متجرك»: النسبة والمهمة التالية، والقائمة عند اللمس. المهام يحسبها الخادم من بيانات
/// المتجر، فتُنجَز وحدها حين يُنجَز ما تطلبه.
class _Readiness extends ConsumerWidget {
  const _Readiness({required this.store});
  final ShopStore store;

  void _open(BuildContext context, String key) {
    switch (key) {
      case 'products' || 'images' || 'categories':
        context.go(StoreRoutes.products);
      case 'delivery':
        context.push(StoreRoutes.zones);
      case 'payment':
        context.push(StoreRoutes.pay);
      case 'coupon':
        context.push(StoreRoutes.coupons);
      case 'about' || 'contact':
        Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => StoreSettingsScreen(store: store)));
      case 'firstOrder':
        context.go(StoreRoutes.orders);
      default:
        context.push(StoreRoutes.design);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = AzmPalette.of(context);
    final r = ref.watch(storeReadinessProvider(store.id)).asData?.value;
    if (r == null || ((r['percent'] as num?) ?? 100) >= 100) return const SizedBox.shrink();
    final tasks = ((r['tasks'] as List?) ?? const []).cast<Map>();
    final next = tasks.where((t) => t['key'] == r['next']).firstOrNull;
    final pct = ((r['percent'] as num?) ?? 0).toDouble();
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: RvCard(
        onTap: () => showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          showDragHandle: true,
          builder: (sheet) => SafeArea(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(sheet).size.height * .8),
              child: ListView(shrinkWrap: true, padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), children: [
                Text('جاهزية متجرك ${pct.round()}٪', style: AppTypography.h3.copyWith(color: p.ink)),
                const SizedBox(height: 8),
                for (final t in tasks)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(t['done'] == true ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                        color: t['done'] == true ? const Color(0xFF16A34A) : p.inkFaint),
                    title: Text('${t['title']}',
                        style: TextStyle(color: t['done'] == true ? p.inkFaint : p.ink, decoration: t['done'] == true ? TextDecoration.lineThrough : null)),
                    subtitle: t['done'] == true ? null : Text('${t['hint']}', style: TextStyle(color: p.inkMuted, fontSize: 12)),
                    trailing: t['done'] == true ? null : const Icon(Icons.chevron_left_rounded),
                    onTap: t['done'] == true
                        ? null
                        : () {
                            Navigator.pop(sheet);
                            _open(context, '${t['key']}');
                          },
                  ),
              ]),
            ),
          ),
        ),
        child: Row(children: [
          SizedBox(
            width: 56,
            height: 56,
            child: Stack(alignment: Alignment.center, children: [
              CircularProgressIndicator(value: pct / 100, strokeWidth: 5, color: Rv.red, backgroundColor: p.hairline),
              Text('${pct.round()}٪', style: TextStyle(fontWeight: FontWeight.w800, color: p.ink, fontSize: 13)),
            ]),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('جاهزية متجرك', style: AppTypography.body.copyWith(color: p.ink, fontWeight: FontWeight.w800)),
              Text('${r['done']} من ${r['total']}${next != null ? ' — التالي: ${next['title']}' : ''}',
                  style: AppTypography.caption.copyWith(color: p.inkMuted), maxLines: 2),
            ]),
          ),
          if (next != null)
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Rv.red, visualDensity: VisualDensity.compact),
              onPressed: () => _open(context, '${next['key']}'),
              child: const Text('ابدأ'),
            ),
        ]),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: .15), borderRadius: BorderRadius.circular(99), border: Border.all(color: Colors.white24)),
        child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w700)),
      );
}

class _HeroButton extends StatelessWidget {
  const _HeroButton({required this.icon, required this.label, required this.onTap, this.filled = false});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool filled;
  @override
  Widget build(BuildContext context) => Material(
        color: filled ? Colors.white : Colors.white.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 11),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(icon, size: 18, color: filled ? Rv.red : Colors.white),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(color: filled ? Rv.red : Colors.white, fontWeight: FontWeight.w700)),
            ]),
          ),
        ),
      );
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.text});
  final Color color;
  final String text;
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 5),
        Text(text, style: AppTypography.caption.copyWith(color: AzmPalette.of(context).inkMuted)),
      ]);
}

class _OrderRow extends StatelessWidget {
  const _OrderRow({required this.order, required this.currency});
  final ShopOrder order;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);
    final tone = switch (order.status) {
      OrderStatus.wait => Rv.red,
      OrderStatus.confirmed => const Color(0xFF2F6FB3),
      OrderStatus.preparing => const Color(0xFF7C3AED),
      OrderStatus.shipped => const Color(0xFF4F46E5),
      OrderStatus.done => const Color(0xFF0F766E),
      OrderStatus.off => p.inkFaint,
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RvCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        onTap: () => context.go(StoreRoutes.orders),
        child: Row(children: [
          CircleAvatar(radius: 20, backgroundColor: tone.withValues(alpha: .12), child: Icon(Icons.shopping_bag_outlined, color: tone, size: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(order.custName.isEmpty ? 'عميل' : order.custName, style: AppTypography.body.copyWith(color: p.ink, fontWeight: FontWeight.w700)),
              Text('${order.ref} · ${order.items.length} منتج', style: AppTypography.caption.copyWith(color: p.inkFaint)),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('${Rv.money(order.total)} $currency', style: AppTypography.body.copyWith(color: p.ink, fontWeight: FontWeight.w700)),
            RvChip(order.status.label, color: tone),
          ]),
        ]),
      ),
    );
  }
}

/// منصة متجرك في سطر: التصميم بمعاينة حية، القوالب، الباقة، طرق الدفع.
class _PlatformStrip extends StatelessWidget {
  const _PlatformStrip({required this.store});
  final ShopStore store;

  @override
  Widget build(BuildContext context) {
    Widget tile(IconData icon, String title, String sub, List<Color> g, String route) => Expanded(
          child: Material(
            borderRadius: BorderRadius.circular(20),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => context.push(route),
              child: Ink(
                height: 104,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(gradient: LinearGradient(begin: AlignmentDirectional.topStart, end: AlignmentDirectional.bottomEnd, colors: g)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(icon, color: Colors.white, size: 24),
                  const Spacer(),
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
                  Text(sub, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white.withValues(alpha: .8), fontSize: 11)),
                ]),
              ),
            ),
          ),
        );
    final plan = switch (store.plan) { 'pro' => 'أعمال', 'plus' => 'احترافي', _ => 'مجاني' };
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        tile(Icons.brush_rounded, 'صمّم متجرك', 'معاينة حية', const [Color(0xFFD12F36), Color(0xFF7A1418)], StoreRoutes.design),
        const SizedBox(width: 8),
        tile(Icons.dashboard_customize_rounded, 'القوالب', '١٨ قالبًا', const [Color(0xFF8B5CF6), Color(0xFF4C1D95)], StoreRoutes.templates),
      ]),
      const SizedBox(height: 8),
      Row(children: [
        tile(Icons.workspace_premium_rounded, 'الباقة', 'باقتك: $plan', const [Color(0xFF2A1714), Color(0xFF120B0A)], StoreRoutes.billing),
        const SizedBox(width: 8),
        tile(Icons.account_balance_wallet_rounded, 'طرق الدفع', 'الكريمي · جيب · جوالي', const [Color(0xFF0E7C86), Color(0xFF0B4F55)], StoreRoutes.pay),
      ]),
    ]);
  }
}
