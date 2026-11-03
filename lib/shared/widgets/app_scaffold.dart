import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/design/azm_tokens.dart';
import '../../core/navigation/azm_nav_model.dart';
import '../../core/router/route_names.dart';
import '../../core/theme/app_typography.dart';
import 'azm_sidebar.dart';
import 'dashboard_fab.dart';

/// AZM — هيكل التطبيق
///
/// طبقتا تنقّل تخدمان قصدين مختلفين:
///
/// **الشريط السفلي** — أربع وجهات يتنقّل بينها المستخدم عشرات المرات يوميًا،
/// في متناول الإبهام. هذا تنقّل بالعادة لا بالبحث.
///
/// **الشريط الجانبي** — الشجرة كاملة (٤٠ وجهة في ست مجموعات) للوصول إلى ما
/// لا يُزار يوميًا. هذا تنقّل بالقصد.
///
/// وهذا ما ألغى تبويب «المزيد»: كان يخلط القصدين في قائمة واحدة مسطّحة.
///
/// عند [AzmBreakpoint.sidebar] فأعلى يصير الجانبي لوحًا ثابتًا ويختفي السفلي —
/// فالإبهام لم يعد قيدًا، والشجرة المرئية دائمًا أسرع.
class AppShellScaffold extends StatelessWidget {
  const AppShellScaffold({super.key, required this.child});

  final Widget child;

