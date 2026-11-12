import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/neu_colors.dart';
import 'rvios_brand.dart';

export 'rvios_brand.dart';

/// شعار ريفيوس: علامة RV فوق العلامة اللفظية «ريفيوس RVIOS للإبداع والتقنية».
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 64,
    this.showText = true,
    this.isDark = false,
    this.useFullBanner = false,
    this.showTagline = false,
    this.animate = false,
  });

  /// عرض العلامة
  final double size;
  final bool showText;
  final bool isDark;

  /// أفقي: العلامة بجوار العلامة اللفظية
  final bool useFullBanner;
  final bool showTagline;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final markColor = isDark ? RvBrand.cream : RvBrand.red;
    final mark = animate ? AnimatedRvMark(width: size * 1.3, color: markColor) : RvMark(width: size * 1.3, color: markColor);
    final word = RviosWordmark(width: size * 2.4, onDark: isDark, animate: animate, delay: const Duration(milliseconds: 650));

    if (useFullBanner) {
      return Row(mainAxisSize: MainAxisSize.min, children: [mark, SizedBox(width: size * .3), word]);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        if (showText) ...[
          SizedBox(height: size * .28),
          word,
          if (showTagline) ...[
            SizedBox(height: size * .18),
            Text(
              AppConstants.appTagline,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTypography.fontFamilyPanorama,
                fontSize: size * .17,
                height: 1.5,
                color: isDark ? NeuColors.textHintDark : NeuColors.textSecondary,
              ),
            ),
          ],
        ],
      ],
    );
  }
}

/// علامة RV في مربع بحجم [size] — حيث تلزم أيقونة: الدخول، القفل، الشريط الجانبي.
/// أحمر على الفاتح، كريمي على الداكن. [animate] لدخول مرسوم.
class AppLogoMark extends StatelessWidget {
  const AppLogoMark({
    super.key,
    this.size = 64,
    this.isDark = false,
    this.animate = false,
    this.color,
  });

  final double size;
  final bool isDark;
  final bool animate;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? (isDark ? RvBrand.cream : RvBrand.red);
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: animate ? AnimatedRvMark(width: size, color: c, loop: false) : RvMark(width: size, color: c),
      ),
    );
  }
}

/// اسم بديل مُبقى للتوافق مع مواضع الاستدعاء القائمة.
typedef AzmMark = AppLogoMark;
