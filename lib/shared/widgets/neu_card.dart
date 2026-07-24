import 'package:flutter/material.dart';

import '../../core/theme/neu_decorations.dart';

/// Neumorphic Card Widget — the building block of the Mudiri UI.
///
/// Supports:
/// - Flat (default) and pressed states
/// - Gold accent top border (for dashboard cards)
/// - Status color right bar (for meetings/tasks, RTL-aware)
/// - Tap and long-press callbacks
class NeuCard extends StatefulWidget {
  const NeuCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.padding,
    this.margin,
    this.radius = 20,
    this.showGoldBorder = false,
    this.statusColor,
    this.isDark = false,
    this.animate = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final bool showGoldBorder;
  final Color? statusColor;
  final bool isDark;
  final bool animate;

  @override
  State<NeuCard> createState() => _NeuCardState();
}

class _NeuCardState extends State<NeuCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark =
        widget.isDark || Theme.of(context).brightness == Brightness.dark;

    BoxDecoration decoration;

    if (widget.showGoldBorder) {
      decoration = _isPressed
          ? NeuDecorations.neuPressed(radius: widget.radius, isDark: isDark)
          : NeuDecorations.neuFlatWithGoldTop(
              radius: widget.radius, isDark: isDark);
    } else if (widget.statusColor != null) {
      decoration = _isPressed
          ? NeuDecorations.neuPressed(radius: widget.radius, isDark: isDark)
          : NeuDecorations.neuFlatWithStatusBar(
              statusColor: widget.statusColor!,
              radius: widget.radius,
              isDark: isDark,
            );
    } else {
      decoration = _isPressed
          ? NeuDecorations.neuPressed(radius: widget.radius, isDark: isDark)
          : NeuDecorations.neuFlat(radius: widget.radius, isDark: isDark);
    }

    final card = AnimatedContainer(
      duration: widget.animate
          ? NeuDecorations.pressDuration
          : Duration.zero,
      curve: NeuDecorations.pressCurve,
      decoration: decoration,
      margin: widget.margin ?? const EdgeInsets.symmetric(vertical: 8),
      padding: widget.padding ?? const EdgeInsets.all(16),
      child: widget.child,
    );

    if (widget.onTap != null || widget.onLongPress != null) {
      return GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: card,
      );
    }

    return card;
  }
}