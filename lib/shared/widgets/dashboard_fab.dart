import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/route_names.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/neu_colors.dart';

/// Dashboard FAB — Floating Action Button with animated bottom menu.
///
/// Shows a (+) FAB at the bottom of the dashboard. On press, it opens
/// an animated bottom sheet with quick-add options for all ERP modules:
/// متابعة - اجتماع - عميل - مشروع - فاتورة - موظف - مصروف - إيراد - توجيه - موعد
class DashboardFab extends StatelessWidget {
  const DashboardFab({super.key});

  static const List<_FabAction> _actions = [
    _FabAction(
      label: 'متابعة',
      icon: Icons.task_alt_rounded,
      color: NeuColors.navyDeep,
      route: RouteNames.followupCreate,
    ),
    _FabAction(
      label: 'اجتماع',
      icon: Icons.groups_rounded,
      color: NeuColors.navyMid,
      route: RouteNames.meetingCreate,
    ),
    _FabAction(
      label: 'عميل',
      icon: Icons.supervisor_account_rounded,
      color: Color(0xFF00B894),
      route: RouteNames.clientCreate,
    ),
    _FabAction(
      label: 'مشروع',
      icon: Icons.work_rounded,
      color: Color(0xFFE17055),
      route: RouteNames.projectCreate,
    ),
    _FabAction(
      label: 'فاتورة',
      icon: Icons.receipt_long_rounded,
      color: NeuColors.success,
      route: RouteNames.invoiceCreate,
    ),
    _FabAction(
      label: 'موظف',
      icon: Icons.badge_rounded,
      color: Color(0xFF6C5CE7),
      route: RouteNames.employeeCreate,
    ),
    _FabAction(
      label: 'مصروف',
      icon: Icons.money_off_rounded,
      color: NeuColors.danger,
      route: RouteNames.expenseCreate,
    ),
    _FabAction(
      label: 'إيراد',
      icon: Icons.attach_money_rounded,
      color: NeuColors.goldDark,
      route: RouteNames.revenueCreate,
    ),
    _FabAction(
      label: 'توجيه',
      icon: Icons.assignment_rounded,
      color: NeuColors.warning,
      route: RouteNames.directiveCreate,
    ),
    _FabAction(
      label: 'موعد',
      icon: Icons.calendar_month_rounded,
      color: NeuColors.info,
      route: RouteNames.appointmentCreate,
    ),
    _FabAction(
      label: 'ملاحظة',
      icon: Icons.note_add_rounded,
      color: NeuColors.navyLight,
      route: RouteNames.noteCreate,
    ),
  ];


  void _showMenu(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withAlpha(120),
      isScrollControlled: true,
      builder: (ctx) => _FabMenuSheet(actions: _actions),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _AnimatedFabButton(isDark: isDark, onTap: () => _showMenu(context));
  }
}

// ─── Animated FAB Button ────────────────────────────────────────────────────

class _AnimatedFabButton extends StatefulWidget {
  const _AnimatedFabButton({required this.isDark, required this.onTap});
  final bool isDark;
  final VoidCallback onTap;

  @override
  State<_AnimatedFabButton> createState() => _AnimatedFabButtonState();
}

