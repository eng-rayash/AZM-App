import 'package:flutter/material.dart';

import '../../core/theme/app_typography.dart';
import '../../core/theme/neu_colors.dart';

/// Sort Menu — Neumorphic sort option popup.
///
/// Shows a popup menu with sort options.
class SortMenu extends StatelessWidget {
  const SortMenu({
    super.key,
    required this.options,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<SortOption> options;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopupMenuButton<int>(
      icon: Icon(
        Icons.sort_rounded,
        color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
      ),
      color: isDark ? NeuColors.surfaceDark : NeuColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      onSelected: onSelected,
      itemBuilder: (context) => options.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;
        final isSelected = index == selectedIndex;

        return PopupMenuItem<int>(
          value: index,
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Row(
              children: [
                Icon(
                  isSelected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: isSelected
                      ? (isDark ? NeuColors.goldAccent : NeuColors.navyDeep)
                      : (isDark
                          ? NeuColors.textHintDark
                          : NeuColors.textHint),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  option.label,
                  style: (isDark
                          ? AppTypography.bodyDark
                          : AppTypography.body)
                      .copyWith(
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? (isDark
                            ? NeuColors.goldAccent
                            : NeuColors.navyDeep)
                        : null,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Sort option model
class SortOption {
  const SortOption(this.label, this.comparator);

  final String label;
  final int Function(dynamic a, dynamic b) comparator;
}