import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/neu_colors.dart';
import 'neu_button.dart';

/// Empty State Widget — shown when a list has no data.
///
/// Displays icon + title + subtitle + optional action button.
/// All within Neumorphic design language.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? NeuColors.surfaceDark
                    : NeuColors.surface,
              ),
              child: Icon(
                icon,
                size: 48,
                color: isDark
                    ? NeuColors.textHintDark
                    : NeuColors.textHint,
              ),
            ),
            AppSpacing.gapXxl,
            Text(
              title,
              style: (isDark ? AppTypography.h3Dark : AppTypography.h3)
                  .copyWith(
                color: isDark
                    ? NeuColors.textSecondaryDark
                    : NeuColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              AppSpacing.gapSm,
              Text(
                subtitle!,
                style: (isDark
                        ? AppTypography.bodySmallDark
                        : AppTypography.bodySmall)
                    .copyWith(
                  color: isDark
                      ? NeuColors.textHintDark
                      : NeuColors.textHint,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              AppSpacing.gapXxl,
              NeuButton(
                label: actionLabel!,
                onPressed: onAction,
                variant: NeuButtonVariant.primary,
                isExpanded: false,
                icon: Icons.add_rounded,
              ),
            ],
          ],
        ),
      ),
    );
  }
}