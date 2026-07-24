import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/neu_colors.dart';
import '../../core/theme/neu_decorations.dart';

/// Filter chip data model for reusable filter bars.
class FilterOption {
  const FilterOption({
    required this.label,
    required this.value,
    this.icon,
  });

  final String label;
  final String value;
  final IconData? icon;
}

/// Search & Filter Bar — unified search input with horizontal filter chips.
///
/// Combines a Neumorphic search input with an optional row of filter chips.
/// Designed for Arabic RTL layouts with executive styling.
///
/// Usage:
/// ```dart
/// SearchFilterBar(
///   searchHint: 'بحث في الاجتماعات...',
///   onSearchChanged: (q) => setState(() => _query = q),
///   filters: [
///     FilterOption(label: 'الكل', value: 'all'),
///     FilterOption(label: 'مجدول', value: 'scheduled'),
///   ],
///   selectedFilter: _selectedFilter,
///   onFilterChanged: (v) => setState(() => _selectedFilter = v),
/// )
/// ```
class SearchFilterBar extends StatefulWidget {
  const SearchFilterBar({
    super.key,
    required this.searchHint,
    required this.onSearchChanged,
    this.filters = const [],
    this.selectedFilter = '',
    this.onFilterChanged,
    this.searchController,
    this.showSearch = true,
  });

  final String searchHint;
  final ValueChanged<String> onSearchChanged;
  final List<FilterOption> filters;
  final String selectedFilter;
  final ValueChanged<String>? onFilterChanged;
  final TextEditingController? searchController;
  final bool showSearch;

  @override
  State<SearchFilterBar> createState() => _SearchFilterBarState();
}

class _SearchFilterBarState extends State<SearchFilterBar>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _searchCtrl;
  bool _hasText = false;
  bool _isSearchExpanded = false;
  late AnimationController _animController;
  late Animation<double> _searchExpandAnim;

  @override
  void initState() {
    super.initState();
    _searchCtrl = widget.searchController ?? TextEditingController();
    _searchCtrl.addListener(_onTextChanged);
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _searchExpandAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
  }

  void _onTextChanged() {
    final has = _searchCtrl.text.isNotEmpty;
    if (has != _hasText) setState(() => _hasText = has);
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_onTextChanged);
    if (widget.searchController == null) _searchCtrl.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchExpanded = !_isSearchExpanded;
      if (_isSearchExpanded) {
        _animController.forward();
      } else {
        _animController.reverse();
        if (_hasText) {
          _searchCtrl.clear();
          widget.onSearchChanged('');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Search Row
        if (widget.showSearch)
          Padding(
            padding: AppSpacing.screenH,
            child: _isSearchExpanded
                ? _buildExpandedSearch(isDark)
                : _buildCollapsedSearch(isDark),
          ),

        // Filter Chips
        if (widget.filters.isNotEmpty) ...[
          if (widget.showSearch) AppSpacing.gapSm,
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: widget.filters.length,
              itemBuilder: (ctx, i) {
                final filter = widget.filters[i];
                final selected =
                    widget.selectedFilter == filter.value;
                return _FilterChip(
                  label: filter.label,
                  icon: filter.icon,
                  selected: selected,
                  isDark: isDark,
                  onTap: () =>
                      widget.onFilterChanged?.call(filter.value),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCollapsedSearch(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: _toggleSearch,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 11),
              decoration: NeuDecorations.neuConcave(
                radius: 16,
                isDark: isDark,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search_rounded,
                    color: isDark
                        ? NeuColors.textHintDark
                        : NeuColors.textHint,
                    size: 20,
                  ),
                  AppSpacing.gapHSm,
                  Text(
                    widget.searchHint,
                    style: AppTypography.body.copyWith(
                      color: isDark
                          ? NeuColors.textHintDark
                          : NeuColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpandedSearch(bool isDark) {
    return SizeTransition(
      sizeFactor: _searchExpandAnim,
      axisAlignment: -1,
      child: Container(
        decoration: NeuDecorations.neuConcave(
          radius: 16,
          isDark: isDark,
        ),
        child: TextField(
          controller: _searchCtrl,
          onChanged: widget.onSearchChanged,
          autofocus: true,
          textDirection: TextDirection.rtl,
          style:
              isDark ? AppTypography.bodyDark : AppTypography.body,
          decoration: InputDecoration(
            hintText: widget.searchHint,
            hintStyle: AppTypography.body.copyWith(
              color: isDark
                  ? NeuColors.textHintDark
                  : NeuColors.textHint,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: isDark
                  ? NeuColors.textHintDark
                  : NeuColors.textHint,
              size: 22,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                Icons.close_rounded,
                color: isDark
                    ? NeuColors.textSecondaryDark
                    : NeuColors.textSecondary,
                size: 20,
              ),
              onPressed: _toggleSearch,
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: AppSpacing.input,
          ),
        ),
      ),
    );
  }
}

// ─── Filter Chip ──────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    this.icon,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  final String label;
  final IconData? icon;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bgColor = selected
        ? NeuColors.navyDeep
        : (isDark ? NeuColors.surfaceDark : NeuColors.surface);
    final textColor = selected
        ? NeuColors.textOnDark
        : (isDark ? NeuColors.textSecondaryDark : NeuColors.textSecondary);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsetsDirectional.only(end: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: selected
              ? null
              : Border.all(
                  color: isDark
                      ? NeuColors.borderDark
                      : NeuColors.border,
                  width: 0.5),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: NeuColors.navyDeep.withAlpha(40),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: textColor),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: textColor,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}