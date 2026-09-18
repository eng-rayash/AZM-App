import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/neu_colors.dart';
import '../../core/theme/neu_decorations.dart';

/// Neumorphic Button — primary interaction element.
///
/// Variants:
/// - Primary (navy background, white text)
/// - Secondary (outlined, navy text)
/// - Danger (red background, white text)
/// - Gold (gold accent, for special actions)
///
/// Features animated press effect (150ms).
enum NeuButtonVariant { primary, secondary, danger, gold }

class NeuButton extends StatefulWidget {
  const NeuButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = NeuButtonVariant.primary,
    this.isLoading = false,
    this.isExpanded = true,
    this.radius = 16,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final NeuButtonVariant variant;
  final bool isLoading;
  final bool isExpanded;
  final double radius;

  @override
  State<NeuButton> createState() => _NeuButtonState();
}

class _NeuButtonState extends State<NeuButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDisabled = widget.onPressed == null || widget.isLoading;

    final (bgColor, textColor, borderColor) = _getColors(isDark);

    final decoration = _isPressed && !isDisabled
        ? NeuDecorations.neuPressed(
            radius: widget.radius,
            isDark: isDark,
          ).copyWith(color: bgColor)
        : NeuDecorations.neuFlatSoft(
            radius: widget.radius,
            isDark: isDark,
            color: bgColor,
          );

    final content = Row(
      mainAxisSize: widget.isExpanded ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading) ...[
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(textColor),
            ),
          ),
          AppSpacing.gapHMd,
        ] else if (widget.icon != null) ...[
          Icon(widget.icon, color: textColor, size: 20),
          AppSpacing.gapHSm,
        ],
        Flexible(
          child: Text(
            widget.label,
            style: AppTypography.button.copyWith(color: textColor),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );

    return GestureDetector(
      onTapDown: isDisabled ? null : (_) => setState(() => _isPressed = true),
      onTapUp: isDisabled ? null : (_) => setState(() => _isPressed = false),
      onTapCancel: isDisabled ? null : () => setState(() => _isPressed = false),
      onTap: isDisabled ? null : widget.onPressed,
      child: AnimatedContainer(
        duration: NeuDecorations.pressDuration,
        curve: NeuDecorations.pressCurve,
        decoration: decoration.copyWith(
          border: borderColor != null
              ? Border.all(color: borderColor, width: 1.5)
              : null,
        ),
        padding: AppSpacing.button,
        child: AnimatedOpacity(
          duration: NeuDecorations.pressDuration,
          opacity: isDisabled ? 0.5 : 1.0,
          child: content,
        ),
      ),
    );
  }

  (Color bg, Color text, Color? border) _getColors(bool isDark) {
    return switch (widget.variant) {
      NeuButtonVariant.primary => (
          NeuColors.navyDeep,
          NeuColors.textOnDark,
          null,
        ),
      NeuButtonVariant.secondary => (
          isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
          isDark ? NeuColors.textPrimaryDark : NeuColors.navyDeep,
          isDark ? NeuColors.textPrimaryDark : NeuColors.navyDeep,
        ),
      NeuButtonVariant.danger => (
          NeuColors.danger,
          NeuColors.textOnDark,
          null,
        ),
      NeuButtonVariant.gold => (
          NeuColors.accentMuted,
          NeuColors.textOnDark,
          null,
        ),
    };
  }
}