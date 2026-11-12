import 'package:flutter/material.dart';
import '../../store_app/store_help.dart';
import '../../../shared/widgets/help_tips.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/azm_tokens.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_typography.dart';
import '../../finance/domain/finance_repository.dart';
import '../../routine_tasks/providers/routine_tasks_provider.dart';
import '../../shop/providers/shop_providers.dart';
import '../../store_app/kit.dart';
import '../../store_app/store_routes.dart';

/// «أعمالي» — ما يحتاجه التاجر حول متجره: متاجره، ودفتر عملائه (ومعه عملاء المتجر
/// الذين طلبوا منه)، ومورّدوه، وروتينه اليومي. وحدات الأعمال العامة في تطبيق «عزم».
class BusinessScreen extends ConsumerWidget {
  const BusinessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = AzmPalette.of(context);
    final stores = ref.watch(storeListProvider).valueOrNull?.stores.length;
    final clients = ref.watch(clientsListProvider).valueOrNull?.length;
    final suppliers = ref.watch(suppliersListProvider).valueOrNull?.length;
    final routine = ref.watch(routineTasksProvider);
    final done = routine.completions.length;
    final total = routine.tasks.length;

    Widget card({
      required IconData icon,
      required Color color,
      required String title,
      required String body,
      required String route,
      String? count,
    }) =>
        RvCard(
          onTap: () => context.push(route),
          child: Row(children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(16)),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: p.ink)),
                const SizedBox(height: 2),
                Text(body, style: AppTypography.caption.copyWith(color: p.inkMuted, height: 1.45)),
              ]),
            ),
            if (count != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(99)),
                child: Text(count, style: TextStyle(color: color, fontWeight: FontWeight.w800)),
              ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_left_rounded, color: p.inkFaint),
          ]),
        );

    String show(int? n) => n == null ? '—' : '$n';

    return WithHelp(tip: StoreHelp.business, child: ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 120), children: [
      RvHero(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('أعمالي', style: TextStyle(fontFamily: 'Zain', fontSize: 34, fontWeight: FontWeight.w800, color: Colors.white, height: 1.1)),
          const SizedBox(height: 6),
          Text('كل ما يدور حول متجرك: عملاؤك ومورّدوك ومتاجرك وروتين يومك — في مكان واحد.',
              style: TextStyle(color: Colors.white.withValues(alpha: .85), height: 1.6)),
          const SizedBox(height: 14),
          Row(children: [
            _Stat(show(stores), 'متجر'),
            _Stat(show(clients), 'عميل'),
            _Stat(show(suppliers), 'مورّد'),
            _Stat(total == 0 ? '—' : '$done/$total', 'روتين اليوم'),
          ]),
        ]),
      ),
      const RvSection('متاجري وعملائي'),
      card(icon: Icons.store_mall_directory_rounded, color: Rv.red, title: 'متاجري', body: 'كل متاجرك على RVIOS، وافتح متجرًا جديدًا', route: RouteNames.storesList, count: stores?.toString()),
      const SizedBox(height: 10),
      card(icon: Icons.people_alt_rounded, color: const Color(0xFF2F6FB3), title: 'عملاء المتجر', body: 'من طلب من متجرك: الطلبات والمبالغ وآخر نشاط', route: StoreRoutes.customers),
      const SizedBox(height: 10),
      card(icon: Icons.handshake_rounded, color: const Color(0xFF0F766E), title: 'دفتر العملاء', body: 'عملاؤك المعتمدون وملفاتهم ومستحقاتهم', route: RouteNames.clientsList, count: clients?.toString()),
      const RvSection('التوريد واليوم'),
      card(icon: Icons.local_shipping_rounded, color: const Color(0xFFD97706), title: 'الموردون', body: 'من تشتري منهم بضاعة متجرك وأرقامهم', route: RouteNames.suppliersList, count: suppliers?.toString()),
      const SizedBox(height: 10),
      card(
        icon: Icons.repeat_rounded,
        color: const Color(0xFF7C3AED),
        title: 'الروتين اليومي',
        body: 'مهام متجرك المتكررة: تجهيز الطلبات، تحديث المخزون، الرد على العملاء',
        route: RouteNames.routineTasksList,
        count: total == 0 ? null : '$done/$total',
      ),
    ]));
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.n, this.label);
  final String n;
  final String label;
  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(n, style: const TextStyle(fontFamily: 'Zain', fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white)),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11.5)),
        ]),
      );
}
