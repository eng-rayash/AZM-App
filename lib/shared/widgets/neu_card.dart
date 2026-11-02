import 'package:flutter/material.dart';

import '../../core/design/azm_tokens.dart';
import '../../core/theme/neu_colors.dart';

/// RVIOS Enterprise Card — Premium Glass/Flat Card Component.
///
/// Supports:
/// - Flat (default) with subtle shadow elevation
/// - Glassmorphism variant (glass: true)
/// - Accent top border (showGoldBorder)
/// - Status color right bar (RTL-aware)
/// - Gradient card (gradientColors)
/// - Press animation
class NeuCard extends StatefulWidget {
  const NeuCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.padding,
    this.margin,
    this.radius = AzmRadius.sm,
    this.showGoldBorder = false,
    this.statusColor,
    this.isDark = false,
    this.animate = true,
    this.glass = false,
    this.gradientColors,
    this.backgroundColor,
    this.elevation = 1,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final bool showGoldBorder;
  final Color? statusColor;
  final bool isDark;
  final bool animate;
  final bool glass;
  final List<Color>? gradientColors;
  final Color? backgroundColor;
  final int elevation; // 0=flat, 1=default, 2=elevated

  @override
  State<NeuCard> createState() => _NeuCardState();
}

class _NeuCardState extends State<NeuCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark =
        widget.isDark || Theme.of(context).brightness == Brightness.dark;

    final bgColor =
        widget.backgroundColor ??
        (isDark ? NeuColors.surfaceDark : NeuColors.surface);

    // الظلّ حسب الارتفاع.
    //
    // عزم لا يرفع أسطحه بالظل: «الفراغ هو أداة الارتفاع، والمسافة هي ما
    // يفصل الطبقات» (`AzmSpace`). المستويان ٠ و١ مسطّحان يفصلهما الحدّ
    // الشعري، ويبقى الظل للمستوى ٢ وحده — الحوارات والأوراق السفلية،
    // حيث السطح يطفو فعلًا فوق ما تحته.
    //
    // كان المستوى ١ (الافتراضي) يرسم ظلًّا تحت ١٧٩ بطاقة عبر التطبيق،
    // فتبدو شاشات البطاقات لغةً أخرى غير شاشات الصفوف.
    List<BoxShadow> shadows = [];
    if (!_isPressed && widget.elevation >= 2) {
      shadows = [
        BoxShadow(
          color: isDark
              ? Colors.black.withValues(alpha: 0.5)
              : Colors.black.withValues(alpha: 0.08),
          offset: const Offset(0, 8),
          blurRadius: 24,
          spreadRadius: 0,
        ),
        BoxShadow(
          color: isDark
              ? Colors.black.withValues(alpha: 0.3)
              : Colors.black.withValues(alpha: 0.04),
          offset: const Offset(0, 2),
          blurRadius: 6,
          spreadRadius: 0,
        ),
      ];
    }

    // Accent — a gold/primary top bar, or a status bar on the leading edge.
    final Color? accentColor = widget.showGoldBorder
        ? (isDark ? NeuColors.goldAccent : NeuColors.primary)
        : widget.statusColor;

    // Border
    BoxBorder? border;
    if (_isPressed) {
      border = Border.all(
        color: isDark ? NeuColors.goldAccent : NeuColors.primary,
        width: 1.5,
      );
    } else if (accentColor != null) {
      // The accent used to be a single thick Border side. Combined with the
      // card's borderRadius that is illegal — Flutter threw
      // "A borderRadius can only be given on borders with uniform colors" on
      // every paint of every accented card. The outline stays uniform and the
      // accent is drawn as an overlay bar below instead.
      border = Border.all(
        color: accentColor.withValues(alpha: isDark ? 0.34 : 0.24),
        width: 1,
      );
    } else {
      // حدّ شعري كامل بعرض بكسل واحد: هو ما يفصل السطح عن الأرض الآن
      // بعد زوال الظل، فلا يصحّ أن يكون نصف شفّاف ونصف عرض.
      border = Border.all(
        color: isDark ? NeuColors.borderDark : NeuColors.border,
        width: 1,
      );
    }

    BoxDecoration decoration;
    if (widget.glass) {
      decoration = BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.07)
            : Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(widget.radius),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.9),
          width: 1,
        ),
        boxShadow: shadows,
      );
    } else if (widget.gradientColors != null) {
      decoration = BoxDecoration(
        gradient: LinearGradient(
          colors: widget.gradientColors!,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(widget.radius),
        boxShadow: shadows,
      );
    } else {
      decoration = BoxDecoration(
        color: _isPressed
            ? (isDark
                  ? NeuColors.surfaceDark.withValues(alpha: 0.8)
                  : NeuColors.primaryTint.withValues(alpha: 0.3))
            : bgColor,
        borderRadius: BorderRadius.circular(widget.radius),
        border: border,
        boxShadow: shadows,
      );
    }

    final radius = BorderRadius.circular(widget.radius);

    Widget card = AnimatedContainer(
      duration: widget.animate
          ? const Duration(milliseconds: 150)
          : Duration.zero,
      curve: Curves.easeInOut,
      decoration: decoration,
      padding: widget.padding ?? const EdgeInsets.all(16),
      child: widget.child,
    );

    if (accentColor != null && !widget.glass) {
      card = Stack(
        children: [
          card,
          // Clipped to the card's own radius so the bar follows its corners.
          Positioned.fill(
            child: ClipRRect(
              borderRadius: radius,
              child: widget.showGoldBorder
                  // Top bar for the "featured" variant.
                  ? Align(
                      alignment: Alignment.topCenter,
                      child: Container(height: 3, color: accentColor),
                    )
                  // Leading-edge bar for the status variant. Directional, so
                  // it sits on the right in Arabic and the left in English.
                  : Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Container(width: 3.5, color: accentColor),
                    ),
            ),
          ),
        ],
      );
    }

    card = Container(
      margin: widget.margin ?? const EdgeInsets.symmetric(vertical: 6),
      child: card,
    );

    if (widget.onTap != null || widget.onLongPress != null) {
      return GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: card,
      );
    }

    return card;
  }
}
