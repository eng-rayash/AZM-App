import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/azm_tokens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/shop_models.dart';
import '../../providers/shop_providers.dart';
import '../product_editor_sheet.dart';
import '../widgets/shop_async.dart';

/// AZM — منتجات المتجر
///
/// الكتالوج يملكه التاجر ويعدّله كثيرًا، والإجراء الأغلب فيه ليس
/// التحرير بل **العرض والإخفاء**: منتج نفد يُخفى حتى يعود، ولا يُحذف.
/// فالمفتاح على الصفّ مباشرة، والتحرير بلمسة على الصفّ نفسه.
///
/// والسعة تُعرض من ردّ الخادم لا تُحسب هنا: الحدّ يفرضه
/// `ShopStoreAccessService`، وحسابُه في الواجهة يعني رقمين قد
/// يختلفان.
class StoreProductsTab extends ConsumerWidget {
  const StoreProductsTab({
    super.key,
    required this.storeId,
    required this.store,
  });

  final String storeId;
  final ShopStore store;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(productsProvider(storeId));

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () async => ref.invalidate(productsProvider(storeId)),
          child: ShopAsync<ProductList>(
            value: list,
            onRetry: () => ref.invalidate(productsProvider(storeId)),
            isEmpty: (l) => l.products.isEmpty,
            empty: ShopEmpty(
              icon: Icons.inventory_2_outlined,
              title: 'لا منتجات بعد',
              body: 'أضف أول منتج — اسم وسعر يكفيان للبدء.',
              action: FilledButton.icon(
                onPressed: () => _openEditor(context, null),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('منتج جديد'),
              ),
            ),
            builder: (data) => ListView.builder(
              padding: const EdgeInsets.only(bottom: 96),
              itemCount: data.products.length + 1,
              itemBuilder: (context, i) {
                if (i == data.products.length) {
                  return _CapacityNote(capacity: data.capacity);
                }
                return _ProductRow(
                  product: data.products[i],
                  store: store,
                  storeId: storeId,
                  onEdit: () => _openEditor(context, data.products[i]),
                );
              },
            ),
          ),
        ),

        // زرّ الإضافة يظهر فقط حين تسمح السعة: زرّ يفشل عند الضغط
        // يبدو كعطب في التطبيق لا كحدّ في الباقة.
        Positioned(
          left: AzmSpace.screenGutter,
          bottom: AzmSpace.xl,
          child: list.maybeWhen(
            data: (d) => d.capacity.canAdd
                ? FloatingActionButton(
                    onPressed: () => _openEditor(context, null),
                    tooltip: 'منتج جديد',
                    child: const Icon(Icons.add_rounded),
                  )
                : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }

  void _openEditor(BuildContext context, ShopProduct? product) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProductEditorSheet(
        storeId: storeId,
        store: store,
        product: product,
      ),
    );
  }
}

// ─────────────────────────────────────────────
// صفّ المنتج
// ─────────────────────────────────────────────

class _ProductRow extends ConsumerWidget {
  const _ProductRow({
    required this.product,
    required this.store,
    required this.storeId,
    required this.onEdit,
  });

  final ShopProduct product;
  final ShopStore store;
  final String storeId;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = AzmPalette.of(context);

    return InkWell(
      onTap: onEdit,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AzmSpace.screenGutter,
          vertical: AzmSpace.md,
        ),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: p.hairline)),
        ),
        child: Row(
          children: [
            _Thumb(product: product),
            const SizedBox(width: AzmSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.body.copyWith(
                      // المخفيّ يبدو مخفيًّا: نصّ باهت لا شارة تُقرأ
                      color: product.live ? p.ink : p.inkGhost,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AzmSpace.xxs),
                  Row(
                    children: [
                      Text(
                        '${_money(product.price)} ${store.currency}',
                        style: AppTypography.caption.copyWith(
                          color: p.inkMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (product.hasDiscount) ...[
                        const SizedBox(width: AzmSpace.sm),
                        Text(
                          _money(product.oldPrice!),
                          style: AppTypography.caption.copyWith(
                            color: p.inkGhost,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                      const SizedBox(width: AzmSpace.sm),
                      _Stock(product: product),
                    ],
                  ),
                ],
              ),
            ),
            Switch(
              value: product.live,
              onChanged: (v) => runShopAction(
                context,
                action: () => ref.read(shopActionsProvider).setProductLive(
                      storeId,
                      product.id,
                      live: v,
                    ),
                success: v ? 'عُرض ${product.name}' : 'أُخفي ${product.name}',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.product});

  final ShopProduct product;

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);
    final url = product.image.isNotEmpty
        ? product.image
        : (product.images.isNotEmpty ? product.images.first : '');

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: p.surfaceSunken,
        borderRadius: AzmRadius.control,
      ),
      clipBehavior: Clip.antiAlias,
      child: url.isEmpty
          ? Icon(Icons.image_outlined, size: 18, color: p.inkGhost)
          : Image.network(
              url,
              fit: BoxFit.cover,
              // صورة لا تُحمَّل لا تترك مربّعًا مكسورًا
              errorBuilder: (_, _, _) =>
                  Icon(Icons.image_not_supported_outlined,
                      size: 18, color: p.inkGhost),
            ),
    );
  }
}

/// حالة المخزون — ثلاث حالات لا رقم مجرّد.
class _Stock extends StatelessWidget {
  const _Stock({required this.product});

  final ShopProduct product;

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);

    if (product.isOutOfStock) {
      return Text(
        'نفد',
        style: AppTypography.caption.copyWith(
          color: p.danger,
          fontWeight: FontWeight.w600,
        ),
      );
    }
    if (product.isLowStock) {
      return Text(
        'بقي ${product.qty}',
        style: AppTypography.caption.copyWith(
          color: p.warning,
          fontWeight: FontWeight.w600,
        ),
      );
    }
    return Text(
      '${product.qty} متاح',
      style: AppTypography.caption.copyWith(color: p.inkFaint),
    );
  }
}

// ─────────────────────────────────────────────
// السعة
// ─────────────────────────────────────────────

class _CapacityNote extends StatelessWidget {
  const _CapacityNote({required this.capacity});

  final CatalogCapacity capacity;

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AzmSpace.screenGutter,
        AzmSpace.xl,
        AzmSpace.screenGutter,
        AzmSpace.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            capacity.max == null
                ? '${capacity.used} منتجًا · السعة غير محدودة'
                : '${capacity.used} من ${capacity.max} منتجًا',
            style: AppTypography.caption.copyWith(color: p.inkMuted),
          ),
          if (!capacity.canAdd) ...[
            const SizedBox(height: AzmSpace.sm),
            Text(
              // نفس ما يقوله الخادم عند الرفض
              'بلغتَ حدّ باقتك — الترقية ترفع سعة الكتالوج.',
              style: AppTypography.caption.copyWith(color: p.warning),
            ),
          ],
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
