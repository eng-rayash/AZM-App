import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/design/azm_tokens.dart';
import '../../core/router/route_names.dart';
import '../../core/theme/app_typography.dart';
import '../auth/providers/auth_providers.dart';
import '../shop/data/shop_models.dart';
import '../store_platform/create_store_wizard.dart';
import '../shop/providers/shop_providers.dart';
import 'kit.dart';

/// بوابة شاشات المتجر: حساب عزم سمارت ← متجر ← المحتوى.
///
/// المتجر يعيش على الخادم، فشاشاته تحتاج حساب التاجر نفسه الذي يدخل به لوحة
/// عزم سمارت. بلا حساب: دعوة للدخول. بلا متجر: دعوة لإنشائه. ثم يُختار المتجر
/// المفتوح (أو الأول) ويُمرَّر للشاشة.
class StoreGate extends ConsumerWidget {
  const StoreGate({super.key, required this.builder});
  final Widget Function(BuildContext context, ShopStore store, List<ShopStore> all) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateNotifierProvider);
    if (auth.status != AuthStatus.authenticated) {
      return RvEmpty(
        icon: Icons.storefront_rounded,
        title: 'متجرك على RVIOS',
        body: 'ادخل بحسابك في RVIOS لتدير متجرك: الطلبات والمنتجات والعملاء والتصميم، من جوالك.',
        action: 'تسجيل الدخول',
        onAction: () => context.go(RouteNames.login),
      );
    }
    final list = ref.watch(storeListProvider);
    return list.when(
      loading: () => const Center(child: CircularProgressIndicator(color: Rv.red)),
      error: (e, _) => RvEmpty(
        icon: Icons.wifi_off_rounded,
        title: 'تعذّر الوصول إلى متجرك',
        body: '$e',
        action: 'إعادة المحاولة',
        onAction: () => ref.invalidate(storeListProvider),
      ),
      data: (l) {
        if (l.stores.isEmpty) {
          if (CreateStoreWizard.openAfterSignUp) {
            CreateStoreWizard.openAfterSignUp = false;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) CreateStoreWizard.open(context);
            });
          }
          return RvEmpty(
            icon: Icons.add_business_rounded,
            title: 'افتح متجرك الأول',
            body: 'اختر قالبًا من ١٨ قالبًا احترافيًا بمعاينة حية، ثم الباقة، ويصير متجرك جاهزًا برابطه الخاص. مجاني للبدء.',
            action: 'افتح متجرك الآن',
            onAction: () => showCreateStoreSheet(context),
          );
        }
        final id = ref.watch(activeStoreIdProvider);
        final store = l.stores.firstWhere((s) => s.id == id, orElse: () => l.stores.first);
        if (id != store.id) {
          WidgetsBinding.instance.addPostFrameCallback((_) => ref.read(activeStoreIdProvider.notifier).state = store.id);
        }
        return builder(context, store, l.stores);
      },
    );
  }
}

/// مبدّل المتجر — لمن يملك أكثر من متجر.
Future<void> pickStore(BuildContext context, WidgetRef ref, List<ShopStore> all, String current) async {
  final p = AzmPalette.of(context);
  final picked = await showModalBottomSheet<String>(
    context: context,
    backgroundColor: p.surface,
    showDragHandle: true,
    builder: (c) => SafeArea(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Padding(padding: const EdgeInsets.only(bottom: 8), child: Text('متاجرك', style: AppTypography.h4.copyWith(color: p.ink))),
        for (final s in all)
          ListTile(
            leading: CircleAvatar(backgroundColor: Rv.red.withValues(alpha: .12), child: Text(s.name.characters.first, style: const TextStyle(color: Rv.red, fontWeight: FontWeight.w700))),
            title: Text(s.name),
            subtitle: Text('/${s.slug}', textDirection: TextDirection.ltr, textAlign: TextAlign.end),
            trailing: s.id == current ? const Icon(Icons.check_circle, color: Rv.red) : null,
            onTap: () => Navigator.pop(c, s.id),
          ),
        ListTile(
          leading: const Icon(Icons.add_circle_outline, color: Rv.red),
          title: const Text('متجر جديد'),
          onTap: () {
            Navigator.pop(c);
            showCreateStoreSheet(context);
          },
        ),
        const SizedBox(height: 8),
      ]),
    ),
  );
  if (picked != null) ref.read(activeStoreIdProvider.notifier).state = picked;
}

/// «افتح متجرك» — معالج المنصة الكامل: القالب بمعاينة حية، الباقة، البيانات، الدفع.
void showCreateStoreSheet(BuildContext context) => CreateStoreWizard.open(context);
