import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/design/azm_tokens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/shop_models.dart';
import '../../providers/shop_providers.dart';
import '../widgets/shop_async.dart';

/// AZM — طلبات المتجر
///
/// الشاشة الأكثر استعمالًا في لوحة التاجر، ومقياس نجاحها واحد: **كم
/// لمسة بين وصول الطلب وتأكيده.**
///
/// لذلك الإجراء الأساسي على الصفّ لا داخل تفصيل: زرّ واحد ينقل الطلب
/// إلى حالته التالية. والانتقالات المسموحة يفرضها الخادم
/// (`ORDER_NEXT`) — الواجهة تعرض المتوقَّع، والخادم يرفض ما ليس
/// مشروعًا. اعتماد الواجهة وحدها على ذلك يجعل عميلًا مُعدَّلًا يقفز
/// حالات.
class StoreOrdersTab extends ConsumerWidget {
  const StoreOrdersTab({
    super.key,
    required this.storeId,
    required this.store,
  });

  final String storeId;
  final ShopStore store;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final page = ref.watch(orderPageProvider(storeId));
    final filter = ref.watch(orderFilterProvider);

    return Column(
      children: [
        _Filters(
          selected: filter,
          counts: page.maybeWhen(
            data: (p) => p.counts,
            orElse: () => const {},
          ),
          onSelect: (s) =>
              ref.read(orderFilterProvider.notifier).state = s,
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async =>
                ref.invalidate(orderPageProvider(storeId)),
            child: ShopAsync<OrderPage>(
              value: page,
              onRetry: () => ref.invalidate(orderPageProvider(storeId)),
              isEmpty: (p) => p.orders.isEmpty,
              empty: ShopEmpty(
                icon: Icons.receipt_long_outlined,
                title: filter == null ? 'لا طلبات بعد' : 'لا طلبات بهذه الحالة',
                body: filter == null
                    ? 'شارك رابط متجرك — الطلبات تظهر هنا وتصلك على '
                        'واتساب.'
                    : 'جرّب حالة أخرى من الأعلى.',
              ),
              builder: (data) => ListView.builder(
                padding: const EdgeInsets.only(bottom: AzmSpace.xxxl),
                itemCount: data.orders.length + (data.pages > 1 ? 1 : 0),
                itemBuilder: (context, i) {
                  if (i == data.orders.length) {
                    return _Pager(
                      page: data.page,
                      pages: data.pages,
                      onGo: (n) => ref
                          .read(orderPageNumberProvider.notifier)
                          .state = n,
                    );
                  }
                  return _OrderRow(
                    order: data.orders[i],
                    store: store,
                    storeId: storeId,
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// المرشّحات
// ─────────────────────────────────────────────

class _Filters extends StatelessWidget {
  const _Filters({
    required this.selected,
    required this.counts,
    required this.onSelect,
  });

  final OrderStatus? selected;
  final Map<OrderStatus, int> counts;
  final ValueChanged<OrderStatus?> onSelect;

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);

    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: p.hairline)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AzmSpace.screenGutter,
          vertical: AzmSpace.md,
        ),
        child: Row(
          children: [
            _FilterChip(
              label: 'الكل',
              selected: selected == null,
              onTap: () => onSelect(null),
            ),
            ...OrderStatus.values.map((s) {
              final n = counts[s] ?? 0;
              return Padding(
                padding: const EdgeInsets.only(right: AzmSpace.sm),
                child: _FilterChip(
                  label: s.label,
                  count: n,
                  selected: selected == s,
                  onTap: () => onSelect(s),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.count,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);

    return Padding(
      padding: const EdgeInsets.only(right: AzmSpace.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: AzmRadius.pill,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AzmSpace.md,
            vertical: AzmSpace.sm,
          ),
          decoration: BoxDecoration(
            color: selected ? p.accent : p.surfaceSunken,
            borderRadius: AzmRadius.pill,
          ),
          child: Text(
            // الصفر لا يُعرض: شارة «٠» ضجيج لا معلومة
            count != null && count! > 0 ? '$label · $count' : label,
            style: AppTypography.caption.copyWith(
              color: selected ? p.onAccent : p.inkMuted,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// صفّ الطلب
// ─────────────────────────────────────────────

class _OrderRow extends ConsumerWidget {
  const _OrderRow({
    required this.order,
    required this.store,
    required this.storeId,
  });

  final ShopOrder order;
  final ShopStore store;
  final String storeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = AzmPalette.of(context);
    final next = _nextStatus(order.status);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AzmSpace.screenGutter,
        vertical: AzmSpace.lg,
      ),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: p.hairline)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.custName.isEmpty ? 'بلا اسم' : order.custName,
                      style: AppTypography.body.copyWith(
                        color: p.ink,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AzmSpace.xxs),
                    Text(
                      '${order.ref} · ${order.items.length} '
                      '${order.items.length == 1 ? "منتج" : "منتجات"}',
                      style: AppTypography.caption.copyWith(color: p.inkFaint),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${_money(order.total)} ${store.currency}',
                    style: AppTypography.body.copyWith(
                      color: p.ink,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AzmSpace.xxs),
                  _StatusDot(status: order.status),
                ],
              ),
            ],
          ),

          if (order.custAddress.isNotEmpty || order.zoneName.isNotEmpty) ...[
            const SizedBox(height: AzmSpace.sm),
            Text(
              [order.zoneName, order.custAddress]
                  .where((s) => s.isNotEmpty)
                  .join(' · '),
              style: AppTypography.caption.copyWith(color: p.inkMuted),
            ),
          ],

          // إيصال تحويل ينتظر المراجعة — أولى من تقدّم الحالة
          if (order.hasProofToReview) ...[
            const SizedBox(height: AzmSpace.md),
            _ProofNote(
              order: order,
              storeId: storeId,
            ),
          ],

          const SizedBox(height: AzmSpace.md),
          Row(
            children: [
              if (order.wa.isNotEmpty)
                _Action(
                  icon: Icons.chat_outlined,
                  label: 'واتساب',
                  // الرابط يبنيه الخادم برسالة الطلب — لا نبنيه هنا
                  onTap: () => _openWhatsApp(context, order.wa),
                ),
              if (order.custPhone.isNotEmpty) ...[
                const SizedBox(width: AzmSpace.sm),
                _Action(
                  icon: Icons.phone_outlined,
                  label: 'اتصال',
                  onTap: () => _call(context, order.custPhone),
                ),
              ],
              const Spacer(),
              if (next != null)
                FilledButton(
                  onPressed: () => _advance(context, ref, next),
                  style: FilledButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                  child: Text(_advanceLabel(next)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// الحالة التالية المتوقَّعة — والخادم هو من يفرض المشروعية.
  ///
  /// «ملغى» ليس تاليًا لشيء: الإلغاء قرار لا تقدّم، وموضعه قائمة
  /// الإجراءات لا الزرّ الأساسي. جعله تاليًا يجعل لمسةً واحدة
  /// بالخطأ تُلغي طلبًا.
  OrderStatus? _nextStatus(OrderStatus current) => switch (current) {
        OrderStatus.wait => OrderStatus.confirmed,
        OrderStatus.confirmed => OrderStatus.done,
        OrderStatus.done => null,
        OrderStatus.off => null,
      };

  String _advanceLabel(OrderStatus next) => switch (next) {
        OrderStatus.confirmed => 'تأكيد',
        OrderStatus.done => 'إكمال',
        _ => next.label,
      };

  Future<void> _advance(
    BuildContext context,
    WidgetRef ref,
    OrderStatus next,
  ) async {
    await runShopAction(
      context,
      action: () => ref
          .read(shopActionsProvider)
          .advanceOrder(storeId, order.id, next),
      success: 'الطلب ${order.ref} → ${next.label}',
    );
  }

  Future<void> _openWhatsApp(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذّر فتح واتساب')),
      );
    }
  }

  Future<void> _call(BuildContext context, String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    final ok = await launchUrl(uri);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذّر بدء الاتصال')),
      );
    }
  }
}

/// إيصال تحويل بانتظار المراجعة.
///
/// يُعرض قبل زرّ التقدّم لأنه شرطه: تأكيد طلب تحويلٍ لم يُتحقَّق منه
/// هو تسليم بضاعة بلا دفع.
class _ProofNote extends ConsumerWidget {
  const _ProofNote({required this.order, required this.storeId});

  final ShopOrder order;
  final String storeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = AzmPalette.of(context);

    return Container(
      padding: const EdgeInsets.all(AzmSpace.md),
      decoration: BoxDecoration(
        color: p.warningSubtle,
        borderRadius: AzmRadius.control,
      ),
      child: Row(
        children: [
          Icon(Icons.receipt_outlined, size: 18, color: p.warning),
          const SizedBox(width: AzmSpace.sm),
          Expanded(
            child: Text(
              'إيصال تحويل بانتظار مراجعتك',
              style: AppTypography.caption.copyWith(color: p.warning),
            ),
          ),
          TextButton(
            onPressed: () => runShopAction(
              context,
              action: () => ref
                  .read(shopActionsProvider)
                  .setOrderPaid(storeId, order.id, paid: true),
              success: 'تأكيد استلام مبلغ ${order.ref}',
            ),
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              foregroundColor: p.warning,
            ),
            child: const Text('استلمتُ المبلغ'),
          ),
        ],
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);
    final color = switch (status) {
      OrderStatus.wait => p.accent,
      OrderStatus.confirmed => p.info,
      OrderStatus.done => p.success,
      OrderStatus.off => p.inkGhost,
    };

    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            borderRadius: AzmRadius.pill,
          ),
        ),
        const SizedBox(width: AzmSpace.xs),
        Text(
          status.label,
          style: AppTypography.caption.copyWith(color: color),
        ),
      ],
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);

    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: TextButton.styleFrom(
        visualDensity: VisualDensity.compact,
        foregroundColor: p.inkMuted,
        padding: const EdgeInsets.symmetric(horizontal: AzmSpace.sm),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// الترقيم
// ─────────────────────────────────────────────

class _Pager extends StatelessWidget {
  const _Pager({
    required this.page,
    required this.pages,
    required this.onGo,
  });

  final int page;
  final int pages;
  final ValueChanged<int> onGo;

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AzmSpace.screenGutter,
        vertical: AzmSpace.xl,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: page > 1 ? () => onGo(page - 1) : null,
            icon: const Icon(Icons.chevron_right_rounded),
            color: p.inkMuted,
          ),
          Text(
            '$page من $pages',
            style: AppTypography.caption.copyWith(color: p.inkMuted),
          ),
          IconButton(
            onPressed: page < pages ? () => onGo(page + 1) : null,
            icon: const Icon(Icons.chevron_left_rounded),
            color: p.inkMuted,
          ),
        ],
      ),
    );
  }
}

String _money(int amount) {
  final s = '$amount';
  final out = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) out.write(',');
    out.write(s[i]);
  }
  return out.toString();
}
