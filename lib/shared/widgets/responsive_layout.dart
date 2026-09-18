import 'package:flutter/material.dart';
import '../../core/theme/app_typography.dart';
import 'app_logo.dart';

/// RVIOS — Responsive Layout System
///
/// Provides breakpoint-aware layout that adapts across:
/// - Mobile  (<600px)  -> BottomNavigationBar
/// - Tablet  (600-1200px) -> NavigationRail (side icons)
/// - Desktop (>1200px) -> Full Sidebar with labels
///
/// Usage:
/// ```dart
/// ResponsiveLayout(
///   mobile: MobileView(),
///   tablet: TabletView(),
///   desktop: DesktopView(),
/// )
/// ```
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  // ─────────────────────────────────────────────────────────────
  // Breakpoints
  // ─────────────────────────────────────────────────────────────
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1200;

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < mobileBreakpoint;

  static bool isTablet(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return w >= mobileBreakpoint && w < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tabletBreakpoint;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= tabletBreakpoint) {
          return desktop ?? tablet ?? mobile;
        }
        if (constraints.maxWidth >= mobileBreakpoint) {
          return tablet ?? mobile;
        }
        return mobile;
      },
    );
  }
}

/// Sidebar Navigation for Web/Desktop
///
/// Full left sidebar with logo, company name, navigation items,
/// and user profile at the bottom.
class SidebarNavigation extends StatelessWidget {
  const SidebarNavigation({
    super.key,
    required this.child,
    required this.navItems,
    required this.currentPath,
    required this.companyName,
    this.onItemSelected,
  });

  final Widget child;
  final List<SidebarItem> navItems;
  final String currentPath;
  final String companyName;
  final ValueChanged<String>? onItemSelected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Row(
        children: [
          // ── Sidebar ───────────────────────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 240,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
              border: Border(
                left: BorderSide(
                  color: isDark
                      ? const Color(0xFF2A2A2A)
                      : const Color(0xFFEEEEEE),
                ),
              ),
            ),
            child: Column(
              children: [
                // ── Header ──────────────────────────────────────
                Container(
                  height: 72,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF9E2226), Color(0xFF7A1A1D)],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                  ),
                  child: Row(
                    children: [
                      const AzmMark(size: 38, isDark: true),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'AZM',
                              style: TextStyle(
                                fontFamily:
                                    AppTypography.fontFamilyGivonic,
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                                letterSpacing: 5,
                              ),
                            ),
                            Text(
                              companyName,
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamilyPanorama,
                                fontSize: 11,
                                color: Colors.white70,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ————————————————————————————————————————————————
                Expanded(
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      children: navItems.map((item) {
                        final isActive = currentPath.startsWith(item.route);
                        return _SidebarNavItem(
                          item: item,
                          isActive: isActive,
                          isDark: isDark,
                          onTap: () => onItemSelected?.call(item.route),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                // ————————————————————————————————————————————————
                Divider(
                  color: isDark
                      ? const Color(0xFF2A2A2A)
                      : const Color(0xFFEEEEEE),
                  height: 1,
                ),
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: ListTile(
                    leading: const Icon(Icons.settings_outlined,
                        color: Color(0xFF6B6B6B), size: 20),
                    title: Text(
                      'الإعدادات',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamilyPanorama,
                        fontSize: 13,
                        color: const Color(0xFF6B6B6B),
                      ),
                    ),
                    onTap: () => onItemSelected?.call('/settings'),
                  ),
                ),
              ],
            ),
          ),

          // ————————————————————————————————————————————————
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _SidebarNavItem extends StatelessWidget {
  const _SidebarNavItem({
    required this.item,
    required this.isActive,
    required this.isDark,
    required this.onTap,
  });

  final SidebarItem item;
  final bool isActive;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFFF5E0E1) // primaryTint
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  isActive ? item.activeIcon : item.icon,
                  color: isActive
                      ? const Color(0xFF9E2226)
                      : (isDark
                          ? const Color(0xFF9E9E9E)
                          : const Color(0xFF6B6B6B)),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.label,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamilyPanorama,
                      fontSize: 13,
                      fontWeight:
                          isActive ? FontWeight.w700 : FontWeight.w500,
                      color: isActive
                          ? const Color(0xFF9E2226)
                          : (isDark
                              ? const Color(0xFF9E9E9E)
                              : const Color(0xFF6B6B6B)),
                    ),
                  ),
                ),
                if (item.badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF9E2226),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${item.badge}',
                      style: const TextStyle(
                        fontFamily: AppTypography.fontFamilyPanorama,
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Sidebar navigation item definition
class SidebarItem {
  const SidebarItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.route,
    this.badge,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;
  final int? badge;
}