  /// التبويبات الخمسة — كل واحد يجيب عن سؤال واحد، وأسماؤها هي أسماء
  /// مجموعات [AzmSidebar] نفسها.
  ///
  /// كانت أربعة: «الرئيسية» و«العمل» و«الأعمال» و«الذكاء». ثلاث علل:
  /// «العمل» و«الأعمال» يفرّق بينهما حرف ومعناهما مختلف تمامًا؛ وأكبر
  /// مجموعتين (المالية ١٠ وجهات، والفريق ١٢) بلا تبويب أصلًا؛ و«الذكاء»
  /// اسمٌ يَعِد بما لا يُسلَّم — فتحته تقارير.
  static const _tabs = <_Tab>[
    _Tab(
      icon: Icons.wb_sunny_outlined,
      activeIcon: Icons.wb_sunny_rounded,
      label: 'اليوم',
      path: RouteNames.dashboardFull,
    ),
    _Tab(
      icon: Icons.checklist_outlined,
      activeIcon: Icons.checklist_rounded,
      label: 'التنفيذ',
      path: RouteNames.workFull,
    ),
    _Tab(
      icon: Icons.business_center_outlined,
      activeIcon: Icons.business_center_rounded,
      label: 'الأعمال',
      path: RouteNames.businessFull,
    ),
    _Tab(
      icon: Icons.groups_outlined,
      activeIcon: Icons.groups_rounded,
      label: 'الفريق',
      path: RouteNames.hrmFull,
    ),
    _Tab(
      icon: Icons.handyman_outlined,
      activeIcon: Icons.handyman_rounded,
      label: 'أدوات',
      path: RouteNames.toolsFull,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);
    final location = GoRouterState.of(context).uri.path;
    final wide = AzmBreakpoint.hasSidebar(context);

    return PopScope(
      canPop: location == RouteNames.dashboardFull,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (location != RouteNames.dashboardFull) {
          context.go(RouteNames.dashboardFull);
        }
      },
      child: Scaffold(
        backgroundColor: p.ground,
        // الدرج على الشاشات الضيّقة وحدها — على العريضة اللوح ثابت
        drawer: wide
            ? null
            : AzmSidebar(currentLocation: location, isDrawer: true),
        drawerEnableOpenDragGesture: !wide,
        body: wide
            ? Row(
                children: [
                  AzmSidebar(currentLocation: location, isDrawer: false),
                  Expanded(
                    child: Column(
                      children: [
                        _TopBar(location: location, showMenu: false),
                        Expanded(child: child),
                      ],
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  _TopBar(location: location, showMenu: true),
                  Expanded(child: child),
                ],
              ),
        // الزرّ العائم على الضيّقة وحدها: على العريضة اللوح الجانبي ظاهر
        // دائمًا ومداخل الإنشاء فيه، فلا يزاحم المحتوى زرٌّ فوقه.
        floatingActionButton: wide ? null : _CreateFab(location: location),
        bottomNavigationBar: wide
            ? null
            : _AzmBottomNav(tabs: _tabs, currentPath: location, palette: p),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Top Bar
// ─────────────────────────────────────────────────────────────

/// شريط علوي رفيع: مدخل الشريط الجانبي، وموضع القسم، والبحث والإشعارات.
///
/// ليس `AppBar` ماديًّا — لا سطح ملوّن ولا ارتفاع. يفصله عن المحتوى خطّ
/// شعري واحد، فيبقى ثقل الشاشة للمحتوى.
class _TopBar extends StatelessWidget {
  const _TopBar({required this.location, required this.showMenu});

  final String location;

  /// زرّ فتح الدرج — لا يظهر حين يكون اللوح ثابتًا
  final bool showMenu;

  /// اسم الموضع الحالي في الشجرة، ليعرف المستخدم أين هو.
  ///
  /// تبويبات الشريط السفلي تُقرأ **أولًا**: الوجهة الواحدة اسمٌ واحد، وقراءة
  /// الشجرة قبلها كانت تسمّي «الذكاء» في الأسفل و«صحة الأعمال» في الأعلى
  /// لنفس الشاشة.
  String _title() {
    if (location == RouteNames.dashboardFull) return AzmNav.home.label;
    for (final tab in AppShellScaffold._tabs) {
      if (location.startsWith(tab.path)) return tab.label;
    }
    for (final g in AzmNav.groups) {
      for (final d in g.destinations) {
        if (location.startsWith(d.route)) return d.label;
      }
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);

    return Container(
      decoration: BoxDecoration(
        color: p.surface,
        border: Border(bottom: BorderSide(color: p.hairline)),
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 52,
          child: Row(
            children: [
              if (showMenu)
                Builder(
                  builder: (ctx) => _BarIcon(
                    icon: Icons.menu_rounded,
                    tooltip: 'القائمة',
                    onTap: () => Scaffold.of(ctx).openDrawer(),
                  ),
                )
              else
                const SizedBox(width: AzmSpace.lg),
              Expanded(
                child: Text(
                  _title(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.h4.copyWith(
                    color: p.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _BarIcon(
                icon: Icons.search_rounded,
                tooltip: 'بحث',
                onTap: () => context.push(RouteNames.globalSearch),
              ),
              _BarIcon(
                icon: Icons.notifications_none_rounded,
                tooltip: 'الإشعارات',
                onTap: () => context.push(RouteNames.notificationCenter),
              ),
              const SizedBox(width: AzmSpace.xs),
            ],
          ),
        ),
      ),
    );
  }
}

class _BarIcon extends StatelessWidget {
  const _BarIcon({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(icon, size: 21, color: p.inkMuted),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Bottom Navigation
// ─────────────────────────────────────────────────────────────

class _AzmBottomNav extends StatelessWidget {
  const _AzmBottomNav({
    required this.tabs,
    required this.currentPath,
    required this.palette,
  });

  final List<_Tab> tabs;
  final String currentPath;
  final AzmPalette palette;

  /// الرئيسية تطابق تمامًا، وما عداها يطابق البادئة فيبقى التبويب مضاءً
  /// داخل وجهاته الفرعية.
  bool _isActive(String path) {
    if (path == RouteNames.dashboardFull) {
      return currentPath == RouteNames.dashboardFull;
    }
    return currentPath.startsWith(path);
  }

  @override
  Widget build(BuildContext context) {
    final p = palette;

    return Container(
      decoration: BoxDecoration(
        color: p.surface,
        border: Border(top: BorderSide(color: p.hairline)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 58,
          // الخمسة تُبنى من القائمة لا بالاسم: إضافة تبويب سادس يومًا
          // ما تصير سطرًا في `_tabs` لا تعديلًا هنا.
          child: Row(
            children: [
              for (final tab in tabs)
                _NavItem(
                  tab: tab,
                  isActive: _isActive(tab.path),
                  palette: p,
                  onTap: () => context.go(tab.path),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// بند تبويب — الحالة النشطة تُقرأ بالحبر والوزن وشريط علوي رفيع.
class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.tab,
    required this.isActive,
    required this.palette,
    required this.onTap,
  });

  final _Tab tab;
  final bool isActive;
  final AzmPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final color = isActive ? p.accent : p.inkFaint;

    return Expanded(
      child: Semantics(
        button: true,
        selected: isActive,
        label: tab.label,
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: AzmMotion.standard,
                curve: AzmMotion.enter,
                width: isActive ? 22 : 0,
                height: 2,
                margin: const EdgeInsets.only(bottom: 6),
                color: isActive ? p.accent : Colors.transparent,
              ),
              Icon(
                isActive ? tab.activeIcon : tab.icon,
                size: 21,
                color: color,
              ),
              const SizedBox(height: 3),
              Text(
                tab.label,
                style: AppTypography.navLabel.copyWith(
                  color: color,
                  fontSize: 10.5,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// زرّ الإنشاء — عائم وواعٍ بالسياق.
///
/// كان يجلس في منتصف الشريط السفلي يفتح قائمةً بأحد عشر خيارًا: تنقّلٌ
/// مقنّع في هيئة إجراء، ويأكل خُمس عرض الشريط الذي صارت التبويبات
/// الخمسة أولى به.
///
/// الآن ضغطةٌ واحدة تُنشئ ما يخصّ التبويب الحالي مباشرةً — مهمة في
/// «التنفيذ»، فاتورة في «الأعمال»، موظفًا في «الفريق» — والضغطة
/// المطوّلة تفتح القائمة الكاملة لمن أراد غير ذلك.
class _CreateFab extends StatelessWidget {
  const _CreateFab({required this.location});

  final String location;

  /// ما يُنشأ بالضغطة القصيرة في كل تبويب، وتسميته لقارئ الشاشة.
  ///
  /// `null` يعني أن التبويب لا كيان أساسيًّا له — فالزرّ يفتح القائمة
  /// الكاملة بدل أن يخمّن.
  (String, String)? _primary() {
    if (location.startsWith(RouteNames.workFull)) {
      return (RouteNames.taskCreate, 'مهمة جديدة');
    }
    if (location.startsWith(RouteNames.businessFull)) {
      return (RouteNames.invoiceCreate, 'فاتورة جديدة');
    }
    if (location.startsWith(RouteNames.hrmFull)) {
      return (RouteNames.employeeCreate, 'موظف جديد');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);
    final primary = _primary();
    final label = primary?.$2 ?? 'إنشاء';

    return Semantics(
      button: true,
      label: label,
      hint: 'اضغط مطوّلًا لكل خيارات الإنشاء',
      child: Tooltip(
        message: label,
        child: GestureDetector(
          onLongPress: () => DashboardFab.showQuickAddMenu(context),
          child: FloatingActionButton(
            onPressed: () => primary == null
                ? DashboardFab.showQuickAddMenu(context)
                : context.push(primary.$1),
            backgroundColor: p.accent,
            foregroundColor: p.onAccent,
            elevation: 0,
            highlightElevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AzmRadius.sm),
            ),
            child: const Icon(Icons.add_rounded, size: 26),
          ),
        ),
      ),
    );
  }
}

class _Tab {
  const _Tab({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.path,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String path;
}
