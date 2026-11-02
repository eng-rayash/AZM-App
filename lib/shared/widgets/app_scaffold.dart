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
  const AppShellScaffold({
    super.key,
    required this.child,
  });

  final Widget child;

  static const _tabs = <_Tab>[
    _Tab(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard_rounded,
      label: 'الرئيسية',
      path: RouteNames.dashboardFull,
    ),
    _Tab(
      icon: Icons.checklist_outlined,
      activeIcon: Icons.checklist_rounded,
      label: 'العمل',
      path: RouteNames.workFull,
    ),
    _Tab(
      icon: Icons.business_center_outlined,
      activeIcon: Icons.business_center_rounded,
      label: 'الأعمال',
      path: RouteNames.businessFull,
    ),
    _Tab(
      icon: Icons.insights_outlined,
      activeIcon: Icons.insights_rounded,
      label: 'الذكاء',
      path: RouteNames.insightsFull,
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
        bottomNavigationBar: wide
            ? null
            : _AzmBottomNav(
                tabs: _tabs,
                currentPath: location,
                palette: p,
              ),
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
          child: Row(
            children: [
              _NavItem(
                tab: tabs[0],
                isActive: _isActive(tabs[0].path),
                palette: p,
                onTap: () => context.go(tabs[0].path),
              ),
              _NavItem(
                tab: tabs[1],
                isActive: _isActive(tabs[1].path),
                palette: p,
                onTap: () => context.go(tabs[1].path),
              ),
              _CreateAction(
                palette: p,
                onTap: () => DashboardFab.showQuickAddMenu(context),
              ),
              _NavItem(
                tab: tabs[2],
                isActive: _isActive(tabs[2].path),
                palette: p,
                onTap: () => context.go(tabs[2].path),
              ),
              _NavItem(
                tab: tabs[3],
                isActive: _isActive(tabs[3].path),
                palette: p,
                onTap: () => context.go(tabs[3].path),
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

/// إجراء الإنشاء — على مستوى التطبيق لا الشاشة: أي كيان أساسي في خطوتين.
class _CreateAction extends StatefulWidget {
  const _CreateAction({required this.palette, required this.onTap});

  final AzmPalette palette;
  final VoidCallback onTap;

  @override
  State<_CreateAction> createState() => _CreateActionState();
}

class _CreateActionState extends State<_CreateAction> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.palette;

    return Expanded(
      child: Semantics(
        button: true,
        label: 'إنشاء',
        child: Center(
          child: GestureDetector(
            onTapDown: (_) => setState(() => _pressed = true),
            onTapUp: (_) {
              setState(() => _pressed = false);
              widget.onTap();
            },
            onTapCancel: () => setState(() => _pressed = false),
            child: AnimatedScale(
              scale: _pressed ? 0.92 : 1.0,
              duration: AzmMotion.instant,
              curve: AzmMotion.enter,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: p.accent,
                  borderRadius: BorderRadius.circular(AzmRadius.sm),
                ),
                child: Icon(
                  Icons.add_rounded,
                  color: p.onAccent,
                  size: 24,
                ),
              ),
            ),
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
