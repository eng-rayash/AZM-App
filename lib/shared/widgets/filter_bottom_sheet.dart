import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/neu_colors.dart';
import '../../core/theme/neu_decorations.dart';
import 'neu_button.dart';

/// Filter Bottom Sheet — Neumorphic filter panel.
///
/// Provides filter sections with chips for selection.
/// Supports multi-select, date range, and custom filters.
class FilterBottomSheet extends StatelessWidget {
  const FilterBottomSheet({
    super.key,
    required this.sections,
    required this.onApply,
    required this.onReset,
  });

  final List<FilterSectionData> sections;
  final VoidCallback onApply;
  final VoidCallback onReset;

  static Future<void> show(
    BuildContext context, {
    required List<FilterSectionData> sections,
    required VoidCallback onApply,
    required VoidCallback onReset,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => FilterBottomSheet(
        sections: sections,
        onApply: () {
          onApply();
          Navigator.pop(ctx);
        },
        onReset: () {
          onReset();
          Navigator.pop(ctx);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? NeuColors.dividerDark : NeuColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            AppSpacing.gapLg,

            // Title
            Row(
              children: [
                Icon(
                  Icons.filter_list_rounded,
                  color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
                ),
                AppSpacing.gapHSm,
                Text(
                  'تصفية النتائج',
                  style: isDark ? AppTypography.h3Dark : AppTypography.h3,
                ),
              ],
            ),

            AppSpacing.gapXxl,

            // Sections
            ...sections.map((section) => _buildSection(section, isDark)),

            AppSpacing.gapXxl,

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: NeuButton(
                    label: 'إعادة تعيين',
                    onPressed: onReset,
                    variant: NeuButtonVariant.secondary,
                    icon: Icons.refresh_rounded,
                  ),
                ),
                AppSpacing.gapHMd,
                Expanded(
                  child: NeuButton(
                    label: 'تطبيق الفلتر',
                    onPressed: onApply,
                    variant: NeuButtonVariant.primary,
                    icon: Icons.check_rounded,
                  ),
                ),
              ],
            ),

            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(FilterSectionData section, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.title,
            style: (isDark ? AppTypography.h4Dark : AppTypography.h4)
                .copyWith(fontSize: 14),
          ),
          AppSpacing.gapSm,
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: section.options.map((option) {
              return StatefulBuilder(
                builder: (context, setState) {
                  return GestureDetector(
                    onTap: () {
                      setState(() => option.isSelected = !option.isSelected);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: option.isSelected
                          ? NeuDecorations.neuPressed(
                              radius: 20,
                              isDark: isDark,
                            ).copyWith(
                              color: isDark
                                  ? NeuColors.navyDeep
                                  : NeuColors.navyDeep.withValues(alpha: 0.1),
                              border: Border.all(
                                color: NeuColors.navyDeep,
                                width: 1.5,
                              ),
                            )
                          : NeuDecorations.neuFlatSoft(
                              radius: 20,
                              isDark: isDark,
                            ),
                      child: Text(
                        option.label,
                        style: AppTypography.bodySmall.copyWith(
                          color: option.isSelected
                              ? (isDark
                                  ? NeuColors.textOnDark
                                  : NeuColors.navyDeep)
                              : (isDark
                                  ? NeuColors.textSecondaryDark
                                  : NeuColors.textSecondary),
                          fontWeight: option.isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// Data model for a filter section
class FilterSectionData {
  FilterSectionData({
    required this.title,
    required this.options,
  });

  final String title;
  final List<FilterOption> options;
}

/// Data model for a filter option
class FilterOption {
  FilterOption({
    required this.label,
    required this.value,
    this.isSelected = false,
  });

  final String label;
  final dynamic value;
  bool isSelected;
}