import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/design/azm_tokens.dart';
import '../../core/navigation/azm_nav_model.dart';
import '../../core/router/route_names.dart';
import '../../core/theme/app_typography.dart';
import '../../features/company/providers/company_providers.dart';
import 'app_logo.dart';

/// AZM — الشريط الجانبي
///
/// مصدره الوحيد [AzmNav]، فيعرض الشجرة نفسها على الجوال (كدرج) وعلى
/// الشاشات العريضة (كلوح ثابت).
///
/// المجموعات مطويّة افتراضيًا وتُفتح واحدة فقط: عرض ست مجموعات مفتوحة
/// دفعةً واحدة يضع ٤٠ وجهة أمام العين ويعيد المشكلة التي جاء الشريط
/// ليحلّها. المجموعة التي يقع فيها المسار الحالي تُفتح تلقائيًا.
class AzmSidebar extends ConsumerStatefulWidget {
  const AzmSidebar({
    super.key,
    required this.currentLocation,
    this.isDrawer = true,
  });

  /// المسار الحالي — يحدّد البند النشط والمجموعة المفتوحة
  final String currentLocation;

  /// درج على الجوال، ولوح ثابت على الشاشات العريضة
  final bool isDrawer;

  @override
  ConsumerState<AzmSidebar> createState() => _AzmSidebarState();
}

class _AzmSidebarState extends ConsumerState<AzmSidebar> {
  /// المجموعة المفتوحة حاليًا — واحدة على الأكثر
  String? _openGroup;

  @override
  void initState() {
    super.initState();
    _openGroup = AzmNav.groupFor(widget.currentLocation)?.label;
  }

  @override
  void didUpdateWidget(AzmSidebar old) {
    super.didUpdateWidget(old);
    // انتقال إلى وجهة في مجموعة أخرى يفتحها ويطوي السابقة
    if (old.currentLocation != widget.currentLocation) {
      final g = AzmNav.groupFor(widget.currentLocation);
      if (g != null) _openGroup = g.label;
    }
  }

  bool _isActive(String route) {
    if (route == RouteNames.dashboardFull) {
      return widget.currentLocation == RouteNames.dashboardFull;
    }
    return widget.currentLocation.startsWith(route);
  }

