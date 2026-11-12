/// AZM — نموذج التنقّل
///
/// شجرة التنقّل معرَّفة هنا كبيانات لا كواجهة، فيقرأها الشريط الجانبي
/// والشريط السفلي ولوحة الأوامر مستقبلًا من مصدر واحد. إضافة وجهة جديدة
/// تعديل في سطر واحد لا في ثلاث شاشات.
///
/// التجميع حسب **ما يفعله المستخدم** لا حسب انتماء الوحدة تقنيًا: الفواتير
/// مع المال لا مع «المبيعات»، والحضور مع الناس لا مع «العمليات».
library;

import 'package:flutter/material.dart';

import '../../features/store_app/store_routes.dart';
import '../router/route_names.dart';

// ─────────────────────────────────────────────────────────────
// Item
// ─────────────────────────────────────────────────────────────

/// وجهة واحدة في شجرة التنقّل.
@immutable
class NavDestination {
  const NavDestination({
    required this.label,
    required this.icon,
    required this.route,
    this.description,
    this.isShellTab = false,
  });

  /// الاسم المعروض — اسم لا جملة
  final String label;

  final IconData icon;

  /// المسار المسجّل في الراوتر
  final String route;

  /// سطر واحد يشرح ما تفعله الوجهة، يُعرض في الشاشات العريضة
  final String? description;

  /// وجهات الـShell تُفتح بـ`go` لا `push` حتى لا تتراكم في المكدّس
  final bool isShellTab;
}

// ─────────────────────────────────────────────────────────────
// Group
// ─────────────────────────────────────────────────────────────

/// مجموعة وجهات تجيب عن سؤال واحد.
@immutable
class NavGroup {
  const NavGroup({
    required this.label,
    required this.icon,
    required this.question,
    required this.destinations,
  });

  final String label;
  final IconData icon;

  /// السؤال الذي تجيب عنه المجموعة — يُعرض تحت العنوان ويضبط ما ينتمي إليها
  final String question;

  final List<NavDestination> destinations;

  /// هل يقع المسار الحالي داخل هذه المجموعة؟
  bool contains(String location) =>
      destinations.any((d) => location.startsWith(d.route));
}

// ─────────────────────────────────────────────────────────────
// Tree
// ─────────────────────────────────────────────────────────────

/// شجرة تنقّل عزم.
class AzmNav {
  AzmNav._();

  /// الوجهة المفردة أعلى الشجرة — لوحة المتجر.
  static const NavDestination home = NavDestination(
    label: 'المتجر',
    icon: Icons.storefront_rounded,
    route: StoreRoutes.home,
    description: 'صحة متجرك اليوم وما يحتاجك',
    isShellTab: true,
  );

  /// RVIOS للتاجر: المتجر وإدارته، ثم أعماله المرتبطة به. وحدات الأعمال العامة
  /// (المالية، الفريق، الوثائق، التنفيذ…) في تطبيق «عزم» المستقل.
  static const List<NavGroup> groups = [
    NavGroup(
      label: 'متجري',
      icon: Icons.storefront_outlined,
      question: 'كيف يبيع متجري',
      destinations: [
        NavDestination(label: 'الطلبات', icon: Icons.receipt_long_outlined, route: StoreRoutes.orders, isShellTab: true),
        NavDestination(label: 'المنتجات', icon: Icons.inventory_2_outlined, route: StoreRoutes.products, isShellTab: true),
        NavDestination(label: 'عملاء المتجر', icon: Icons.people_alt_outlined, route: StoreRoutes.customers),
        NavDestination(label: 'التقييمات', icon: Icons.star_outline_rounded, route: StoreRoutes.reviews),
        NavDestination(label: 'التوصيل', icon: Icons.local_shipping_outlined, route: StoreRoutes.zones),
        NavDestination(label: 'التحليلات', icon: Icons.insights_outlined, route: StoreRoutes.analytics),
        NavDestination(label: 'فريق المتجر', icon: Icons.groups_outlined, route: StoreRoutes.team),
      ],
    ),
    NavGroup(
      label: 'المنصة',
      icon: Icons.palette_outlined,
      question: 'كيف يبدو متجري وباقته',
      destinations: [
        NavDestination(label: 'تصميم المتجر', icon: Icons.brush_outlined, route: StoreRoutes.design),
        NavDestination(label: 'القوالب', icon: Icons.dashboard_customize_outlined, route: StoreRoutes.templates),
        NavDestination(label: 'الباقة والاشتراك', icon: Icons.workspace_premium_outlined, route: StoreRoutes.billing),
        NavDestination(label: 'طرق الدفع', icon: Icons.account_balance_wallet_outlined, route: StoreRoutes.pay),
      ],
    ),
    NavGroup(
      label: 'أعمالي',
      icon: Icons.business_center_outlined,
      question: 'من أتعامل معه وما أفعله كل يوم',
      destinations: [
        NavDestination(label: 'متاجري', icon: Icons.store_mall_directory_outlined, route: RouteNames.storesList),
        NavDestination(label: 'دفتر العملاء', icon: Icons.handshake_outlined, route: RouteNames.clientsList),
        NavDestination(label: 'الموردون', icon: Icons.local_shipping_outlined, route: RouteNames.suppliersList),
        NavDestination(label: 'الروتين اليومي', icon: Icons.repeat_rounded, route: RouteNames.routineTasksList),
      ],
    ),
  ];

  /// وجهات أسفل الشريط — النظام والحساب.
  static const List<NavDestination> system = [
    NavDestination(label: 'الإشعارات', icon: Icons.notifications_none_rounded, route: StoreRoutes.notifications),
    NavDestination(label: 'الإعدادات', icon: Icons.settings_outlined, route: RouteNames.settings),
  ];

  /// المجموعة التي تحوي المسار الحالي، أو `null` للرئيسية وما لا ينتمي.
  static NavGroup? groupFor(String location) {
    for (final g in groups) {
      if (g.contains(location)) return g;
    }
    return null;
  }
}
