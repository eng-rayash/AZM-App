import 'package:flutter/material.dart';

import '../../../core/constants/enums.dart';
import '../../../core/database/app_database.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../shared/widgets/neu_card.dart';

/// Directive Card — Neumorphic card for directive list items.
///
/// Displays: title, assigned entity, deadline, status badge, progress bar.
class DirectiveCard extends StatelessWidget {
  const DirectiveCard({
    super.key,
    required this.directive,
    this.onTap,
  });

  final Directive directive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final status = UnifiedStatus.fromValue(directive.status);
    final priority = Priority.fromValue(directive.priority);
    final statusColor = _statusColor(status);

    return NeuCard(
      onTap: onTap,
      statusColor: statusColor,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + Priority
          Row(
            children: [
              Expanded(
                child: Text(
                  directive.title,
                  style: isDark ? AppTypography.h4Dark : AppTypography.h4,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _buildPriorityBadge(priority, isDark),
            ],
          ),

          AppSpacing.gapSm,

          // Assigned to
          if (directive.assignedTo != null &&
              directive.assignedTo!.isNotEmpty) ...[
            Row(
              children: [
                Icon(
                  Icons.person_outline_rounded,
                  size: 16,
                  color: isDark
                      ? NeuColors.textSecondaryDark
                      : NeuColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  directive.assignedTo!,
                  style: isDark
                      ? AppTypography.bodySmallDark
                      : AppTypography.bodySmall,
                ),
              ],
            ),
            AppSpacing.gapXs,
          ],

          // Deadline
          if (directive.deadline != null &&
              directive.deadline!.isNotEmpty) ...[
            Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 16,
                  color: isDark
                      ? NeuColors.textSecondaryDark
                      : NeuColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  directive.deadline!,
                  style: isDark
                      ? AppTypography.captionDark
                      : AppTypography.caption,
                ),
              ],
            ),
            AppSpacing.gapSm,
          ],

          // Status badge + Progress
          Row(
            children: [
              _buildStatusBadge(status, isDark),
              const Spacer(),
              // Neumorphic progress bar
              SizedBox(
                width: 100,
                child: _buildProgressBar(status, isDark),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityBadge(Priority priority, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _priorityColor(priority).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        priority.arabicLabel,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _priorityColor(priority),
          fontFamily: 'Panorama',
        ),
      ),
    );
  }

  Widget _buildStatusBadge(UnifiedStatus status, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _statusColor(status).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.arabicLabel,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _statusColor(status),
          fontFamily: 'Panorama',
        ),
      ),
    );
  }

  Widget _buildProgressBar(UnifiedStatus status, bool isDark) {
    final progress = _statusProgress(status);
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: LinearProgressIndicator(
        value: progress,
        minHeight: 6,
        backgroundColor:
            isDark ? NeuColors.surfaceDark : NeuColors.divider,
        valueColor: AlwaysStoppedAnimation<Color>(
          _statusColor(status),
        ),
      ),
    );
  }

  Color _statusColor(UnifiedStatus status) {
    switch (status) {
      case UnifiedStatus.newItem:
        return NeuColors.info;
      case UnifiedStatus.inProgress:
        return NeuColors.warning;
      case UnifiedStatus.awaitingResponse:
        return NeuColors.goldAccent;
      case UnifiedStatus.completed:
        return NeuColors.success;
      case UnifiedStatus.overdue:
        return NeuColors.danger;
      case UnifiedStatus.stalled:
        return NeuColors.priorityHigh;
      case UnifiedStatus.cancelled:
        return NeuColors.textHint;
    }
  }

  double _statusProgress(UnifiedStatus status) {
    switch (status) {
      case UnifiedStatus.newItem:
        return 0.1;
      case UnifiedStatus.inProgress:
        return 0.5;
      case UnifiedStatus.awaitingResponse:
        return 0.6;
      case UnifiedStatus.completed:
        return 1.0;
      case UnifiedStatus.overdue:
        return 0.7;
      case UnifiedStatus.stalled:
        return 0.3;
      case UnifiedStatus.cancelled:
        return 0.0;
    }
  }

  Color _priorityColor(Priority priority) {
    switch (priority) {
      case Priority.critical:
        return NeuColors.priorityCritical;
      case Priority.high:
        return NeuColors.priorityHigh;
      case Priority.medium:
        return NeuColors.priorityMedium;
      case Priority.low:
        return NeuColors.priorityLow;
    }
  }
}