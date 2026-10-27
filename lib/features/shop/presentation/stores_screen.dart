import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/azm_tokens.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/azm_screen.dart';
import '../data/shop_models.dart';
import '../providers/shop_providers.dart';
import 'create_store_sheet.dart';
import 'store_workspace_screen.dart';
import 'widgets/shop_async.dart';

/// AZM — متاجري
///
/// مدخل منصة المتاجر. يجيب عن سؤالين: **ما متاجري؟** و**هل أستطيع
/// إضافة واحد؟**
///
/// الثاني ليس تفصيلًا: الباقة المجانية تمنح خانة واحدة، والخادم يرفض
/// الثاني برسالة «اشترِ خانة متجر إضافي». عرض زرّ يفشل عند الضغط هو
/// الصيغة التي تجعل المستخدم يظنّ التطبيق معطوبًا — فالزرّ يُعطَّل
/// بـ`canAddStore` ويُقال السبب قبل الضغط.
class StoresScreen extends ConsumerWidget {
  const StoresScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(storeListProvider);

    return AzmScreen(
      title: 'متاجري',
      caption: 'متجر إلكتروني لكل نشاط — بالكتالوج والطلبات',
      primaryAction: list.maybeWhen(
        data: (d) => d.slots.canAddStore
            ? AzmIconAction(
                icon: Icons.add_rounded,
                tooltip: 'متجر جديد',
                onTap: () => _openCreate(context, ref),
              )
            : null,
        orElse: () => null,
      ),
      slivers: [
        ShopAsyncSliver<StoreList>(
          value: list,
          onRetry: () => ref.invalidate(storeListProvider),
          isEmpty: (d) => d.stores.isEmpty,
          empty: ShopEmpty(
            icon: Icons.storefront_outlined,
            title: 'لا متاجر بعد',
            body: 'أنشئ متجرك الأول — رابط عام، كتالوج، وطلبات تصلك '
                'على واتساب.',
            action: FilledButton.icon(
              onPressed: () => _openCreate(context, ref),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('متجر جديد'),
            ),
          ),
          builder: (data) => SliverList(
            delegate: SliverChildBuilderDelegate(
              childCount: data.stores.length + 1,
              (context, i) {
                // الحصّة بعد القائمة لا قبلها: القائمة هي الجواب،
                // والحصّة قيد عليه.
                if (i == data.stores.length) {
                  return _SlotsNote(
                    slots: data.slots,
                    onCreate: () => _openCreate(context, ref),
                  );
                }
                return _StoreRow(
                  store: data.stores[i],
                  onTap: () => _openStore(context, ref, data.stores[i]),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _openCreate(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CreateStoreSheet(),
    );
  }

  void _openStore(BuildContext context, WidgetRef ref, ShopStore store) {
    // المعرّف يُضبط قبل الدفع: الشاشة التالية تقرأه لا تستقبل الكائن،
    // لأن الكائن يتقادم بعد أول تعديل والمعرّف لا يتقادم.
    ref.read(activeStoreIdProvider.notifier).state = store.id;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StoreWorkspaceScreen(storeId: store.id),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// صفّ المتجر
// ─────────────────────────────────────────────

class _StoreRow extends StatelessWidget {
  const _StoreRow({required this.store, required this.onTap});

  final ShopStore store;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AzmSpace.screenGutter,
          vertical: AzmSpace.lg,
        ),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: p.hairline)),
        ),
        child: Row(
          children: [
            _StoreMark(store: store),
            const SizedBox(width: AzmSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          store.name,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.body.copyWith(
                            color: p.ink,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (store.verified) ...[
                        const SizedBox(width: AzmSpace.xs),
                        Icon(Icons.verified_rounded,
                            size: 14, color: p.info),
                      ],
                      if (store.isSuspended) ...[
                        const SizedBox(width: AzmSpace.sm),
                        _Chip(
                          label: 'موقوف',
                          color: p.danger,
                          subtle: p.dangerSubtle,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AzmSpace.xxs),
                  Text(
                    // الرابط هو هوية المتجر العامّة — يستحقّ الظهور
                    '/${store.slug}',
                    style: AppTypography.caption.copyWith(
                      color: p.inkFaint,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AzmSpace.sm),
            _Chip(
              label: store.planLabel,
              color: store.plan == 'basic' ? p.inkMuted : p.accent,
              subtle: store.plan == 'basic' ? p.surfaceSunken : null,
            ),
            const SizedBox(width: AzmSpace.sm),
            Icon(Icons.chevron_right_rounded, size: 20, color: p.inkGhost),
          ],
        ),
      ),
    );
  }
}

/// علامة المتجر — شعاره، أو حرفه الأول بلونه.
class _StoreMark extends StatelessWidget {
  const _StoreMark({required this.store});

  final ShopStore store;

  @override
  Widget build(BuildContext context) {
    final color = _parseHex(store.color) ?? AzmPalette.of(context).accent;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AzmRadius.control,
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: store.logo.isNotEmpty
          ? Image.network(
              store.logo,
              fit: BoxFit.cover,
              width: 40,
              height: 40,
              // شعار لا يُحمَّل لا يجوز أن يترك مربّعًا مكسورًا
              errorBuilder: (_, _, _) => _Initial(store: store, color: color),
            )
          : _Initial(store: store, color: color),
    );
  }
}

class _Initial extends StatelessWidget {
  const _Initial({required this.store, required this.color});

  final ShopStore store;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final name = store.name.trim();
    return Text(
      name.isEmpty ? '؟' : name.characters.first,
      style: AppTypography.body.copyWith(
        color: color,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color, this.subtle});

  final String label;
  final Color color;
  final Color? subtle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AzmSpace.sm,
        vertical: AzmSpace.xxs,
      ),
      decoration: BoxDecoration(
        color: subtle ?? color.withValues(alpha: 0.12),
        borderRadius: AzmRadius.pill,
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// الحصّة
// ─────────────────────────────────────────────

/// سطر الحصّة — يقول ما المتاح، وما يُفعل إن نفد.
class _SlotsNote extends StatelessWidget {
  const _SlotsNote({required this.slots, required this.onCreate});

  final StoreSlots slots;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);
    final full = !slots.canAddStore;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AzmSpace.screenGutter,
        AzmSpace.xl,
        AzmSpace.screenGutter,
        AzmSpace.xxxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                full ? Icons.lock_outline_rounded : Icons.inventory_2_outlined,
                size: 16,
                color: p.inkFaint,
              ),
              const SizedBox(width: AzmSpace.sm),
              Expanded(
                child: Text(
                  slots.max == null
                      ? 'متاجر غير محدودة في باقتك'
                      : 'استعملتَ ${slots.owned} من ${slots.slots} '
                          '${slots.slots == 1 ? "خانة" : "خانات"}',
                  style: AppTypography.caption.copyWith(color: p.inkMuted),
                ),
              ),
            ],
          ),
          if (full) ...[
            const SizedBox(height: AzmSpace.sm),
            Text(
              // نفس ما يقوله الخادم عند الرفض — فلا يُفاجأ المستخدم
              'لإضافة متجر آخر اشترِ خانة متجر إضافي من قسم الاشتراك.',
              style: AppTypography.caption.copyWith(color: p.inkFaint),
            ),
          ] else ...[
            const SizedBox(height: AzmSpace.md),
            OutlinedButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('متجر جديد'),
              style: OutlinedButton.styleFrom(
                foregroundColor: p.accent,
                side: BorderSide(color: p.rule),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// `#RRGGBB` → لون. يعيد `null` لصيغة غير صالحة بدل أن يرمي.
Color? _parseHex(String hex) {
  final v = hex.replaceFirst('#', '');
  if (v.length != 6) return null;
  final n = int.tryParse(v, radix: 16);
  return n == null ? null : Color(0xFF000000 | n);
}
