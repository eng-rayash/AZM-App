import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/neu_colors.dart';
import '../../core/theme/neu_decorations.dart';

/// Neumorphic Input Field — concave sunken text field.
///
/// Features:
/// - Concave Neumorphic decoration
/// - Floating Arabic label
/// - RTL-optimized
/// - Validation states with error display
class NeuInput extends StatelessWidget {
  const NeuInput({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
    this.minLines,
    this.obscureText = false,
    this.enabled = true,
    this.autofocus = false,
    this.focusNode,
    this.radius = 16,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? errorText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int maxLines;
  final int? minLines;
  final bool obscureText;
  final bool enabled;
  final bool autofocus;
  final FocusNode? focusNode;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: isDark ? AppTypography.labelDark : AppTypography.label,
          ),
          AppSpacing.gapSm,
        ],
        AnimatedContainer(
          duration: NeuDecorations.pressDuration,
          decoration: NeuDecorations.neuConcave(
            radius: radius,
            isDark: isDark,
          ),
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            onChanged: onChanged,
            onFieldSubmitted: onSubmitted,
            validator: validator,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            maxLines: maxLines,
            minLines: minLines,
            obscureText: obscureText,
            enabled: enabled,
            autofocus: autofocus,
            textDirection: TextDirection.rtl,
            style: isDark ? AppTypography.bodyDark : AppTypography.body,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTypography.body.copyWith(
                color: isDark ? NeuColors.textHintDark : NeuColors.textHint,
              ),
              prefixIcon: prefixIcon != null
                  ? Icon(
                      prefixIcon,
                      color: isDark ? NeuColors.textSecondaryDark : NeuColors.textSecondary,
                      size: 20,
                    )
                  : null,
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              contentPadding: AppSpacing.input,
            ),
          ),
        ),
        if (errorText != null) ...[
          AppSpacing.gapXs,
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 12),
            child: Text(
              errorText!,
              style: AppTypography.caption.copyWith(color: NeuColors.danger),
            ),
          ),
        ],
      ],
    );
  }
}