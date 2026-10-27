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

  /// الوجهة المفردة أعلى الشجرة — بلا مجموعة.
  static const NavDestination home = NavDestination(
    label: 'الرئيسية',
    icon: Icons.dashboard_rounded,
    route: RouteNames.dashboardFull,
    description: 'ما وضع عملك · ما يحتاجك · ماذا تفعل الآن',
    isShellTab: true,
  );

  static const List<NavGroup> groups = [
    // ── التنفيذ ───────────────────────────────────────────────
    NavGroup(
      label: 'التنفيذ',
      icon: Icons.checklist_rounded,
      question: 'ما الذي يجب تنفيذه',
      destinations: [
        NavDestination(
          label: 'المتابعات',
          icon: Icons.playlist_add_check_rounded,
          route: RouteNames.followupsListFull,
          description: 'كل ما هو مفتوح ومسند',
          isShellTab: true,
        ),
        NavDestination(
          label: 'الاجتماعات',
          icon: Icons.groups_2_outlined,
          route: RouteNames.meetingsList,
          description: 'جدول الأعمال والقرارات والمخرجات',
        ),
        NavDestination(
          label: 'التوجيهات',
          icon: Icons.assignment_turned_in_outlined,
          route: RouteNames.directivesList,
          description: 'ما وجّهتَ به ولم يُغلق',
        ),
        NavDestination(
          label: 'الموافقات',
          icon: Icons.approval_outlined,
          route: '/approvals',
          description: 'ما ينتظر قرارك',
        ),
        NavDestination(
          label: 'المواعيد',
          icon: Icons.event_outlined,
          route: RouteNames.appointmentsList,
          description: 'ما هو مثبّت في التقويم',
        ),
        NavDestination(
          label: 'الروتين اليومي',
          icon: Icons.repeat_rounded,
          route: RouteNames.routineTasksList,
          description: 'الالتزامات المتكررة',
        ),
        NavDestination(
          label: 'الجدول الزمني',
          icon: Icons.timeline_rounded,
          route: RouteNames.timeline,
          description: 'أحداث اليوم مرتّبة بالأولوية',
        ),
      ],
    ),

    // ── الأعمال ───────────────────────────────────────────────
    NavGroup(
      label: 'الأعمال',
      icon: Icons.handshake_outlined,
      question: 'من تخدم وما تسلّم',
      destinations: [
        NavDestination(
          label: 'متاجري',
          icon: Icons.storefront_outlined,
          route: RouteNames.storesList,
          description: 'المتجر العام والكتالوج والطلبات',
        ),
        NavDestination(
          label: 'العملاء',
          icon: Icons.people_alt_outlined,
          route: RouteNames.clientsList,
          description: 'الملف والنشاط والمستحقات',
        ),
        NavDestination(
          label: 'المشاريع',
          icon: Icons.account_tree_outlined,
          route: RouteNames.projectsList,
          description: 'ما هو قيد التنفيذ',
        ),
        NavDestination(
          label: 'الموردون',
          icon: Icons.local_shipping_outlined,
          route: RouteNames.suppliersList,
          description: 'من تشتري منه',
        ),
        NavDestination(
          label: 'جهات الاتصال',
          icon: Icons.contacts_outlined,
          route: RouteNames.contactsList,
          description: 'دفتر العلاقات',
        ),
        NavDestination(
          label: 'المكالمات',
          icon: Icons.call_outlined,
          route: RouteNames.callsList,
        ),
        NavDestination(
          label: 'الزيارات',
          icon: Icons.meeting_room_outlined,
          route: RouteNames.visitorsList,
        ),
        NavDestination(
          label: 'الحركات الميدانية',
          icon: Icons.directions_car_outlined,
          route: RouteNames.movementsList,
        ),
      ],
    ),

    // ── المالية ───────────────────────────────────────────────
    NavGroup(
      label: 'المالية',
      icon: Icons.account_balance_outlined,
      question: 'ما يدخل وما يخرج وما لم يُحصَّل',
      destinations: [
        NavDestination(
          label: 'الملخص المالي',
          icon: Icons.donut_small_outlined,
          route: RouteNames.financeFull,
          description: 'الإيراد والمصروف والربح',
          isShellTab: true,
        ),
        NavDestination(
          label: 'الفواتير',
          icon: Icons.receipt_long_outlined,
          route: RouteNames.invoicesList,
          description: 'المُصدَرة والمستحقة والمتأخرة',
        ),
        NavDestination(
          label: 'المصروفات',
          icon: Icons.south_west_rounded,
          route: RouteNames.expensesList,
          description: 'ما صُرف ولمن',
        ),
        NavDestination(
          label: 'الإيرادات',
          icon: Icons.north_east_rounded,
          route: RouteNames.revenuesList,
          description: 'ما دخل ومن أين',
        ),
        NavDestination(
          label: 'الحسابات البنكية',
          icon: Icons.account_balance_wallet_outlined,
          route: RouteNames.bankAccountsList,
        ),
        NavDestination(
          label: 'السندات',
          icon: Icons.receipt_outlined,
          route: RouteNames.paymentVouchersList,
          description: 'القبض والصرف',
        ),
        NavDestination(
          label: 'القيود اليومية',
          icon: Icons.menu_book_outlined,
          route: RouteNames.journalEntries,
        ),
        NavDestination(
          label: 'دليل الحسابات',
          icon: Icons.list_alt_outlined,
          route: RouteNames.chartOfAccounts,
        ),
        NavDestination(
          label: 'التقارير المالية',
          icon: Icons.query_stats_rounded,
          route: RouteNames.financeReports,
        ),
      ],
    ),

    // ── الفريق ────────────────────────────────────────────────
    NavGroup(
      label: 'الفريق',
      icon: Icons.badge_outlined,
      question: 'من ينفّذ وما له وما عليه',
      destinations: [
        NavDestination(
          label: 'ملخص العاملين',
          icon: Icons.groups_outlined,
          route: RouteNames.hrmFull,
          description: 'المؤشرات ومداخل الوحدات',
          isShellTab: true,
        ),
        NavDestination(
          label: 'الموظفون',
          icon: Icons.person_outline_rounded,
          route: RouteNames.employeesList,
          description: 'الملفات الشخصية',
        ),
        NavDestination(
          label: 'الحضور',
          icon: Icons.how_to_reg_outlined,
          route: RouteNames.attendanceList,
        ),
        NavDestination(
          label: 'الإجازات',
          icon: Icons.beach_access_outlined,
          route: RouteNames.leavesList,
        ),
        NavDestination(
          label: 'الرواتب',
          icon: Icons.payments_outlined,
          route: RouteNames.payroll,
        ),
        NavDestination(
          label: 'الأقسام',
          icon: Icons.domain_outlined,
          route: RouteNames.departmentsList,
        ),
        NavDestination(
          label: 'الفروع',
          icon: Icons.location_city_outlined,
          route: RouteNames.branchesList,
        ),
        NavDestination(
          label: 'السلف',
          icon: Icons.savings_outlined,
          route: RouteNames.advancesList,
        ),
        NavDestination(
          label: 'التقييم',
          icon: Icons.star_outline_rounded,
          route: RouteNames.evaluationsList,
        ),
        NavDestination(
          label: 'التدريب',
          icon: Icons.school_outlined,
          route: RouteNames.trainingsList,
        ),
        NavDestination(
          label: 'المكافآت والجزاءات',
          icon: Icons.gavel_rounded,
          route: RouteNames.rewardsPenaltiesList,
        ),
        NavDestination(
          label: 'تقارير الموارد',
          icon: Icons.insert_chart_outlined_rounded,
          route: RouteNames.hrmReports,
        ),
      ],
    ),

    // ── الوثائق ───────────────────────────────────────────────
    NavGroup(
      label: 'الوثائق',
      icon: Icons.folder_open_outlined,
      question: 'ما يُحفظ ويُرجع إليه',
      destinations: [
        NavDestination(
          label: 'الأرشيف',
          icon: Icons.inventory_2_outlined,
          route: RouteNames.archiveList,
          description: 'الصادر والوارد بالمسح الضوئي',
        ),
        NavDestination(
          label: 'الملاحظات',
          icon: Icons.sticky_note_2_outlined,
          route: RouteNames.notesList,
          description: 'ما دوّنتَه على السريع',
        ),
      ],
    ),

    // ── الذكاء والتحليلات ─────────────────────────────────────
    NavGroup(
      label: 'الذكاء والتحليلات',
      icon: Icons.insights_rounded,
      question: 'ماذا يحدث ولماذا',
      destinations: [
        NavDestination(
          label: 'صحة الأعمال',
          icon: Icons.monitor_heart_outlined,
          route: RouteNames.insightsFull,
          description: 'المؤشر وعوامله',
          isShellTab: true,
        ),
        NavDestination(
          label: 'التقارير العامة',
          icon: Icons.summarize_outlined,
          route: RouteNames.reports,
        ),
        NavDestination(
          label: 'البحث العالمي',
          icon: Icons.manage_search_rounded,
          route: RouteNames.globalSearch,
          description: 'عبر كل الوحدات',
        ),
      ],
    ),
  ];

  /// وجهات أسفل الشريط — النظام والحساب.
  static const List<NavDestination> system = [
    NavDestination(
      label: 'مركز الإشعارات',
      icon: Icons.notifications_none_rounded,
      route: RouteNames.notificationCenter,
    ),
    NavDestination(
      label: 'إدارة الشركة',
      icon: Icons.business_outlined,
      route: '/company/manage',
    ),
    NavDestination(
      label: 'الوحدات والباقة',
      icon: Icons.layers_outlined,
      route: '/settings/modules',
    ),
    NavDestination(
      label: 'السجلّ الأمني',
      icon: Icons.security_outlined,
      route: RouteNames.securityLog,
    ),
    NavDestination(
      label: 'الإعدادات',
      icon: Icons.settings_outlined,
      route: RouteNames.settings,
    ),
  ];

  /// المجموعة التي تحوي المسار الحالي، أو `null` للرئيسية وما لا ينتمي.
  static NavGroup? groupFor(String location) {
    for (final g in groups) {
      if (g.contains(location)) return g;
    }
    return null;
  }
}
