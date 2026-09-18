import 'package:flutter/material.dart';

import '../../core/theme/app_typography.dart';
import '../../core/theme/neu_colors.dart';
import 'neu_button.dart';

/// Failure state for a screen or section whose data could not be loaded.
///
/// Replaces the bare `Text('خطأ: $e')` that used to dump a raw Dart exception
/// into the interface: the reader gets a plain sentence and a retry, while the
/// technical detail stays available behind a disclosure for support.
class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    this.title = 'تعذّر تحميل البيانات',
    this.message,
    this.error,
    this.onRetry,
    this.compact = false,
  });

  /// Headline shown to the reader.
  final String title;

  /// Optional plain-language explanation under the headline.
  final String? message;

  /// The underlying error, shown only inside the technical details panel.
  final Object? error;

  final VoidCallback? onRetry;

  /// Tighter layout for use inside a card or list section.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary =
        isDark ? NeuColors.textSecondaryDark : NeuColors.textSecondary;
    final hint = isDark ? NeuColors.textHintDark : NeuColors.textHint;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(compact ? 20 : 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(compact ? 14 : 20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: NeuColors.danger.withValues(alpha: 0.10),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: compact ? 28 : 40,
                color: NeuColors.danger,
              ),
            ),
            SizedBox(height: compact ? 12 : 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: (isDark ? AppTypography.h4Dark : AppTypography.h4)
                  .copyWith(fontSize: compact ? 14 : 16),
            ),
            if (message != null) ...[
              const SizedBox(height: 6),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall.copyWith(color: textSecondary),
              ),
            ],
            if (onRetry != null) ...[
              SizedBox(height: compact ? 14 : 22),
              NeuButton(
                label: 'إعادة المحاولة',
                onPressed: onRetry,
                variant: NeuButtonVariant.primary,
                isExpanded: false,
                icon: Icons.refresh_rounded,
              ),
            ],
            if (error != null) ...[
              const SizedBox(height: 10),
              Theme(
                data: Theme.of(context)
                    .copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: EdgeInsets.zero,
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  title: Text(
                    'تفاصيل تقنية',
                    textAlign: TextAlign.center,
                    style: AppTypography.caption.copyWith(color: hint),
                  ),
                  children: [
                    SelectableText(
                      '$error',
                      textAlign: TextAlign.center,
                      style: AppTypography.caption.copyWith(color: hint),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
