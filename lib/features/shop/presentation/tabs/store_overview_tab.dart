import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/azm_tokens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/shop_models.dart';
import '../../providers/shop_providers.dart';
import '../widgets/shop_async.dart';

/// AZM — نظرة المتجر
///
/// تجيب سؤالًا واحدًا: **ماذا يحتاج انتباهي الآن؟** لا «كل الأرقام
/// المتاحة». فالترتيب هو الرسالة: الطلبات المعلّقة أولًا لأنها وحدها
/// تخسر عميلًا إن تُركت، ثم المخزون المنخفض لأنه يخسر بيعًا، ثم
/// الزوّار والمبيعات لأنها سياق لا إجراء.
///
/// كل هذا من **نداء واحد** (`/overview`) لا خمسة: خمسة نداءات على
/// شبكة جوّال تعني خمس فرص للفشل الجزئي، فتظهر لوحة نصفها أرقام
/// ونصفها دوائر تحميل.
class StoreOverviewTab extends ConsumerWidget {
  const StoreOverviewTab({super.key, required this.storeId});

  final String storeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(storeOverviewProvider(storeId));

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(storeOverviewProvider(storeId)),
      child: ShopAsync<StoreOverview>(
        value: overview,
        onRetry: () => ref.invalidate(storeOverviewProvider(storeId)),
        builder: (o) => ListView(
          padding: const EdgeInsets.fromLTRB(
            AzmSpace.screenGutter,
            AzmSpace.lg,
            AzmSpace.screenGutter,
            AzmSpace.xxxl,
          ),
          children: [
            _Kpis(kpis: o.kpis),
            const SizedBox(height: AzmSpace.sectionGap),
            _WeekChart(chart: o.chart),
            const SizedBox(height: AzmSpace.sectionGap),
            _Capacity(capacity: o.capacity),
            if (o.lowStock.isNotEmpty) ...[
              const SizedBox(height: AzmSpace.sectionGap),
              _LowStock(products: o.lowStock),
            ],
            if (o.recent.isNotEmpty) ...[
              const SizedBox(height: AzmSpace.sectionGap),
              _Recent(orders: o.recent),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// المؤشّرات
// ─────────────────────────────────────────────

class _Kpis extends StatelessWidget {
  const _Kpis({required this.kpis});

  final StoreKpis kpis;

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _Kpi(
                label: 'قيد التأكيد',
                value: '${kpis.pending}',
                // الوحيد الذي يستحقّ لونًا: ما لا يُؤكَّد يخسر عميلًا
                tone: kpis.pending > 0 ? p.accent : p.inkMuted,
                emphasize: kpis.pending > 0,
              ),
            ),
            _Divider(),
            Expanded(
              child: _Kpi(
                label: 'زوّار ٧ أيام',
                value: '${kpis.visits}',
                tone: p.inkMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: AzmSpace.lg),
        Row(
          children: [
            Expanded(
              child: _Kpi(
                label: 'منتجات معروضة',
                value: '${kpis.products}',
                tone: p.inkMuted,
              ),
            ),
            _Divider(),
            Expanded(
              child: _Kpi(
                label: 'مبيعات الشهر',
                value: _money(kpis.confirmed),
                tone: p.inkMuted,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Kpi extends StatelessWidget {
  const _Kpi({
    required this.label,
    required this.value,
    required this.tone,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final Color tone;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: AppTypography.h1.copyWith(
            color: tone,
            fontSize: 28,
            fontWeight: emphasize ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
        const SizedBox(height: AzmSpace.xxs),
        Text(
          label,
          style: AppTypography.caption.copyWith(color: p.inkFaint),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        height: 40,
        margin: const EdgeInsets.symmetric(horizontal: AzmSpace.lg),
        color: AzmPalette.of(context).hairline,
      );
}

// ─────────────────────────────────────────────
// منحنى الأسبوع
// ─────────────────────────────────────────────

/// سبعة أيام من الزيارات والطلبات — أعمدة لا خطوط.
///
/// العمود أصدق هنا: البيانات يومية منفصلة لا متّصلة، والخطّ بينها
/// يرسم قيمًا لم تُقَس. والمقياس يُشتقّ من أعلى قيمة لا من رقم ثابت،
/// وإلّا بدا متجر بثلاث زيارات وآخر بثلاثمئة سواءً.
class _WeekChart extends StatelessWidget {
  const _WeekChart({required this.chart});

  final List<DayPoint> chart;

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);

    if (chart.isEmpty) return const SizedBox.shrink();

    final peak = chart
        .map((d) => d.visits > d.orders ? d.visits : d.orders)
        .fold<int>(0, (a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'آخر سبعة أيام',
              style: AppTypography.body.copyWith(
                color: p.ink,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            _Legend(color: p.inkGhost, label: 'زيارات'),
            const SizedBox(width: AzmSpace.md),
            _Legend(color: p.accent, label: 'طلبات'),
          ],
        ),
        const SizedBox(height: AzmSpace.lg),
        SizedBox(
          height: 96,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: chart.map((d) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _Bars(point: d, peak: peak),
                      const SizedBox(height: AzmSpace.sm),
                      Text(
                        _weekday(d.day),
                        style: AppTypography.caption.copyWith(
                          color: p.inkGhost,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _Bars extends StatelessWidget {
  const _Bars({required this.point, required this.peak});

  final DayPoint point;
  final int peak;

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);
    const maxH = 64.0;

    // peak صفر يعني لا بيانات: عمود بحدّ أدنى مرئي أصدق من فراغ،
    // لأن الفراغ يُقرأ «لم تُحمَّل» لا «صفر».
    double h(int v) => peak == 0 ? 2 : (v / peak * maxH).clamp(2, maxH);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _Bar(height: h(point.visits), color: p.inkGhost),
        const SizedBox(width: 2),
        _Bar(height: h(point.orders), color: p.accent),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.height, required this.color});

  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        width: 6,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(3),
          ),
        ),
      );
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);

    return Row(
      children: [
        Container(width: 6, height: 6, color: color),
        const SizedBox(width: AzmSpace.xs),
        Text(
          label,
          style: AppTypography.caption.copyWith(color: p.inkFaint),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// السعة
// ─────────────────────────────────────────────

class _Capacity extends StatelessWidget {
  const _Capacity({required this.capacity});

  final StoreCapacity capacity;

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);

    if (capacity.isUnlimited) {
      return Row(
        children: [
          Icon(Icons.all_inclusive_rounded, size: 16, color: p.inkFaint),
          const SizedBox(width: AzmSpace.sm),
          Text(
            'منتجات غير محدودة · ${capacity.used} مُسجَّل',
            style: AppTypography.caption.copyWith(color: p.inkMuted),
          ),
        ],
      );
    }

    // ٨٠٪ هو حيث يصير التنبيه مفيدًا: قبله لا داعي لإزعاج التاجر،
    // وبعد الامتلاء يكون الإخبار متأخّرًا.
    final tight = capacity.pct >= 80;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'سعة الكتالوج',
              style: AppTypography.body.copyWith(
                color: p.ink,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              '${capacity.used} / ${capacity.max}',
              style: AppTypography.caption.copyWith(
                color: tight ? p.warning : p.inkMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: AzmSpace.sm),
        ClipRRect(
          borderRadius: AzmRadius.pill,
          child: LinearProgressIndicator(
            value: capacity.pct / 100,
            minHeight: 4,
            backgroundColor: p.surfaceSunken,
            valueColor: AlwaysStoppedAnimation(
              tight ? p.warning : p.accent,
            ),
          ),
        ),
        if (tight) ...[
          const SizedBox(height: AzmSpace.sm),
          Text(
            'قاربتَ الحدّ — الترقية ترفع سعة الكتالوج.',
            style: AppTypography.caption.copyWith(color: p.inkFaint),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────
// المخزون المنخفض
// ─────────────────────────────────────────────

class _LowStock extends StatelessWidget {
  const _LowStock({required this.products});

  final List<ShopProduct> products;

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.inventory_outlined, size: 16, color: p.warning),
            const SizedBox(width: AzmSpace.sm),
            Text(
              'مخزون منخفض',
              style: AppTypography.body.copyWith(
                color: p.ink,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: AzmSpace.md),
        ...products.map(
          (product) => Padding(
            padding: const EdgeInsets.only(bottom: AzmSpace.sm),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    product.name,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.body.copyWith(color: p.inkMuted),
                  ),
                ),
                Text(
                  product.isOutOfStock ? 'نفد' : 'بقي ${product.qty}',
                  style: AppTypography.caption.copyWith(
                    color: product.isOutOfStock ? p.danger : p.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// أحدث الطلبات
// ─────────────────────────────────────────────

class _Recent extends StatelessWidget {
  const _Recent({required this.orders});

  final List<ShopOrder> orders;

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'أحدث الطلبات',
          style: AppTypography.body.copyWith(
            color: p.ink,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AzmSpace.md),
        ...orders.map(
          (order) => Padding(
            padding: const EdgeInsets.only(bottom: AzmSpace.md),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.custName.isEmpty ? order.ref : order.custName,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.body.copyWith(color: p.ink),
                      ),
                      Text(
                        order.ref,
                        style: AppTypography.caption.copyWith(
                          color: p.inkFaint,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  _money(order.total),
                  style: AppTypography.body.copyWith(
                    color: p.inkMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: AzmSpace.md),
                Text(
                  order.status.label,
                  style: AppTypography.caption.copyWith(color: p.inkFaint),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// أدوات
// ─────────────────────────────────────────────

/// مبلغ بفواصل الآلاف.
///
/// بلا رمز عملة: الرمز يأتي من المتجر (`store.currency`) ويختلف
/// بدولته، ووضع رمز ثابت هنا كان سيعرض الريال لمتجر يمنيّ.
String _money(int amount) {
  final s = '$amount';
  final out = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) out.write(',');
    out.write(s[i]);
  }
  return out.toString();
}

/// `YYYY-MM-DD` → اسم اليوم مختصرًا.
String _weekday(String ymd) {
  final date = DateTime.tryParse(ymd);
  if (date == null) return '';
  const names = ['اث', 'ثل', 'أر', 'خم', 'جم', 'سب', 'أح'];
  return names[(date.weekday - 1) % 7];
}
