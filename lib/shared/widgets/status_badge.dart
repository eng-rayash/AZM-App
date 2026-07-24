import 'package:flutter/material.dart';

import '../../core/theme/app_typography.dart';
import '../../core/theme/neu_colors.dart';

/// Status Badge — color-coded status indicator.
///
/// Used across meetings, tasks, follow-ups, and directives.
/// Displays Arabic status labels with matching colors.
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.isSmall = false,
  });

  final String label;
  final Color color;
  final bool isSmall;

  /// Factory constructors for common meeting statuses
  factory StatusBadge.scheduled() => const StatusBadge(
        label: 'مجدول',
        color: NeuColors.info,
      );

  factory StatusBadge.inProgress() => const StatusBadge(
        label: 'قيد التنفيذ',
        color: NeuColors.warning,
      );

  factory StatusBadge.completed() => const StatusBadge(
        label: 'مكتمل',
        color: NeuColors.success,
      );

  factory StatusBadge.postponed() => const StatusBadge(
        label: 'مؤجل',
        color: NeuColors.warning,
      );

  factory StatusBadge.cancelled() => const StatusBadge(
        label: 'ملغي',
        color: NeuColors.danger,
      );

  factory StatusBadge.overdue() => const StatusBadge(
        label: 'متأخر',
        color: NeuColors.danger,
      );

  factory StatusBadge.stalled() => const StatusBadge(
        label: 'متعثر',
        color: NeuColors.danger,
      );

  factory StatusBadge.newItem() => const StatusBadge(
        label: 'جديد',
        color: NeuColors.info,
      );

  factory StatusBadge.awaitingResponse() => const StatusBadge(
        label: 'بانتظار الرد',
        color: NeuColors.warning,
      );

  /// Create from meeting status value
  factory StatusBadge.fromMeetingStatus(int status) {
    return switch (status) {
      0 => StatusBadge.scheduled(),
      1 => StatusBadge.inProgress(),
      2 => StatusBadge.completed(),
      3 => StatusBadge.postponed(),
      4 => StatusBadge.cancelled(),
      _ => StatusBadge.scheduled(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 8 : 12,
        vertical: isSmall ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(isSmall ? 6 : 8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: (isSmall ? AppTypography.caption : AppTypography.bodySmall)
            .copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}