import 'package:flutter/material.dart';
import '../../core/constants/enums.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/neu_colors.dart';

class PriorityChip extends StatelessWidget {
  const PriorityChip({super.key, required this.priority});

  final Priority priority;

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (priority) {
      case Priority.critical:
        color = NeuColors.priorityCritical;
        break;
      case Priority.high:
        color = NeuColors.priorityHigh;
        break;
      case Priority.medium:
        color = NeuColors.priorityMedium;
        break;
      case Priority.low:
        color = NeuColors.priorityLow;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        priority.arabicLabel,
        style: AppTypography.caption.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}