class _AnimatedFabButtonState extends State<_AnimatedFabButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(_) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _onTapUp(_) {
    setState(() => _isPressed = false);
    _controller.reverse();
    widget.onTap();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [NeuColors.navyMid, NeuColors.navyDeep],
            ),
            boxShadow: [
              BoxShadow(
                color: NeuColors.navyDeep.withAlpha(_isPressed ? 60 : 100),
                blurRadius: _isPressed ? 6 : 16,
                offset: Offset(0, _isPressed ? 2 : 6),
              ),
              if (!isDark)
                BoxShadow(
                  color: NeuColors.goldAccent.withAlpha(40),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Gold ring pulse
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: _isPressed ? 52 : 56,
                height: _isPressed ? 52 : 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: NeuColors.goldAccent.withAlpha(60),
                    width: 1.5,
                  ),
                ),
              ),
              const Icon(
                Icons.add_rounded,
                color: NeuColors.goldAccent,
                size: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Bottom Sheet Menu ───────────────────────────────────────────────────────

class _FabMenuSheet extends StatefulWidget {
  const _FabMenuSheet({required this.actions});
  final List<_FabAction> actions;

  @override
  State<_FabMenuSheet> createState() => _FabMenuSheetState();
}

class _FabMenuSheetState extends State<_FabMenuSheet>
    with TickerProviderStateMixin {
  late List<AnimationController> _itemControllers;
  late List<Animation<Offset>> _slideAnims;
  late List<Animation<double>> _fadeAnims;

  @override
  void initState() {
    super.initState();
    _itemControllers = List.generate(
      widget.actions.length,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 260),
      ),
    );
    _slideAnims = _itemControllers
        .map((c) => Tween<Offset>(
              begin: const Offset(0, 0.3),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: c, curve: Curves.easeOutCubic)))
        .toList();
    _fadeAnims = _itemControllers
        .map((c) => Tween<double>(begin: 0, end: 1)
            .animate(CurvedAnimation(parent: c, curve: Curves.easeOut)))
        .toList();

    // Staggered entrance animation
    for (int i = 0; i < _itemControllers.length; i++) {
      Future.delayed(Duration(milliseconds: 40 * i), () {
        if (mounted) _itemControllers[i].forward();
      });
    }
  }

  @override
  void dispose() {
    for (final c in _itemControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark ? NeuColors.bgColorDark : NeuColors.bgColor;
    final surfaceColor =
        isDark ? NeuColors.surfaceDark : NeuColors.surface;
    final dividerColor =
        isDark ? NeuColors.dividerDark : NeuColors.divider;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 80 : 40),
              blurRadius: 24,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: isDark
                            ? NeuColors.textSecondaryDark
                            : NeuColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            Divider(
                color: dividerColor, height: 1, indent: 24, endIndent: 24),
            const SizedBox(height: 8),

            // Action Grid — 4 columns, 2 rows
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 12,
                ),
                itemCount: widget.actions.length,
                itemBuilder: (ctx, i) {
                  return SlideTransition(
                    position: _slideAnims[i],
                    child: FadeTransition(
                      opacity: _fadeAnims[i],
                      child: _FabActionItem(
                        action: widget.actions[i],
                        isDark: isDark,
                        onTap: () {
                          Navigator.pop(ctx);
                          // Small delay to let sheet close smoothly
                          Future.delayed(
                            const Duration(milliseconds: 80),
                            () {
                              if (ctx.mounted) {
                                final route = widget.actions[i].route;
                                if (route.startsWith('/home/')) {
                                  ctx.go(route);
                                } else {
                                  ctx.push(route);
                                }
                              }
                            },
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),

            // Bottom safe area
            SizedBox(
              height:
                  MediaQuery.of(context).padding.bottom + 16,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Action Item Cell ─────────────────────────────────────────────────────────

class _FabActionItem extends StatefulWidget {
  const _FabActionItem({
    required this.action,
    required this.isDark,
    required this.onTap,
  });

  final _FabAction action;
  final bool isDark;
  final VoidCallback onTap;

  @override
  State<_FabActionItem> createState() => _FabActionItemState();
}

class _FabActionItemState extends State<_FabActionItem> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final bgBase =
        isDark ? NeuColors.surfaceDark : NeuColors.surface;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        decoration: BoxDecoration(
          color: _pressed
              ? widget.action.color.withAlpha(isDark ? 30 : 20)
              : bgBase,
          borderRadius: BorderRadius.circular(16),
          boxShadow: _pressed
              ? []
              : [
                  BoxShadow(
                    color: isDark
                        ? NeuColors.shadowDarkDark
                        : NeuColors.shadowDark,
                    blurRadius: 6,
                    offset: const Offset(3, 3),
                  ),
                  BoxShadow(
                    color: isDark
                        ? NeuColors.shadowLightDark
                        : NeuColors.shadowLight,
                    blurRadius: 6,
                    offset: const Offset(-3, -3),
                  ),
                ],
          border: _pressed
              ? Border.all(
                  color: widget.action.color.withAlpha(80),
                  width: 1.5)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              padding: EdgeInsets.all(_pressed ? 10 : 12),
              decoration: BoxDecoration(
                color: widget.action.color.withAlpha(isDark ? 25 : 18),
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.action.icon,
                color: widget.action.color,
                size: 22,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.action.label,
              style: AppTypography.caption.copyWith(
                color: isDark
                    ? NeuColors.textPrimaryDark
                    : NeuColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Data Model ──────────────────────────────────────────────────────────────

class _FabAction {
  const _FabAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.route,
  });

  final String label;
  final IconData icon;
  final Color color;
  final String route;
}