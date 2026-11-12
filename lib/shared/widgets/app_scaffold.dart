import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/design/azm_tokens.dart';
import '../../core/navigation/azm_nav_model.dart';
import '../../core/router/route_names.dart';
import '../../core/theme/app_typography.dart';
import '../../features/store_app/store_routes.dart';
import 'azm_sidebar.dart';

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
  /// عزم للتاجر: المتجر أولًا (المتجر · الطلبات · المنتجات)، ثم وحدات
  /// الأعمال التي تساعده على إدارة عمله (الأعمال · اليوم). بقية الوحدات في
  /// الشريط الجانبي.
  static const _tabs = <_Tab>[
    _Tab(
      icon: Icons.storefront_outlined,
      activeIcon: Icons.storefront_rounded,
      label: 'المتجر',
      path: StoreRoutes.home,
    ),
    _Tab(
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long_rounded,
      label: 'الطلبات',
      path: StoreRoutes.orders,
    ),
    _Tab(
      icon: Icons.inventory_2_outlined,
      activeIcon: Icons.inventory_2_rounded,
      label: 'المنتجات',
      path: StoreRoutes.products,
    ),
    _Tab(
      icon: Icons.business_center_outlined,
      activeIcon: Icons.business_center_rounded,
      label: 'أعمالي',
      path: RouteNames.businessFull,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);
    final location = GoRouterState.of(context).uri.path;
    final wide = AzmBreakpoint.hasSidebar(context);

    return PopScope(
      canPop: location == StoreRoutes.home,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (location != StoreRoutes.home) {
          context.go(StoreRoutes.home);
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
        // شاشات المتجر لها أزرارها (منتج جديد، تبديل المتجر) — لا زرّ عائم فوقها
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
    if (location == StoreRoutes.home) return AzmNav.home.label;
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
                icon: Icons.notifications_none_rounded,
                tooltip: 'الإشعارات',
                onTap: () => context.push(StoreRoutes.notifications),
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
    if (path == StoreRoutes.home) {
      return currentPath == path;
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
