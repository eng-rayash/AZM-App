import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/route_names.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/neu_colors.dart';
import '../../core/theme/neu_decorations.dart';

/// App Shell Scaffold — ERP bottom navigation wrapper.
///
/// 5-tab navigation:
/// 1. لوحة التحكم  (Dashboard)
/// 2. المتابعات    (Follow-ups — merged Tasks here)
/// 3. شؤون العاملين (HRM)
/// 4. المالية      (Finance)
/// 5. المزيد       (More)
class AppShellScaffold extends StatelessWidget {
  const AppShellScaffold({
    super.key,
    required this.child,
  });

  final Widget child;

  static const _navItems = [
    _NavItem(
      icon: Icons.dashboard_rounded,
      activeIcon: Icons.dashboard_rounded,
      label: 'الرئيسية',
      path: RouteNames.dashboardFull,
    ),
    _NavItem(
      icon: Icons.task_alt_rounded,
      activeIcon: Icons.task_alt_rounded,
      label: 'المتابعات',
      path: RouteNames.followupsListFull,
    ),
    _NavItem(
      icon: Icons.people_alt_rounded,
      activeIcon: Icons.people_alt_rounded,
      label: 'العاملون',
      path: RouteNames.hrmFull,
    ),
    _NavItem(
      icon: Icons.account_balance_wallet_rounded,
      activeIcon: Icons.account_balance_wallet_rounded,
      label: 'المالية',
      path: RouteNames.financeFull,
    ),
    _NavItem(
      icon: Icons.grid_view_rounded,
      activeIcon: Icons.grid_view_rounded,
      label: 'المزيد',
      path: RouteNames.moreFull,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentPath = GoRouterState.of(context).uri.path;

    return PopScope(
      canPop: currentPath == RouteNames.dashboardFull,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (currentPath != RouteNames.dashboardFull) {
          context.go(RouteNames.dashboardFull);
        }
      },
      child: Scaffold(
        body: child,
        bottomNavigationBar: _ERPBottomNav(
          items: _navItems,
          currentPath: currentPath,
          isDark: isDark,
        ),
      ),
    );
  }
}

/// Custom ERP-style bottom navigation bar.
class _ERPBottomNav extends StatelessWidget {
  const _ERPBottomNav({
    required this.items,
    required this.currentPath,
    required this.isDark,
  });

  final List<_NavItem> items;
  final String currentPath;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
        boxShadow: [
          BoxShadow(
            color: NeuColors.darkShadow(isDark ? Brightness.dark : Brightness.light)
                .withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: items.map((item) {
              final isSelected = _isSelected(currentPath, item.path);
              return _NavBarItem(
                item: item,
                isSelected: isSelected,
                isDark: isDark,
                onTap: () => context.go(item.path),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  bool _isSelected(String currentPath, String itemPath) {
    if (itemPath == RouteNames.dashboardFull) {
      return currentPath == RouteNames.dashboardFull;
    }
    return currentPath.startsWith(itemPath.replaceAll('/home/', '/home/'));
  }
}

/// Individual navigation bar item.
class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.item,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  final _NavItem item;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final activeColor = isDark ? NeuColors.goldAccent : NeuColors.navyDeep;
    final inactiveColor = NeuColors.textHint;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: NeuDecorations.pressDuration,
          curve: NeuDecorations.pressCurve,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          decoration: isSelected
              ? NeuDecorations.neuPressed(radius: 12, isDark: isDark)
              : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Indicator dot
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: isSelected ? 20 : 0,
                height: 3,
                margin: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  color: isSelected ? activeColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Icon(
                isSelected ? item.activeIcon : item.icon,
                size: 22,
                color: isSelected ? activeColor : inactiveColor,
              ),
              const SizedBox(height: 3),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  item.label,
                  style: AppTypography.navLabel.copyWith(
                    color: isSelected ? activeColor : inactiveColor,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
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