  void _navigate(NavDestination dest) {
    // الدرج يُغلق قبل الانتقال حتى لا يبقى فوق الشاشة الجديدة
    if (widget.isDrawer) Navigator.of(context).maybePop();

    if (dest.isShellTab) {
      context.go(dest.route);
    } else {
      context.push(dest.route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);
    final company = ref.watch(activeCompanyProvider);

    final panel = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SidebarHeader(companyName: company?.name),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: AzmSpace.sm),
            children: [
              // الرئيسية — بلا مجموعة، فهي ليست فرعًا من شيء
              _DestinationTile(
                destination: AzmNav.home,
                isActive: _isActive(AzmNav.home.route),
                onTap: () => _navigate(AzmNav.home),
                topLevel: true,
              ),
              const SizedBox(height: AzmSpace.xs),
              _Divider(color: p.hairline),

              for (final group in AzmNav.groups)
                _GroupTile(
                  group: group,
                  isOpen: _openGroup == group.label,
                  hasActiveChild: group.contains(widget.currentLocation),
                  onToggle: () => setState(
                    () => _openGroup =
                        _openGroup == group.label ? null : group.label,
                  ),
                  isActive: _isActive,
                  onSelect: _navigate,
                ),

              _Divider(color: p.hairline),
              const SizedBox(height: AzmSpace.xs),
              _SectionLabel(text: 'النظام'),
              for (final dest in AzmNav.system)
                _DestinationTile(
                  destination: dest,
                  isActive: _isActive(dest.route),
                  onTap: () => _navigate(dest),
                  topLevel: true,
                ),
              const SizedBox(height: AzmSpace.xl),
            ],
          ),
        ),
        _SidebarFooter(companyName: company?.name),
      ],
    );

    if (!widget.isDrawer) {
      return Container(
        width: 288,
        decoration: BoxDecoration(
          color: p.surface,
          border: Border(left: BorderSide(color: p.hairline)),
        ),
        child: SafeArea(right: false, child: panel),
      );
    }

    return Drawer(
      backgroundColor: p.surface,
      width: 300,
      shape: const RoundedRectangleBorder(),
      child: SafeArea(bottom: false, child: panel),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────────────────

class _SidebarHeader extends StatelessWidget {
  const _SidebarHeader({this.companyName});

  final String? companyName;

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);
    final isDark = p.isDark;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AzmSpace.lg,
        AzmSpace.lg,
        AzmSpace.lg,
        AzmSpace.lg,
      ),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: p.hairline)),
      ),
      child: Row(
        children: [
          AppLogoMark(size: 44, isDark: isDark),
          const SizedBox(width: AzmSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppConstants.appNameAr,
                  style: AppTypography.h3.copyWith(
                    color: p.ink,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  // اسم الشركة حين توجد، وإلا وصف المنتج — لا فراغ
                  companyName ?? AppConstants.appDescriptionAr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption.copyWith(color: p.inkFaint),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Group
// ─────────────────────────────────────────────────────────────

class _GroupTile extends StatelessWidget {
  const _GroupTile({
    required this.group,
    required this.isOpen,
    required this.hasActiveChild,
    required this.onToggle,
    required this.isActive,
    required this.onSelect,
  });

  final NavGroup group;
  final bool isOpen;

  /// المسار الحالي داخل هذه المجموعة — تُميَّز حتى وهي مطويّة
  final bool hasActiveChild;

  final VoidCallback onToggle;
  final bool Function(String route) isActive;
  final void Function(NavDestination) onSelect;

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);
    final headerColor = hasActiveChild ? p.accent : p.ink;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          button: true,
          expanded: isOpen,
          label: '${group.label} — ${group.question}',
          child: InkWell(
            onTap: onToggle,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AzmSpace.lg,
                vertical: AzmSpace.md,
              ),
              child: Row(
                children: [
                  Icon(group.icon, size: 19, color: headerColor),
                  const SizedBox(width: AzmSpace.md),
                  Expanded(
                    child: Text(
                      group.label,
                      style: AppTypography.body.copyWith(
                        color: headerColor,
                        fontWeight:
                            hasActiveChild ? FontWeight.w700 : FontWeight.w600,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: isOpen ? 0.25 : 0,
                    duration: AzmMotion.instant,
                    child: Icon(
                      // في RTL يُعكس السهم تلقائيًا فيشير يسارًا وهو مطويّ
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: p.inkFaint,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // المجموعة المطويّة لا تُبنى أصلًا.
        //
        // `AnimatedCrossFade` كان يُبقي الطفلين في الشجرة معًا، فتُبنى
        // وجهات المجموعات الست كلها (٤٦ صفًّا) في كل إعادة رسم وإن لم
        // يُعرض منها إلا سبعة — وتبقى قابلة للعثور عليها برمجيًا وهي
        // مخفيّة. البناء الشرطي يحلّ الأمرين.
        AnimatedSize(
          duration: AzmMotion.standard,
          curve: AzmMotion.enter,
          alignment: Alignment.topCenter,
          child: isOpen
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final dest in group.destinations)
                      _DestinationTile(
                        destination: dest,
                        isActive: isActive(dest.route),
                        onTap: () => onSelect(dest),
                        topLevel: false,
                      ),
                    const SizedBox(height: AzmSpace.xs),
                  ],
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Destination
// ─────────────────────────────────────────────────────────────

class _DestinationTile extends StatelessWidget {
  const _DestinationTile({
    required this.destination,
    required this.isActive,
    required this.onTap,
    required this.topLevel,
  });

  final NavDestination destination;
  final bool isActive;
  final VoidCallback onTap;

  /// بنود المستوى الأعلى بلا إزاحة؛ وبنود المجموعات مزاحة لتقرأ كفروع
  final bool topLevel;

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);
    final color = isActive ? p.accent : p.inkMuted;

    return Semantics(
      button: true,
      selected: isActive,
      label: destination.label,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          padding: EdgeInsetsDirectional.fromSTEB(
            topLevel ? AzmSpace.lg : AzmSpace.xxl,
            AzmSpace.sm,
            AzmSpace.lg,
            AzmSpace.sm,
          ),
          decoration: BoxDecoration(
            // شريط حبري على الحافة البادئة بدل تعبئة كاملة: يميّز البند
            // النشط دون أن يحوّل الصف إلى كتلة لونية
            border: BorderDirectional(
              start: BorderSide(
                color: isActive ? p.accent : Colors.transparent,
                width: 3,
              ),
            ),
            color: isActive
                ? p.accent.withValues(alpha: p.isDark ? 0.14 : 0.07)
                : null,
          ),
          child: Row(
            children: [
              Icon(destination.icon, size: 18, color: color),
              const SizedBox(width: AzmSpace.md),
              Expanded(
                child: Text(
                  destination.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmall.copyWith(
                    color: color,
                    fontWeight:
                        isActive ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 13.5,
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

// ─────────────────────────────────────────────────────────────
// Footer
// ─────────────────────────────────────────────────────────────

class _SidebarFooter extends StatelessWidget {
  const _SidebarFooter({this.companyName});

  final String? companyName;

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AzmSpace.lg,
        vertical: AzmSpace.md,
      ),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: p.hairline)),
      ),
      child: SafeArea(
        top: false,
        child: InkWell(
          onTap: () => context.push(RouteNames.account),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AzmSpace.xs),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: p.surfaceSunken,
                    shape: BoxShape.circle,
                    border: Border.all(color: p.hairline),
                  ),
                  child: Icon(
                    Icons.person_outline_rounded,
                    size: 18,
                    color: p.inkMuted,
                  ),
                ),
                const SizedBox(width: AzmSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'الحساب',
                        style: AppTypography.bodySmall.copyWith(
                          color: p.ink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        companyName ?? 'وضع شخصي',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.caption
                            .copyWith(color: p.inkFaint, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: p.inkGhost,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Bits
// ─────────────────────────────────────────────────────────────

class _Divider extends StatelessWidget {
  const _Divider({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AzmSpace.lg,
          vertical: AzmSpace.xs,
        ),
        child: Container(height: 1, color: color),
      );
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AzmSpace.lg,
        AzmSpace.sm,
        AzmSpace.lg,
        AzmSpace.xs,
      ),
      child: Text(
        text,
        style: AppTypography.caption.copyWith(
          color: p.inkFaint,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}
