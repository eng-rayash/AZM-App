import 'package:flutter/material.dart';

import '../../core/theme/app_typography.dart';
import '../../core/theme/neu_colors.dart';

/// Official Brand Logo & Typography Component
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 64,
    this.showText = true,
    this.isDark = false,
    this.useFullBanner = false,
    this.showTagline = false,
  });

  /// Logo Icon Size
  final double size;

  /// Whether to display brand text alongside logo icon
  final bool showText;

  /// Dark mode toggle
  final bool isDark;

  /// Whether to use full logo banner image asset
  final bool useFullBanner;

  /// Whether to show the tagline line under the wordmark
  final bool showTagline;

  @override
  Widget build(BuildContext context) {
    if (useFullBanner) {
      // الشعار الأفقي: العلامة بجوار الاسم — لا صورة مسطّحة للاسم، فيبقى
      // النص بخطوط التطبيق وألوان الوضع الحالي.
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/brand/azmsmart_mark.png', height: size, fit: BoxFit.contain),
          SizedBox(width: size * 0.25),
          _buildTextLogo(),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Brand Logo Icon
        AppLogoMark(size: size, isDark: isDark),

        if (showText) ...[
          SizedBox(height: size * 0.2),

          // English Title (Yapari Bold)
          Text(
            'عزم',
            style: TextStyle(
              fontFamily: AppTypography.fontFamilyRTLMaghfira,
              fontSize: size * 0.46,
              color: isDark ? NeuColors.textPrimaryDark : NeuColors.primary,
            ),
          ),

          Text(
            'AZM',
            style: TextStyle(
              fontFamily: AppTypography.fontFamilyYapari,
              fontSize: size * 0.3,
              fontWeight: FontWeight.w700,
              letterSpacing: 3.0,
              color: isDark ? NeuColors.gold : NeuColors.primaryDark,
            ),
          ),

          if (showTagline) ...[
            SizedBox(height: size * 0.18),
            Text(
              'افهم عملك · احسم ما يهم · نفّذ بعزم',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTypography.fontFamilyPanorama,
                fontSize: size * 0.15,
                height: 1.5,
                letterSpacing: 0.8,
                color:
                    isDark ? NeuColors.textHintDark : NeuColors.textSecondary,
              ),
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildTextLogo() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'عزم',
          style: TextStyle(
            fontFamily: AppTypography.fontFamilyRTLMaghfira,
            fontSize: size * 0.5,
            color: isDark ? NeuColors.textPrimaryDark : NeuColors.primary,
          ),
        ),
        Text(
          'AZM',
          style: TextStyle(
            fontFamily: AppTypography.fontFamilyYapari,
            fontSize: size * 0.32,
            fontWeight: FontWeight.w700,
            letterSpacing: 3.0,
            color: isDark ? NeuColors.gold : NeuColors.primaryDark,
          ),
        ),
      ],
    );
  }
}

/// علامة التطبيق المربّعة — أيقونة عزم سمارت نفسها التي تستعملها منصة الويب:
/// العلامة الكريمية فوق مربّع أحمر مستدير الزوايا (الاستدارة في الصورة نفسها).
///
/// تُستخدم حيث تلزم أيقونة مربعة: شاشة البداية، القفل، الترحيب،
/// الإعدادات، والشريط الجانبي.
class AppLogoMark extends StatelessWidget {
  const AppLogoMark({
    super.key,
    this.size = 64,
    this.isDark = false,
  });

  final double size;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        // يطابق استدارة زوايا الصورة (≈٢٢٪) كي يتبع الظلّ حوافها
        borderRadius: BorderRadius.circular(size * 0.21),
        boxShadow: [
          BoxShadow(
            color: NeuColors.primary.withValues(alpha: 0.25),
            blurRadius: size * 0.25,
            offset: Offset(0, size * 0.1),
          ),
        ],
      ),
      child: Image.asset(
        'assets/brand/azmsmart_icon.png',
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
      ),
    );
  }
}

/// اسم بديل مُبقى للتوافق مع مواضع الاستدعاء القائمة.
typedef AzmMark = AppLogoMark;
