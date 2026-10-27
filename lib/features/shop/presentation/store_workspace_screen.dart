import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/azm_tokens.dart';
import '../../../core/theme/app_typography.dart';
import '../data/shop_models.dart';
import '../providers/shop_providers.dart';
import 'tabs/store_orders_tab.dart';
import 'tabs/store_overview_tab.dart';
import 'tabs/store_products_tab.dart';
import 'widgets/shop_async.dart';

/// AZM — لوحة المتجر
///
/// ثلاثة تبويبات تجيب أسئلة التاجر الثلاثة بالترتيب الذي يسألها:
///   **ماذا يحتاج انتباهي؟** (نظرة عامة) ·
///   **ما الطلبات؟** · **ما المعروض؟**
///
/// الطلبات قبل المنتجات عمدًا: طلب لم يُؤكَّد يخسر عميلًا، ومنتج لم
/// يُحدَّث لا يخسر شيئًا اليوم.
class StoreWorkspaceScreen extends ConsumerStatefulWidget {
  const StoreWorkspaceScreen({super.key, required this.storeId});

  final String storeId;

  @override
  ConsumerState<StoreWorkspaceScreen> createState() =>
      _StoreWorkspaceScreenState();
}

class _StoreWorkspaceScreenState extends ConsumerState<StoreWorkspaceScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 3, vsync: this);

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);
    final store = ref.watch(storeProvider(widget.storeId));

    return Scaffold(
      backgroundColor: p.ground,
      body: SafeArea(
        bottom: false,
        child: ShopAsync<ShopStore>(
          value: store,
          onRetry: () => ref.invalidate(storeProvider(widget.storeId)),
          builder: (data) => Column(
            children: [
              _Header(store: data),
              _Tabs(controller: _tabs, storeId: widget.storeId),
              Expanded(
                child: TabBarView(
                  controller: _tabs,
                  children: [
                    StoreOverviewTab(storeId: widget.storeId),
                    StoreOrdersTab(storeId: widget.storeId, store: data),
                    StoreProductsTab(storeId: widget.storeId, store: data),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// الرأس
// ─────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.store});

  final ShopStore store;

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AzmSpace.screenGutter,
        AzmSpace.md,
        AzmSpace.screenGutter,
        AzmSpace.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () => Navigator.of(context).maybePop(),
                borderRadius: AzmRadius.control,
                child: Padding(
                  padding: const EdgeInsets.all(AzmSpace.xs),
                  // يُنعكس تلقائيًا في RTL فيشير إلى اليمين
                  child: Icon(Icons.chevron_right_rounded,
                      size: 24, color: p.ink),
                ),
              ),
              const SizedBox(width: AzmSpace.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.name,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.h2.copyWith(color: p.ink),
                    ),
                    Text(
                      '/${store.slug}',
                      style: AppTypography.caption.copyWith(color: p.inkFaint),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (store.isSuspended) ...[
            const SizedBox(height: AzmSpace.md),
            _Banner(
              icon: Icons.pause_circle_outline_rounded,
              // الإيقاف من فريق المنصة، والتاجر لا يستطيع رفعه بنفسه
              text: 'المتجر موقوف — واجهته العامّة لا تستقبل طلبات. '
                  'راجع فريق المنصة.',
              color: p.danger,
              subtle: p.dangerSubtle,
            ),
          ] else if (store.hasHiddenTemplate || store.hasHiddenTheme) ...[
            const SizedBox(height: AzmSpace.md),
            _Banner(
              icon: Icons.auto_awesome_outlined,
              // المحفوظ ≠ الفعّال: قوله صراحةً يمنع التاجر من الظنّ
              // أن متجره يبدو بشكل لا يراه زوّاره
              text: 'اختيارك للقالب محفوظ لكنه غير مطبَّق على باقتك '
                  'الحالية — يعود بالترقية.',
              color: p.warning,
              subtle: p.warningSubtle,
            ),
          ],
        ],
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({
    required this.icon,
    required this.text,
    required this.color,
    required this.subtle,
  });

  final IconData icon;
  final String text;
  final Color color;
  final Color subtle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AzmSpace.md),
      decoration: BoxDecoration(
        color: subtle,
        borderRadius: AzmRadius.control,
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: AzmSpace.sm),
          Expanded(
            child: Text(
              text,
              style: AppTypography.caption.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// التبويبات
// ─────────────────────────────────────────────

class _Tabs extends ConsumerWidget {
  const _Tabs({required this.controller, required this.storeId});

  final TabController controller;
  final String storeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = AzmPalette.of(context);

    // شارة الطلبات المعلّقة تأتي من النظرة العامة: نداء واحد يخدم
    // التبويب والشارة بدل نداء ثانٍ للعدّ وحده.
    final pending = ref.watch(storeOverviewProvider(storeId)).maybeWhen(
          data: (o) => o.kpis.pending,
          orElse: () => 0,
        );

    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: p.hairline)),
      ),
      child: TabBar(
        controller: controller,
        labelColor: p.ink,
        unselectedLabelColor: p.inkFaint,
        indicatorColor: p.accent,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
        labelStyle: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: AppTypography.body,
        tabs: [
          const Tab(text: 'نظرة عامة'),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('الطلبات'),
                if (pending > 0) ...[
                  const SizedBox(width: AzmSpace.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AzmSpace.sm,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: p.accent,
                      borderRadius: AzmRadius.pill,
                    ),
                    child: Text(
                      '$pending',
                      style: AppTypography.caption.copyWith(
                        color: p.onAccent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Tab(text: 'المنتجات'),
        ],
      ),
    );
  }
}
