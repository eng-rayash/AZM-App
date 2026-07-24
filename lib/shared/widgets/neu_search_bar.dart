import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/neu_colors.dart';
import '../../core/theme/neu_decorations.dart';

/// Neumorphic Search Bar — concave sunken search input.
///
/// Features:
/// - Concave Neumorphic styling
/// - Search icon with debounced input
/// - Clear button when text is present
/// - Dark mode aware
class NeuSearchBar extends StatefulWidget {
  const NeuSearchBar({
    super.key,
    required this.hint,
    required this.onChanged,
    this.controller,
  });

  final String hint;
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;

  @override
  State<NeuSearchBar> createState() => _NeuSearchBarState();
}

class _NeuSearchBarState extends State<NeuSearchBar> {
  late final TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(() {
      final has = _controller.text.isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
    });
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: NeuDecorations.neuConcave(
        radius: 16,
        isDark: isDark,
      ),
      child: TextField(
        controller: _controller,
        onChanged: widget.onChanged,
        textDirection: TextDirection.rtl,
        style: isDark ? AppTypography.bodyDark : AppTypography.body,
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: AppTypography.body.copyWith(
            color: isDark ? NeuColors.textHintDark : NeuColors.textHint,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: isDark ? NeuColors.textHintDark : NeuColors.textHint,
            size: 22,
          ),
          suffixIcon: _hasText
              ? IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: isDark
                        ? NeuColors.textSecondaryDark
                        : NeuColors.textSecondary,
                    size: 20,
                  ),
                  onPressed: () {
                    _controller.clear();
                    widget.onChanged('');
                  },
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: AppSpacing.input,
        ),
      ),
    );
  }
}