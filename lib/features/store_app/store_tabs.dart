import 'package:flutter/material.dart';
import 'store_help.dart';
import '../../shared/widgets/help_tips.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design/azm_tokens.dart';
import '../../core/theme/app_typography.dart';
import '../shop/presentation/tabs/store_orders_tab.dart';
import '../shop/presentation/tabs/store_products_tab.dart';
import 'kit.dart';
import 'manual_order_screen.dart';
import 'store_gate.dart';

/// تبويب «الطلبات»: طلبات المتجر المفتوح بمرشّحاتها وتفاصيلها.
class StoreOrdersScreen extends ConsumerWidget {
  const StoreOrdersScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => StoreGate(
        builder: (context, store, all) => WithHelp(tip: StoreHelp.orders, child: Column(children: [
          _StoreBar(title: 'الطلبات', subtitle: store.name, tip: StoreHelp.orders, onSwitch: all.length > 1 ? () => pickStore(context, ref, all, store.id) : null),
          Expanded(
            child: Stack(children: [
              StoreOrdersTab(key: ValueKey('o${store.id}'), storeId: store.id, store: store),
              PositionedDirectional(
                start: 16,
                bottom: 104,
                child: FloatingActionButton.extended(
                  heroTag: 'manual-order',
                  backgroundColor: Rv.red,
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('طلب يدوي'),
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ManualOrderScreen(store: store))),
                ),
              ),
            ]),
          ),
        ])),
      );
}

/// تبويب «المنتجات»: الكتالوج والتصنيفات والمخزون.
class StoreProductsScreen extends ConsumerWidget {
  const StoreProductsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => StoreGate(
        builder: (context, store, all) => WithHelp(tip: StoreHelp.products, child: Column(children: [
          _StoreBar(title: 'المنتجات', subtitle: store.name, tip: StoreHelp.products, onSwitch: all.length > 1 ? () => pickStore(context, ref, all, store.id) : null),
          Expanded(child: StoreProductsTab(key: ValueKey('p${store.id}'), storeId: store.id, store: store)),
        ])),
      );
}

class _StoreBar extends StatelessWidget {
  const _StoreBar({required this.title, required this.subtitle, required this.tip, this.onSwitch});
  final HelpTip tip;
  final String title;
  final String subtitle;
  final VoidCallback? onSwitch;
  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: AppTypography.h2.copyWith(color: p.ink, fontFamily: 'Zain', fontWeight: FontWeight.w800)),
            Text(subtitle, style: AppTypography.caption.copyWith(color: p.inkFaint)),
          ]),
        ),
        HelpButton(tip, color: p.inkMuted),
        if (onSwitch != null)
          OutlinedButton.icon(
            onPressed: onSwitch,
            icon: const Icon(Icons.swap_horiz_rounded, size: 18),
            label: const Text('تبديل المتجر'),
            style: OutlinedButton.styleFrom(foregroundColor: Rv.red, side: BorderSide(color: Rv.red.withValues(alpha: .3))),
          ),
      ]),
    );
  }
}
